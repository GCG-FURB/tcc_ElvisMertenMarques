//
//  PatientSymbol.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 04/08/13.
//  Copyright (c) 2013 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PatientSymbol : NSManagedObject

@property (nonatomic) int16_t serverID;
@property (nonatomic) int16_t patientID;
@property (nonatomic) int16_t symbolID;

@end
