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

#import "TVDBRequestOperation.h"
#import "NSMutableURLRequestToken.h"

@interface TVDBRequestOperation ()

@property (readwrite, nonatomic, strong) NSURLRequest *request;

@end

@implementation TVDBRequestOperation
@synthesize request;

#pragma mark - Init

+ (nullable instancetype)GET:(nonnull NSURL *)url parameters:(nullable id)parameters Token:(nullable NSString *)token {
    NSError *serializationError = nil;
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:url.absoluteString
                                                                                parameters:parameters
                                                                                     error:&serializationError];
    
    if (serializationError) {
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, serializationError);
    }
    
    if (token) {
        [request setAuthorizationToken:token];
    }
    
    return [[[self class] alloc] initWithRequest:request];
}

+ (nullable instancetype)POST:(nonnull NSURL *)url parameters:(nullable id)parameters Token:(nullable NSString *)token {
    NSError *serializationError = nil;
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:url.absoluteString
                                                                                parameters:parameters
                                                                                     error:&serializationError];
    
    if (serializationError) {
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, serializationError);
    }
    
    if (token) {
        [request setAuthorizationToken:token];
    }
    
    return [[[self class] alloc] initWithRequest:request];
}

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

#pragma mark - Properties

- (void)setToken:(NSString *)token {
    @synchronized(self) {
        if (![self isExecuting]) {// Only change the token if the operation is not running.
            NSMutableURLRequest *newRequest = [self.request mutableCopy];
            [newRequest setAuthorizationToken:token];
            
            self.request = newRequest;
            _token = token;
        }
    }
}

@end
