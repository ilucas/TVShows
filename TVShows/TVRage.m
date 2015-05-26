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

- (void)getShow:(NSNumber *)showid completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
//    NSString *url = [TVRageBaseURL stringByAppendingPathComponent:@"/feeds/showinfo.php"];
//    NSDictionary *parameters = @{@"sid" : [showid stringValue]};
}

- (void)getShowWithEpisodeList:(NSNumber *)showid completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    NSString *url = [TVRageBaseURL stringByAppendingPathComponent:@"/feeds/full_show_info.php"];
    NSDictionary *parameters = @{@"sid" : [showid stringValue]};
    
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//Show" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            [element.document.dateFormatter setDateFormat:@"MM/dd/yyyy"];
            
            [show setObject:[[element firstChildWithTag:@"name"] stringValue] forKey:@"name"];
            [show setObject:[[element firstChildWithTag:@"totalseasons"] numberValue] forKey:@"totalseasons"];
            [show setObject:[[element firstChildWithTag:@"image"] stringValue] forKey:@"banner"];
            [show setObject:[[element firstChildWithTag:@"showlink"] stringValue] forKey:@"tvRageLink"];
            [show setObject:[[element firstChildWithTag:@"started"] dateValue] forKey:@"started"];
            [show setObject:[[element firstChildWithTag:@"ended"] dateValue] forKey:@"ended"];
            [show setObject:[[element firstChildWithTag:@"status"] stringValue] forKey:@"status"];
            [show setObject:[[element firstChildWithTag:@"runtime"] numberValue] forKey:@"runtime"];
            [show setObject:[[element firstChildWithTag:@"network"] stringValue] forKey:@"network"];
            [show setObject:[[element firstChildWithTag:@"airtime"] stringValue] forKey:@"airtime"];
            [show setObject:[[element firstChildWithTag:@"airday"] stringValue] forKey:@"airday"];
            [show setObject:[[element firstChildWithTag:@"timezone"] stringValue] forKey:@"timezone"];
            
            ONOXMLElement *Episodelist = [element firstChildWithTag:@"Episodelist"];
            
            NSMutableArray __block *episodes = [[NSMutableArray alloc] init];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
            
            // Loop thorough all episodes
            [Episodelist enumerateElementsWithXPath:@"//Season" usingBlock:^(ONOXMLElement *seasonElement, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary __block *episode = [[NSMutableDictionary alloc] init];
                
                NSNumber *season = [numberFormatter numberFromString:[seasonElement valueForAttribute:@"no"]];
                
                [seasonElement enumerateElementsWithXPath:@"//episode" usingBlock:^(ONOXMLElement *episodeElement, NSUInteger idx, BOOL *stop) {
                    @autoreleasepool {
                        [episodeElement.document.dateFormatter setDateFormat:@"yyyy-mm-dd"];
                        
                        [episode setObject:season forKey:@"season"];
                        [episode setObject:[[episodeElement firstChildWithTag:@"seasonnum"] numberValue] forKey:@"episode"];
                        [episode setObject:[[episodeElement firstChildWithTag:@"epnum"] numberValue] forKey:@"number"];
                        [episode setObject:[[episodeElement firstChildWithTag:@"link"] stringValue] forKey:@"tvRageLink"];
                        [episode setObject:[[episodeElement firstChildWithTag:@"title"] stringValue] forKey:@"name"];
                        [episode setObject:[[episodeElement firstChildWithTag:@"airdate"] dateValue] forKey:@"airDate"];
                        
                        // Add the episode to the episodes array.
                        [episodes addObject:[episode copy]];
                    }
                }];
            }];
            
            // Add epidodes to the show dictionary
            [show setObject:episodes forKey:@"episodes"];
        }];
        
        if (!self.isCancelled)
            handler(show, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    [operation start];
}

- (void)searchForShowWithName:(NSString *)name Detailed:(BOOL)detailed completionHandler:(void(^)(NSArray *results, NSError *error))handler {
    
}

- (void)getEipsodeListForShow:(NSNumber *)showid completionHandler:(void(^)(NSArray *results, NSError *error))handler {
    
}

- (void)getEipsodeInfoForShow:(NSString *)name Season:(NSInteger)season Episode:(NSInteger)episode completionHandler:(void(^)(NSArray *results, NSError *error))handler {
    
}

@end
