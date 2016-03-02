//
//  RARBGHTTPClient.m
//  TVShows
//
//  Created by Lucas casteletti on 2/26/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "RARBGClient.h"
#import "RARBGSearchOperation.h"

//Spec: https://torrentapi.org/apidocs_v2.txt
static NSString * const kBaseURL = @"https://torrentapi.org/pubapi_v2.php";

@interface RARBGClient ()

@property (nonatomic, strong) NSString *token;

@end

@implementation RARBGClient
@synthesize token;

- (void)search:(NSString *)search {
    if (token) {
        // Create a search operation
        RARBGSearchOperation *searchOP = [self searchRequestWithSearch:search];
        
        [searchOP setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id _Nonnull responseObject) {
            
            NSLog(@"Got a serch");
            NSLog(@"%@", responseObject);
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            DDLogError(@"%s Error: %@", __PRETTY_FUNCTION__, error);
        }];
        
        [self.operationQueue addOperation:searchOP];
    } else {
        // When there's no token.
        // 1) Request a token.
        // 2) when the token is received, create a search operation.
        AFHTTPRequestOperation *tokenOP = [self tokenRequest];
        
        [tokenOP setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            token = responseObject[@"token"];
            [self search:search];
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            DDLogError(@"%s Error: %@", __PRETTY_FUNCTION__, error);
        }];
        
        [self.operationQueue addOperation:tokenOP];
    }
}

#pragma mark - Internal

- (RARBGSearchOperation *)searchRequestWithSearch:(NSString *)search {
    NSMutableDictionary *parameters = [[RARBGSearchOperation parameters] mutableCopy];
    [parameters setValue:search forKey:@"search_string"];
    [parameters setValue:self.token forKey:@"token"];
    
    NSError *serializationError = nil;
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:kBaseURL
                                                                  parameters:parameters
                                                                       error:&serializationError];
    
    if (serializationError) {
        DDLogError(@"RARBG Search SerializationError: %@", serializationError);
    }
    
    RARBGSearchOperation *operation = [[RARBGSearchOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    operation.search = search;
    
    return operation;
}

- (AFHTTPRequestOperation *)tokenRequest {
    NSDictionary *parameters = @{@"get_token" : @"get_token"};
    
    NSError *serializationError = nil;
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:kBaseURL
                                                                  parameters:parameters
                                                                       error:&serializationError];
    
    if (serializationError) {
        DDLogError(@"RARBG Token SerializationError: %@", serializationError);
    }
    
    return [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
}

#pragma mark - Init

- (instancetype)init {
    return [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
}

@end
