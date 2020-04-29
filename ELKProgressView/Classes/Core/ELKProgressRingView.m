//
//  ELKProgressRingView.m
//  ELKAitingtu
//
//  Created by wx on 2020/4/17.
//  Copyright © 2020 wx. All rights reserved.
//

#import "ELKProgressRingView.h"

#define kELKProgressRingViewHideKey @"Hide"
#define kELKProgressRingViewShowKey @"Show"


@implementation ELKProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    _progress = progress;
}

- (void)performAction:(ELKProgressViewAction)action animated:(BOOL)animated
{
    //To be overriden in subclasses
}
@end


@interface ELKProgressRingView ()
/**The number formatter to display the progress percentage.*/
@property (nonatomic, retain) NSNumberFormatter *percentageFormatter;
/**The label that shows the percentage.*/
@property (nonatomic, retain) UILabel *percentageLabel;
/**The start progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationFromValue;
/**The end progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationToValue;
/**The start time interval for the animaiton.*/
@property (nonatomic, assign) CFTimeInterval animationStartTime;
/**Link to the display to keep animations in sync.*/
@property (nonatomic, strong) CADisplayLink *displayLink;
/**The layer that progress is shown on.*/
@property (nonatomic, retain) CAShapeLayer *progressLayer;
/**The layer that the background and indeterminate progress is shown on.*/
@property (nonatomic, retain) CAShapeLayer *backgroundLayer;
/**The layer that is used to render icons for success or failure.*/
@property (nonatomic, retain) CAShapeLayer *iconLayer;
/**The action currently being performed.*/
@property (nonatomic, assign) ELKProgressViewAction currentAction;
/**The center imageview that inside the ring.*/
@property (nonatomic, strong) UIImageView * centerImageView;

@end

@implementation ELKProgressRingView
{
    //Wether or not the corresponding values have been overriden by the user
    BOOL _backgroundRingWidthOverriden;
    BOOL _progressRingWidthOverriden;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    //Set own background color
    self.backgroundColor = [UIColor clearColor];
    
    //Set defaut sizes
    _backgroundRingWidth = fmaxf((float)self.bounds.size.width * .025f, 1.0);
    _progressRingWidth = _backgroundRingWidth;
    _progressRingWidthOverriden = NO;
    _backgroundRingWidthOverriden = NO;
    self.animationDuration = .3;
    
    //Set default colors
    self.primaryColor = [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
    self.secondaryColor = self.primaryColor;
    
    //Set up the number formatter
    _percentageFormatter = [[NSNumberFormatter alloc] init];
    _percentageFormatter.numberStyle = NSNumberFormatterPercentStyle;
    
    //Set up the background layer
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.strokeColor = self.secondaryColor.CGColor;
    _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
    _backgroundLayer.lineCap = kCALineCapRound;
    _backgroundLayer.lineWidth = _backgroundRingWidth;
    [self.layer addSublayer:_backgroundLayer];
    
    //Set up the progress layer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = self.primaryColor.CGColor;
    _progressLayer.fillColor = nil;
    _progressLayer.lineCap = kCALineCapButt;
    _progressLayer.lineWidth = _progressRingWidth;
    [self.layer addSublayer:_progressLayer];
    
    //Set up the icon layer
    _iconLayer = [CAShapeLayer layer];
    _iconLayer.fillColor = self.primaryColor.CGColor;
    _iconLayer.fillRule = kCAFillRuleNonZero;
    [self.layer addSublayer:_iconLayer];
    
    //Set the label
    _percentageLabel = [[UILabel alloc] init];
    _percentageLabel.textAlignment = NSTextAlignmentCenter;
    _percentageLabel.contentMode = UIViewContentModeCenter;
    _percentageLabel.frame = self.bounds;
    [self addSubview:_percentageLabel];
    
    //Set the centerimageView
    _centerImageView = [[UIImageView alloc] init];
    _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    _centerImageView.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.width/2);
    _centerImageView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    [self addSubview:_centerImageView];
}

#pragma mark Appearance

