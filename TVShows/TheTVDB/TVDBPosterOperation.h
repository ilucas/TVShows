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

@interface TVDBPosterOperation : TVDBRequestOperation

@property (readonly, nonatomic, nullable) NSNumber *serieID;
@property (readonly, nonatomic, nullable) NSArray<NSDictionary *> *posters;

NS_ASSUME_NONNULL_BEGIN

+ (nullable instancetype)requestPoster:(NSNumber *)serieID
                                       WithToken:(nullable NSString *)token;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(TVDBRequestOperation *operation, NSArray<NSDictionary *> *posters))success
                              failure:(nullable void (^)(TVDBRequestOperation *operation, NSError *error))failure;


NS_ASSUME_NONNULL_END

@end
