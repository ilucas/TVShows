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
#import "TVDBEpisode.h"
#import "Serie.h"

@implementation TVDBSerie

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"serieID": @"id",
             @"name": @"seriesName",
             @"status": @"status",
             @"network": @"network",
             @"networkID": @"networkID",
             @"runtime": @"runtime",
             @"firstAired": @"firstAired",
             @"genre": @"genre",
             @"overview": @"overview",
             @"lastUpdated": @"lastUpdated",
             @"contentRating": @"rating",
             @"airDay": @"airsDayOfWeek",
             @"airTime": @"airsTime",
             @"rating": @"siteRating",
             @"imdbID": @"imdbId",
             @"banner": @"banner",
             @"episodes": @"episodes"
             };
}

#pragma mark - MTLManagedObjectSerializing

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{
             @"serieID": @"serieID",
             @"name": @"name",
             @"status": @"status",
             @"network": @"network",
             @"runtime": @"runtime",
             @"firstAired": @"firstAired",
             @"genre": @"genre",
             @"overview": @"overview",
             @"lastUpdated": @"lastUpdated",
             @"contentRating": @"contentRating",
             @"airDay": @"airDay",
             @"airTime": @"airTime",
             @"rating": @"rating",
             @"imdbID": @"imdb",
             @"banner": @"poster",
             @"episodes": @"episodes"
             };
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"serieID"];
}

+ (NSString *)managedObjectEntityName {
    return [Serie entityName];
}

#pragma mark - MTLManagedObjectAdapter

- (id)insertManagedObjectIntoContext:(NSManagedObjectContext *)context error:(NSError * _Nullable __autoreleasing *)error {
    return [MTLManagedObjectAdapter managedObjectFromModel:self insertingIntoContext:context error:error];
};

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

+ (NSValueTransformer *)episodesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TVDBEpisode class]];
}

+ (NSValueTransformer *)firstAiredJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *airDate, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:airDate];
    }];
}

//+ (NSValueTransformer *)bannerJSONTransformer {
//    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
//        return [@"https://www.thetvdb.com/banners/_cache/" stringByAppendingPathComponent:value];
//    }];
//}

#pragma mark - NSDateFormatter

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    });
    return dateFormatter;
}

@end
