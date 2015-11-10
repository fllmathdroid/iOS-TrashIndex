#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface ProductViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSString *barCode;
@end			      
