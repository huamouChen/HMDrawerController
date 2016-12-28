//
//  HMDrawerViewController.m
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import "HMDrawerViewController.h"

@interface HMDrawerViewController()<UIGestureRecognizerDelegate>
// 主控制器
@property (nonatomic, strong) UIViewController *mainVc;
// 左边菜单控制器
@property (nonatomic, strong) UIViewController *leftMenuVc;
// 右边控制器
@property (strong, nonatomic) UIViewController *rightMenuVc;
// 左边菜单显示的最大宽度
@property (nonatomic, assign) CGFloat leftWidth;
// 右边控制器的最大宽度
@property (assign, nonatomic) CGFloat rightWidth;
// 遮盖按钮
@property (nonatomic, strong) UIButton *coverBtn;
// 打开的是左边还是右边
@property (assign, nonatomic) BOOL isLeft, isRight;
@end

@implementation HMDrawerViewController

#pragma mark - 手势冲突
/**
 *  主要是为了解决学馆页面的手势冲突，学馆页面主体是由scrollView构成，要解决scrollview的手势冲突
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    return NO;
}

/**
 *  返回抽屉控制器
 *
 */
+(instancetype)sharedDrawer {
    return (HMDrawerViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

#pragma mark - 创建抽屉控制器
/**
 *  快速创建一个抽屉控制器
 *
 *  @param mainVc      主控制器
 *  @param leftMenuVc  左边控制器
 *  @param leftWidth   左边控制器最大宽度
 *  @param rightMenuVc 右边控制器
 *  @param rightWidth  右边控制器的最大宽度
 *
 *  @return 抽屉控制器
 */
+(instancetype)drawerWithMainVc:(UIViewController *)mainVc leftMenuVc:(UIViewController *)leftMenuVc leftWidth:(CGFloat)leftWidth rightMenuVC:(UIViewController *)rightMenuVc rightWidth:(CGFloat)rightWidth {
    // 创建抽屉控制器
    HMDrawerViewController *drawerVc = [[HMDrawerViewController alloc] init];
    // 记录属性
    // 主控制器
    drawerVc.mainVc = mainVc;
    // 左边控制器
    drawerVc.leftMenuVc = leftMenuVc;
    drawerVc.leftWidth = leftWidth;
    // 右边控制器
    drawerVc.rightMenuVc = rightMenuVc;
    drawerVc.rightWidth = rightWidth;
    
    // 将leftMenuVc控制器的view添加到当前控制器view上
    [drawerVc.view addSubview:leftMenuVc.view];
    // 将rightMenuVc控制器的view添加到当前控制器view上
    [drawerVc.view addSubview:rightMenuVc.view];
    // 将mainVc控制器的view添加到当前控制器view上
    [drawerVc.view addSubview:mainVc.view];
    
    // 让外界传入的三个控制器成为当前控制器的子控制器
    [drawerVc addChildViewController:leftMenuVc];
    [drawerVc addChildViewController:rightMenuVc];
    [drawerVc addChildViewController:mainVc];
    // 返回创建好的抽屉控制器
    return drawerVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置左边菜单控制器默认向左边偏移leftWidth
    self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth, 0);
    // 设置右边菜单控制器默认向右偏移屏幕宽度
    self.rightMenuVc.view.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
    // 为主控制器添加屏幕边缘拖拽手势
    if([self.mainVc isKindOfClass:[UITabBarController class]]) {
        NSArray *childViewControllers = self.mainVc.childViewControllers;
        for (UIViewController *childVc in childViewControllers) {
            UINavigationController *nav = (UINavigationController *)childVc;
            [self addScreenEdgePanGestureRecognizerToView:nav.topViewController.view];
        }
    } else {
        [self addScreenEdgePanGestureRecognizerToView:self.mainVc.view];
    }
}

#pragma mark - 手势相关方法
/**
 *  给指定的view的添加边缘拖拽手势
 */
- (void)addScreenEdgePanGestureRecognizerToView:(UIView *)view{
    // 创建屏幕边缘拖拽手势对象 左边
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGestureRecognizer:)];
    // 设置手势触发边缘为左边缘
    pan.edges = UIRectEdgeLeft;
    pan.delegate = self;
    [view addGestureRecognizer:pan];
    
    // 右边
    UIScreenEdgePanGestureRecognizer *rightPan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgePanGestureRecognizer:)];
    // 设置手势触发边缘为右边缘
    rightPan.edges = UIRectEdgeRight;
    [view addGestureRecognizer:rightPan];
}

