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

#import "TheTVDB.h"
#import "AFOnoResponseSerializer.h"

static NSString * const TVDBBaseURL = @"http://www.thetvdb.com";

@implementation TheTVDB

#pragma mark - Async request

- (void)getShow:(NSString *)showName completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    NSString *url = [TVDBBaseURL stringByAppendingPathComponent:@"/api/GetSeries.php"];
    NSDictionary *parameters = @{@"seriesname" : showName};
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//Series" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            *stop = YES; // Stop enumerating. we only need the first value.
            [element.document.dateFormatter setDateFormat:@"yyyy-mm-dd"];
            
            [show setObject:[[element firstChildWithTag:@"id"] numberValue] forKey:@"tvdb_id"];
            [show setObject:([[element firstChildWithTag:@"IMDB_ID"] stringValue] ?: [NSNull null]) forKey:@"imdb_id"];
            [show setObject:[[element firstChildWithTag:@"FirstAired"] dateValue] forKey:@"started"];
            [show setObject:[[element firstChildWithTag:@"language"] stringValue] forKey:@"language"];
            [show setObject:[[element firstChildWithTag:@"SeriesName"] stringValue] forKey:@"name"];
            [show setObject:([[element firstChildWithTag:@"Overview"] stringValue] ?: [NSNull null]) forKey:@"seriesDescription"];
            [show setObject:([[element firstChildWithTag:@"Network"] stringValue] ?: [NSNull null]) forKey:@"network"];
            [show setObject:([[element firstChildWithTag:@"banner"] stringValue] ?: [NSNull null]) forKey:@"banner"];
        }];
        
        if (!self.isCancelled)
            handler(show, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    [operation start];
}

- (void)getShowWithIMDB:(NSString *)serieID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    NSString *url = [TVDBBaseURL stringByAppendingPathComponent:@"/api/GetSeriesByRemoteID.php"];
    NSDictionary *parameters = @{@"imdbid" : serieID};
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//Series" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            *stop = YES; // Stop enumerating. we only need the first value.
            
            [show setObject:[[element firstChildWithTag:@"id"] numberValue] forKey:@"tvdb_id"];
            [show setObject:[[element firstChildWithTag:@"IMDB_ID"] stringValue] forKey:@"imdb_id"];
            [show setObject:[[element firstChildWithTag:@"FirstAired"] stringValue] forKey:@"started"];
            [show setObject:[[element firstChildWithTag:@"language"] stringValue] forKey:@"language"];
            [show setObject:[[element firstChildWithTag:@"SeriesName"] stringValue] forKey:@"name"];
            [show setObject:[[element firstChildWithTag:@"Overview"] stringValue] forKey:@"seriesDescription"];
            [show setObject:[[element firstChildWithTag:@"Network"] stringValue] forKey:@"network"];
            [show setObject:[[element firstChildWithTag:@"banner"] stringValue] forKey:@"banner"];
        }];
        
        if (!self.isCancelled)
            handler(show, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    [operation start];
}

- (void)searchEpisode:(NSString *)aEpisodeNum seasonNum:(NSString *)aSeasonNum ShowID:(NSString *)seriesID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    
}

- (void)getPosterForShow:(NSString *)showName withShowID:(NSString *)seriesID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    
}

@end
