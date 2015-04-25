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
@import Ono;

#import "TSAbstractAPI.h"

@interface TheTVDB : TSAbstractAPI

//TODO: Add support for multiples languages
- (void)getShow:(NSString *)showName completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)getShowWithIMDB:(NSString *)serieID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)searchEpisode:(NSString *)aEpisodeNum seasonNum:(NSString *)aSeasonNum ShowID:(NSString *)seriesID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)getPosterForShow:(NSString *)showName withShowID:(NSString *)seriesID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;

@end