- (void)setPrimaryColor:(UIColor *)primaryColor
{
    [super setPrimaryColor:primaryColor];
    _progressLayer.strokeColor = self.primaryColor.CGColor;
    _iconLayer.fillColor = self.primaryColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setSecondaryColor:(UIColor *)secondaryColor
{
    [super setSecondaryColor:secondaryColor];
    _backgroundLayer.strokeColor = self.secondaryColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setBackgroundRingWidth:(CGFloat)backgroundRingWidth
{
    _backgroundRingWidth = backgroundRingWidth;
    _backgroundLayer.lineWidth = _backgroundRingWidth;
    _backgroundRingWidthOverriden = YES;
    [self setNeedsDisplay];
}

- (void)setProgressRingWidth:(CGFloat)progressRingWidth
{
    _progressRingWidth = progressRingWidth;
    _progressLayer.lineWidth = _progressRingWidth;
    _progressRingWidthOverriden = YES;
    [self setNeedsDisplay];
}

- (void)setShowPercentage:(BOOL)showPercentage
{
    _showPercentage = showPercentage;
    if (_showPercentage == YES) {
        self.centerImage = nil;
        if (_percentageLabel.superview == nil) {
            //Show the label if not already
            [self addSubview:_percentageLabel];
            [self setNeedsLayout];
        }
    } else {
        if (_percentageLabel.superview != nil) {
            //Hide the label if not already
            [_percentageLabel removeFromSuperview];
        }
    }
}

- (void)setCenterImage:(UIImage *)centerImage
{
    if (centerImage != nil) {
        self.showPercentage = NO;
        _centerImage = centerImage;
        if (_centerImageView.superview == nil) {
            //Show the imageView if not already
            [self addSubview:_centerImageView];
            
            [self setNeedsLayout];
        }
        _centerImageView.image = centerImage;
    }else {
        if (_centerImageView.superview != nil) {
            //Hide the label if not already
            [_centerImageView removeFromSuperview];
        }
    }
}

#pragma mark Actions

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (self.progress == progress) {
        return;
    }
    if (animated == NO) {
        if (_displayLink) {
            //Kill running animations
            [_displayLink invalidate];
            _displayLink = nil;
        }
        [super setProgress:progress animated:animated];
        [self setNeedsDisplay];
    } else {
        _animationStartTime = CACurrentMediaTime();
        _animationFromValue = self.progress;
        _animationToValue = progress;
        if (!_displayLink) {
            //Create and setup the display link
            [self.displayLink invalidate];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
            [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        } /*else {
            //Reuse the current display link
        }*/
    }
}

- (void)animateProgress:(CADisplayLink *)displayLink
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat dt = (displayLink.timestamp - self.animationStartTime) / self.animationDuration;
        if (dt >= 1.0) {
            //Order is important! Otherwise concurrency will cause errors, because setProgress: will detect an animation in progress and try to stop it by itself. Once over one, set to actual progress amount. Animation is over.
            [self.displayLink invalidate];
            self.displayLink = nil;
            [super setProgress:self.animationToValue animated:NO];
            [self setNeedsDisplay];
            return;
        }
        
        //Set progress
        [super setProgress:self.animationFromValue + dt * (self.animationToValue - self.animationFromValue) animated:YES];
        [self setNeedsDisplay];
        
    });
}

