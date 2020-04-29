//
//  ELKViewController.m
//  ELKProgressView
//
//  Created by MoZhuXuanKe on 04/29/2020.
//  Copyright (c) 2020 MoZhuXuanKe. All rights reserved.
//

#import "ELKViewController.h"
#import "ELKProgressView-umbrella.h"
#import <ELKGCDTimer/ELKGCDTimer.h>

#define ELKScreenHeight       ([[UIScreen mainScreen] bounds].size.height)
#define ELKScreenWidth        ([[UIScreen mainScreen] bounds].size.width)

#define ELK_StatusBarHeight   ([UIApplication sharedApplication].statusBarFrame.size.height)

#define ELK_isiPhoneX         ((ELK_StatusBarHeight > 21.f) ? YES : NO)
#define ELK_NavBarHeight      (ELK_isiPhoneX ? 88.f : 64.f)
#define ELK_SafeTop           (ELK_isiPhoneX ? 44.f : 0.f)
#define ELK_TabBarHeight      (ELK_isiPhoneX ? 83.f : 49.f)
#define ELK_SafeBottom        (ELK_isiPhoneX ? 34.f : 0.f)


@interface ELKViewController ()
/// 环形进度条
@property (nonatomic, strong) ELKProgressRingView * ringView;
/// 横向进度条
@property (strong,nonatomic) ELKProgressBarView *progressBar;
@end

@implementation ELKViewController
{
    CGFloat progress;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    progress = 0;

    self.ringView = [[ELKProgressRingView alloc] initWithFrame:CGRectMake((ELKScreenWidth - 100)/2, 100, 100, 100)];
//    self.ringView.center = self.view.center;
    self.ringView.progressRingWidth = 2;
    self.ringView.backgroundRingWidth = 2;
    self.ringView.primaryColor = UIColor.cyanColor;
    self.ringView.secondaryColor = UIColor.grayColor;
    
    /// 环形进度条中间的文字和图片是互斥的 centerImage有值,则隐藏文字
    self.ringView.centerImage = [UIImage imageNamed:@"icon_down"];
    self.ringView.showPercentage = YES;
    [self.view addSubview:self.ringView];

    
    self.progressBar = [[ELKProgressBarView alloc]initWithFrame:CGRectMake(20, 300, ELKScreenWidth - 40,3)];
    self.progressBar.progressDirection=ELKProgressViewBarProgressDirectionLeftToRight;//从左到右
    self.progressBar.showPercentage = YES;
    self.progressBar.indeterminate = NO;
    self.progressBar.progressBarThickness = 3.0f;//厚度
    self.progressBar.primaryColor = UIColor.cyanColor;
    self.progressBar.secondaryColor = UIColor.grayColor;
    self.progressBar.animationDuration = 2.0f;//时间
    
    [self.view addSubview:self.progressBar];
    
    [ELKGCDTimer elk_easyTimeInterval:0.1 repeatCount:0 block:^(ELKGCDTimer * _Nonnull timer, NSInteger releaseCount) {
        if (progress<1) {
            progress += 0.008;
        }else{
            [timer killTimer];
            return;
        }
        [self.ringView setProgress:progress animated:YES];
        [self.progressBar setProgress:progress animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