/**
 *  手势识别回调方法
 */
- (void)edgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)pan {
    // 获得x方向拖动的距离
    CGFloat offsetX = [pan translationInView:pan.view].x;
    
    // 左边手势
    if (pan.edges == UIRectEdgeLeft) {
        // 限制offsetX的最大值为leftWidth
        offsetX = MIN(self.leftWidth, offsetX);
        // 小于 0 ，就停止， 不然右边会漏出来
        if (offsetX < 0) return;
        
        // 判断手势的状态
        if(pan.state == UIGestureRecognizerStateChanged) {
            // 手势一直处于改变状态
            self.mainVc.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
            self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth + offsetX, 0);
        } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            // 手势结束或手势被取消了
            // 获得mainVc的x值
            CGFloat mainX = self.mainVc.view.frame.origin.x;
            if (mainX >= self.leftWidth * 0.5) { // 超过屏幕的一半
                [self openLeftMenuWithDuration:0.15 completion:nil];
            } else { // 没有超过屏幕的一半
                [self closeLeftMenuWithDuration:0.15];
            }
        }
    }
    // 右边手势
    else {
        // 限制offSetX的最大值为rightWidth
        offsetX = MAX(-self.rightWidth, offsetX);
        // 大于 0 ，就结束，不然左边漏出来
        if (offsetX > 0) return;
        // 判断手势的状态
        if (pan.state == UIGestureRecognizerStateChanged) {
            // 手势一直处于变化状态
            self.mainVc.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
            self.rightMenuVc.view.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width + offsetX, 0);
        } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            // 手势结束或者取消了
            // 获得mainVc的x值
            CGFloat mainX = self.mainVc.view.frame.origin.x;
            if (-mainX >= self.rightWidth * 0.5) { // 超过右边宽度一半
                [self openRightMenuWithDuration:0.15 completion:nil];
            } else { // 没有超过一半
                [self closeRightMenuWithDuration:0.15];
            }
        }
    }
}

#pragma mark - 遮盖按钮拖拽手势回调方法
/**
 *  遮盖按钮拖拽手势回调方法
 */
-(void)panCoverBtn:(UIPanGestureRecognizer *)pan {
    // 获得x方向的拖拽的距离
    CGFloat offsetX = [pan translationInView:pan.view].x;
    
    // 关闭右边控制器
    if(offsetX > 0 && self.isRight) {
        NSInteger distance = self.rightWidth - offsetX;
        if (pan.state == UIGestureRecognizerStateChanged) {
            self.mainVc.view.transform = CGAffineTransformMakeTranslation(-MAX(distance, 0), 0);
            self.rightMenuVc.view.transform = CGAffineTransformMakeTranslation(-(-[UIScreen mainScreen].bounds.size.width + distance), 0);
        } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            CGFloat mainX = self.mainVc.view.frame.origin.x;
            if (mainX <= -self.rightWidth * 0.5) { // 超过屏幕的一半
                [self openRightMenuWithDuration:0.15 completion:nil];
            } else { // 没有超过屏幕的一半
                [self closeRightMenuWithDuration:0.15];
            }
        }
    }
    
    // 关闭左边控制器
    if (offsetX < 0 && self.isLeft) {
        // 关闭左边控制器
        NSInteger distance =  self.leftWidth - ABS(offsetX);
        if (pan.state == UIGestureRecognizerStateChanged) {
            self.mainVc.view.transform = CGAffineTransformMakeTranslation(MAX(distance, 0), 0);
            self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth + distance, 0);
        } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            CGFloat mainX = self.mainVc.view.frame.origin.x;
            if (mainX >= self.leftWidth * 0.5) { // 超过屏幕的一半
                [self openLeftMenuWithDuration:0.15 completion:nil];
            } else { // 没有超过屏幕的一半
                [self closeLeftMenuWithDuration:0.15];
            }
        }
    }
}

