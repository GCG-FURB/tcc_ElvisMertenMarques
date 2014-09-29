//
//  PatientsRelationships.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 12/10/13.
//  Copyright (c) 2013 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PatientsRelationships : NSManagedObject

@property (nonatomic, retain) NSString * patientEmail;
@property (nonatomic, retain) NSString * patientName;
@property (nonatomic, retain) NSData * patientPicture;
@property (nonatomic) int16_t patientServerID;
@property (nonatomic) int16_t patientTutorID;
@property (nonatomic) int16_t serverID;
@property (nonatomic) int16_t relationshipType;

@end