- (void)performAction:(ELKProgressViewAction)action animated:(BOOL)animated
{
    if (action == ELKProgressViewActionNone && _currentAction != ELKProgressViewActionNone) {
        //Animate
        [CATransaction begin];
        [_iconLayer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
        [_percentageLabel.layer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
        [CATransaction commit];
        _currentAction = action;
    } else if (action == ELKProgressViewActionSuccess && _currentAction != ELKProgressViewActionSuccess) {
        if (_currentAction == ELKProgressViewActionNone) {
            _currentAction = action;
            //Just show the icon layer
            [self drawIcon];
            //Animate
            [CATransaction begin];
            [_iconLayer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
            [_percentageLabel.layer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
            [CATransaction commit];
        } else if (_currentAction == ELKProgressViewActionFailure) {
            //Hide the icon layer before showing
            [CATransaction begin];
            [_iconLayer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
            [CATransaction setCompletionBlock:^{
                self.currentAction = action;
                [self drawIcon];
                [self.iconLayer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
            }];
            [CATransaction commit];
        }
    } else if (action == ELKProgressViewActionFailure && _currentAction != ELKProgressViewActionFailure) {
        if (_currentAction == ELKProgressViewActionNone) {
            //Just show the icon layer
            _currentAction = action;
            [self drawIcon];
            [CATransaction begin];
            [_iconLayer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
            [_percentageLabel.layer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
            [CATransaction commit];
        } else if (_currentAction == ELKProgressViewActionSuccess) {
            //Hide the icon layer before showing
            [CATransaction begin];
            [_iconLayer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
            [CATransaction setCompletionBlock:^{
                self.currentAction = action;
                [self drawIcon];
                [self.iconLayer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
            }];
            [CATransaction commit];
        }
    }
}

- (void)setIndeterminate:(BOOL)indeterminate
{
    [super setIndeterminate:indeterminate];
    if (self.indeterminate == YES) {
        //Draw the indeterminate circle
        [self drawBackground];
        
        //Create the rotation animation
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: (float)(M_PI * 2.0)];
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = HUGE_VALF;
        
        //Set the animations
        [_backgroundLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        [CATransaction begin];
        [_progressLayer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
        [_percentageLabel.layer addAnimation:[self hideAnimation] forKey:kELKProgressRingViewHideKey];
        [CATransaction commit];
    } else {
        //Animate
        [CATransaction begin];
        [_progressLayer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
        [_percentageLabel.layer addAnimation:[self showAnimation] forKey:kELKProgressRingViewShowKey];
        [CATransaction setCompletionBlock:^{
            //Remove the rotation animation and reset the background
            [self.backgroundLayer removeAnimationForKey:@"rotationAnimation"];
            [self drawBackground];
        }];
        [CATransaction commit];
    }
}

- (CABasicAnimation *)showAnimation
{
    //Show the progress layer and percentage
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    showAnimation.toValue = [NSNumber numberWithFloat:1.0];
    showAnimation.duration = self.animationDuration;
    showAnimation.repeatCount = 1.0;
    //Prevent the animation from resetting
    showAnimation.fillMode = kCAFillModeForwards;
    showAnimation.removedOnCompletion = NO;
    return showAnimation;
}

- (CABasicAnimation *)hideAnimation
{
    //Hide the progress layer and percentage
    CABasicAnimation *hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hideAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    hideAnimation.toValue = [NSNumber numberWithFloat:0.0];
    hideAnimation.duration = self.animationDuration;
    hideAnimation.repeatCount = 1.0;
    //Prevent the animation from resetting
    hideAnimation.fillMode = kCAFillModeForwards;
    hideAnimation.removedOnCompletion = NO;
    return hideAnimation;
}

#pragma mark Layout

- (void)layoutSubviews
{
    //Update frames of layers
    _backgroundLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
    _iconLayer.frame = self.bounds;
    _percentageLabel.frame = self.bounds;
    _centerImageView.frame = CGRectMake(self.bounds.size.width/2, self.bounds.size.width/2, self.bounds.size.width/2, self.bounds.size.width/2);
    _centerImageView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);;
    
    //Update font size
    _percentageLabel.font = [UIFont systemFontOfSize:(self.bounds.size.width / 5)];
    _percentageLabel.textColor = self.primaryColor;
    
    //Update line widths if not overriden
    if (!_backgroundRingWidthOverriden) {
        _backgroundRingWidth = fmaxf((float)self.frame.size.width * .025f, 1.0);
    }
     _backgroundLayer.lineWidth = _backgroundRingWidth;

    if (!_progressRingWidthOverriden) {
        _progressRingWidth = _backgroundRingWidth;
    }
    _progressLayer.lineWidth = _progressRingWidth;

    //Redraw
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    //Keep the progress view square.
    if (frame.size.width != frame.size.height) {
        frame.size.height = frame.size.width;
    }
    [super setFrame:frame];
}

- (CGSize)intrinsicContentSize
{
    //This progress view scales
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //Draw the background
    [self drawBackground];
    
    //Draw Icons
    [self drawIcon];
    
    //Draw Progress
    [self drawProgress];
}

- (void)drawSuccess
{
    //Draw relative to a base size and percentage, that way the check can be drawn for any size.*/
    CGFloat radius = (self.frame.size.width / 2.0);
    CGFloat size = radius * .3;
    
    //Create the path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, size * 2)];
    [path addLineToPoint:CGPointMake(size * 3, size * 2)];
    [path addLineToPoint:CGPointMake(size * 3, size)];
    [path addLineToPoint:CGPointMake(size, size)];
    [path addLineToPoint:CGPointMake(size, 0)];
    [path closePath];
    
    //Rotate it through -45 degrees...
    [path applyTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    
    //Center it
    [path applyTransform:CGAffineTransformMakeTranslation(radius * .46, 1.02 * radius)];
    
    //Set path
    [_iconLayer setPath:path.CGPath];
    [_iconLayer setFillColor:self.primaryColor.CGColor];
}

- (void)drawFailure
{
    //Calculate the size of the X
    CGFloat radius = self.frame.size.width / 2.0;
    CGFloat size = radius * .3;
    
    //Create the path for the X
    UIBezierPath *xPath = [UIBezierPath bezierPath];
    [xPath moveToPoint:CGPointMake(size, 0)];
    [xPath addLineToPoint:CGPointMake(2 * size, 0)];
    [xPath addLineToPoint:CGPointMake(2 * size, size)];
    [xPath addLineToPoint:CGPointMake(3 * size, size)];
    [xPath addLineToPoint:CGPointMake(3 * size, 2 * size)];
    [xPath addLineToPoint:CGPointMake(2 * size, 2 * size)];
    [xPath addLineToPoint:CGPointMake(2 * size, 3 * size)];
    [xPath addLineToPoint:CGPointMake(size, 3 * size)];
    [xPath addLineToPoint:CGPointMake(size, 2 * size)];
    [xPath addLineToPoint:CGPointMake(0, 2 * size)];
    [xPath addLineToPoint:CGPointMake(0, size)];
    [xPath addLineToPoint:CGPointMake(size, size)];
    [xPath closePath];
    
    
    //Center it
    [xPath applyTransform:CGAffineTransformMakeTranslation(radius - (1.5 * size), radius - (1.5 * size))];
    
    //Rotate path
    [xPath applyTransform:CGAffineTransformMake(cos(M_PI_4),sin(M_PI_4),-sin(M_PI_4),cos(M_PI_4),radius * (1 - cos(M_PI_4)+ sin(M_PI_4)),radius * (1 - sin(M_PI_4)- cos(M_PI_4)))];
    
    //Set path and fill color
    [_iconLayer setPath:xPath.CGPath];
    [_iconLayer setFillColor:self.primaryColor.CGColor];
}

- (void)drawBackground
{
    //Create parameters to draw background
    float startAngle = - (float)M_PI_2;
    float endAngle = (float)(startAngle + (2.0 * M_PI));
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _backgroundRingWidth) / 2.0;
    
    //If indeterminate, recalculate the end angle
    if (self.indeterminate) {
        endAngle = .8f * endAngle;
    }
    
    //Draw path
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = _progressRingWidth;
    path.lineCapStyle = kCGLineCapRound;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    //Set the path
    _backgroundLayer.path = path.CGPath;
}

- (void)drawProgress
{
    //Create parameters to draw progress
    float startAngle = - (float)M_PI_2;
    float endAngle = (float)(startAngle + (2.0 * M_PI * self.progress));
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.width / 2.0);
    CGFloat radius = (self.bounds.size.width - _progressRingWidth) / 2.0;
    
    //Draw path
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapButt;
    path.lineWidth = _progressRingWidth;
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    //Set the path
    [_progressLayer setPath:path.CGPath];
    
    //Update label
    _percentageLabel.text = [_percentageFormatter stringFromNumber:[NSNumber numberWithFloat:(float)self.progress]];
}

- (void)drawIcon
{
    if (_currentAction == ELKProgressViewActionSuccess) {
        [self drawSuccess];
    } else if (_currentAction == ELKProgressViewActionFailure) {
        [self drawFailure];
    } else if (_currentAction == ELKProgressViewActionNone) {
        //Clear layer
        _iconLayer.path = nil;
    }
}

@end



@interface ELKProgressBarView ()
/**The number formatter to display the progress percentage.*/
@property (nonatomic, retain) NSNumberFormatter *percentageFormatter;
/**The label that shows the percentage.*/
@property (nonatomic, retain) CATextLayer *percentageLabel;
/**The start progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationFromValue;
/**The end progress for the progress animation.*/
@property (nonatomic, assign) CGFloat animationToValue;
/**The start time interval for the animaiton.*/
@property (nonatomic, assign) CFTimeInterval animationStartTime;
/**Link to the display to keep animations in sync.*/
@property (nonatomic, strong) CADisplayLink *displayLink;
/**The view of the progress bar.*/
@property (nonatomic, retain) UIView *progressBar;
/**The layer that displays progress in the progress bar.*/
@property (nonatomic, retain) CAShapeLayer *progressLayer;
/**The layer that is used to animate indeterminate progress.*/
@property (nonatomic, retain) CALayer *indeterminateLayer;
/**The action currently being performed.*/
@property (nonatomic, assign) ELKProgressViewAction currentAction;
@end
@implementation ELKProgressBarView


#pragma mark Initalization and setup

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    //Set own background color
    self.backgroundColor = [UIColor clearColor];
    
    //Set defauts
    self.animationDuration = .3;
    _progressDirection = ELKProgressViewBarProgressDirectionLeftToRight;
    _progressBarThickness = 2;
    _progressBarCornerRadius = _progressBarThickness / 2.0;
    _percentagePosition = ELKProgressViewBarPercentagePositionRight;
    _showPercentage = YES;
    
    //Set default colors
    self.primaryColor = [UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0];
    self.secondaryColor = [UIColor colorWithRed:181/255.0 green:182/255.0 blue:183/255.0 alpha:1.0];
    _successColor = [UIColor colorWithRed:63.0f/255.0f green:226.0f/255.0f blue:80.0f/255.0f alpha:1];
    _failureColor = [UIColor colorWithRed:249.0f/255.0f green:37.0f/255.0f blue:0 alpha:1];
    
    //Set up the number formatter
    _percentageFormatter = [[NSNumberFormatter alloc] init];
    _percentageFormatter.numberStyle = NSNumberFormatterPercentStyle;
    
    //Progress View
    _progressBar = [[UIView alloc] init];
    _progressBar.backgroundColor = self.secondaryColor;
    _progressBar.layer.cornerRadius = _progressBarCornerRadius;
    _progressBar.clipsToBounds = YES;
    [self addSubview:_progressBar];
    
    //ProgressLayer
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = self.primaryColor.CGColor;
    _progressLayer.lineWidth = _progressBarThickness;
    _progressLayer.lineCap = kCALineCapRound;
    [_progressBar.layer addSublayer:_progressLayer];
    
    //Percentage
    _percentageLabel = [CATextLayer layer];
    _percentageLabel.foregroundColor = self.primaryColor.CGColor;
    _percentageLabel.alignmentMode = kCAAlignmentCenter;
    UILabel *temp = [[UILabel alloc] init];
    _percentageLabel.font = (__bridge CFTypeRef)temp.font;
    _percentageLabel.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:_percentageLabel];
    
    //IndeterminateLayer
    _indeterminateLayer = [CALayer layer];
    _indeterminateLayer.backgroundColor = self.primaryColor.CGColor;
    _indeterminateLayer.cornerRadius = _progressBarCornerRadius;
    _indeterminateLayer.opacity = 0;
    [_progressBar.layer addSublayer:_indeterminateLayer];
    
    //Layout
    [self layoutSubviews];
}

#pragma mark Appearance

- (void)setPrimaryColor:(UIColor *)primaryColor
{
    [super setPrimaryColor:primaryColor];
    _percentageLabel.foregroundColor = self.primaryColor.CGColor;
    _progressLayer.strokeColor = self.primaryColor.CGColor;
    _indeterminateLayer.backgroundColor = self.primaryColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setSecondaryColor:(UIColor *)secondaryColor
{
    [super setSecondaryColor:secondaryColor];
    _progressBar.backgroundColor = self.secondaryColor;
    [self setNeedsDisplay];
}

- (void)setSuccessColor:(UIColor *)successColor
{
    _successColor = successColor;
    [self setNeedsDisplay];
}

- (void)setFailureColor:(UIColor *)failureColor
{
    _failureColor = failureColor;
    [self setNeedsDisplay];
}

- (void)setShowPercentage:(BOOL)showPercentage
{
    _showPercentage = showPercentage;
    _percentageLabel.hidden = !_showPercentage;
    [self layoutSubviews];
    [self setNeedsDisplay];
}

- (void)setPercentagePosition:(ELKProgressViewBarPercentagePosition)percentagePosition
{
    _percentagePosition = percentagePosition;
    [self layoutSubviews];
    [self setNeedsDisplay];
}

- (void)setProgressDirection:(ELKProgressViewBarProgressDirection)progressDirection
{
    _progressDirection = progressDirection;
    [self layoutSubviews];
    [self setNeedsDisplay];
}

- (void)setProgressBarThickness:(CGFloat)progressBarThickness
{
    _progressBarThickness = progressBarThickness;
    //Update the layer size
    [self setNeedsDisplay];
    //Update strokeWidth
    _progressLayer.lineWidth = progressBarThickness;
    [self invalidateIntrinsicContentSize];
}

- (void)setProgressBarCornerRadius:(CGFloat)progressBarCornerRadius
{
    _progressBarCornerRadius = progressBarCornerRadius;
    
    // Update the layer size
    [self setNeedsDisplay];
    
    // Update corner radius for layers
    _progressBar.layer.cornerRadius = _progressBarCornerRadius;
    _indeterminateLayer.cornerRadius = _progressBarCornerRadius;
    [self invalidateIntrinsicContentSize];
}

#pragma mark Actions

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated == NO) {
        if (_displayLink) {
            //Kill running animations
            [_displayLink invalidate];
            _displayLink = nil;
        }
        [super setProgress:progress animated:NO];
        [self setNeedsDisplay];
    } else {
        _animationStartTime = CACurrentMediaTime();
        _animationFromValue = self.progress;
        _animationToValue = progress;
        if (!_displayLink) {
            //Create and setup the display link
            [self.displayLink invalidate];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateProgress:)];
            [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        } /*else {
           //Reuse the current display link
           }*/
    }
}

- (void)animateProgress:(CADisplayLink *)displayLink
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat dt = (displayLink.timestamp - self.animationStartTime) / self.animationDuration;
        if (dt >= 1.0) {
            //Order is important! Otherwise concurrency will cause errors, because setProgress: will detect an animation in progress and try to stop it by itself. Once over one, set to actual progress amount. Animation is over.
            [self.displayLink invalidate];
            self.displayLink = nil;
            [super setProgress:self.animationToValue animated:NO];
            [self setNeedsDisplay];
            return;
        }
        
        //Set progress
        [super setProgress:self.animationFromValue + dt * (self.animationToValue - self.animationFromValue) animated:YES];
        [self setNeedsDisplay];
        
    });
}

- (void)performAction:(ELKProgressViewAction)action animated:(BOOL)animated
{
    if (action == ELKProgressViewActionNone && _currentAction != ELKProgressViewActionNone) {
        _currentAction = action;
        _percentageLabel.string = [self.percentageFormatter stringFromNumber:[NSNumber numberWithFloat:(float)self.progress]];
        [self setNeedsDisplay];
        [CATransaction begin];
        CABasicAnimation *barAnimation = [self barColorAnimation];
        CABasicAnimation *textAnimation = [self textColorAnimation];
        CABasicAnimation *indeterminateAnimation = [self indeterminateColorAnimation];
        barAnimation.fromValue = (id)_progressLayer.strokeColor;
        barAnimation.toValue = (id)self.primaryColor.CGColor;
        textAnimation.fromValue = (id)_percentageLabel.foregroundColor;
        textAnimation.toValue = (id)self.primaryColor.CGColor;
        indeterminateAnimation.fromValue = (id)_indeterminateLayer.backgroundColor;
        indeterminateAnimation.toValue = (id)self.primaryColor.CGColor;
        [_progressLayer addAnimation:barAnimation forKey:@"strokeColor"];
        [_percentageLabel addAnimation:textAnimation forKey:@"foregroundLayer"];
        [_indeterminateLayer addAnimation:indeterminateAnimation forKey:@"backgroundColor"];
        [CATransaction commit];
    } else if (action == ELKProgressViewActionSuccess && _currentAction != ELKProgressViewActionSuccess) {
        _currentAction = action;
        _percentageLabel.string = @"✓";
        [self setNeedsDisplay];
        [CATransaction begin];
        CABasicAnimation *barAnimation = [self barColorAnimation];
        CABasicAnimation *textAnimation = [self textColorAnimation];
        CABasicAnimation *indeterminateAnimation = [self indeterminateColorAnimation];
        barAnimation.fromValue = (id)_progressLayer.strokeColor;
        barAnimation.toValue = (id)_successColor.CGColor;
        textAnimation.fromValue = (id)_percentageLabel.foregroundColor;
        textAnimation.toValue = (id)_successColor.CGColor;
        indeterminateAnimation.fromValue = (id)_indeterminateLayer.backgroundColor;
        indeterminateAnimation.toValue = (id)_successColor.CGColor;
        [_progressLayer addAnimation:barAnimation forKey:@"strokeColor"];
        [_percentageLabel addAnimation:textAnimation forKey:@"foregroundLayer"];
        [_indeterminateLayer addAnimation:indeterminateAnimation forKey:@"backgroundColor"];
        [CATransaction commit];
    } else if (action == ELKProgressViewActionFailure && _currentAction != ELKProgressViewActionFailure) {
        _currentAction = action;
        _percentageLabel.string = @"✕";
        [self setNeedsDisplay];
        [CATransaction begin];
        CABasicAnimation *barAnimation = [self barColorAnimation];
        CABasicAnimation *textAnimation = [self textColorAnimation];
        CABasicAnimation *indeterminateAnimation = [self indeterminateColorAnimation];
        barAnimation.fromValue = (id)_progressLayer.strokeColor;
        barAnimation.toValue = (id)_failureColor.CGColor;
        textAnimation.fromValue = (id)_percentageLabel.foregroundColor;
        textAnimation.toValue = (id)_failureColor.CGColor;
        indeterminateAnimation.fromValue = (id)_indeterminateLayer.backgroundColor;
        indeterminateAnimation.toValue = (id)_failureColor.CGColor;
        [_progressLayer addAnimation:barAnimation forKey:@"strokeColor"];
        [_percentageLabel addAnimation:textAnimation forKey:@"foregroundLayer"];
        [_indeterminateLayer addAnimation:indeterminateAnimation forKey:@"backgroundColor"];
        [CATransaction commit];
    }
}

- (CABasicAnimation *)barColorAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    animation.duration = 2 * self.animationDuration;
    animation.repeatCount = 1;
    //Prevent the animation from resetting
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

- (CABasicAnimation *)textColorAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
    animation.duration = 2 * self.animationDuration;
    animation.repeatCount = 1;
    //Prevent the animation from resetting
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

- (CABasicAnimation *)indeterminateColorAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.duration = 2 * self.animationDuration;
    animation.repeatCount = 1;
    //Prevent the animation from resetting
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

- (void)setIndeterminate:(BOOL)indeterminate
{
    [super setIndeterminate:indeterminate];
    if (self.indeterminate == YES) {
        //show the indeterminate view
        _indeterminateLayer.opacity = 1;
        _progressLayer.opacity = 0;
        //Create the animation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 5 * self.animationDuration;
        animation.repeatCount = HUGE_VALF;
        animation.removedOnCompletion = YES;
        //Set the animation control points
        if (_progressDirection == ELKProgressViewBarProgressDirectionLeftToRight) {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(-_indeterminateLayer.frame.size.width, 0)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(_indeterminateLayer.frame.size.width + _progressBar.bounds.size.width, 0)];
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionRightToLeft) {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(_indeterminateLayer.frame.size.width + _progressBar.bounds.size.width, 0)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(-_indeterminateLayer.frame.size.width, 0)];
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionBottomToTop) {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, _progressBar.bounds.size.height + _indeterminateLayer.frame.size.height)];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -_indeterminateLayer.frame.size.height)];
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionTopToBottom) {
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, _progressBar.bounds.size.height + _indeterminateLayer.frame.size.height)];
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, -_indeterminateLayer.frame.size.height)];
        }
        [_indeterminateLayer addAnimation:animation forKey:@"position"];
        _percentageLabel.string = @"∞";
    } else {
        //Hide the indeterminate view
        _indeterminateLayer.opacity = 0;
        _progressLayer.opacity = 1;
        //Remove all animations
        [_indeterminateLayer removeAnimationForKey:@"position"];
        //Reset progress text
        _percentageLabel.string = [_percentageFormatter stringFromNumber:[NSNumber numberWithFloat:(float)self.progress]];
    }
}

