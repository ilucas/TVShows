//
//  Serie.h
//  TVShows
//
//  Created by Lucas on 25/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Foundation;
@import CoreData;
@import MagicalRecord;

#import "_Serie.h"
#import "NSManagedObject+Attributes.h"

@interface Serie : _Serie

+ (void)create:(NSDictionary *)data InContext:(NSManagedObjectContext *)context WithCompletion:(void(^)(SerieID *serieID))completion Error:(void(^)(NSError *error))error;

@end
