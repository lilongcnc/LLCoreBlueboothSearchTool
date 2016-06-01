//
//  ViewController.m
//  coreBluetooth66666
//
//  Created by 李龙 on 16/5/28.
//  Copyright © 2016年 李龙. All rights reserved.
//

#import "ViewController.h"
#import "LLBluetoothTool.h"

@interface ViewController ()<LLBluetoothToolDelegate>

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //LLactivityAlertView使用的KeyWindow必须得在viewDidLoad后才能创建.
    //在实际项目中,我们要使用蓝牙连接几乎不可能是在进入app的第一个控制器中执行,所以不必担心
    //即使项目中真的出现,作为rootWindow或者rootVC,也可以在viewDidLoad后调用
    [LLBluetoothTool shareInstence].delegate = self;
    [LLBluetoothTool shareInstence].isUseLLActivityAlertView = YES;
    [LLBluetoothTool shareInstence].scanPeripheralTime = 10;
}

- (IBAction)saartCan:(id)sender {

    //实际项目中我们已经设置了自动重连控制属性isOpenAutoConnect=YES,因为考虑到我的实际项目中使用和Miss唐的Dmeo中的需求是一样的."autoConnect"设置在类的init方法中,所以不提供控制属性来指定是否开启自动重连
    [[LLBluetoothTool shareInstence] startScan];
}

- (IBAction)autoConnect:(id)sender {
    
    //在我们修改isOpenAutoConnect=NO的情况下,进行自动重连
    [[LLBluetoothTool shareInstence] autoConnect];
}

- (IBAction)disConned:(id)sender {
     [[LLBluetoothTool shareInstence] disConnectPeripheral];
}

- (void)ll_bluetooth:(LLBluetoothTool *)llBluetoothTool findPeripherals:(NSArray *)peripheralArray{
    NSLog(@"%s  %@",__FUNCTION__,peripheralArray);
    
    [[LLBluetoothTool shareInstence] connectedPeripheral:peripheralArray[0]];
}

- (void)ll_bluetooth:(LLBluetoothTool *)llBluetoothTool connectFailure:(NSError *)error{
    
    NSLog(@"%s  %@",__FUNCTION__,error);
    
}



- (void)ll_bluetooth:(LLBluetoothTool *)llBluetoothTool connectSuccess:(CBPeripheral *)peripheral{
       NSLog(@"🐷🐷🐷🐷%s  %@",__FUNCTION__,peripheral);
   
}

- (void)ll_bluetooth:(LLBluetoothTool *)llBluetoothTool disconnectPeripheral:(CBPeripheral *)peripheral{
    
}

-(void)ll_bluetooth:(LLBluetoothTool *)llBluetoothTool didSelectPeripheralInLLActivityAlertView:(NSInteger)index withPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"🐶🐶🐶🐶🐶🐶🐶%s  %@",__FUNCTION__,peripheral);
    
}



@end
