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
@import AFNetworking;

// Networking
@class TVDBAuthenticationOperation;
@class TVDBSearchOperation;
@class TVDBSeriesOperation;
@class TVDBEpisodeOperation;
@class TVDBEpisodesOperation;
@class TVDBUpdatesOperation;
@class TVDBImageOperation;
@class TVDBPosterOperation;

// Models
@class TVDBSerie;
@class TVDBEpisode;
@class Serie;

@interface TVDBManager : AFHTTPRequestOperationManager

@property (nonatomic, strong, nullable) NSString *token;
@property (nonatomic, strong, nullable) NSDate *tokenLife;

NS_ASSUME_NONNULL_BEGIN

+ (NSURL *)baseURL;

- (TVDBAuthenticationOperation *)requestToken;
- (TVDBAuthenticationOperation *)refreshToken;

- (TVDBSearchOperation *)searchSerie:(NSString *)name
                     completionBlock:(nullable void (^)(NSArray<TVDBSerie *> *series))success
                             failure:(nullable void (^)(NSError *error))failure;

- (TVDBSeriesOperation *)serie:(NSNumber *)serieID
               completionBlock:(nullable void (^)(TVDBSerie *serie))success
                       failure:(nullable void (^)(NSError *error))failure;

- (TVDBEpisodeOperation *)episode:(NSNumber *)episodeID
                  completionBlock:(nullable void (^)(TVDBEpisode *serie))success
                          failure:(nullable void (^)(NSError *error))failure;

- (TVDBEpisodesOperation *)episodes:(NSNumber *)serieID
                    completionBlock:(nullable void (^)(NSArray<TVDBEpisode *> *episodes))success
                            failure:(nullable void (^)(NSError *error))failure;

- (nullable TVDBImageOperation *)poster:(Serie *)serie
                        completionBlock:(nullable void (^)(NSImage *poster, NSNumber *serieID))success
                                failure:(nullable void (^)(NSError *error))failure;

NS_ASSUME_NONNULL_END

@end
