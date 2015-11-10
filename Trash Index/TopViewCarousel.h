// -*- mode: objc; -*-

#import <UIKit/UIKit.h>
#import "iCarousel.h"


@interface TopViewCarousel : UIView

-(instancetype) initWithFrame:(CGRect)frame 
            iCarouselDelegate:(id<iCarouselDelegate>)delegate
          iCarouselDataSource:(id<iCarouselDataSource>)dataSource;

-(CGSize)getViewSize;
-(void)reloadData;
-(void)updateBackgroundWithImage:(UIImage *)image animated:(BOOL)animated;
- (void)setCarouselCurrentItemIndex:(NSInteger)currentItemIndex;
-(NSUInteger)currentCarouselItemIndex;
@end
