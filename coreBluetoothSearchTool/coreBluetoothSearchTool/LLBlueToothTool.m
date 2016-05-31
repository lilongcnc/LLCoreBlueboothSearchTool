//
//  LLBlueToothTool.m
//  coreBluetoothSearchTool
//
//  Created by 李龙 on 16/5/31.
//  Copyright © 2016年 lauren. All rights reserved.
//

#import "LLBlueToothTool.h"
#import "LLActivityAlertView.h"




#define LLUserDefaultSetBindedPeripheralIndetify(object,key) [[NSUserDefaults standardUserDefaults] setObject:object forKey:key]
#define LLUserDefaultGetBindedPeripheralIndetify(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define ST_ERROR(description) [NSError errorWithDomain:@"com.lauren" code:0 userInfo:@{NSLocalizedDescriptionKey:description}]



static NSString * const STCentralErrorConnectTimeOut = @"time out";
static NSString * const STCentralErrorConnectOthers = @"other error";
static NSString * const STCentralErrorConnectAutoConnectFail = @"auto connect fail";
//是否开启自动重连
static BOOL const isOpenAutoConnect = YES;

@interface LLBlueToothTool () <CBCentralManagerDelegate, CBPeripheralDelegate,LLActivityAlertViewDelegate>

@property (nonatomic, strong) CBCentralManager *myCentralManager;
@property (strong, nonatomic) CBPeripheral *myConnectedPeripheral; ///< 上一次连接上的 Peripheral，用来做自动连接时，保存强引用


@property (nonatomic, strong) NSMutableArray *peripheralArray;

@property (nonatomic,strong) LLActivityAlertView *myActivityAlertView;

//===============================
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property (nonatomic,assign) NSTimeInterval STCentralToolTimeOut; ///< 超时时长，如果 <= 0 则不做超时处理

@end


@implementation LLBlueToothTool

static  NSString * const bindingFlag = @"bindingBlueToothFlag";

+ (instancetype)shareInstence{
    static LLBlueToothTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [LLBlueToothTool new];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 1. 创建中心设备管理者,并且设置代理
        //    _myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];//初始化方式一:,不会提示出现"打开蓝牙允许'xxxx'连接都配件"的系统提示
        _myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//初始化方式二
        
        _STCentralToolTimeOut = 5.0;
        
        // 2. 如果设置了自动连接
        if (isOpenAutoConnect) {
            // 这里需要延迟 0.1s 才能走连接成功的代理，具体原因未知
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self autoConnect];
            });
        }
    }
    return self;
}

#pragma mark ================ 自动重连 ================
- (void)autoConnect{
    NSLog(@"================ 自动重连 ================");
    //这里得搜索到我们要自动连接的需要的设备才可以
    NSLog(@"saved blueTooth :%@",LLUserDefaultGetBindedPeripheralIndetify(bindingFlag));
    
    NSUUID *connentIdentify = [[NSUUID alloc] initWithUUIDString:LLUserDefaultGetBindedPeripheralIndetify(bindingFlag)];
    NSArray *resultArray = [NSArray arrayWithArray:[self.myCentralManager retrievePeripheralsWithIdentifiers:@[connentIdentify]]];
    
    NSLog(@"🐲🐲🐲🐲🐲resultArray = %@",resultArray);
    
    if (resultArray.count == 0) {
        //如果resultArray为空,则说明目前我们的central没找到我们要自动连接的绑定设备或者我们的绑定设备在搜索范围之外,又或者该设备压根就没有开
        //如果resultArray为空,没有成功自动重新连接,那么就执行搜索方法,重新搜索设备,让用户连接.但是也可以根据实际项目的需要来更改
        //这里的处理方式和Miss.唐一样,直接抛出错误,我们可以在控制器中重新调用搜索方法
        [self returnConnectFailureInfo:ST_ERROR(STCentralErrorConnectAutoConnectFail)];
        
    }else if(resultArray.count == 1){
        //resultArray有一个自动连接保存的设备说明我们的设备需要
        
        self.myConnectedPeripheral = (CBPeripheral *)resultArray[0];//这里需强引用,Miss.唐提到的坑
        
        switch (self.myConnectedPeripheral.state) {//根据设备的当前的状态来判断时是否
            case CBPeripheralStateDisconnected:
            {
                //在设备处在未连接状态时候,去执行 重新连接 方法
                //但是其他状态下,也可以调用链接,成功连接上,因为我没有和peripheral进行数据交换,所以不得验证是否其他状态下连链接是否成功.可以参考Miss.唐的Demo
                [self connectedPeripheral:_myConnectedPeripheral];
                
                break;
            }
            case CBPeripheralStateConnecting:
            {
                break;
            }
            case CBPeripheralStateConnected:
            {
                break;
            }
            case CBPeripheralStateDisconnecting:
            {
                break;
            }
            default:
                break;
        }
    }
    
}



#pragma mark ================ LLActivityAlertViewDelegate ================
-(void)activityAlertView:(LLActivityAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"选中了 第 %tu 个按钮",buttonIndex);
    
    [self connectedPeripheral:self.peripheralArray[buttonIndex]];
//    [self returnSelectPeripheralIndexInfo:buttonIndex];
}

