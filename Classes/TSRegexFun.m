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

#import "TSRegexFun.h"
#import "RegexKitLite.h"
#import "TSUserDefaults.h"
#import "AppInfoConstants.h"
@implementation TSRegexFun

+ (NSArray *) parseSeasonAndEpisode:(NSString *)title
{
    // Set up our regex strings.
    NSArray *matchedRegex;
    NSArray *parseTypes = [NSArray arrayWithObjects:@"[sS]([0-9]+)(?:[[:space:]]*)[eE]([0-9]+)",  // S01E01
                                                    @"[^0-9]([0-9][0-9]?)(?:[[:space:]]*[xX][[:space:]]*)([0-9]+)", // 01x01
                                                    @"EPI-([0-9]+)-([0-9]+)", // EPI-1-1 (Hamsterpit)
                                                    @"DAY-([0-9]{4})([0-9]{2})([0-9]{2})", // DAY-20110115 (Hamsterpit)
                                                    @"Episode ([0-9]+).([0-9]+)", // Episode 1.1 (BitSnoop)
                                                    @"([0-9]{4})(?:[[:space:]]|[.-])([0-9]{2})(?:[[:space:]]|[.-])([0-9]{2})", // YYYY MM DD
                                                    @"([0-9]{2})(?:[[:space:]]|[.-])([0-9]{2})(?:[[:space:]]|[.-])([0-9]{4})", // MM DD YYYY
                                                    @"[^a-zA-Z0-9\\(]([0-9]?[0-9])([0-9][0-9])[^a-zA-Z0-9]", nil]; // 101
    
    // Run through each of the regex strings we've listed above.
    for (NSString *regex in parseTypes) {
        matchedRegex = [title arrayOfCaptureComponentsMatchedByRegex:regex];
        
        // If there's a match then return it, otherwise do nothing.
        if([matchedRegex count] != 0) {
            // Avoid matches with 2011, 2012, etc
            if ([[[matchedRegex objectAtIndex:0] objectAtIndex:0] isEqualToString:@"20"] &&
                [[matchedRegex objectAtIndex:0] objectAtIndex:2] == nil &&
                [title isMatchedByRegex:@"201[0-9]"]) {
                return nil;
            }
            return [matchedRegex objectAtIndex:0];
        }
    }
    
    return nil;
}

+ (NSString *) removeLeadingZero:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfRegex:@"^ *0+" withString:@""];
}

+ (BOOL) isEpisodeHD:(NSString *)title
{
    return [title isMatchedByRegex:@"(720|1080)"];
}

+ (NSString *) parseTitleFromString:(NSString *)title withIdentifier:(NSArray* )identifier withType:(NSString *)type
{
    // This is a temporary method until theTVDB support is added
    NSString *showTitle = [title stringByReplacingOccurrencesOfRegex:@"HD 720p: " withString:@""];
    
    showTitle = [showTitle stringByReplacingOccurrencesOfRegex:@"[\\._ ]+([\\[-].*)?[sS]?\\d.*" withString:@""];
    showTitle = [showTitle stringByReplacingOccurrencesOfRegex:@"[\\._ ]+" withString:@" "];
    showTitle = [showTitle stringByReplacingOccurrencesOfRegex:@": Episode" withString:@""];
    
    if (type == @"episode") {
        
        // TVShow is in a Season and Episode format
        if ([TSUserDefaults getFloatFromKey:@"NamingConvention" withDefault:0] == 0) {
            return [NSString stringWithFormat:@"%@ S%02dE%02d",
                    showTitle,
                    [[identifier objectAtIndex:1] intValue],
                    [[identifier objectAtIndex:2] intValue]];
        } else {
            return [NSString stringWithFormat:@"%@ %dx%02d",
                    showTitle,
                    [[identifier objectAtIndex:1] intValue],
                    [[identifier objectAtIndex:2] intValue]];
        }
        
    } else if (type == @"date") {
        
        // TVShow is in a Date format
        return [NSString stringWithFormat:@"%@ %@ %@ %@",
                showTitle,
                [identifier objectAtIndex:1],
                [identifier objectAtIndex:2],
                [identifier objectAtIndex:3]];
        
    } else {
        
        // TVShow is "unknown" so at least return something
        return [title stringByReplacingOccurrencesOfRegex:@"[\\._ ]+" withString:@" "];
        
    }
}

