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

#import "AppInfoConstants.h"
#import "TSParseXMLFeeds.h"
#import "FeedParser.h"
#import "TSRegexFun.h"
#import "TSUserDefaults.h"
#import "TorrentzParser.h"
#import "WebsiteFunctions.h"
#import "RegexKitLite.h"
#define NSMaximumRange ((NSRange){.location=0UL, .length=NSUIntegerMax})

@implementation TSParseXMLFeeds

+ (NSString *) getMagnetLink:(FPItem *)item
{
    for (FPExtensionNode *node in item.extensionElements) {
		if ([node.name isEqualToString:@"torrent"]) {
			for (FPExtensionNode *subnode in [node children]) {
                if ([subnode.name isEqualToString:@"magnetURI"]) {
                    return subnode.stringValue;
                }
            }
		}
	}
    
    // Check if the permalink is a magnet URI
    if ([item.guid rangeOfString:@"magnet:"].location != NSNotFound) {
        return item.guid;
    }
    
    return nil;
}

+ (NSArray *) parseEpisodesFromFeed:(NSString *)url
{
    // Begin parsing the feed
    NSString *episodeTitle = @"", *lastEpisodeTitle = @"", *episodeSeason = @"", *episodeNumber = @"", *episodeQuality = @"", *lastEpisodeQuality = @"", *qualityString = @"", *link = @"";
    NSDate *episodeDate;
    NSError *error;
    NSMutableArray *episodeArray = [NSMutableArray array];
    NSData *feedData = [WebsiteFunctions downloadDataFrom:url];
    FPFeed *parsedData = [FPParser parsedFeedWithData:feedData error:&error];
    
    lastEpisodeTitle = lastEpisodeQuality = @"";
    
    for (FPItem *item in parsedData.items) {
        // If the user wants only episodes from eztv or vtv and this is not from them, ignore it
        // But, don't ignore it if the episode is more than 12 hours old, because that means
        // that they didn't release it in a good format so the user would have to use this :(
        float resortToAdditionalSourcesInterval = [TSUserDefaults getFloatFromKey:@"ResortToAdditionalSourcesInterval" withDefault:12];
        
        if (![TSUserDefaults getBoolFromKey:@"UseAdditionalSourcesHD" withDefault:YES] &&
            [url rangeOfString:@"tvshowsapp"].location != NSNotFound &&
            ![item.description isMatchedByRegex:@"eztv" options:RKLCaseless inRange:NSMaximumRange error:nil] &&
            ![item.description isMatchedByRegex:@"vtv" options:RKLCaseless inRange:NSMaximumRange error:nil] &&
            [[NSDate date] timeIntervalSinceDate:item.pubDate] < resortToAdditionalSourcesInterval*60*60) {
            continue;
        }
        
        NSMutableDictionary *Episode = [[NSMutableDictionary alloc] init];
        NSArray *seasonAndEpisode = [TSRegexFun parseSeasonAndEpisode:item.title];
        
        if ([seasonAndEpisode count] == 3) {
            episodeTitle = [TSRegexFun parseTitleFromString:item.title
                                             withIdentifier:seasonAndEpisode
                                                   withType:@"episode"];
            episodeSeason = [TSRegexFun removeLeadingZero:[seasonAndEpisode objectAtIndex:1]];
            episodeNumber = [TSRegexFun removeLeadingZero:[seasonAndEpisode objectAtIndex:2]];
            
        } else if ([seasonAndEpisode count] == 4) {
            episodeTitle = [TSRegexFun parseTitleFromString:item.title
                                             withIdentifier:seasonAndEpisode
                                                   withType:@"date"];
            episodeSeason = @"-";
            episodeNumber = @"-";
            
        } else {
            episodeTitle = [TSRegexFun parseTitleFromString:item.title
                                             withIdentifier:seasonAndEpisode
                                                   withType:@"other"];
            episodeSeason = @"-";
            episodeNumber = @"-";
        }
        
        episodeQuality = [NSString stringWithFormat:@"%d",[TSRegexFun isEpisodeHD:item.title]];
        
        if ([episodeQuality intValue] == 1) {
            qualityString = @"✓";
        } else {
            // qualityString = @"✗";
            qualityString = @"";
        }
        
        // Try Magnet links
        if ([TSUserDefaults getBoolFromKey:@"PreferMagnets" withDefault:NO]) {
            link = [TSParseXMLFeeds getMagnetLink:item];
        } else {
            link = nil;
        }
        
        // If no magnets, try enclosures and links
        if (link == nil) {
            if (item.enclosures && [item.enclosures count] > 0) {
                link = [[item.enclosures objectAtIndex:0] url];
            } else {
                link = item.link.href;
            }
        }
        
        // RSS that have no dates. I hate it
        if (item.pubDate) {
            episodeDate = item.pubDate;
        } else {
            episodeDate = [NSDate dateWithTimeIntervalSinceNow:-3*60];
            // Generate slightly different date for each episode based on episode season/number
            episodeDate = [episodeDate addTimeInterval:60*[episodeSeason intValue] + [episodeNumber intValue]];
        }
        
        [Episode setValue:episodeTitle          forKey:@"episodeName"];
        [Episode setValue:episodeDate           forKey:@"pubDate"];
        [Episode setValue:link                  forKey:@"link"];
        [Episode setValue:episodeSeason         forKey:@"episodeSeason"];
        [Episode setValue:episodeNumber         forKey:@"episodeNumber"];
        [Episode setValue:episodeQuality        forKey:@"isHD"];
        [Episode setValue:qualityString         forKey:@"qualityString"];
        
        // Check if we already add this same episode
        if (![episodeTitle isEqualToString:lastEpisodeTitle] ||
            ![episodeQuality isEqualToString:lastEpisodeQuality]) {
            [episodeArray addObject:Episode];
            lastEpisodeTitle = episodeTitle;
            lastEpisodeQuality = episodeQuality;
        }
        
        [Episode release];
    }
    
    return episodeArray;
    [episodeArray release];
}

