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
#import "Episode.h"

@implementation Episode
@synthesize fullEpisodeNumber;

- (NSString *)fullEpisodeNumber {
    if (!fullEpisodeNumber) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMinimumIntegerDigits:2];
        
        NSString *season = [numberFormatter stringFromNumber:self.season];
        NSString *episodeNumber = [numberFormatter stringFromNumber:self.episode];
        
        fullEpisodeNumber = [NSString stringWithFormat:@"S%@E%@", season, episodeNumber];
    }
    
    return fullEpisodeNumber;
}

@end
