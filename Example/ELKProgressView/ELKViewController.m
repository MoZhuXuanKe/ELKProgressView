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



@interface ELKViewController ()

@property (nonatomic, strong) ELKProgressRingView * ringView;
@end

@implementation ELKViewController
{
    CGFloat progress;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    progress = 0;

    self.ringView = [[ELKProgressRingView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.ringView.center = self.view.center;
    self.ringView.progressRingWidth = 2;
    self.ringView.backgroundRingWidth = 2;
    self.ringView.primaryColor = UIColor.cyanColor;
    self.ringView.secondaryColor = UIColor.grayColor;
    
    /// 环形进度条中间的文字和图片是互斥的 centerImage有值,则隐藏文字
    self.ringView.centerImage = [UIImage imageNamed:@"icon_down"];
    self.ringView.showPercentage = YES;
    [self.view addSubview:self.ringView];
    
    [ELKGCDTimer elk_easyTimeInterval:0.1 repeatCount:0 block:^(ELKGCDTimer * _Nonnull timer, NSInteger releaseCount) {
        if (progress<1) {
             progress += 0.008;
         }else{
             [timer killTimer];
             return;
         }
         [self.ringView setProgress:progress animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

