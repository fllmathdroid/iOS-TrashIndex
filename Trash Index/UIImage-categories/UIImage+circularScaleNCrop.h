#import <UIKit/UIKit.h>
@interface UIImage (circularScaleNCrop)
+(UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect) rect;
+(UIImage*)circularScaleNCrop:(UIImage*)image rect:(CGRect) rect keepAspectRatio:(BOOL)keepAspectRatio;
+(UIImage*)scaleNCrop:(UIImage*)image rect:(CGRect) rect keepAspectRatio:(BOOL)keepAspectRatio;
@end
