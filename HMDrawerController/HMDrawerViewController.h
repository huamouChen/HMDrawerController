//
//  HMDrawerViewController.h
//  仿QQ框架
//
//  Created by kangxingpan on 16/5/25.
//  Copyright © 2016年 pkxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMDrawerViewController : UIViewController

/**
 *  快速创建一个抽屉控制器
 *
 *  @param mainVc      中间控制器
 *  @param leftMenuVc  左边控制器
 *  @param leftWidth   左边控制器宽度
 *  @param rightMenuVc 右边控制器
 *  @param rightWidth  右边控制器宽度
 *
 *  @return 返回一个左右抽屉控制器
 */
+(instancetype)drawerWithMainVc:(UIViewController *)mainVc leftMenuVc:(UIViewController *)leftMenuVc leftWidth:(CGFloat)leftWidth rightMenuVC:(UIViewController *)rightMenuVc rightWidth:(CGFloat)rightWidth;
/**
 *  返回抽屉控制器
 */
+ (instancetype)sharedDrawer;
/**
 *  打开左边菜单
 */
- (void)openLeftMenuWithDuration:(CGFloat)duration completion:(void (^)())completion;
/**
 *  关闭左边菜单
 */
- (void)closeLeftMenuWithDuration:(CGFloat)duration;

/**
 *  打开右边菜单
 */
- (void)openRightMenuWithDuration:(CGFloat)duration completion:(void (^)())completion;
/**
 *  关闭右边菜单
 */
- (void)closeRightMenuWithDuration:(CGFloat)duration;

/**
 *  切换到指定的控制器
 */
- (void)switchViewController:(UIViewController *)vc;
@end

#pragma mark - 代理
@protocol HMDrawerViewControllerDelegate <NSObject>

@optional
- (UINavigationController *)drawerNavigationController;

@end