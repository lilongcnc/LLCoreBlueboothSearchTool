//
//  ViewController.m
//  coreBluetooth66666
//
//  Created by 李龙 on 16/5/28.
//  Copyright © 2016年 李龙. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "LLActivityAlertView.h"




#define LLUserDefaultSetBindedPeripheralIndetify(object,key) [[NSUserDefaults standardUserDefaults] setObject:object forKey:key]
#define LLUserDefaultGetBindedPeripheralIndetify(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate,LLActivityAlertViewDelegate>{
    BOOL isAutoConnected;
}

@property (nonatomic, strong) CBCentralManager *mgr;

@property (nonatomic, strong) NSMutableArray *peripherals;

@property (nonatomic,strong) LLActivityAlertView *myActivityAlertView;

@end


@implementation ViewController
#define LLKeyWindow [UIApplication sharedApplication].keyWindow
- (void)viewDidLoad {
    [super viewDidLoad];
    

}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.peripherals = [NSMutableArray array];
    
    // 创建中心设备管理者,并且设置代理
    //    _mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];//这个初始化方法,不会提示出现"打开蓝牙允许'xxxx'连接都配件"的系统提示
    _mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//出现提示框
    
    //选择器
    LLActivityAlertView *alert = [[LLActivityAlertView alloc] init];
    alert.delegate = self;
    _myActivityAlertView = alert;

    NSLog(@"================================================================");
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%s  %@",__FUNCTION__,central);
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
            // scanForPeripheralsWithServices必须放到这个方法中执行,才可以扫描到外围设备
            [self.mgr scanForPeripheralsWithServices:nil options:nil];
            
            message = @"蓝牙已经成功开启，稍后……";
            break;
        }
        default:
            break;
    }
    
    NSLog(@"%@",message);
    
}

#pragma mark ================ LLActivityAlertViewDelegate ================
-(void)activityAlertView:(LLActivityAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    NSLog(@"选中了 第 %tu 个按钮",buttonIndex);
    [self ll_connectedPeriperal:self.peripherals[buttonIndex]];
    
}









static NSString *bindingFlag = @"myRFTest002";
static NSString *flag = @"2EE309FD-1492-A024-425A-ACDC05D8EB09";
#pragma mark ================ CBCentralManager的代理方法 ================
/**
 *  当扫描到外围设备时,会执行该方法
 *
 *  @param peripheral        发现的外围设备
 *  @param advertisementData 额外信息
 *  @param RSSI              信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%s  CBPeripheral:%@ ",__FUNCTION__,peripheral);
    
    //执行自动连接
    if (LLUserDefaultGetBindedPeripheralIndetify(bindingFlag) != nil && !isAutoConnected) {
        
        [_myActivityAlertView close];
        isAutoConnected = YES;
        
        //这里得搜索到我们要自动连接的需要的设备才可以
        
        NSLog(@"saved blueTooth :%@",LLUserDefaultGetBindedPeripheralIndetify(bindingFlag));
        
        NSUUID *connentIdentify = [[NSUUID alloc] initWithUUIDString:LLUserDefaultGetBindedPeripheralIndetify(bindingFlag)];
        NSArray *resultArray = [NSArray arrayWithArray:[self.mgr retrievePeripheralsWithIdentifiers:@[connentIdentify]]];
        
        NSLog(@"resultArray= %@",resultArray);
        
        if (resultArray.count == 0) {
            
            CBPeripheral *kownPeripheral = (CBPeripheral *)resultArray[0];
            [self ll_connectedPeriperal:kownPeripheral];
            
            
        }else{
            NSLog(@"----------------------- 重新连接设备 -----------------------");
        }
        
        
        
    }else if(LLUserDefaultGetBindedPeripheralIndetify(bindingFlag) == nil){
        
        [_myActivityAlertView addWantShowName:peripheral.name];
        
        // 将发现的外围设备添加到数组中
        if (![self.peripherals containsObject:peripheral]) {
            [self.peripherals addObject:peripheral];
        }

    }

}

//centralManager:didConnectPeripheral:
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"😃😃😃😃😃😃 connect succeed %s  %@",__FUNCTION__,peripheral.name);
    
     if (LLUserDefaultGetBindedPeripheralIndetify(bindingFlag) == nil) {
        LLUserDefaultSetBindedPeripheralIndetify([self getPeripheralIndetifyString:peripheral], bindingFlag);
     }
    [self.mgr stopScan];
}


- (NSString *)getPeripheralIndetifyString:(CBPeripheral *)peripheral{
    return [NSString stringWithFormat:@"%@",[peripheral.identifier UUIDString]];
}


//--- 连接/重新连接设备
-(void)ll_connectedPeriperal:(CBPeripheral *)peripheral{
    self.mgr.delegate = self;
    [self.mgr connectPeripheral:peripheral options:nil];
    
}



- (CBCentralManager *)mgr
{
    if (_mgr == nil) {
        // 创建中心设备管理者,并且设置代理
        _mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        //        _mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _mgr;
}



@end
