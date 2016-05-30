//
//  LLActivityAlertView.m
//  模仿UIalertView-实现动态加载
//
//  Created by 李龙 on 15/9/28.
//  Copyright © 2015年 李龙. All rights reserved.
//

#import "LLActivityAlertView.h"
#import "UIView+Frame.h"
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
    __block BOOL doOnce;
//    BOOL modifyAgain;
}
@property (nonatomic,strong) NSMutableArray *allShowNameArray;
@property (nonatomic,assign) int showTypeID;

@property (nonatomic,strong) UIButton *myBackgroundCoverBtn;
@property (nonatomic,strong) UIView *mySelectItemBgView;
@property (nonatomic,strong) UILabel *myTitleLabel;
@property (nonatomic,strong) UIView *myTopLineView;
@property (nonatomic,strong) UIButton *myCannelBtn;

@property (nonatomic,strong) UIScrollView *mySelectItemScrollView;

@end

@implementation LLActivityAlertView


- (instancetype)init {
    if (self = [super init]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

#pragma mark ========================= 创建基础 view  =========================
- (void)initSubViews{
    // 1.创建蒙版
    _myBackgroundCoverBtn = ({
        
        UIButton *cover = [[UIButton alloc] init];
        cover.frame = [UIScreen mainScreen].bounds;
        cover.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.3];
        cover.backgroundColor = [UIColor orangeColor];
        //    [cover addTarget:self action:@selector(coverBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        cover;
    });
    
    //2.选择View
    _mySelectItemBgView = ({
        
        CGFloat menuViewY = (LLKeyWindowSize.height - 1*menuListBtnH - titleLabelH)*0.5;
        
        UIView *menuView = [[UIView alloc] init];
        menuView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        menuView.backgroundColor = [UIColor greenColor];
        menuView.frame = CGRectMake(menuViewX, menuViewY, menuViewW, 25 + titleLabelH + menuListBtnH);
        menuView.layer.cornerRadius = 5;
        menuView.layer.borderWidth = 0.5;
        menuView.layer.masksToBounds = YES;
        
        //菜单标题
        _myTitleLabel = ({
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.numberOfLines = 0;
            titleLabel.font = [UIFont systemFontOfSize:18];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"正在搜索设备...请耐心等待";
            titleLabel.frame = CGRectMake(0, 25, menuViewW, titleLabelH);
            [menuView addSubview:titleLabel];
            titleLabel;
        });
        

        //创建顶部分割线
        _myTopLineView = ({
            
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = [UIColor colorWithRed:230/255.0 green:231/255.0 blue:232/255.0 alpha:1];
            lineView.frame = CGRectMake(0, CGRectGetMaxY(_myTitleLabel.frame), menuViewW, lineViewH);
            [menuView addSubview:lineView];
            lineView;
        
        });
        
        
        _mySelectItemScrollView = ({
            
            UIScrollView *itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _myTopLineView.y, menuView.width,menuListBtnH)];
            itemScrollView.contentSize = CGSizeMake(menuView.width, 0);
            itemScrollView.backgroundColor = [UIColor redColor];
            [menuView addSubview:itemScrollView];
            itemScrollView;
        });
        
        //创建取消按钮
        _myCannelBtn = ({
            UIButton *cannnelBtn = [self getListBtnWithTag:10000 withIndex:10000 withTitle:@"取消"];
            cannnelBtn.frame = CGRectMake(0, menuView.height-menuListBtnH, menuViewW, menuListBtnH);
            cannnelBtn.backgroundColor = [UIColor yellowColor];
            [menuView addSubview:cannnelBtn];
            cannnelBtn;
            
        });
        
        menuView;
    });
    
    
    [_myBackgroundCoverBtn addSubview:_mySelectItemBgView];
    [LLKeyWindow addSubview:_myBackgroundCoverBtn];
    
}

#pragma mark ========================= 增加选择条目 =========================
- (void)addWantShowName:(NSString *)name{
    
    if (name == nil || [name isEqualToString:@""]) {
        name = @"**未命名设备**";
//        name = @"**nil Name**";
    }
    [self.allShowNameArray addObject:name];
    
    
    NSLog(@"self.allShowNameArray:%@",self.allShowNameArray);
    //创建选项按钮
    NSInteger count = self.allShowNameArray.count;
    for (NSInteger i = currentShowItemIndex; i < count; i++) {
        UIButton *menuListBtn = [self getListBtnWithTag:i withIndex:i withTitle:self.allShowNameArray[i]];
        menuListBtn.tag = i;
        [_mySelectItemScrollView addSubview:menuListBtn];
        menuListBtn.frame = CGRectMake(0,(menuListBtnH + lineViewH)*i, menuViewW, menuListBtnH);
        
        //创建分割线
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithRed:230/255.0 green:231/255.0 blue:232/255.0 alpha:1];
        lineView.frame = CGRectMake(0, CGRectGetMaxY(menuListBtn.frame), menuViewW, lineViewH);
        [_mySelectItemScrollView addSubview:lineView];
        
        currentShowItemIndex = i;
    }
    
    
    if (count > 1) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (!doOnce) {
                doOnce = YES;
                _myTitleLabel.frame = CGRectMake(0, 0, menuViewW, titleLabelH);
                _myTitleLabel.text = @"请选择您需要连接的设备";
                
                _myTopLineView.frame = CGRectMake(0, CGRectGetMaxY(_myTitleLabel.frame), menuViewW, lineViewH);
            }
            
            
            if (count*menuListBtnH <= menuListBtnH*20) {//446
                _mySelectItemBgView.y = [self getmySelectItemBgViewY];
                _mySelectItemBgView.height = titleLabelH + (count+1)*menuListBtnH;//加上取消按钮的
                _mySelectItemScrollView.y = CGRectGetMaxY(_myTopLineView.frame);
                _mySelectItemScrollView.height = count*menuListBtnH;
                _myCannelBtn.y = _mySelectItemBgView.height - menuListBtnH;
                
            }
            _mySelectItemScrollView.contentSize = CGSizeMake(_mySelectItemBgView.width, count*menuListBtnH);

        }];
    }
    
    NSLog(@"_mySelectItemBgView.height:%f",_mySelectItemBgView.height);
}


-(CGFloat)getmySelectItemBgViewY{
    return (LLKeyWindowSize.height - _mySelectItemBgView.height)*0.5;
}


//- (void)coverBtnOnClick:(UIButton *)sender{
////    [self close];
//}

-(void)close
{
    [self.mySelectItemBgView removeFromSuperview];
    [self.myBackgroundCoverBtn removeFromSuperview];
}

- (void)listBtnOnclicck:(UIButton *)sender{
    NSLog(@"选中了 第 %tu 个按钮",sender.tag);
    if ([self.delegate respondsToSelector:@selector(activityAlertView:clickedButtonAtIndex:)]) {
        [self.delegate activityAlertView:self clickedButtonAtIndex:sender.tag];
    }
    
    [self close];
}

//创建选择按钮
- (UIButton *)getListBtnWithTag:(NSInteger)tag withIndex:(NSInteger)index withTitle:(NSString *)titleStr{

    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//文字居中
    btn.tag = tag;
    [btn addTarget:self action:@selector(listBtnOnclicck:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (NSMutableArray *)allShowNameArray
{
    if (!_allShowNameArray) {
        _allShowNameArray = [[NSMutableArray alloc] init];
    }
    return _allShowNameArray;
}

@end
