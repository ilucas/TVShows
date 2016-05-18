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

#import "RARBGClient.h"
#import "RARBGSearchOperation.h"
#import "DelayOperation.h"

//Spec: https://torrentapi.org/apidocs_v2.txt
static NSString * const kBaseURL = @"https://torrentapi.org/pubapi_v2.php";

@interface RARBGClient ()

@property (nonatomic, strong) NSString *token;

@end

@implementation RARBGClient

- (RARBGSearchOperation *)search:(NSString *)search {
    NSMutableURLRequest *request = [self searchRequestWithSearch:search];
    
    RARBGSearchOperation *operation = [[RARBGSearchOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.search = search;
    
    [self setupOperation:operation];
    
    return operation;
}

#pragma mark - Internal

- (NSMutableURLRequest *)searchRequestWithSearch:(NSString *)search {
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
    
    return request;
}

- (void)setupOperation:(RARBGSearchOperation *)operation {
    if (!self.token) {
        // Search in all operation in the queue if there's a token request.
        AFHTTPRequestOperation __block __weak *tokenRequest = nil;
        [self.operationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.name isEqualToString:@"RARBGTokenRequest"]) {
                tokenRequest = obj;
                *stop = true;
            }
        }];
        
        // If no token request found, create one.
        if (!tokenRequest) {
            tokenRequest = [self tokenRequest];
            [self.operationQueue addOperation:tokenRequest];
        }
        
        // Create the adapter to set the token to operation.
        NSBlockOperation *adapter = [NSBlockOperation blockOperationWithBlock:^{
            if (tokenRequest.response.statusCode != 200) {// Not ok.
                DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, tokenRequest.responseString);
                [operation cancel];
                return;
            }
            
            self.token = tokenRequest.responseObject[@"token"];
            
            [operation setRequest:[self searchRequestWithSearch:operation.search]];
        }];
        
        [adapter addDependency:tokenRequest];
        [operation addDependency:adapter];
        
        [self.operationQueue addOperation:adapter];
    }
    
    DelayOperation *delay = [DelayOperation new];
    [delay addDependency:operation];
    
    [self.operationQueue addOperations:@[operation, delay] waitUntilFinished:NO];
}

- (AFHTTPRequestOperation *)tokenRequest {
    NSError *serializationError;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:kBaseURL
                                                                  parameters:@{@"get_token" : @"get_token"}
                                                                       error:&serializationError];
    
    if (serializationError) {
        DDLogError(@"RARBG Token SerializationError: %@", serializationError);
    }
    
    AFHTTPRequestOperation *tokenRequest = [self HTTPRequestOperationWithRequest:request success:nil failure:nil];
    tokenRequest.queuePriority = NSOperationQueuePriorityHigh;
    tokenRequest.name = @"RARBGTokenRequest";
    
    return tokenRequest;
}

#pragma mark - Init

+ (instancetype)manager {
    static RARBGClient *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RARBGClient alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    
    if (self) {
        dispatch_queue_t underlyingQueue = dispatch_queue_create("TVShows.Providers.RARBG.UnderlyingQueue", DISPATCH_QUEUE_SERIAL);
        
        [self.operationQueue setUnderlyingQueue:underlyingQueue];
        [self.operationQueue setMaxConcurrentOperationCount:1];// The api has a 1req/2s limit.
        [self.operationQueue setName:@"TVShows.Providers.RARBG.Queue"];
    }
    
    return self;
}

@end
