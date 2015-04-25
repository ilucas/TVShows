//
//  TVRage.m
//  TVShows
//
//  Created by Lucas on 21/04/15.
//  Copyright (c) 2015 Lucas Castelettis. All rights reserved.
//

#import "TVRage.h"
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
            [[element children] enumerateObjectsUsingBlock:^(ONOXMLElement *obj, NSUInteger idx, BOOL *stop){
                [show setObject:[obj stringValue] forKey:[obj tag]];
            }];
            [shows addObject:show];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isCancelled) {
                handler(shows, nil);
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isCancelled) {
                handler(nil, error);
            }
        });
    }];
}

- (void)getShow:(NSInteger)showid WithEpisodeList:(BOOL)episodelist completionHandler:(void(^)(NSDictionary *result))handler {
    //NSString *url = [TVRageBaseURL stringByAppendingPathComponent:@"/feeds/show_list.php"];
    
}

- (void)searchForShowWithName:(NSString *)name Detailed:(BOOL)detailed completionHandler:(void(^)(NSArray *results))handler {
    
}

- (void)getEipsodeListForShow:(NSInteger)showid completionHandler:(void(^)(NSArray *results))handler {
    
}

- (void)getEipsodeInfoForShow:(NSString *)name Season:(NSInteger)season Episode:(NSInteger)episode completionHandler:(void(^)(NSArray *results))handler {
    
}

@end
