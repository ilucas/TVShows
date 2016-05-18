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

#import "TVDBAuthenticationOperation.h"
#import "TVDBManager.h"
#import "NSMutableURLRequestToken.h"
#import "AppSecretConstants.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@implementation TVDBAuthenticationOperation

+ (instancetype)request {
    NSError *serializationError = nil;
    NSURL *url = [NSURL URLWithString:@"login" relativeToURL:[TVDBManager baseURL]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:url.absoluteString
                                                                                parameters:@{@"apikey": TVDB_API_KEY}
                                                                                     error:&serializationError];
    
    TVDBAuthenticationOperation *operation = [[TVDBAuthenticationOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return operation;
}

+ (instancetype)refreshToken:(NSString *)token {
    NSError *serializationError = nil;
    NSURL *url = [NSURL URLWithString:@"refresh_token" relativeToURL:[TVDBManager baseURL]];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:url.absoluteString
                                                                                parameters:nil
                                                                                     error:&serializationError];
    
    [request setAuthorizationToken:token];
    
    TVDBAuthenticationOperation *operation = [[TVDBAuthenticationOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return operation;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBAuthenticationOperation * operation, id responseObject))success
                              failure:(void (^)(TVDBAuthenticationOperation * operation, NSError * error))failure {
    
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if (success) {
            @strongify(self)
            success(self, responseObject);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, self.error);
        }
    }];
}

#pragma mark - Properties

- (NSString *)token {
    if (![self isFinished] || [self isCancelled]) return nil;
    
    return self.responseObject[@"token"];
}

- (NSDate *)tokenLife {
    if (![self isFinished] || [self isCancelled]) return nil;
    
    NSString *date = self.response.allHeaderFields[@"Date"];
    
    return [[TVDBAuthenticationOperation dateFormatter] dateFromString:date];
}

#pragma mark - Private

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    });
    return dateFormatter;
}

@end
