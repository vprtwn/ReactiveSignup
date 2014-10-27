#import "FlickrSearchViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

NSString *const FlickrAPIKey = @"9be5b08cd8168fa82d136aa55f1fdb3c";

@interface FlickrSearchViewController ()

@property (strong, nonatomic) UIImage *photo;

@end

@implementation FlickrSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (NSDictionary *)requestParametersWithTag:(NSString *)tag
{
    return @{@"api_key": FlickrAPIKey,
             @"nojsoncallback": @YES,
             @"method": @"flickr.photos.search",
             @"sort": @"random",
             @"per_page": @10,
             @"tags": tag};
}


@end

