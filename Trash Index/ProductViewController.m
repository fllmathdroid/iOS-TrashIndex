#import "ProductViewController.h"
#import "TopViewCarousel.h"
#import "UIImage+Resize.h"
#import "Trash_Index-Swift.h"

@interface ProductViewController () <iCarouselDelegate,iCarouselDataSource>
{
    CGFloat statusAndNavigationBarHeight;
}
@property (nonatomic, strong) NSString *productTrashIndex;
@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSMutableArray *productImageList;
@property (nonatomic, strong) NSMutableArray *productAttributes;
@property (nonatomic) CGRect wholeScreeViewFrame;
@property (nonatomic, strong) TopViewCarousel *topView;
@property (nonatomic, strong) UITableView *tableView;

@end

static float  kTopViewHeight=250.0;
#define kTopViewImageSize 220

@implementation ProductViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog (@"barcode %@", self.barCode);

    self.title = self.barCode;

    // try to find the trash index
    self.productTrashIndex = @"Trash Index: Unknown"; // default value
    // local data base look up
    Product *product = [Product find:self.barCode];
    if (product) {
        self.productTrashIndex = [NSString stringWithFormat:@"Trash Index: %lu", (unsigned long)[product trashIndex]];
    }
    self.product = product;
    
    UIImage *image = [UIImage imageNamed:@"ShoppingCart"];
    if (image.size.height > kTopViewImageSize)
        image= [image thumbnailImage:kTopViewImageSize transparentBorder:1 cornerRadius:2
                         interpolationQuality:kCGInterpolationHigh];
    self.productImageList = [@[image] mutableCopy];
    self.productAttributes = [NSMutableArray arrayWithCapacity:10];
    
    CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
    statusAndNavigationBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height+
        navigationBarFrame.size.height;
    self.wholeScreeViewFrame = self.view.bounds;
    self.topView = [[TopViewCarousel  alloc]
                       initWithFrame:CGRectMake(self.wholeScreeViewFrame.origin.x,
                                                statusAndNavigationBarHeight,
                                                self.wholeScreeViewFrame.size.width,
                                                kTopViewHeight)
                       iCarouselDelegate:self
                       iCarouselDataSource:self];
    //self.topView.backgroundColor = [UIColor colorWithRed:0.0f green:0.22f blue:122.0/255.0 alpha:1.0f];
    self.topView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.topView];
    //[self.topView updateBackgroundWithImage:self.productImageList[0] animated:YES];
    
    CGRect topviewFrame = self.topView.frame;
    CGRect bottomviewFrame = CGRectMake(self.wholeScreeViewFrame.origin.x,
                                        statusAndNavigationBarHeight+topviewFrame.size.height,
                                        self.wholeScreeViewFrame.size.width,
                                        self.wholeScreeViewFrame.size.height-statusAndNavigationBarHeight-
                                        topviewFrame.size.height);
	self.tableView = [[UITableView alloc] initWithFrame:bottomviewFrame style:UITableViewStyleGrouped];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    __weak typeof(self) weakSelf = self;
    
    //curl -u 74c15defc7d63f2467469faa9adbee4d:dl-outpan https://api.outpan.com/v1/products/044000037420
    NSString *urlString = [NSString stringWithFormat:@"https://api.outpan.com/v1/products/%@", self.barCode];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *authStr = @"74c15defc7d63f2467469faa9adbee4d:dl-outpan";
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [urlRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Response: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = (NSDictionary *)responseObject;
                [weakSelf getProductResponseWithData:data];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"getProduct error: %@", error);
        }];
    [requestOperation start];
}

-(void) getProductResponseWithData:(NSDictionary *)data
{
    self.productName = @"Unknown Product";
    NSString *productName = data[@"name"];
    if ([productName isKindOfClass:[NSString class]] && productName.length > 0)
        self.productName = productName;
    id attributeId = data[@"attributes"];
    if ([attributeId isKindOfClass:[NSDictionary class]]) {
        NSDictionary *attributesTable = (NSDictionary *)attributeId;
        for (NSString *key in attributesTable.allKeys) {
            NSString *value = attributesTable[key];
            NSString *info = [NSString stringWithFormat:@"%@:%@", key, value];
            [self.productAttributes addObject:info];
        }
    }
    
    id imageItems = data[@"images"];
    if ([imageItems isKindOfClass:[NSArray class]]) {
        NSArray *images = (NSArray *)imageItems;
        if ([images count] > 0 ) {
            self.productImageList = [NSMutableArray arrayWithCapacity:images.count];
            for (NSString *imageURLString in images) {
                if ([imageURLString isKindOfClass:[NSString class]]) {
                    __weak typeof(self) weakSelf = self;
                
                    NSLog(@"try to get product image from %@", imageURLString);
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]
                                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                            timeoutInterval:120.0];
                    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            //NSLog(@"Response: %@", responseObject);
                            if ([responseObject isKindOfClass:[UIImage class]]) {
                                UIImage *image = (UIImage*)responseObject;
                                [weakSelf getProductResponseWithImage:image];
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Image error: %@", error);
                        }];
                    [requestOperation start];
                }
            }
        }
    }
    [self.tableView reloadData];
}

-(void)getProductResponseWithImage:(UIImage *)image
{
    //if (image.size.height > kTopViewImageSize)
    image= [image thumbnailImage:kTopViewImageSize transparentBorder:1 cornerRadius:2
                  interpolationQuality:kCGInterpolationHigh];
    [self.productImageList addObject:image];
    [self.topView reloadData];
    //if (self.productImageList.count == 1) // the first
          //  [self.topView updateBackgroundWithImage:self.productImageList[0] animated:YES];

}
#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    if (section == 1)
        return self.productAttributes.count;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *cellType = [NSString stringWithFormat:@"Cell-%ld", indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
        if(cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellType];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = self.productName;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = self.productTrashIndex;
            if (self.product)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } 
    if (indexPath.section == 1) {
        if (!(indexPath.row >= 0 && indexPath.row < self.productAttributes.count))
            return nil;
        NSString *cellType = @"attributeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
        if(cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellType];
        }
        cell.textLabel.text = self.productAttributes[indexPath.row];
        return cell;
    }
    return nil;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 1)) {
        if (self.product) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *detailViewController = nil;
            detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"BarChartViewController"];
            BarChartViewController *bcvc = (BarChartViewController*)detailViewController;
            bcvc.product = self.product;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } 
}
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.productImageList count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImage *image = self.productImageList[index];
    UIImageView *viewItem = (UIImageView*)view;
    if(!viewItem) {
        viewItem = [[UIImageView alloc] initWithImage:image];
        viewItem.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        viewItem.image = image;
    }
    return viewItem;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    NSLog(@"Current Carousel Item Changed");
    NSInteger index = [self.topView currentCarouselItemIndex];
    if (index < 0 || index >= self.productImageList.count)
        return;
    UIImage * image= self.productImageList[index];
    //[self.topView updateBackgroundWithImage:image animated:YES];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return 0;// _wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}


@end
