/*
 *  This file is part of the TVShows source code.
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

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
