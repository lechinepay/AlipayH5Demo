//
//  RequestHUD.h
//  lechinepay
//
//  Created by 马洪亮 on 16/6/2.
//  Copyright © 2016年 马洪亮. All rights reserved.
//

#import <UIKit/UIKit.h>


enum {
    RequestHUDMaskTypeNone = 1,
    RequestHUDMaskTypeClear,
    RequestHUDMaskTypeBlack,
    RequestHUDMaskTypeGradient
};
typedef NSUInteger RequestHUDMaskType;
@interface RequestHUD : UIView

+ (void)show;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(RequestHUDMaskType)maskType;
+ (void)showWithMaskType:(RequestHUDMaskType)maskType;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)setStatus:(NSString*)string;

+ (void)dismiss;
+ (void)dismissWithSuccess:(NSString*)successString;
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString; 
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString *)successString title:(NSString *)titleString andImage:(UIImage *)image afterDelay:(NSTimeInterval)duration;

+ (BOOL)isVisible;

@end
