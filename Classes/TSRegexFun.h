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


@interface TSRegexFun : NSObject {

}

+ (NSArray *) parseSeasonAndEpisode:(NSString *)title;
+ (NSString *) removeLeadingZero:(NSString *)string;
+ (BOOL) isEpisodeHD:(NSString *)title;
+ (NSString *) parseTitleFromString:(NSString *)title withIdentifier:(NSArray* )identifier withType:(NSString *)type;
+ (NSString *) parseShowFromTitle:(NSString *)title;
+ (NSString *) parseHashFromMagnetLink:(NSString *)aMagnetLink;
+ (NSString *) replaceHTMLEntitiesInString:(NSString *)string;
+ (BOOL) wasThisEpisode:(NSString *)anEpisode airedAfterThisOne:(NSString *)anotherEpisode;
+ (NSString *) obtainFullFeed:(NSString *)aFeed;

@end
