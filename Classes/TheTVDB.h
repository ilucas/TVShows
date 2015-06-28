/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

@import Cocoa;
@import AFNetworking;

@interface TheTVDB : NSObject

@property (assign, getter=isCancelled) BOOL canceled;

+ (instancetype)sharedInstance;

- (void)searchShow:(NSString *)showName completionHandler:(void(^)(NSArray *result, NSError *error))handler;
- (void)getShow:(NSNumber *)showid completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)getShowWithIMDB:(NSString *)serieID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)getShowWithEpisodeList:(NSString *)showName completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;

@end
