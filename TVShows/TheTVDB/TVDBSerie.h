/*
 *  This file is part of the TVShows source code.
 *  http://github.com/ilucas/TVShows
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

@import Cocoa;
@import Mantle;
@import MTLManagedObjectAdapter;

#import "MTLModel+JSONAdapter.h"

@class TVDBEpisode;

@interface TVDBSerie : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

@property (strong, nonatomic, nullable) NSNumber *serieID;
@property (strong, nonatomic, nullable) NSString *name;
@property (strong, nonatomic, nullable) NSString *status;
@property (strong, nonatomic, nullable) NSString *network;
@property (strong, nonatomic, nullable) NSNumber *networkID;
@property (strong, nonatomic, nullable) NSString *runtime;
@property (strong, nonatomic, nullable) NSDate *firstAired;
@property (strong, nonatomic, nullable) NSString *genre;
@property (strong, nonatomic, nullable) NSString *overview;
@property (strong, nonatomic, nullable) NSNumber *lastUpdated;
@property (strong, nonatomic, nullable) NSString *contentRating;
@property (strong, nonatomic, nullable) NSString *airDay;
@property (strong, nonatomic, nullable) NSString *airTime;
@property (strong, nonatomic, nullable) NSNumber *rating;
@property (strong, nonatomic, nullable) NSString *imdbID;
@property (strong, nonatomic, nullable) NSString *banner;

@property (strong, nonatomic, nullable) NSSet<TVDBEpisode *> *episodes;

NS_ASSUME_NONNULL_BEGIN

- (nullable id)insertManagedObjectIntoContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (nullable id)modelFromManagedObject:(NSManagedObject *)managedObject error:(NSError **)error;

- (void)addEpisodes:(NSArray<TVDBEpisode *> *)newEpisodes;

NS_ASSUME_NONNULL_END

@end

