//
//  LLActivityAlertView.m
//  模仿UIalertView-实现动态加载
//
//  Created by 李龙 on 15/9/28.
//  Copyright © 2015年 李龙. All rights reserved.
//

#import "LLActivityAlertView.h"
#define LLKeyWindowSize [UIScreen mainScreen].bounds.size
#define LLKeyWindow [UIApplication sharedApplication].keyWindow
#define menuListBtnH 44
#define menuViewX 30
#define menuViewW [UIScreen mainScreen].bounds.size.width - menuViewX*2
#define titleLabelH 50
#define lineViewH 0.5



@interface LLActivityAlertView (){
    NSInteger currentShowItemIndex;
    CGFloat itemViewFirstBtnY;
}
@property (nonatomic,strong) NSMutableArray *allShowNameArray;
@property (nonatomic,assign) int showTypeID;

@property (nonatomic,strong) UIButton *myBackgroundCoverBtn;
@property (nonatomic,strong) UIView *mySelectItemView;
@property (nonatomic,strong) UILabel *myTitleLabel;
@property (nonatomic,strong) UIView *myTopLineView;

@end

@implementation LLActivityAlertView


- (instancetype)init {
    if (self = [super init]) {
        //初始化控件
        [self initListData];
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //初始化控件
        [self initListData];
        [self initSubViews];
    }
    return self;
}

- (void)initListData{
    [self.allShowNameArray addObject:@"取消"];
}
#pragma mark ========================= 创建基础 view  =========================
- (void)initSubViews{
////        if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
//    UIView *view = [[UIApplication sharedApplication].windows lastObject];
//    view.backgroundColor = [UIColor redColor];
//    NSLog(@"------------------view:=======>%@",view);
    itemViewFirstBtnY = (LLKeyWindowSize.height - 1*menuListBtnH - titleLabelH) /2;
    
    // 2.创建蒙版
    _myBackgroundCoverBtn = ({
        
        UIButton *cover = [[UIButton alloc] init];
        cover.frame = [UIScreen mainScreen].bounds;
        cover.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.3];
        cover.backgroundColor = [UIColor orangeColor];
        //    [cover addTarget:self action:@selector(coverBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        cover;
    });
    
    
    //菜单View

    
    _mySelectItemView = ({
        
        
        UIView *menuView = [[UIView alloc] init];
        menuView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        menuView.backgroundColor = [UIColor greenColor];
        menuView.frame = CGRectMake(menuViewX, itemViewFirstBtnY, menuViewW, 25 + titleLabelH + menuListBtnH);
        
//        if (_showTypeID == 2) {
//            menuView.frame = CGRectMake(menuViewX, itemViewFirstBtnY, menuViewW, 25 + titleLabelH + menuListBtnH);
//        }else{
        //            menuView.frame = CGRectMake(menuViewX, itemViewFirstBtnY, menuViewW, titleLabelH + (count + 1)*menuListBtnH);
        
//        }
        
        menuView.layer.cornerRadius = 5;
        menuView.layer.borderWidth = 0.5;
        menuView.layer.masksToBounds = YES;
        
        _myTitleLabel = ({
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.numberOfLines = 0;
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.frame = CGRectMake(0, 0, menuViewW, titleLabelH);
            titleLabel.textAlignment = NSTextAlignmentCenter;
            //        titleLabel.text = @"请选择您需要连接的设备";
            //        if (_showTypeID == 0) {
            //            titleLabel.text = @"没有搜到到可连接设备,请重新尝试";
            //            titleLabel.frame = CGRectMake(0, 25, menuViewW, titleLabelH);
            //            count = 0;
            //        }else  if (_showTypeID == 1){
            titleLabel.text = @"正在搜索设备...请耐心等待";
            titleLabel.frame = CGRectMake(0, 25, menuViewW, titleLabelH);
            //            count = 0;
            //        }
            [menuView addSubview:titleLabel];
            titleLabel;
        
        
        });
        //菜单标题
        
        
        //创建顶部分割线
        _myTopLineView = ({
            
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = [UIColor colorWithRed:230/255.0 green:231/255.0 blue:232/255.0 alpha:1];
            lineView.frame = CGRectMake(0, CGRectGetMaxY(_myTitleLabel.frame), menuViewW, lineViewH);
            [menuView addSubview:lineView];
            lineView;
        
        });
        
        

        
        //创建取消按钮
        UIButton *menuListBtn;
//        if (_showTypeID != 2) {
//            menuListBtn = [self getListBtnWithTag:100 withIndex:20000 withTitle:@"取消"];
//        }else{
            menuListBtn = [self getListBtnWithTag:self.allShowNameArray.count withIndex:self.allShowNameArray.count withTitle:self.allShowNameArray[0]];
//        }
                    menuListBtn.frame = CGRectMake(0, titleLabelH + 25 + lineViewH, menuViewW, menuListBtnH);
        menuListBtn.backgroundColor = [UIColor yellowColor];
        [menuView addSubview:menuListBtn];
        
        
        
        menuView;
    });
    
    
    [_myBackgroundCoverBtn addSubview:_mySelectItemView];
    [LLKeyWindow addSubview:_myBackgroundCoverBtn];
    
    
    
