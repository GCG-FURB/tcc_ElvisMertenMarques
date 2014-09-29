#import "TGCurrentUserManager.h"

@implementation TGCurrentUserManager

+ (id)sharedCurrentUserManager
{
    static TGCurrentUserManager *shareCurrentUserManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCurrentUserManager = [[self alloc]init];
    });
    return shareCurrentUserManager;
}

@end