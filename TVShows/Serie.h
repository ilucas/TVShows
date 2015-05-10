//
//  Series.h
//  TVShows
//
//  Created by Lucas on 21/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Episode, Subscription;

@interface Serie : NSManagedObject

@property (nonatomic, retain) NSString *banner;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSDate *firstAired;
@property (nonatomic, retain) NSString *imdb_id;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSString *seriesDescription;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSNumber *tvdb_id;
@property (nonatomic, retain) NSNumber *tvrage_id;
@property (nonatomic, retain) NSSet *episodes;
@property (nonatomic, retain) Subscription *subscription;
@end

@interface Serie (CoreDataGeneratedAccessors)

- (void)addEpisodesObject:(Episode *)value;
- (void)removeEpisodesObject:(Episode *)value;
- (void)addEpisodes:(NSSet *)values;
- (void)removeEpisodes:(NSSet *)values;


- (void)updateAttributes:(NSDictionary *)attributes;

@end
