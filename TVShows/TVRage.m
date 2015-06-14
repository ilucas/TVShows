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
#import "NSMutableDictionary+Extensions.h"

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
            @autoreleasepool {
                NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
                
                [show addObject:[[element firstChildWithTag:@"name"] stringValue] key:@"name"];
                [show addObject:[[element firstChildWithTag:@"country"] stringValue] key:@"country"];
                //[show addObject:[[element firstChildWithTag:@"status"] numberValue] key:@"status"];
                [show addObject:[[element firstChildWithTag:@"id"] numberValue] key:@"tvrage_id"];
                [shows addObject:[show copy]];
            }
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
            *stop = true;// in case the return has multiples Show nodes.
            
            [element.document.dateFormatter setDateFormat:@"MM/dd/yyyy"];
            
            [show addObject:[[element firstChildWithTag:@"name"] stringValue] key:@"name"];
            [show addObject:[[element firstChildWithTag:@"totalseasons"] numberValue] key:@"totalseasons"];
            [show addObject:[[element firstChildWithTag:@"image"] stringValue] key:@"banner"];
            [show addObject:[[element firstChildWithTag:@"showlink"] stringValue] key:@"tvRageLink"];
            [show addObject:[[element firstChildWithTag:@"started"] dateValue] key:@"started"];
            [show addObject:[[element firstChildWithTag:@"ended"] dateValue] key:@"ended"];
            [show addObject:[[element firstChildWithTag:@"status"] stringValue] key:@"status"];
            [show addObject:[[element firstChildWithTag:@"runtime"] numberValue]  key:@"runtime"];
            [show addObject:[[element firstChildWithTag:@"network"] stringValue] key:@"network"];
            [show addObject:[[element firstChildWithTag:@"airtime"] stringValue] key:@"airtime"];
            [show addObject:[[element firstChildWithTag:@"airday"] stringValue] key:@"airday"];
            [show addObject:[[element firstChildWithTag:@"timezone"] stringValue] key:@"timezone"];
            
            // Genres
            NSMutableArray __block *genres = [NSMutableArray arrayWithCapacity:2];
            
            [[[element firstChildWithTag:@"genres"] children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (idx < 2)// only get the first 2 genres.
                    [genres addObject:[obj stringValue]];
                else
                    *stop = true;// stop if idx is higher than 1
            }];
            
            [show addObject:[genres componentsJoinedByString:@", "] key:@"genre"];
            
            // Episode List
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
                        
                        [episode addObject:season key:@"season"];
                        [episode addObject:[[episodeElement firstChildWithTag:@"seasonnum"] numberValue] key:@"episode"];
                        [episode addObject:[[episodeElement firstChildWithTag:@"epnum"] numberValue] key:@"number"];
                        [episode addObject:[[episodeElement firstChildWithTag:@"link"] stringValue] key:@"tvRageLink"];
                        [episode addObject:[[episodeElement firstChildWithTag:@"title"] stringValue] key:@"name"];
                        [episode addObject:[[episodeElement firstChildWithTag:@"airdate"] dateValue] key:@"airDate"];
                        
                        // Add the episode to the episodes array.
                        [episodes addObject:[episode copy]];
                    }
                }];
            }];
            
            // Add the epidodes to the show
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
