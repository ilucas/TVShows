//
//  Episode.h
//  TVShows
//
//  Created by Lucas on 25/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Serie;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, retain) NSString * episodeDescription;
@property (nonatomic, retain) NSNumber * episodeID;
@property (nonatomic, retain) NSDate * airDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) NSString * tvRageLink;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Serie *serie;

@end
