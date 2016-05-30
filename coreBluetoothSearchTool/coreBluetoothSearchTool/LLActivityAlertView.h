//
//  LLActivityAlertView.h
//  动态添加要显示的代理回调方法
//
//  Created by 李龙 on 15/9/28.
//  Copyright © 2015年 李龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LLActivityAlertView;

@protocol LLActivityAlertViewDelegate <NSObject>

- (void)activityAlertView:(LLActivityAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface LLActivityAlertView : UIView


/**
 * 动态添加需要显示的list项的名称
 *
 * typeID:
 *  - 0: 没有找到设备
 *  - 1: 开始寻找设备
 *  - 2: 找到了设备
 */
- (void)addWantShowName:(NSString *)name;

//- (void)show;
/**
 * 获取点击行TAG的的代理回调方式
 */
@property (nonatomic,assign) id<LLActivityAlertViewDelegate> delegate;

@end