#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_showPercentage) {
        //If the percentage is shown, the layout calculation must take the label frame into account.
        CGRect labelFrame = CGRectZero;
        CGRect progressFrame = CGRectZero;
        CGFloat labelProgressBufferDistance = _progressBarThickness * 4;
        
        //Calculate progress bar and label size. The bar is long along its direction of travel. The direction perpendicular to travel is the thickness.
        if (_progressDirection == ELKProgressViewBarProgressDirectionLeftToRight || _progressDirection == ELKProgressViewBarProgressDirectionRightToLeft) {
            
            //Calculate the bar's and label's position
            if (_percentagePosition == ELKProgressViewBarPercentagePositionBottom) {
                //Calculate the sizes
                progressFrame.size = CGSizeMake(self.bounds.size.width, _progressBarThickness);
                labelFrame.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height - labelProgressBufferDistance - progressFrame.size.height);
                //Align the bar with the top of self
                progressFrame.origin = CGPointMake(0, 0);
                //Align the label with the bottom of self
                labelFrame.origin = CGPointMake(0, labelProgressBufferDistance + progressFrame.size.height);
                //Set frames of progress and label
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set label font
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
            } else if (_percentagePosition == ELKProgressViewBarPercentagePositionTop) {
                //Calculate the sizes
                progressFrame.size = CGSizeMake(self.bounds.size.width, _progressBarThickness);
                labelFrame.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height - labelProgressBufferDistance - progressFrame.size.height);
                //Align the bar with the bottom of self
                progressFrame.origin = CGPointMake(0, self.bounds.size.height - progressFrame.size.height);
                //Align the label with the top of self
                labelFrame.origin = CGPointMake(0, 0);
                //Set the frames of progress and label
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the label font
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
                
            } else if (_percentagePosition == ELKProgressViewBarPercentagePositionLeft) {
                //Calculate sizes.
                labelFrame.size = [self maximumSizeForFontSizeThatFitsInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
                progressFrame.size = CGSizeMake(self.bounds.size.width - labelFrame.size.width - labelProgressBufferDistance, _progressBarThickness);
                //Align the label to the left
                labelFrame.origin = CGPointMake(0, 0);
                progressFrame.origin = CGPointMake(labelFrame.size.width + labelProgressBufferDistance, (self.bounds.size.height / 2.0) - (_progressBarThickness / 2.0));
                //Set the frames
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the font size
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
                
            } else if (_percentagePosition == ELKProgressViewBarPercentagePositionRight) {
                //Calculate sizes.
                labelFrame.size = [self maximumSizeForFontSizeThatFitsInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
                progressFrame.size = CGSizeMake(self.bounds.size.width - labelFrame.size.width - labelProgressBufferDistance, _progressBarThickness);
                //Align the label to the right
                progressFrame.origin = CGPointMake(0, (self.bounds.size.height / 2.0) - (_progressBarThickness / 2.0));
                labelFrame.origin = CGPointMake(progressFrame.size.width + labelProgressBufferDistance, 0);
                //Set the frames
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the font size
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
            }
            
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionBottomToTop || _progressDirection == ELKProgressViewBarProgressDirectionTopToBottom) {
            
            //Calculate the bar's and label's position
            if (_percentagePosition == ELKProgressViewBarPercentagePositionLeft) {
                //Calculate sizes
                progressFrame.size = CGSizeMake(_progressBarThickness, self.bounds.size.height);
                labelFrame.size = CGSizeMake(self.bounds.size.width - labelProgressBufferDistance - progressFrame.size.width, self.bounds.size.height);
                //Align the bar with the right side of the frame.
                progressFrame.origin = CGPointMake(self.bounds.size.width - labelProgressBufferDistance - progressFrame.size.width, 0);
                labelFrame.origin = CGPointMake(0, 0);
                //Set the frames of the progress and label
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the label font
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
                
            } else if (_percentagePosition == ELKProgressViewBarPercentagePositionRight) {
                //Calculate Sizes
                progressFrame.size = CGSizeMake(_progressBarThickness, self.bounds.size.height);
                labelFrame.size = CGSizeMake(self.bounds.size.width - labelProgressBufferDistance - progressFrame.size.width, self.bounds.size.height);
                //Align the bar with the left side of the frame
                progressFrame.origin = CGPointMake(0, 0);
                labelFrame.origin = CGPointMake(labelProgressBufferDistance + progressFrame.size.width, 0);
                //Set the frames of the progress and label
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the label font
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
                
            } else if (_percentagePosition == ELKProgressViewBarPercentagePositionTop) {
                //Calculate Sizes
                labelFrame.size = [self maximumSizeForFontSizeThatFitsInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
                progressFrame.size = CGSizeMake(_progressBarThickness, self.bounds.size.height - labelFrame.size.height - labelProgressBufferDistance);
                //Align the bar with the bottom of frame
                labelFrame.origin = CGPointMake(0, 0);
                progressFrame.origin = CGPointMake((self.bounds.size.width / 2.0) - (_progressBarThickness / 2.0), labelFrame.size.height + labelProgressBufferDistance);
                //Set the frames
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the label font
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
                
            } else if (_percentagePosition == ELKProgressViewBarPercentagePositionBottom) {
                //Calculate Sizes
                labelFrame.size = [self maximumSizeForFontSizeThatFitsInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
                progressFrame.size = CGSizeMake(_progressBarThickness, self.bounds.size.height - labelFrame.size.height - labelProgressBufferDistance);
                //Align the bar with the bottom of frame
                labelFrame.origin = CGPointMake(0, self.bounds.size.height - labelFrame.size.height);
                progressFrame.origin = CGPointMake((self.bounds.size.width / 2.0) - (_progressBarThickness / 2.0), 0);
                //Set the frames
                _progressBar.frame = progressFrame;
                _percentageLabel.frame = labelFrame;
                //Set the label font
                UIFont *font = [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:labelFrame]];
                _percentageLabel.font = (__bridge CFTypeRef)font;
                _percentageLabel.fontSize = font.pointSize;
            }
        }
    } else {
        //Label not shown, The progress bar can be the full size of the progress view.
        if (_progressDirection == ELKProgressViewBarProgressDirectionBottomToTop || _progressDirection == ELKProgressViewBarProgressDirectionTopToBottom) {
            _progressBar.frame = CGRectMake((self.bounds.size.width / 2.0) - (_progressBarThickness / 2.0), 0, _progressBarThickness, self.bounds.size.height);
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionLeftToRight || _progressDirection == ELKProgressViewBarProgressDirectionRightToLeft) {
            _progressBar.frame = CGRectMake(0, (self.bounds.size.height / 2.0) - (_progressBarThickness / 2.0), self.bounds.size.width, _progressBarThickness);
        }
    }
    
    //Set the indeterminate layer frame
    if (_progressDirection == ELKProgressViewBarProgressDirectionLeftToRight || _progressDirection == ELKProgressViewBarProgressDirectionRightToLeft) {
        //Set the indeterminate layer frame (reset the animation so the animation starts and ends at the right points)
        [_indeterminateLayer removeAllAnimations];
        _indeterminateLayer.frame = CGRectMake(0, 0, _progressBar.frame.size.width * .2, _progressBarThickness * 2);
        [self setIndeterminate:self.indeterminate];
    } else {
        //Set the indeterminate layer frame (reset the animation so the animation starts and ends at the right points)
        [_indeterminateLayer removeAllAnimations];
        _indeterminateLayer.frame = CGRectMake(0, 0, _progressBarThickness * 2, _progressBar.frame.size.height * .2);
        [self setIndeterminate:self.indeterminate];
    }
    
    
    //Set the progress layer frame
    _progressLayer.frame = _progressBar.bounds;
    
}

