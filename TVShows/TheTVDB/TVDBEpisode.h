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

@interface TVDBEpisode : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

@property (strong, nonatomic, nullable) NSNumber *episodeID;
@property (strong, nonatomic, nullable) NSNumber *episode;
@property (strong, nonatomic, nullable) NSNumber *season;
@property (strong, nonatomic, nullable) NSNumber *number;
@property (strong, nonatomic, nullable) NSData *airDate;
@property (strong, nonatomic, nullable) NSString *name;
@property (strong, nonatomic, nullable) NSString *overview;

@end
