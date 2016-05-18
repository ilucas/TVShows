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

@interface TVDBEpisodesOperation : TVDBRequestOperation

@property (readonly, nonatomic, strong, nullable) NSNumber *serieID;

NS_ASSUME_NONNULL_BEGIN

// All episodes for a given series. Paginated with 100 results per page.
+ (nullable instancetype)requestEpisodesForSerie:(NSNumber *)serieID WithToken:(nullable NSString *)token;
+ (nullable instancetype)requestEpisodesForSerie:(NSNumber *)serieID WithToken:(nullable NSString *)token Page:(NSNumber *)page;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(TVDBEpisodesOperation * operation, NSArray <TVDBEpisode *> *episodes))success
                              failure:(nullable void (^)(TVDBEpisodesOperation * operation, NSError * error))failure;

NS_ASSUME_NONNULL_END

@end
