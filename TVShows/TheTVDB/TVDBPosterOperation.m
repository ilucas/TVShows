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

#import "TVDBPosterOperation.h"
#import "TVDBManager.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@interface TVDBPosterOperation ()

@property (readwrite, nonatomic, nullable) NSNumber *serieID;
@property (readwrite, nonatomic, nullable) NSArray<NSDictionary *> *posters;

@end

@implementation TVDBPosterOperation

+ (nullable instancetype)requestPoster:(NSNumber *)serieID WithToken:(nullable NSString *)token {
    NSString *rawURL = [NSString stringWithFormat:@"/series/%@/images/query", serieID];
    NSURL *url = [NSURL URLWithString:rawURL relativeToURL:[TVDBManager baseURL]];
    
    TVDBPosterOperation *operation = [TVDBPosterOperation GET:url
                                                     parameters:@{@"keyType": @"poster"}
                                                          Token:token];
    operation.serieID = serieID;
    
    return operation;
}

#pragma mark - Properties

- (NSArray<NSDictionary *> *)posters {
    @synchronized(self) {
        if (!_posters && [self isFinished] && !self.error) {
            _posters = self.responseObject[@"data"];
        }
    }
    return _posters;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBRequestOperation *, NSArray<NSDictionary *> *posters))success
                              failure:(void (^)(TVDBRequestOperation *, NSError *))failure {
    
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (success) {
            @strongify(self)
            success(self, self.posters);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, self.error);
        }
    }];
}

@end
