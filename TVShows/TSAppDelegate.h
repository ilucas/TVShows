//
//  TSAppDelegate.h
//  TVShows
//
//  Created by Lucas Casteletti on 2/9/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

@import Foundation;

@interface TSAppDelegate : NSObject

- (void)setupLogging;
- (void)setupCoreData;

- (NSUserDefaults *)sharedUserDefaults;

@end
