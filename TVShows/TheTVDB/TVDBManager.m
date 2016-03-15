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

#import "TVDBSerie.h"
#import "TVDBEpisode.h"

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
    TVDBSeriesOperation __block *operation = [TVDBSeriesOperation requestSerie:serieID WithToken:self.token];
    
    [operation setCompletionBlockWithSuccess:^(TVDBSeriesOperation * _Nonnull operation, TVDBSerie * _Nonnull serie) {
        success(serie);
    } failure:^(TVDBSeriesOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (operation.response.statusCode == 401) {// Not Authorized
            self.token = nil;// Reset token, get a new one.
            [self serie:operation.serieID completionBlock:success failure:failure];
        } else {// Other error
            failure(error);
        }
    }];
    
    [self setupOperation:operation];
    
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

#pragma mark - Private

- (void)setupOperation:(TVDBRequestOperation *)operation {
    if (!self.token) {
        TVDBAuthenticationOperation *tokenRequest = [self requestToken];
        
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
    return [[self alloc] init];
}

- (instancetype)init {
    return [super initWithBaseURL:[self baseURL]];
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
