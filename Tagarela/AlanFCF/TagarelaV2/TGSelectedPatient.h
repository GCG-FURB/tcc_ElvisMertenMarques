#import <Foundation/Foundation.h>

@interface TGSelectedPatient : NSObject

@property (strong, nonatomic) NSString *selectedPatientName;
@property (strong, nonatomic) NSString *selectedPatientEmail;
@property (strong, nonatomic) NSData *selectedPatientImage;
@property (nonatomic) int selectedPatientID;

@end