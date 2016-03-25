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

#import "TVDBEpisodesOperation.h"
#import "TVDBEpisode.h"
#import "TVDBManager.h"
#import "NSMutableURLRequestToken.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@interface TVDBEpisodesOperation ()

@property (readwrite, nonatomic, strong) NSNumber *serieID;

@end

@implementation TVDBEpisodesOperation

// All episodes for a given series. Paginated with 100 results per page.
+ (instancetype)requestEpisodesForSerie:(NSNumber *)serieID WithToken:(NSString *)token {
    return [self requestEpisodesForSerie:serieID WithToken:token Page:@1];
}

// All episodes for a given series. Paginated with 100 results per page.
+ (instancetype)requestEpisodesForSerie:(NSNumber *)serieID WithToken:(NSString *)token Page:(NSNumber *)page {
    NSString *rawURL = [@"series" stringByAppendingPathComponent:serieID.stringValue];
    NSURL *url = [NSURL URLWithString:rawURL relativeToURL:[TVDBManager baseURL]];
    
    TVDBEpisodesOperation *operation = [TVDBEpisodesOperation GET:url parameters:@{@"page": page} Token:token];
    operation.serieID = serieID;
    
    return operation;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBEpisodesOperation * operation, NSArray <TVDBEpisode *> *episodes))success
                              failure:(void (^)(TVDBEpisodesOperation * operation, NSError * error))failure {

    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (!success) return;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            __block NSMutableArray <TVDBEpisode *> *results = [NSMutableArray array];
            
            [responseObject[@"data"] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @autoreleasepool {
                    NSError *error = nil;
                    TVDBEpisode *episode = [TVDBEpisode modelFromJSONDictionary:obj error:&error];
                    
                    if (error) {
                        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
                    } else {
                        [results addObject:[episode copy]];
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
