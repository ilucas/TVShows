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

#import "RARBGSearchOperation.h"
#import "RARBGTorrent.h"

@import Mantle;

@implementation RARBGSearchOperation
@synthesize search;

+ (NSDictionary *)parameters {
    return @{
             @"mode": @"search",
             @"category": @"tv",
             @"format": @"json_extended",
             @"ranked": @"0"
             };
}

- (void)setCompletionBlockWithSuccess:(nullable void (^)(RARBGSearchOperation *, NSArray<RARBGTorrent *> *))success
                              failure:(nullable void (^)(RARBGSearchOperation *, NSError *))failure {
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (success) {
            @strongify(self)
            
            NSError *error;
            
            NSArray<RARBGTorrent *> *torrents = [MTLJSONAdapter modelsOfClass:[self class]
                                                                fromJSONArray:responseObject[@"torrent_results"]
                                                                        error:&error];
            
            if (error) {
                if (failure) {
                    failure(self, error);
                }
                return;
            }
            
            success(self, torrents);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, error);
        }
    }];
}

- (void)setRequest:(NSMutableURLRequest *)request {
    @synchronized (self) {
        if (![self isExecuting]) {// Only change the token if the operation is not running.
            self.request = request;
        }
    }
}

@end
