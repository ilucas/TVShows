//
//  RARBGSearchOperation.h
//  TVShows
//
//  Created by Lucas casteletti on 2/20/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

@import Foundation;
@import AFNetworking;

@interface RARBGSearchOperation : AFHTTPRequestOperation

@property (nonatomic, strong) NSString *search;

+ (NSDictionary *)parameters;

@end