+ (NSString *) parseShowFromTitle:(NSString *)title
{
    // This is a temporary method until theTVDB support is added
    NSString *showTitle = [title stringByReplacingOccurrencesOfRegex:@"HD 720p: " withString:@""];
    
    showTitle = [showTitle stringByReplacingOccurrencesOfRegex:@"[\\._ ]+([\\[-].*)?[sS]?\\d.*" withString:@""];
    showTitle = [showTitle stringByReplacingOccurrencesOfRegex:@"[\\._ ]+" withString:@" "];
    
    return showTitle;
}

+ (NSString *) parseHashFromMagnetLink:(NSString *)aMagnetLink
{
    NSString *magnetHash = [aMagnetLink stringByReplacingOccurrencesOfRegex:@"^.*btih:" withString:@""];
    
    magnetHash = [magnetHash stringByReplacingOccurrencesOfRegex:@"[^a-fA-F0-9].*$" withString:@""];
    
    return magnetHash;
}

+ (NSString *) replaceHTMLEntitiesInString:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfRegex:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfRegex:@"&quot;" withString:@"\""];
    
    return string;
}

+ (BOOL) wasThisEpisode:(NSString *)anEpisode airedAfterThisOne:(NSString *)anotherEpisode
{
    NSArray *seasonAndEpisodeOne = [self parseSeasonAndEpisode:anEpisode];
    NSArray *seasonAndEpisodeTwo = [self parseSeasonAndEpisode:anotherEpisode];
    
    // If the second episode is not actually an episode, it is the beginning or
    // it follows a straange convention, so download it
    if (seasonAndEpisodeTwo == nil) {
        return YES;
    // But if the first episode is not, there is probably some error
    } else if (seasonAndEpisodeOne == nil) {
        return NO;
    // If they are numbered differently, treat it as differente shows (so yes)
    } else if ([seasonAndEpisodeOne count] != [seasonAndEpisodeTwo count]) {
        return YES;
    }
    
    // Compare the arrays
    if ([seasonAndEpisodeOne count] == 3) {
        return ([[seasonAndEpisodeOne objectAtIndex:1] integerValue] >
                [[seasonAndEpisodeTwo objectAtIndex:1] integerValue]) ||
        ([[seasonAndEpisodeOne objectAtIndex:1] integerValue] ==
         [[seasonAndEpisodeTwo objectAtIndex:1] integerValue] &&
         [[seasonAndEpisodeOne objectAtIndex:2] integerValue] >
         [[seasonAndEpisodeTwo objectAtIndex:2] integerValue]);
    } else if ([seasonAndEpisodeOne count] == 4) {
        return ([[seasonAndEpisodeOne objectAtIndex:1] integerValue] >
                [[seasonAndEpisodeTwo objectAtIndex:1] integerValue]) ||
        ([[seasonAndEpisodeOne objectAtIndex:1] integerValue] ==
         [[seasonAndEpisodeTwo objectAtIndex:1] integerValue] &&
         [[seasonAndEpisodeOne objectAtIndex:2] integerValue] >
         [[seasonAndEpisodeTwo objectAtIndex:2] integerValue]) ||
        ([[seasonAndEpisodeOne objectAtIndex:1] integerValue] ==
         [[seasonAndEpisodeTwo objectAtIndex:1] integerValue] &&
         [[seasonAndEpisodeOne objectAtIndex:2] integerValue] ==
         [[seasonAndEpisodeTwo objectAtIndex:2] integerValue] &&
         [[seasonAndEpisodeOne objectAtIndex:3] integerValue] >
         [[seasonAndEpisodeTwo objectAtIndex:3] integerValue]);
    }
    
    // Otherwise better be safe than sorry
    return YES;
}

+ (NSString *) obtainFullFeed:(NSString *)aFeed
{
    NSString *fullFeed = aFeed;
    
    if ([aFeed isMatchedByRegex:@"tvshowsapp\\.com"]) {
        fullFeed = [aFeed stringByReplacingOccurrencesOfRegex:@"\\.xml$"
                                                   withString:@".full.xml"];
    }
    
    return fullFeed;
}

@end
