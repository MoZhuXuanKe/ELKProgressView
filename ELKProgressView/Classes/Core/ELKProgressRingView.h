//
//  ELKProgressRingView.h
//  ELKAitingtu
//
//  Created by wx on 2020/4/17.
//  Copyright © 2020 wx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ELKProgressViewBarPercentagePositionLeft,
    ELKProgressViewBarPercentagePositionRight,
    ELKProgressViewBarPercentagePositionTop,
    ELKProgressViewBarPercentagePositionBottom,
} ELKProgressViewBarPercentagePosition;

typedef enum {
    ELKProgressViewBarProgressDirectionLeftToRight,
    ELKProgressViewBarProgressDirectionBottomToTop,
    ELKProgressViewBarProgressDirectionRightToLeft,
    ELKProgressViewBarProgressDirectionTopToBottom
} ELKProgressViewBarProgressDirection;

typedef enum {
    /**Resets the action and returns the progress view to its normal state.*/
    ELKProgressViewActionNone,
    /**The progress view shows success.*/
    ELKProgressViewActionSuccess,
    /**The progress view shows failure.*/
    ELKProgressViewActionFailure
} ELKProgressViewAction;

/**A standardized base upon which to build progress views for applications. This allows one to use any subclass progress view in any component that use this standard.*/
@interface ELKProgressView : UIView

/**@name Appearance*/
/**The primary color of the `ELKProgressView`.*/
@property (nonatomic, retain) UIColor *primaryColor;
/**The secondary color of the `ELKProgressView`.*/
@property (nonatomic, retain) UIColor *secondaryColor;
/**Wether or not the progress view is indeterminate.*/
@property (nonatomic, assign) BOOL indeterminate;
/**The durations of animations in seconds.*/
@property (nonatomic, assign) CGFloat animationDuration;
/**The progress displayed to the user.*/
@property (nonatomic, readonly) CGFloat progress;

/**@name Actions*/
/**Set the progress of the `ELKProgressView`.
 @param progress The progress to show on the progress view.
 @param animated Wether or not to animate the progress change.*/
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
/**Perform the given action if defined. Usually showing success or failure.
 @param action The action to perform.
 @param animated Wether or not to animate the change*/
- (void)performAction:(ELKProgressViewAction)action animated:(BOOL)animated;

@end

/// 环形进度条
@interface ELKProgressRingView : ELKProgressView

/**@name Appearance*/
/**The width of the background ring in points.*/
@property (nonatomic, assign) CGFloat backgroundRingWidth;//!< 背景进度条线宽
/**The width of the progress ring in points.*/
@property (nonatomic, assign) CGFloat progressRingWidth;//!< 进度条线宽
/**Wether or not to display a percentage inside the ring.*/
@property (nonatomic, assign) BOOL showPercentage;//!< 是否显示中间的文字label
/**Wether or not to display a image inside the ring.*/
@property (nonatomic, strong, nullable) UIImage * centerImage;//!< 如果传入一张图片,就显示

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end


/// 直线进度条
/**A replacement for UIProgressBar.*/
@interface ELKProgressBarView : ELKProgressView

/**@name Appearance*/
/**The direction of progress. (What direction the fill proceeds in.)*/
@property (nonatomic, assign) ELKProgressViewBarProgressDirection progressDirection;
/**The thickness of the progress bar.*/
@property (nonatomic, assign) CGFloat progressBarThickness;
/**The corner radius of the progress bar.*/
@property (nonatomic, assign) CGFloat progressBarCornerRadius;
/**@name Actions*/
/**The color the bar changes to for the success action.*/
@property (nonatomic, retain) UIColor *successColor;
/**The color the bar changes to for the failure action.*/
@property (nonatomic, retain) UIColor *failureColor;
/**@name Percentage*/
/**Wether or not to show percentage text. If shown exterior to the progress bar, the progress bar is shifted to make room for the text.*/
@property (nonatomic, assign) BOOL showPercentage;
/**The location of the percentage in comparison to the progress bar.*/
@property (nonatomic, assign) ELKProgressViewBarPercentagePosition percentagePosition;

@end


NS_ASSUME_NONNULL_END
