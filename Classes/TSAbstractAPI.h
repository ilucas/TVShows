//
//  TSAbstractAPI.h
//  TVShows
//
//  Created by Lucas on 25/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Foundation;

@interface TSAbstractAPI : NSObject
@property (assign, getter=isCancelled) BOOL canceled;

+ (instancetype)sharedInstance;

@end
