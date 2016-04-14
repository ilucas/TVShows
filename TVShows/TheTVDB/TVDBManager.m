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

#import "TVDBManager.h"

#import "TVDBRequestOperation.h"
#import "TVDBAuthenticationOperation.h"
#import "TVDBEpisodeOperation.h"
#import "TVDBEpisodesOperation.h"
#import "TVDBSearchOperation.h"
#import "TVDBSeriesOperation.h"
#import "TVDBUpdatesOperation.h"
#import "TVDBImageOperation.h"
#import "TVDBPosterOperation.h"

#import "TVDBSerie.h"
#import "TVDBEpisode.h"
#import "Serie.h"

// Spec: https://api-beta.thetvdb.com/swagger#/
static NSString * const kBaseURL = @"https://api-beta.thetvdb.com";

@implementation TVDBManager

#pragma mark - Authentication

- (TVDBAuthenticationOperation *)requestToken {
    TVDBAuthenticationOperation *op = [TVDBAuthenticationOperation request];
    
    [op setCompletionBlockWithSuccess:^(TVDBAuthenticationOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.token = operation.token;
        self.tokenLife = operation.tokenLife;
        DDLogDebug(@"Got a token: %@", self.token);
    } failure:^(TVDBAuthenticationOperation * _Nonnull operation, NSError * _Nonnull error) {
        DDLogError(@"Erro: %@", error);
    }];
    
    [self.operationQueue addOperation:op];
    
    return op;
}

- (TVDBAuthenticationOperation *)refreshToken {
    // if the token is older than 1 hour. refresh
    
    TVDBAuthenticationOperation *op = [TVDBAuthenticationOperation refreshToken:self.token];
    
    [op setCompletionBlockWithSuccess:^(TVDBAuthenticationOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.token = operation.token;
        self.tokenLife = operation.tokenLife;
    } failure:^(TVDBAuthenticationOperation * _Nonnull operation, NSError * _Nonnull error) {
        DDLogError(@"Erro: %@", error);
    }];
    
    [self.operationQueue addOperation:op];
    
    return op;
}

#pragma mark - Series

- (TVDBSeriesOperation *)serie:(NSNumber *)serieID completionBlock:(void (^)(TVDBSerie * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    TVDBSeriesOperation *operation = [TVDBSeriesOperation requestSerie:serieID WithToken:self.token];
    
    [operation setCompletionBlockWithSuccess:nil failure:^(TVDBSeriesOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {// Not Authorized
            self.token = nil;// Reset token, get a new one.
            [self serie:operation.serieID completionBlock:success failure:failure];
        } else {// Other error
            failure(error);
        }
    }];
    
    // request serie posters
    TVDBPosterOperation *posterOperation = [TVDBPosterOperation requestPoster:serieID WithToken:self.token];
    
    // Set the poster in the serie model.
    NSBlockOperation *mergeOperation = [NSBlockOperation blockOperationWithBlock:^{
        TVDBSerie *serie = operation.serie;
        if (!serie) return;// Probably some request error.
        
        if (posterOperation.posters.count > 0) {
            NSString *posterName = posterOperation.posters[0][@"fileName"];
            serie.banner = posterName;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            success(serie);
        });
    }];
    
    [mergeOperation addDependency:operation];
    [mergeOperation addDependency:posterOperation];
    
    [self setupOperation:operation];
    [self setupOperation:posterOperation];
    [self.operationQueue addOperation:mergeOperation];
    
    return operation;
}

#pragma mark - Episode

