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

@import Foundation;
@import AFNetworking;

@class RARBGTorrent;

NS_ASSUME_NONNULL_BEGIN

@interface RARBGSearchOperation : AFHTTPRequestOperation

@property (nonatomic, strong, nullable) NSString *search;

+ (NSDictionary *)parameters;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(RARBGSearchOperation *, NSArray<RARBGTorrent *> *))success
                              failure:(nullable void (^)(RARBGSearchOperation *, NSError *))failure;

- (void)setRequest:(NSMutableURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
