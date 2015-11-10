#import <UIKit/UIKit.h>

@interface UIImage (tintImageWithColor)
- (UIImage *) tintImageWithColor: (UIColor *) color;
- (UIImage *) maskToImage: (UIImage *) image;
@end