- (TVDBEpisodeOperation *)episode:(NSNumber *)episodeID completionBlock:(void (^)(TVDBEpisode * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    TVDBEpisodeOperation __block *operation = [TVDBEpisodeOperation requestEpisode:episodeID WithToken:self.token];
    
    [operation setCompletionBlockWithSuccess:^(TVDBEpisodeOperation * _Nonnull operation, TVDBEpisode * _Nonnull episode) {
        success(episode);
    } failure:^(TVDBEpisodeOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (operation.response.statusCode == 401) {// Not Authorized
            self.token = nil;// Reset token, get a new one.
            [self episode:operation.episodeID completionBlock:success failure:failure];
        } else {// Other error
            failure(error);
        }
    }];
    
    [self setupOperation:operation];
    
    return operation;
}

#pragma mark - Episodes

- (TVDBEpisodesOperation *)episodes:(NSNumber *)serieID completionBlock:(void (^)(NSArray<TVDBEpisode *> *episodes))success failure:(void (^)(NSError *error))failure {
    TVDBEpisodesOperation *firstRequest = [TVDBEpisodesOperation requestEpisodesForSerie:serieID WithToken:self.token];
    
    // the success block will be called in the mergeOperation.
    [firstRequest setCompletionBlockWithSuccess:nil failure:^(TVDBEpisodesOperation *operation, NSError *error) {
        failure(error);
    }];
    
    NSMutableArray <TVDBEpisodesOperation *> __block *operations = [NSMutableArray arrayWithObject:firstRequest];
    
    // Merge the episodes from all pages.
    // This block will execute after all the pages request is done.
    NSBlockOperation *mergeOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray <TVDBEpisode *> __block *episodes = [NSMutableArray array];
        
        [operations enumerateObjectsUsingBlock:^(TVDBEpisodesOperation *op, NSUInteger idx, BOOL *stop) {
            if (firstRequest.response.statusCode != 200) return;
            
            NSArray <NSDictionary *> *data = op.responseObject[@"data"];
            
            // Enumerate episodes
            [data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    NSError *error = nil;
                    TVDBEpisode *episode = [TVDBEpisode modelFromJSONDictionary:obj error:&error];
                    
                    if (error) {
                        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, error);
                    } else {
                        [episodes addObject:[episode copy]];
                    }
                }
            }];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            success(episodes);
        });
    }];
    
    // If there's more then 1 page, create a request for each page.
    // This block will execute after the firstRequest.
    NSBlockOperation *pagesOperation = [NSBlockOperation blockOperationWithBlock:^{
        if (firstRequest.response.statusCode != 200) return;
        
        NSDictionary *response = firstRequest.responseObject;
        NSNumber *totalPages = response[@"links"][@"last"];
        
        // Ignoring the first page, create a request for each page.
        [@2 upto:totalPages.intValue do:^(NSInteger number) {
            TVDBEpisodesOperation *request = [TVDBEpisodesOperation requestEpisodesForSerie:serieID WithToken:self.token Page:@(number)];
            [mergeOperation addDependency:request];
            [operations addObject:request];
            [self.operationQueue addOperation:request];
        }];
        
        [self.operationQueue addOperation:mergeOperation];
    }];
    
    [self setupOperation:firstRequest];
    
    [pagesOperation addDependency:firstRequest];
    [self.operationQueue addOperation:pagesOperation];
    
    return firstRequest;
}

#pragma mark - Search

- (TVDBSearchOperation *)searchSerie:(NSString *)name completionBlock:(void (^)(NSArray<TVDBSerie *> *series))success failure:(void (^)(NSError *error))failure {
    TVDBSearchOperation __block *operation = [TVDBSearchOperation requestWithToken:self.token SerieName:name];
    
    [operation setCompletionBlockWithSuccess:^(TVDBSearchOperation * _Nonnull operation, NSArray<TVDBSerie *> * _Nonnull series) {
        success(series);
    } failure:^(TVDBSearchOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (operation.response.statusCode == 401) {// Not Authorized
            self.token = nil;// Reset token, get a new one.
            [self searchSerie:operation.search completionBlock:success failure:failure];
        } else {// Other error
            failure(error);
        }
    }];
    
    [self setupOperation:operation];
    
    return operation;
}

#pragma mark - Poster

- (TVDBImageOperation *)poster:(Serie *)serie
               completionBlock:(void (^)(NSImage *, NSNumber *))success
                       failure:(void (^)(NSError *))failure {
    
    NSNumber *serieID = serie.serieID;
    
    // If theres no poster in the entity, return a error
    if (!serie.poster) {
        NSImage *placeholder = [NSImage imageNamed:@"posterArtPlaceholder"];
        success(placeholder, serieID);
        return nil;
    }
    
    TVDBImageOperation *operation = [TVDBImageOperation requestImage:serie.poster
                                          CompletionBlockWithSuccess:^(TVDBImageOperation *operation, NSImage *poster) {
                                              success(poster, serieID);
                                          } failure:^(TVDBImageOperation *operation, NSError *error) {
                                              failure(error);
                                          }];
    
    // Image request don't need token;
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - Private

- (void)setupOperation:(TVDBRequestOperation *)operation {
    if (!self.token) {
        // Search in all operation in the queue if there's a token request.
        TVDBAuthenticationOperation __block __weak *tokenRequest = nil;
        [self.operationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[TVDBAuthenticationOperation class]]) {
                tokenRequest = obj;
                *stop = true;
            }
        }];
        
        // If no token request found, create one.
        if (!tokenRequest) {
            tokenRequest = [self requestToken];
        }
        
        // Create the adapter to set the token to operation.
        NSBlockOperation *adapter = [NSBlockOperation blockOperationWithBlock:^{
            if (tokenRequest.response.statusCode == 200) {
                operation.token = tokenRequest.token;
            } else {
                // No token, no request.
                [operation cancel];
            }
        }];
        
        [adapter addDependency:tokenRequest];
        [operation addDependency:adapter];
        
        [self.operationQueue addOperation:adapter];
    }
    
    [self.operationQueue addOperation:operation];
}

#pragma mark - Init

+ (instancetype)manager {
    static TVDBManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TVDBManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super initWithBaseURL:[self baseURL]];
    
    if (self) {
        //[self.operationQueue setMaxConcurrentOperationCount:1];
        [self.operationQueue setName:@"com.TVShows.TVDB.Queue"];
    }
    
    return self;
}

+ (NSURL *)baseURL {
    static NSURL *url = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        url = [NSURL URLWithString:kBaseURL];
    });
    
    return url;
}

@end