#pragma mark ================ CBCentralManagerDelegate ================
/**
 *  当扫描到外围设备时,会执行该方法
 *
 *  @param peripheral        发现的外围设备
 *  @param advertisementData 额外信息
 *  @param RSSI              信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%s finde device:%@ ",__FUNCTION__,peripheral);
    
    //避免重复显示搜索到的设备
    if([self.peripheralArray containsObject:peripheral]) {
        return;
    }
    
    // 将发现的外围设备添加到数组中
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
    }
    
    if (_myActivityAlertView) {
        [_myActivityAlertView addWantShowName:peripheral.name];
    }
    
}

// 连接失败（但不包含超时，系统没有超时处理）
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self returnConnectFailureInfo:error];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"😃😃😃😃😃😃 connect succeed %s  %@",__FUNCTION__,peripheral);
   
    if (LLUserDefaultGetBindedPeripheralIndetify(bindingFlag) == nil) {
        LLUserDefaultSetBindedPeripheralIndetify([peripheral.identifier UUIDString], bindingFlag);
    }
    
    [self stopScan];
    [self stopTimer];
    [self returnConnectPeripheralSuccessedInfo:peripheral];
}




#pragma mark ================ 其他蓝牙方法 ================
//连接蓝牙设备
-(void)connectedPeripheral:(CBPeripheral *)peripheral{
    [self stopScan];
    self.myCentralManager.delegate = self;
    [self.myCentralManager connectPeripheral:peripheral options:nil];
    [self startTimer];
}

- (void)disConnectPeripheral{
    
//    for (CBCharacteristic *characteristic in self.readCharacteristics) {
//        [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
//    }
    if ([self isConnected]) {
        [self.myCentralManager cancelPeripheralConnection:self.myConnectedPeripheral];
        self.myConnectedPeripheral = nil;
    }
}

//开始搜索蓝牙设备
- (void)startScan{
    
    [self.peripheralArray removeAllObjects];
    
    if (_isUseLLActivityAlertView) {
        //开始蓝牙设备选择器列表
        _myActivityAlertView = ({
            LLActivityAlertView *alertView = [[LLActivityAlertView alloc] init];
            alertView.delegate = self;
            alertView;
        });
    }else{
        //开启定时器
        [self startScanPeripheralTimer];
    }
    
    
    //同时和CBCentralManager一起执行会不调用系统代理方法
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //搜索蓝牙设备
        [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
    });
    
}

- (void)stopScan{
    
    [self.myCentralManager stopScan];
}


- (BOOL)isConnected{
    
    if (self.myConnectedPeripheral == nil) {
        return NO;
    }
    return self.myConnectedPeripheral.state == CBPeripheralStateConnected;
}

#pragma mark ================ NSTimer超时处理 ================
//搜索显示蓝牙设备列表超时处理
- (void)startScanPeripheralTimer {
    [self stopTimer];
    NSLog(@"%f",_scanPeripheralTime);
    
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:_scanPeripheralTime target:self selector:@selector(scanPeripheralResult) userInfo:nil repeats:NO];
    
}

- (void)scanPeripheralResult {
    [self stopTimer];
    [self stopScan]; //蓝牙停止搜索
    [self returnScannedPeripheralsInfo:self.peripheralArray];
}

//连接设备超时处理
- (void)startTimer {
    [self stopTimer];

    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:_STCentralToolTimeOut target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [_myActivityAlertView close];
    _myActivityAlertView = nil;
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)timeOut {
    
    [self stopTimer];
    [self stopScan]; //蓝牙停止搜索
    [self returnConnectFailureInfo:ST_ERROR(STCentralErrorConnectTimeOut)];
}


-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *message;
    switch (central.state) {
        case 0:
            message = @"初始化中，请稍后……";
            break;
        case 1:
            message = @"设备不支持状态，过会请重试……";
            break;
        case 2:
            message = @"设备未授权状态，过会请重试……";
            break;
        case 3:
            message = @"设备未授权状态，过会请重试……";
            break;
        case 4:
            message = @"尚未打开蓝牙，请在设置中打开……";
            break;
        case 5:{
            message = @"蓝牙已经成功开启，稍后……";
            break;
        }
        default:
            break;
    }
    
    NSLog(@"%@",message);
    
}


#pragma mark ================ 本类代理方法封装 ================
//返回错误信息
- (void)returnConnectFailureInfo:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ll_bluetooth:connectFailure:)]) {
        [self.delegate ll_bluetooth:self connectFailure:error];
    }
}
//返回搜索到的蓝牙设备数组
- (void)returnScannedPeripheralsInfo:(NSArray *)Peripherals{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ll_bluetooth:findPeripherals:)]) {
        [self.delegate ll_bluetooth:self findPeripherals:Peripherals];
    }
}

//返回搜索到的蓝牙设备数组
- (void)returnSelectPeripheralIndexInfo:(NSInteger)index{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(ll_bluetooth:didSelectPeripheralInLLActivityAlertView:)]) {
//        [self.delegate ll_bluetooth:self didSelectPeripheralInLLActivityAlertView:index];
//    }
}

//设备连接成功
- (void)returnConnectPeripheralSuccessedInfo:(CBPeripheral *)peripheral{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ll_bluetooth:connectSuccess:)]) {
        [self.delegate ll_bluetooth:self connectSuccess:peripheral];
    }
}

//设备断开连接
- (void)returnDisConnectPeripheralInfo:(CBPeripheral *)peripheral{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(ll_bluetooth:disconnectPeripheral:)]) {
//        [self.delegate ll_bluetooth:self disconnectPeripheral:peripheral];
//    }
}

#pragma mark ================ get ================
-(NSTimeInterval)scanPeripheralTime{
    return _scanPeripheralTime <= 0 ? 10 : _scanPeripheralTime;
}

-(BOOL)STCentralToolAutoConnect{
    return _STCentralToolTimeOut <= 0 ? 5 : _STCentralToolTimeOut;
}

- (NSMutableArray *)peripheralArray
{
    if (!_peripheralArray) {
        _peripheralArray = [[NSMutableArray alloc] init];
    }
    return _peripheralArray;
}



@end
