//
//  Serie.m
//  TVShows
//
//  Created by Lucas on 25/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

@implementation Serie

+ (void)create:(NSDictionary *)data InContext:(NSManagedObjectContext *)context
                               WithCompletion:(void(^)(SerieID *serieID))completion
                                        Error:(void(^)(NSError *error))errorBlock {
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextWithParent:context];
    
    [localContext performBlock:^{
        // Create the entity
        Serie *serie = [Serie MR_createEntityInContext:localContext];
        
        [serie updateAttributes:data];
        
        // Update the Serie in Core Data
        [data[@"episodes"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                Episode *ep = [Episode MR_createEntityInContext:localContext];
                [ep updateAttributes:obj];
                [serie addEpisodesObject:ep];// Add the episode to the serie.
            }
        }];
        
        NSMutableDictionary *updates = [NSMutableDictionary dictionaryWithDictionary:data];
        [updates removeObjectForKey:@"episodes"];
        
        [serie updateAttributes:updates];
        
        // Save the changes
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                completion(serie.objectID);
            } else {
                errorBlock(error);
            }
        }];
    }];
}

@end