//    [self reload];
//    
//    [self addSubview:_myBackgroundCoverBtn];
//    
//    [self setNeedsLayout];
//    
//    [self setNeedsDisplay];
//    [self layoutIfNeeded];
//    
}



-(void)layoutSubviews{
    [super layoutSubviews]; 
    NSLog(@"🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶");
}


-(void)layoutIfNeeded{
    NSLog(@"🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶🐶");
    
}



-(void)drawRect:(CGRect)rect{
    
}

- (void)loadSourceData:(NSArray *)data {
    [self reload];
}

//这个方法视情况而定
- (void)reload {
    UIView *father = self.superview;
    [father setNeedsLayout];
    [father layoutIfNeeded];
}



#pragma mark ========================= 旧代码 =========================
- (NSMutableArray *)allShowNameArray
{
    if (!_allShowNameArray) {
        _allShowNameArray = [[NSMutableArray alloc] init];
    }
    return _allShowNameArray;
}

/*
 *  - 0: 没有找到设备
 *  - 1: 开始寻找设备
 *  - 2: 找到了设备
 */
- (void)addWantShowName:(NSString *)name showTypeID:(int)typeID{
    _showTypeID = typeID;
    

    
//    if(typeID == 2){
        if (name == nil) {
            name = @"**名字输入为空的**";
        }
        [self.allShowNameArray addObject:name];
//    }
    
//        [self reload];
//    
//        [self addSubview:_myBackgroundCoverBtn];
//    
//        [self setNeedsLayout];
//    
//        [self setNeedsDisplay];
    
    //创建选项按钮
    NSInteger count = self.allShowNameArray.count;
//    for (NSInteger i = currentShowItemIndex; i < count; i++) {
//        UIButton *menuListBtn = [self getListBtnWithTag:i withIndex:i withTitle:self.allShowNameArray[i]];
//        [_mySelectItemView addSubview:menuListBtn];
//        if(i == self.allShowNameArray.count){
//            menuListBtn.frame = CGRectMake(0, titleLabelH + 25 + lineViewH, menuViewW, menuListBtnH);
//        }else{
//            menuListBtn.frame = CGRectMake(0,titleLabelH + lineViewH +(menuListBtnH + lineViewH)*i, menuViewW, menuListBtnH);
//        }
//        //创建分割线
//        UIView *lineView = [[UIView alloc] init];
//        lineView.backgroundColor = [UIColor colorWithRed:230/255.0 green:231/255.0 blue:232/255.0 alpha:1];
//        lineView.frame = CGRectMake(0, CGRectGetMaxY(menuListBtn.frame), menuViewW, lineViewH);
//        [_mySelectItemView addSubview:lineView];
//        
//        currentShowItemIndex = i;
//    }
    
    
    if (count > 1) {
        _myTitleLabel.frame = CGRectMake(0, 0, menuViewW, titleLabelH);
        _myTitleLabel.text = @"请选择您需要连接的设备";
        
        _myTopLineView.frame = CGRectMake(0, CGRectGetMaxY(_myTitleLabel.frame), menuViewW, lineViewH);
    }
    
    _mySelectItemView.frame = CGRectMake(menuViewX, itemViewFirstBtnY, menuViewW, titleLabelH + count*menuListBtnH);
//    _mySelectItemView.frame = CGRectMake(menuViewX, itemViewFirstBtnY, menuViewW, 25 + titleLabelH + menuListBtnH);
    

    
//    _mySelectItemView.frame =
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self initSubViews];
//    });
    
}


//-(CGFloat)height{
//    
//}


//- (void)coverBtnOnClick:(UIButton *)sender{
//    //bug9110
////    [self close];
//}

-(void)close
{
//    NSLog(@"mySelectItemView:%@--+++++++++++++++--myBackgroundCoverBtn:%@",self.mySelectItemView,self.myBackgroundCoverBtn);
        [self.mySelectItemView removeFromSuperview];
        [self.myBackgroundCoverBtn removeFromSuperview];
//    NSLog(@"mySelectItemView:%@->>>>>>>>>>>>>>>>>-myBackgroundCoverBtn:%@",self.mySelectItemView,self.myBackgroundCoverBtn);
}

- (void)listBtnOnclicck:(UIButton *)sender{
    NSLog(@"选中了 第 %tu 个按钮",sender.tag);
    if ([self.delegate respondsToSelector:@selector(activityAlertView:clickedButtonAtIndex:)]) {
        [self.delegate activityAlertView:self clickedButtonAtIndex:sender.tag];
    }
    
    [self close];
}


- (UIButton *)getListBtnWithTag:(NSInteger)tag withIndex:(NSInteger)index withTitle:(NSString *)titleStr{

    UIButton *btn = [[UIButton alloc] init];

//    btn.backgroundColor = [UIColor greenColor];
    btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//文字居中
    btn.tag = tag;
    [btn addTarget:self action:@selector(listBtnOnclicck:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


@end
