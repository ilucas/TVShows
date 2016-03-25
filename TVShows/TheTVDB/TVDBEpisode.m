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

#import "TVDBEpisode.h"
#import "Episode.h"

@implementation TVDBEpisode

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"episodeID": @"id",
             @"episode": @"airedEpisodeNumber",
             @"season": @"airedSeason",
             @"number": @"absoluteNumber",
             @"airDate": @"firstAired",
             @"name": @"episodeName",
             @"overview": @"overview",
             };
}

#pragma mark - MTLManagedObjectSerializing

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{
             @"episodeID": @"episodeID",
             @"episode": @"episode",
             @"season": @"season",
             @"number": @"number",
             @"airDate": @"airDate",
             @"name": @"name",
             @"overview": @"overview",
             };
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"episodeID"];
}

+ (NSString *)managedObjectEntityName {
    return [Episode entityName];
}

#pragma mark - MTLManagedObjectAdapter

- (id)insertManagedObjectIntoContext:(NSManagedObjectContext *)context error:(NSError * _Nullable __autoreleasing *)error {
    return [MTLManagedObjectAdapter managedObjectFromModel:self insertingIntoContext:context error:error];
};

#pragma mark - JSON Value Transformers

+ (NSValueTransformer *)airDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *airDate, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:airDate];
    }];
}

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
