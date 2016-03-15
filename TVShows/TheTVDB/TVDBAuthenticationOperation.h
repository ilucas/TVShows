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

@interface TVDBAuthenticationOperation : AFHTTPRequestOperation

@property (readonly, nonatomic, strong, nullable) NSString *token;
@property (readonly, nonatomic, strong, nullable) NSDate *tokenLife;

NS_ASSUME_NONNULL_BEGIN

// Returns a session token to be included in the rest of the requests. Note that API key authentication is required for all subsequent requests.
+ (nullable instancetype)request;

// Refreshes your current, valid token and returns a new token.
+ (nullable instancetype)refreshToken:(NSString *)token;

- (void)setCompletionBlockWithSuccess:(nullable void (^)(TVDBAuthenticationOperation * operation, id responseObject))success
                              failure:(nullable void (^)(TVDBAuthenticationOperation * operation, NSError * error))failure;

NS_ASSUME_NONNULL_END

@end
