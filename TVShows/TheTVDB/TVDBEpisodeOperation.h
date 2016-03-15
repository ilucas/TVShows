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

@import Foundation;
@import AFNetworking;

#import "TVDBRequestOperation.h"

@class TVDBEpisode;

@interface TVDBEpisodeOperation : TVDBRequestOperation

@property (readonly, nonatomic, strong, nullable) NSNumber *episodeID;

NS_ASSUME_NONNULL_BEGIN

// Returns the full information for a given episode id.
+ (nullable instancetype)requestEpisode:(NSNumber *)episodeID WithToken:(nullable NSString *)token;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(TVDBEpisodeOperation * operation, TVDBEpisode* episode))success
                              failure:(nullable void (^)(TVDBEpisodeOperation * operation, NSError * error))failure;

NS_ASSUME_NONNULL_END

@end
