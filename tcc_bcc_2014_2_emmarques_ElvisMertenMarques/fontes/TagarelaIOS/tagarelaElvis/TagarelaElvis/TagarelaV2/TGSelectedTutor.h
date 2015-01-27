#import <Foundation/Foundation.h>

@interface TGSelectedTutor : NSObject

@property (strong, nonatomic) NSString *selectedTutorName;
@property (strong, nonatomic) NSString *selectedTutorEmail;
@property (strong, nonatomic) NSData *selectedTutorImage;
@property (nonatomic) int selectedTutorID;

@end