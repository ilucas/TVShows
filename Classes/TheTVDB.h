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

#import <Cocoa/Cocoa.h>


@interface TheTVDB : NSObject {
}

+ (NSString *) applicationCacheDirectory;
+ (NSString *) getIDForShow:(NSString *)showName;
+ (NSString *) getValueForKey:(NSString *)key withShowID:(NSString *)seriesID andShowName:(NSString *)show;
+ (NSArray *) getValuesForKey:(NSString *)key withShowID:(NSString *)seriesID andShowName:(NSString *)show;

+ (NSString *) getShowStatus:(NSString *)showName withShowID:(NSString *)seriesID;
+ (NSDate *) getShowNextEpisode:(NSString *)showName withShowID:(NSString *)seriesID;
+ (NSImage *) getPosterForShow:(NSString *)showName withShowID:(NSString *)seriesID withHeight:(float)height withWidth:(float)width;
+ (void) removePosterForShow:(NSString *)showName;

@end
