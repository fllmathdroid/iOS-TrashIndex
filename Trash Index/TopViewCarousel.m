#import "TopViewCarousel.h"
#import "UIImage+ImageEffects.h"
#import "NYXImagesKit.h"
//#import "UIImage+tintImageWithColor.h" // we need to create our own normal and selected image


@interface TopViewCarousel ()
{
    CGSize _mySize;
}
@property(nonatomic, strong) UIView *mainContainerView;
@property(nonatomic, strong) iCarousel *carousel;
@property(nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation TopViewCarousel
-(instancetype) initWithFrame:(CGRect)frame 
            iCarouselDelegate:(id<iCarouselDelegate>)delegate
          iCarouselDataSource:(id<iCarouselDataSource>)dataSource
{
    if ([super initWithFrame:frame]) {
        _mySize = CGSizeMake(frame.size.width, frame.size.height);
        self.mainContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
        [self addSubview:self.mainContainerView];
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
        [self.mainContainerView addSubview:self.backgroundImageView];
        self.carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
        self.carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.carousel.type = iCarouselTypeLinear;
        self.carousel.delegate = delegate;
        self.carousel.dataSource = dataSource;
        self.carousel.contentOffset = CGSizeMake(0, -10);
        [self.mainContainerView addSubview:self.carousel];
        self.clipsToBounds = YES;
    }
    return self;
}

-(CGSize )getViewSize
{
    return _mySize;
}

-(NSUInteger)currentCarouselItemIndex
{
    return [self.carousel currentItemIndex];
}
- (void)setCarouselCurrentItemIndex:(NSInteger)currentItemIndex
{
    [self.carousel setCurrentItemIndex:currentItemIndex];
}

-(void)updateBackgroundWithImage:(UIImage *)image animated:(BOOL)animated
{
    CGSize containerSize = self.backgroundImageView.frame.size;
    CGSize imageSize = image.size;
    
    CGFloat scale = containerSize.width / imageSize.width;
    
    image = [image scaleByFactor:scale * 1.1];

    if(!animated) {
        self.backgroundImageView.image = [image applyBlurWithRadius:10 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
    }
    else {
        [UIView transitionWithView:self.backgroundImageView
                          duration:0.3f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.backgroundImageView.image = [image applyBlurWithRadius:10 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
                        } completion:nil];
    }
}

-(void)reloadData
{
    [self.carousel reloadData];
}
@end