#pragma mark - 切换到指定的控制器
- (void)switchViewController:(UIViewController *)vc {
    // 关闭抽屉
    if (self.isLeft) {
        [self closeLeftMenuWithDuration:0.25];
    } else {
        [self closeRightMenuWithDuration:0.25];
    }
    
    // 切换控制器
    if ([self.mainVc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)self.mainVc;
        [nav pushViewController:vc animated:NO];
    } else {
        id<HMDrawerViewControllerDelegate>delegate = (id<HMDrawerViewControllerDelegate>)self.mainVc;
        if ([delegate respondsToSelector:@selector(drawerNavigationController)]) {
            UINavigationController *nav = [delegate drawerNavigationController];
            [nav pushViewController:vc animated:NO];
        }
    }
}

#pragma mark - 打开和关闭左边抽屉方法
/**
 *  打开左边菜单
 */
- (void)openLeftMenuWithDuration:(CGFloat)duration completion:(void (^)())completion {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.mainVc.view.transform = CGAffineTransformMakeTranslation(self.leftWidth, 0);
        self.leftMenuVc.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.isLeft = YES;
        if (!self.coverBtn.superview) {
            // 添加遮盖按钮
            [self.mainVc.view addSubview:self.coverBtn];
        }
        if (completion) {
            completion();
        }
    }];
}

/**
 *  关闭左边菜单
 */
- (void)closeLeftMenuWithDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.mainVc.view.transform = CGAffineTransformIdentity;
        self.leftMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.leftWidth, 0);
    } completion:^(BOOL finished) {
        self.isLeft = NO;
        // 移除遮盖按钮
        [self.coverBtn removeFromSuperview];
        self.coverBtn = nil;
    }];
}

#pragma mark - 打开和关闭右边抽屉
/**
 *  打开右边菜单
 */
- (void)openRightMenuWithDuration:(CGFloat)duration completion:(void (^)())completion {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        // 打开右边控制器，向左边偏移，为负数
        self.mainVc.view.transform = CGAffineTransformMakeTranslation(-self.rightWidth, 0);
        self.rightMenuVc.view.transform = CGAffineTransformMakeTranslation(-self.rightWidth + [UIScreen mainScreen].bounds.size.width, 0);
    } completion:^(BOOL finished) {
        self.isRight = YES;
        if (!self.coverBtn.superview) {
            // 添加遮盖按钮
            [self.mainVc.view addSubview:self.coverBtn];
        }
        if (completion) {
            completion();
        }
    }];
}

/**
 *  关闭右边菜单
 */
- (void)closeRightMenuWithDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        // 恢复默认
        self.mainVc.view.transform = CGAffineTransformIdentity;
        self.rightMenuVc.view.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
        
        // 发布关闭右边抽屉的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseRightMenu object:nil];
        
    } completion:^(BOOL finished) {
        self.isRight = NO;
        // 移除遮盖按钮
        [self.coverBtn removeFromSuperview];
        self.coverBtn = nil;
    }];
}

#pragma mark - 懒加载遮盖按钮
- (UIButton *)coverBtn {
    if (_coverBtn == nil) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverBtn.frame = self.mainVc.view.bounds;
        _coverBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.564];
        [_coverBtn addTarget:self action:@selector(coverBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 添加拖拽手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCoverBtn:)];
        [_coverBtn addGestureRecognizer:pan];
    }
    return _coverBtn;
}

#pragma mark - 点击遮盖按钮
- (void)coverBtnClick:(UIButton *)coverBtn {
    // 关闭抽屉
    if (self.isLeft) {
        [self closeLeftMenuWithDuration:0.25];
    } else {
        [self closeRightMenuWithDuration:0.25];
    }
}
@end
