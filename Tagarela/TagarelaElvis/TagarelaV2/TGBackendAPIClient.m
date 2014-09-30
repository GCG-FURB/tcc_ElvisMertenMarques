#import "TGBackendAPIClient.h"

@implementation TGBackendAPIClient

+ (id)sharedAPIClient
{
    static TGBackendAPIClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:TAGARELA_HOST];
        __instance = [[TGBackendAPIClient alloc]initWithBaseURL:baseUrl];
    });
    return __instance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        
    }
    return self;
}

@end