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

#import "RARBGTorrent.h"

@implementation RARBGTorrent

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"category": @"category",
             @"magnet": @"download",
             @"leechers": @"leechers",
             @"seeders": @"seeders",
             @"episode": @"episode_info.epnum",
             @"season": @"episode_info.seasonnum",
             @"title": @"title"
             };
}

+ (NSValueTransformer *)episodeJSONTransformer {
    return [self numberValueTransformer];
}

+ (NSValueTransformer *)seasonJSONTransformer {
    return [self numberValueTransformer];
}

+ (MTLValueTransformer *)numberValueTransformer {
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        } else {
            return [formatter numberFromString:value];
        }
    }];;
}

@end