- (CGSize)intrinsicContentSize
{
    CGFloat labelProgressBufferDistance = _progressBarThickness * 4;
    
    //Progress bar thickness is the only non-scale based size parameter.
    if (_progressDirection == ELKProgressViewBarProgressDirectionBottomToTop || _progressDirection == ELKProgressViewBarProgressDirectionTopToBottom) {
        if (_percentagePosition == ELKProgressViewBarPercentagePositionTop || _percentagePosition == ELKProgressViewBarPercentagePositionBottom) {
            return CGSizeMake(_progressBarThickness, labelProgressBufferDistance);
        } else {
            return CGSizeMake(_progressBarThickness + labelProgressBufferDistance, UIViewNoIntrinsicMetric);
        }
    } else {
        if (_percentagePosition == ELKProgressViewBarPercentagePositionTop || _percentagePosition == ELKProgressViewBarPercentagePositionBottom) {
            return CGSizeMake(UIViewNoIntrinsicMetric, _progressBarThickness + labelProgressBufferDistance);
        } else {
            return CGSizeMake(labelProgressBufferDistance, _progressBarThickness);
        }
    }
}

- (CGFloat)maximumFontSizeThatFitsInRect:(CGRect)frame
{
    //Starting parameters
    CGFloat fontSize = 0;
    CGRect textRect = CGRectZero;
    //While the width and height are within the constraint
    while (frame.size.width > textRect.size.width && frame.size.height > textRect.size.height && textRect.size.width >= textRect.size.height) {
        //Increase font size
        fontSize += 1;
        //Calculate frame size
        textRect = [@"100%" boundingRectWithSize:frame.size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName : [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:fontSize]} context:nil];
    }
    //Decrease font size as the previous one was the last size that worked
    return fontSize - 1;
}

