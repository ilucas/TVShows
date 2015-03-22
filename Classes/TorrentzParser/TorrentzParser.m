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
#import "TorrentzParser.h"
#import "RegexKitLite.h"
#import "WebsiteFunctions.h"
#import "TSTorrentFunctions.h"

@implementation TorrentzParser

- (id)init
{
    if((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *) getAlternateTorrentForEpisode:(NSString *)episodeName
{
    NSString *torrentzURLFormat;
    
    // Decide if quotes are needed (for late nights) or not
    // Because I'm lazy, this piece of code will be useless in 2020
    // Sorry late nights viewers from the next decade
    if ([episodeName rangeOfString:@" 201"].location == NSNotFound) {
        torrentzURLFormat = @"http://torrentz.eu/feed?q=%@+720p";
    } else {
        torrentzURLFormat = @"http://torrentz.eu/feed?q=%%22%@%%22+720p";
    }
    
    // Now let's grab the search results
    NSString *torrentzURL = [NSString stringWithFormat:torrentzURLFormat,
                             [episodeName stringByReplacingOccurrencesOfString:@" "
                                                                    withString:@"+"]];
    NSString *searchResults = [WebsiteFunctions downloadStringFrom:torrentzURL];
    
    // Regex fun...
    NSString *regex = @"<guid>[^<]+</guid>";
    NSArray *tempValues = [searchResults componentsMatchedByRegex:regex];
    
    // Check the first result
    if ([tempValues count] >= 1) {
        
        // Get the torrentz result page
        torrentzURL = [[tempValues objectAtIndex:0] stringByReplacingOccurrencesOfRegex:@"<[^<]+>" withString:@""];
        
        // Get all possible torrent files
        tempValues = [TorrentzParser getAllTorrentsFromTorrenzURL:torrentzURL];
        
        // And choose one randomly
        if ([tempValues count] >= 1) {
            return [tempValues objectAtIndex:arc4random()%[tempValues count]];
        } else {
            return nil;
        }
        
    } else {
        return nil;
    }
}

+ (NSArray *) getAllTorrentsFromTorrenzURL:(NSString *)aTorrentzURL
{
    // Now let's grab the meta search results
    NSString *searchResults = [WebsiteFunctions downloadStringFrom:aTorrentzURL];
    
    // Get all the external links (the trackers)
    NSString *regex = @"<a href=\"http[^\"]+";
    NSArray *tempValues = [searchResults componentsMatchedByRegex:regex];
    NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:10];
    
    // And process one by one
    for (__strong NSString *tracker in tempValues) {
        tracker = [tracker stringByReplacingOccurrencesOfRegex:@"<a href=\"" withString:@""];
        NSString *torrent = nil;
        
        // Process only known trackers
        if ([tracker hasPrefix:@"http://www.vertor.com"]) {
            torrent = [TorrentzParser getTorrentFromTracker:tracker
                                            withLinkMatcher:@"http://www.vertor.com/([^\"]*)mod=download([^\"]*)id=([^\"]*)"
                                                  appending:@""];
            torrent = [torrent stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
        } else if ([tracker hasPrefix:@"http://btjunkie.org"]) {
            torrent = [TorrentzParser getTorrentFromTracker:tracker
                                            withLinkMatcher:@"http://dl.btjunkie.org/torrent/([^\"]*)\\.torrent"
                                                  appending:@""];
        } else if ([tracker hasPrefix:@"http://www.btmon.com"]) {
            torrent = [tracker stringByReplacingOccurrencesOfString:@".html" withString:@""];
        } else if ([tracker hasPrefix:@"http://www.torrenthound.com"]) {
            torrent = [TorrentzParser getTorrentFromTracker:tracker
                                            withLinkMatcher:@"/torrent/([^\"]*)"
                                                  appending:@"http://www.torrenthound.com"];
        }
        
        if (torrent != nil) {
            [torrents addObject:torrent]; 
        }
    }
    
    // Anyway, add torcache link as a backup plan
    NSString *magnetHash = [TorrentzParser getHashFromTorrentzURL:aTorrentzURL];
    [torrents addObject:[TSTorrentFunctions getTorrentFileFromMagnetHash:magnetHash]];
    
    return torrents;
}

+ (NSString *) getTorrentFromTracker:(NSString*)theURL withLinkMatcher:(NSString*)theLinkMatcher appending:(NSString*)aString
{
    // Let's grab this URL content
    NSString *content = [WebsiteFunctions downloadStringFrom:theURL];
    
    // Get all the URLs
    NSArray *tempValues = [content componentsMatchedByRegex:theLinkMatcher];
    
    // Return the first result
    if ([tempValues count] >= 1) {
        return [aString stringByAppendingString:[tempValues objectAtIndex:0]];
    } else {
        return nil;
    }
}

+ (NSString *) getHashFromTorrentzURL:(NSString*)theURL
{
    NSString *magnetHash = [theURL stringByReplacingOccurrencesOfRegex:@".*torrentz.eu/" withString:@""];
    
    return magnetHash;
}

@end
