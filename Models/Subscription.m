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

#import "Serie.h"
#import "Subscription.h"
#import "Episode.h"

@implementation Subscription

- (NSString *)searchNameForEpisode:(Episode *)episode {
    NSAssert(episode, @"Episode cannot be nil!");
    
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\((.*?)\\)"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        
        if (error) {
            DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        }
    });
    
    NSString *name = [[regex stringByReplacingMatchesInString:self.serie.name // "House of Cards (US)" -> "House of Cards"
                                                      options:0
                                                        range:self.serie.name.range
                                                  withTemplate:@""] stringByTrimmingWhitespaces];
    
    return [NSString stringWithFormat:@"%@ %@ %@", name, episode.fullEpisodeNumber, self.quality];
}

@end
