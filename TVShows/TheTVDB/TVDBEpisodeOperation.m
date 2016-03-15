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

#import "TVDBEpisodeOperation.h"
#import "TVDBEpisode.h"
#import "TVDBManager.h"
#import "NSMutableURLRequestToken.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@interface TVDBEpisodeOperation ()

@property (readwrite, nonatomic, strong) NSNumber *episodeID;

@end

@implementation TVDBEpisodeOperation

// Returns the full information for a given episode id.
+ (instancetype)requestEpisode:(NSNumber *)episodeID WithToken:(NSString *)token {
    NSString *rawURL = [@"episodes" stringByAppendingPathComponent:episodeID.stringValue];
    NSURL *url = [NSURL URLWithString:rawURL relativeToURL:[TVDBManager baseURL]];
    
    TVDBEpisodeOperation *operation = [TVDBEpisodeOperation GET:url parameters:nil Token:token];
    operation.episodeID = episodeID;
    
    return operation;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBEpisodeOperation * operation, TVDBEpisode* episode))success
                              failure:(void (^)(TVDBEpisodeOperation * operation, NSError * error))failure {
    
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSError *error;
        TVDBEpisode *episode = [TVDBEpisode modelFromJSONDictionary:responseObject[@"data"] error:&error];
        
        if (error) {
            NSLog(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
        }
        
        if (success) {
            @strongify(self)
            success(self, episode);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, self.error);
        }
    }];
}

@end
