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

@class TVDBSerie;

@interface TVDBSearchOperation : TVDBRequestOperation

@property (readonly, nonatomic, strong, nonnull) NSString *search;

NS_ASSUME_NONNULL_BEGIN

// search for a series based on the name.
+ (nullable instancetype)requestWithToken:(nullable NSString *)token SerieName:(NSString *)name;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(TVDBSearchOperation *operation, NSArray <TVDBSerie *> *series))success
                              failure:(nullable void (^)(TVDBSearchOperation *operation, NSError *error))failure;

NS_ASSUME_NONNULL_END
@end