- (CGSize)maximumSizeForFontSizeThatFitsInRect:(CGRect)frame
{
    CGRect textRect = [@"100%" boundingRectWithSize:frame.size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName : [UIFont fontWithName:((__bridge UIFont*)_percentageLabel.font).fontName size:[self maximumFontSizeThatFitsInRect:frame]]} context:nil];
    return textRect.size;
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    //Update Percentage Label
    if (_currentAction == ELKProgressViewActionSuccess) {
        _percentageLabel.string = @"✓";
    } else if (_currentAction == ELKProgressViewActionFailure) {
        _percentageLabel.string = @"✕";
    } else if (_currentAction == ELKProgressViewActionNone) {
        if (!self.indeterminate) {
            _percentageLabel.string = [_percentageFormatter stringFromNumber:[NSNumber numberWithFloat:(float)self.progress]];
        } else {
            _percentageLabel.string = @"∞";
        }
    }
    
    //Set path to draw the progress
    if (self.progress != 0) {
        if (_progressDirection == ELKProgressViewBarProgressDirectionLeftToRight) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, _progressBarThickness / 2.0)];
            [path addLineToPoint:CGPointMake(_progressLayer.frame.size.width * self.progress, _progressBarThickness / 2.0)];
            [_progressLayer setPath:path.CGPath];
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionRightToLeft) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(_progressLayer.frame.size.width, _progressBarThickness / 2.0)];
            [path addLineToPoint:CGPointMake(_progressLayer.frame.size.width * (1 - self.progress), _progressBarThickness / 2.0)];
            [_progressLayer setPath:path.CGPath];
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionBottomToTop) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(_progressBarThickness / 2.0, _progressLayer.frame.size.height)];
            [path addLineToPoint:CGPointMake(_progressBarThickness / 2.0, _progressLayer.frame.size.height * (1 - self.progress))];
            [_progressLayer setPath:path.CGPath];
        } else if (_progressDirection == ELKProgressViewBarProgressDirectionTopToBottom) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(_progressBarThickness / 2.0, 0)];
            [path addLineToPoint:CGPointMake(_progressBarThickness / 2.0, _progressLayer.frame.size.height * self.progress)];
            [_progressLayer setPath:path.CGPath];
        }
    } else {
        [_progressLayer setPath:nil];
    }
}

@end
