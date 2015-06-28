//
//  TVRage.h
//  TVShows
//
//  Created by Lucas on 21/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Cocoa;
@import AFNetworking;

@interface TVRage : NSObject

@property (assign, getter=isCancelled) BOOL canceled;

+ (instancetype)sharedInstance;

- (void)getShowListWithCompletionHandler:(void(^)(NSArray *results, NSError *error))handler;
- (void)getShow:(NSNumber *)showid completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)getShowWithEpisodeList:(NSNumber *)showid completionHandler:(void(^)(NSDictionary *result, NSError *error))handler;
- (void)searchForShowWithName:(NSString *)name Detailed:(BOOL)detailed completionHandler:(void(^)(NSArray *results, NSError *error))handler;
- (void)getEipsodeListForShow:(NSNumber *)showid completionHandler:(void(^)(NSArray *results, NSError *error))handler;
- (void)getEipsodeInfoForShow:(NSString *)name Season:(NSInteger)season Episode:(NSInteger)episode completionHandler:(void(^)(NSArray *results, NSError *error))handler;

@end
