//
//  TVRage.m
//  TVShows
//
//  Created by Lucas on 21/04/15.
//  Copyright (c) 2015 Lucas Castelettis. All rights reserved.
//

#import "TVRage.h"
#import <Ono/Ono.h>
#import "AFOnoResponseSerializer.h"

static NSString * const TVRageDefaultLanguage = @"en";
static NSString * const TVRageBaseURL = @"http://services.tvrage.com";

@implementation TVRage

#pragma mark - Async request

- (void)getShowListWithCompletionHandler:(void(^)(NSArray *results, NSError *error))handler {
    NSString *url = [TVRageBaseURL stringByAppendingPathComponent:@"/feeds/show_list.php"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *shows = [[NSMutableArray alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//show" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
            [show setObject:[[element firstChildWithTag:@"name"] stringValue] forKey:@"name"];
            [show setObject:[[element firstChildWithTag:@"country"] stringValue] forKey:@"country"];
            [show setObject:[[element firstChildWithTag:@"status"] numberValue] forKey:@"status"];
            [show setObject:[[element firstChildWithTag:@"id"] numberValue] forKey:@"tvrage_id"];
            
            [shows addObject:show];
        }];
        
        if (!self.isCancelled) {
            handler(shows, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled) {
            handler(nil, error);
        }
    }];
}

- (void)getShow:(NSInteger)showid WithEpisodeList:(BOOL)episodelist completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    
}

- (void)searchForShowWithName:(NSString *)name Detailed:(BOOL)detailed completionHandler:(void(^)(NSArray *results, NSError *error))handler {
    
}

- (void)getEipsodeListForShow:(NSNumber *)showid completionHandler:(void(^)(NSArray *results, NSError *error))handler {
    
}

- (void)getEipsodeInfoForShow:(NSString *)name Season:(NSInteger)season Episode:(NSInteger)episode completionHandler:(void(^)(NSArray *results, NSError *error))handler {
    
}

@end
