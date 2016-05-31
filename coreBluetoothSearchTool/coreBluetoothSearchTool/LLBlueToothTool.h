//
//  LLBlueToothTool.h
//  coreBluetoothSearchTool
//
//  Created by 李龙 on 16/5/31.
//  Copyright © 2016年 lauren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class LLBlueToothTool;

@protocol LLBlueToothToolDelegate <NSObject>

@optional
/**
 *  如果isUseLLActivityAlertView设置为YES,则实现此代理方法,获取选择在LLActivityAlertView上选择设备的序号
 *
 *  @param llBluetoothTool 本类
 *  @param index           选择设备所在的序号
 */
//- (void)ll_bluetooth:(LLBlueToothTool *)llBluetoothTool didSelectPeripheralInLLActivityAlertView:(NSInteger )index;

/**
 *  如果没有设置isUseLLActivityAlertView,则实现此代理方法,返回规定时间内找到的全部 Peripheral 的数组
 *
 *  @param llBluetoothTool 本类
 *  @param peripheralArray 规定时间内搜索到的全部的蓝牙设备
 */
- (void)ll_bluetooth:(LLBlueToothTool *)llBluetoothTool findPeripherals:(NSArray *)peripheralArray;

/**
 *  链接蓝牙过程中的的错误回调
 *
 *  @param llBluetoothTool 本类
 *  @param error           错误信息
 */
- (void)ll_bluetooth:(LLBlueToothTool *)llBluetoothTool connectFailure:(NSError *)error;

/**
 * 仅仅是 Peripheral 连接成功，如果内部的 Service 或者 Characteristic 连接失败，会走失败代理
 *
 *  @param llBluetoothTool 本类
 *  @param peripheral      连接上的设备
 */
- (void)ll_bluetooth:(LLBlueToothTool *)llBluetoothTool connectSuccess:(CBPeripheral *)peripheral;

/**
 *  断开连接（准备断开就会走这个方法，具体是否真正断开要看苹果底层的实现，如果有其他 app 正连接着，不会断开）
 *
 *  @param llBluetoothTool 本类
 *  @param peripheral      断开的设备
 */
//- (void)ll_bluetooth:(LLBlueToothTool *)llBluetoothTool disconnectPeripheral:(CBPeripheral *)peripheral;

@end




@interface LLBlueToothTool : NSObject

/**
 *  是否使用自带的设备选择视图
 */
@property (nonatomic,assign) BOOL isUseLLActivityAlertView;

/**
 *  代理方法
 */
@property (nonatomic,assign) id<LLBlueToothToolDelegate> delegate;

/**
 *  指定搜索设备的时间,double类型
 */
@property (nonatomic,assign) NSTimeInterval scanPeripheralTime;


//===============
+ (instancetype)shareInstence;

/**
 *  开始搜索蓝牙设备
 */
- (void)startScan;

/**
 *  自动连接保存的设备
 */
- (void)autoConnect;

/**
 *  连接指定设备
 *
 *  @param peripheral 指定设备
 */
-(void)connectedPeripheral:(CBPeripheral *)peripheral;

/**
 * 和已连接设备断开连接
 */
- (void)disConnectPeripheral;

/**
 *  判断设备是否处在 正在连接中 状态
 *
 *  @return <#return value description#>
 */
- (BOOL)isConnected;

@end
