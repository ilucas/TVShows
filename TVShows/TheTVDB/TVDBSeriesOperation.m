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

#import "TVDBSeriesOperation.h"
#import "TVDBSerie.h"
#import "TVDBManager.h"
#import "NSMutableURLRequestToken.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@interface TVDBSeriesOperation ()

@property (readwrite, nonatomic, strong) NSNumber *serieID;

@end

@implementation TVDBSeriesOperation

+ (instancetype)requestSerie:(NSNumber *)serieID WithToken:(NSString *)token {
    NSString *rawURL = [@"series" stringByAppendingPathComponent:serieID.stringValue];
    NSURL *url = [NSURL URLWithString:rawURL relativeToURL:[TVDBManager baseURL]];
    
    TVDBSeriesOperation *operation = [TVDBSeriesOperation GET:url parameters:nil Token:token];
    operation.serieID = serieID;
    
    return operation;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBSeriesOperation * operation, TVDBSerie *serie))success
                              failure:(void (^)(TVDBSeriesOperation * operation, NSError * error))failure {
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (success) {
            NSError *error = nil;
            TVDBSerie *serie = [TVDBSerie modelFromJSONDictionary:responseObject[@"data"] error:&error];
            
            if (error) {
                NSLog(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
            }
            
            @strongify(self)
            success(self, serie);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, self.error);
        }
    }];
}

@end
