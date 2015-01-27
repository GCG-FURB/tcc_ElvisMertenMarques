#import "TGSymbolVideoViewController.h"

@interface TGSymbolVideoViewController ()

@end

@implementation TGSymbolVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self embedYouTube:[self videoLink]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)embedYouTube:(NSString*)url
{
    NSRange startRange = [url rangeOfString:@"="];
    
    NSRange searchRange = NSMakeRange(startRange.location+1, url.length-startRange.location-1);
    NSString *subStr = [url substringWithRange:searchRange];
    
    if ([subStr hasSuffix:@"&"]) {
        subStr = [subStr stringByReplacingOccurrencesOfString:@"&" withString:@""];
    }
    
    NSString *embedHTML =[NSString stringWithFormat:@"\
                          <html><head>\
                          <style type=\"text/css\">\
                          body {\
                          background-color: transparent;\
                          color: blue;\
                          }\
                          </style>\
                          </head><body style=\"margin:0\">\
                          <iframe height=\"%d\" width=\"%d\" src=\"http://www.youtube.com/embed/%@\"></iframe>\
                          </body></html>", 400, 400, subStr];
    [[self videoWebView]loadHTMLString:embedHTML baseURL:nil];
}

@end