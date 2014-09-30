#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
#ifdef TAGARELA_TESTE
    NSLog(@"..TAGARELA_TESTE");
#else
    NSLog(@"..TAGARELA Produção");
#endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));        
    }
}