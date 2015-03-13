//
//  CLProgressHUD.m
//  WeChatXmpp
//
//  Created by Charles Leo on 15/3/11.
//  Copyright (c) 2015年 Charles Leo. All rights reserved.
//

#import "CLProgressHUD.h"
@interface CLProgressHUD()
{
    NSTimer * myTimer;
    int angle;
    
    UILabel * centerLabel;
    UIImageView *edgeImageView;
}

@property (readonly,strong,nonatomic) UIWindow *overlayWindow;

@end

@implementation CLProgressHUD
@synthesize overlayWindow;

+(CLProgressHUD *)sharedView
{
    static dispatch_once_t once;
    static CLProgressHUD * sharedView;
    dispatch_once(&once, ^{
        sharedView = [[CLProgressHUD alloc]initWithFrame:[UIScreen mainScreen].bounds];
        sharedView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    });
    return sharedView;
}
+(void)show
{
    [[CLProgressHUD sharedView] show];
}
- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.superview) {
            [self.overlayWindow addSubview:self];
        }
        if (!centerLabel) {
            centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
            centerLabel.backgroundColor = [UIColor clearColor];
        }
        if (!self.subTitleLabel) {
            self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.subTitleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!self.titleLabel) {
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.titleLabel.backgroundColor =[UIColor clearColor];
        }
        if (!edgeImageView) {
            edgeImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Chat_record_circle"]];
        }
        self.subTitleLabel.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2 + 30);
        self.subTitleLabel.text = @"Slide up to cancel";
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        self.subTitleLabel.textColor = [UIColor whiteColor];
        
        self.titleLabel.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2 - 30);
        self.titleLabel.text = @"Time Limit";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        
        
        centerLabel.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2);
        centerLabel.text = @"60";
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.font = [UIFont systemFontOfSize:30.0f];
        centerLabel.textColor = [UIColor yellowColor];
        
        edgeImageView.frame = CGRectMake(0, 0, 154, 154);
        edgeImageView.center = centerLabel.center;
        [self addSubview:edgeImageView];
        [self addSubview:centerLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.titleLabel];
        
        
        if (myTimer) {
            [myTimer invalidate];
            myTimer = nil;
            myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
            [self setNeedsDisplay];
        }
    });
}

- (void)startAnimation
{
    angle -=3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.09];
    
    edgeImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    float second = [centerLabel.text floatValue];
    if (second <= 10.0f) {
        centerLabel.textColor = [UIColor redColor];
    }
    else
    {
        centerLabel.textColor = [UIColor yellowColor];
    }
    centerLabel.text = [NSString stringWithFormat:@"%.1f",second-0.1];
    [UIView commitAnimations];
}
- (void)setState:(NSString *)str
{
    self.subTitleLabel.text = str;
}
+ (void)changeSubTitle:(NSString *)str
{
    [[CLProgressHUD sharedView]setState:str];
}

+ (void)dismissWithError:(NSString *)str
{
    [[CLProgressHUD sharedView]dismiss:str];
}
+ (void)dismissWithSucess:(NSString *)str
{
    [[CLProgressHUD sharedView]dismiss:str];
}

- (void)dismiss:(NSString *)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [myTimer invalidate];
        myTimer = nil;
        self.subTitleLabel.text = nil;
        self.titleLabel.text = nil;
        centerLabel.text = state;
        centerLabel.textColor = [UIColor whiteColor];
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }
        else
        {
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger delay:0 options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.alpha == 0) {
                [centerLabel removeFromSuperview];
                centerLabel = nil;
                [edgeImageView removeFromSuperview];
                edgeImageView = nil;
                [self.subTitleLabel removeFromSuperview];
                self.subTitleLabel = nil;
                
                NSMutableArray * windows = [[NSMutableArray alloc]initWithArray:[UIApplication sharedApplication].windows];
                [windows removeObject:overlayWindow];
                overlayWindow = nil;
                
                [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow * window, NSUInteger idx, BOOL *stop) {
                    if ([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                        [window makeKeyWindow];
                        *stop = YES;
                    }
                }];
            }
        }];
    });
}

- (UIWindow *)overlayWindow{
    if (!overlayWindow) {
        overlayWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}

@end
