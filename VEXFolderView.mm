#import <UIKit/UIKit.h>
#import "VeloxFolderViewProtocol.h"


@interface VEXFolderView : UIView <VeloxFolderViewProtocol, UIAlertViewDelegate>
{
    UIImageView *_imageView;
    UIActivityIndicatorView *_spinner;
}
@property (nonatomic, assign) BOOL showsActivityIndicator;

- (void)downloadLatestImage;
- (void)showAlertWithMessage:(NSString *)message;
- (void)cleanup;

@end

@implementation VEXFolderView
@synthesize showsActivityIndicator=_showsActivityIndicator;
+ (int)folderHeight
{
    return 350;
}

- (UIView *)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _imageView = [[[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)] autorelease];
        [self addSubview:_imageView];
        [self downloadLatestImage];
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
    [super dealloc];
}

- (void)downloadLatestImage
{
    self.showsActivityIndicator = YES;

    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://xkcd.com/info.0.json"]] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {        
        if (error) {
            [self showAlertWithMessage:@"An error occurred when downloading info about the latest comic."];
            return;
        }
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dictionary objectForKey:@"img"]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                [self showAlertWithMessage:@"An error occurred when downloading the image."];
                return;
            }
            
            self.showsActivityIndicator = NO;
            
            UIImage *image = [UIImage imageWithData:data];
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
            _imageView.image = image;
        }];
    }];
}


- (void)showAlertWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"vexkcd" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Retry", nil] autorelease];
        [alert show];
        self.showsActivityIndicator = NO;
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index
{
    if (!(index == alertView.cancelButtonIndex)) {
        [self downloadLatestImage];
    }
}

- (void)setShowsActivityIndicator:(BOOL)showsIndicator
{
    _showsActivityIndicator = showsIndicator;

    if (showsIndicator == NO) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        _spinner = nil;
    }
    else {
        _spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        _spinner.center = _imageView.center;
        [_spinner startAnimating];
        [self addSubview:_spinner];
    }
}

-(void)unregisterFromStuff
{
    [self cleanup];
}

- (void)cleanup
{
    [_spinner removeFromSuperview];
    _spinner = nil;

    [_imageView removeFromSuperview];
    _imageView = nil;
}

@end