+ (NSInteger) getEpisode:(NSMutableDictionary *)episode fromArray:(NSArray *)episodes
{
    NSInteger i = 0;
    for (NSMutableDictionary *ep in episodes) {
        if ([[[[[[[episode valueForKey:@"episodeName"] lowercaseString]
                 stringByReplacingOccurrencesOfRegex:@"\\s+us\\s+" withString:@" "]
                stringByReplacingOccurrencesOfRegex:@"\\s+\\(.*\\)\\s+" withString:@" "]
               stringByReplacingOccurrencesOfRegex:@"\\s+and\\s+" withString:@" "]
              stringByReplacingOccurrencesOfRegex:@"\\s+&\\s+" withString:@" "]
             isEqualToString:
             [[[[[[ep valueForKey:@"episodeName"] lowercaseString]
                 stringByReplacingOccurrencesOfRegex:@"\\s+us\\s+" withString:@" "]
                stringByReplacingOccurrencesOfRegex:@"\\s+\\(.*\\)\\s+" withString:@" "]
               stringByReplacingOccurrencesOfRegex:@"\\s+and\\s+" withString:@" "]
              stringByReplacingOccurrencesOfRegex:@"\\s+&\\s+" withString:@" "]] &&
            [[episode valueForKey:@"isHD"] boolValue] == [[ep valueForKey:@"isHD"] boolValue]) {
            return i;
        }
        i++;
    }
    return NSNotFound;
}

