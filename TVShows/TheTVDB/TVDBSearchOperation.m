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

#import "TVDBSearchOperation.h"
#import "TVDBSerie.h"
#import "TVDBManager.h"
#import "NSMutableURLRequestToken.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@interface TVDBSearchOperation ()

@property (readwrite, nonatomic, strong) NSString *search;

@end

@implementation TVDBSearchOperation

+ (instancetype)requestWithToken:(NSString *)token SerieName:(NSString *)name {
    NSURL *url = [NSURL URLWithString:@"search/series" relativeToURL:[TVDBManager baseURL]];
    
    TVDBSearchOperation *operation = [TVDBSearchOperation GET:url parameters:@{@"name": name} Token:token];
    operation.search = name;
    
    return operation;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBSearchOperation *operation, NSArray <TVDBSerie *> *series))success
                              failure:(void (^)(TVDBSearchOperation *operation, NSError *error))failure {
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (!success) return;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            __block NSMutableArray <TVDBSerie *> *results = [NSMutableArray array];
            
            [responseObject[@"data"] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @autoreleasepool {
                    NSError *error = nil;
                    TVDBSerie *serie = [TVDBSerie modelFromJSONDictionary:obj error:&error];
                    
                    if (error) {
                        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
                    } else {
                        [results addObject:[serie copy]];
                    }
                }
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                success(self, results);
            });
        });
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, self.error);
        }
    }];
}

@end
