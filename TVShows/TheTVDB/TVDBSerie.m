/*
 *  This file is part of the TVShows source code.
 *  http://github.com/ilucas/TVShows
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

#import "TVDBSerie.h"

@implementation TVDBSerie

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"seriesID": @"id",
            @"name": @"seriesName",
            @"status": @"status",
            @"network": @"network",
            @"networkID": @"networkID",
            @"runtime": @"runtime",
            @"genre": @"genre",
            @"overview": @"overview",
            @"lastUpdated": @"lastUpdated",
            @"airDay": @"airsDayOfWeek",
            @"airTime": @"airsTime",
            @"rating": @"siteRating",
            @"imdbId": @"imdbId",
            @"banner": @"banner"
            };
}

#pragma mark - MTLManagedObjectSerializing

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{};
}

+ (NSString *)managedObjectEntityName {
    return @"";
}

#pragma mark - JSON Value Transformers

+ (NSValueTransformer *)ratingJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSDecimalNumber *decimalRating = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
        float finalRating = [decimalRating floatValue] / 2;// TVDB Rating is up to 10, we divide by 2 to have a 5 stars reating.
        
        if (isnan(finalRating)) finalRating = 0.0;// set 0 to finalRating if the value is not a number.
        
        return [NSNumber numberWithFloat:finalRating];
    }];
}

+ (NSValueTransformer *)genreJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *value, BOOL *success, NSError *__autoreleasing *error) {
        NSArray *genres = [value subarrayWithRange:NSMakeRange(0, MIN(3, value.count))]; // Only show 3 genres.
        return [genres componentsJoinedByString:@", "];
    }];
}

@end
