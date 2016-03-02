//
//  RARBGHTTPClient.h
//  TVShows
//
//  Created by Lucas casteletti on 2/26/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

@import Foundation;
@import AFNetworking;

@interface RARBGClient : AFHTTPRequestOperationManager

- (void)search:(NSString *)search;

@end