+ (NSMutableArray *) fakeEpisodes:(NSMutableArray *)episodes
{
    NSMutableArray *fakeEpisodes = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *realEpisode in episodes) {
        
        // Ignore this episode if it is a daily show
        // The scene does not release late nights regularly
        // Also ignore episodes that are already in HD
        // And do not search for episodes until there has been
        // two hours since the SD episode was released
        if (![[realEpisode valueForKey:@"episodeSeason"] isEqualToString:@"-"] &&
            [[realEpisode valueForKey:@"isHD"] isEqualToString:[NSString stringWithFormat:@"%d", NO]] &&
            [[realEpisode valueForKey:@"pubDate"] compare:[NSDate dateWithTimeIntervalSinceNow:-2*60]] == NSOrderedAscending) {
            
            NSMutableDictionary *fakeEpisode = [[NSMutableDictionary alloc] init];
            
            [fakeEpisode setValue:[realEpisode valueForKey:@"episodeName"]     forKey:@"episodeName"];
            [fakeEpisode setValue:[realEpisode valueForKey:@"pubDate"]         forKey:@"pubDate"];
            // Append the name as first link, that will tell the TorrentzParser to search for an HD torrent
            [fakeEpisode setValue:[[realEpisode valueForKey:@"episodeName"]
                                   stringByAppendingFormat:@"#%@", [realEpisode valueForKey:@"link"]]
                           forKey:@"link"];
            [fakeEpisode setValue:[realEpisode valueForKey:@"episodeSeason"]   forKey:@"episodeSeason"];
            [fakeEpisode setValue:[realEpisode valueForKey:@"episodeNumber"]   forKey:@"episodeNumber"];
            [fakeEpisode setValue:[NSString stringWithFormat:@"%d", YES]       forKey:@"isHD"];
            [fakeEpisode setValue:@"✓"                                         forKey:@"qualityString"];
            
            // Check if the episode is already in HD
            if ([self getEpisode:fakeEpisode fromArray:episodes] == NSNotFound) {
                [fakeEpisodes addObject:fakeEpisode];
            }
            
            [fakeEpisode autorelease];
        }
        
        [fakeEpisodes addObject:realEpisode];
    }
    
    return [fakeEpisodes autorelease];
}

+ (NSArray *) parseEpisodesFromFeeds:(NSArray *)urls beingCustomShow:(BOOL)isCustomShow
{
    NSMutableArray *episodes = [[[NSMutableArray alloc] init] autorelease];
    
    // Parse and store all results
    for (NSString *url in urls) {
        // Deal with NULLs feeds from the fetch controller
        if (url == (id)[NSNull null] || [url length] == 0) {
            continue;
        }
        // Deal with "feed://" protocol that Safari puts in there
        for (NSMutableDictionary *episode in [self parseEpisodesFromFeed:
              [url stringByReplacingOccurrencesOfString:@"feed://" withString:@"http://"]]) {
            // For each episode add it to the results if the episode is not already in the results
            NSInteger mirrorIndex = [self getEpisode:episode fromArray:episodes];
            // If the episode already exists, add the episode
            if (mirrorIndex != NSNotFound) {
                [[episodes objectAtIndex:mirrorIndex]
                 setValue:[[[episodes objectAtIndex:mirrorIndex] valueForKey:@"link"]
                           stringByAppendingFormat:@"#%@", [episode valueForKey:@"link"]]
                   forKey:@"link"];
            } else {
                if (![[episode valueForKey:@"episodeName"] isEqualToString:@""]) {
                    [episodes addObject:episode];
                }
            }
        }
    }
    
    // Fake HD episodes! Do not fake custom shows
    if ([TSUserDefaults getBoolFromKey:@"UseAdditionalSourcesHD" withDefault:YES] && !isCustomShow) {
        episodes = [self fakeEpisodes:episodes];
    }
    
    // Sort results by date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [episodes sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    return episodes;
}

+ (BOOL) feedHasHDEpisodes:(NSArray *)parsedFeed
{
    for (NSArray *item in parsedFeed) {
        if ([[item valueForKey:@"isHD"] boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL) feedHasSDEpisodes:(NSArray *)parsedFeed
{
    for (NSArray *item in parsedFeed) {
        if (![[item valueForKey:@"isHD"] boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

@end
