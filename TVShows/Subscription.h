//
//  Subscription.h
//  TVShows
//
//  Created by Lucas on 21/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Series;

@interface Subscription : NSManagedObject

@property (nonatomic, retain) id filters;
@property (nonatomic, retain) NSNumber *isEnabled;
@property (nonatomic, retain) NSDate *lastDownloaded;
@property (nonatomic, retain) NSNumber *quality;
@property (nonatomic, retain) Series *serie;

@end
