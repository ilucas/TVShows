//
//  Serie.m
//  TVShows
//
//  Created by Lucas on 25/05/15.
//  Copyright (c) 2015 Víctor Pimentel. All rights reserved.
//

#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

#import <MagicalRecord/MagicalRecord.h>
#import "NSDictionary+Extensions.h"

@implementation Serie

@dynamic banner;
@dynamic country;
@dynamic started;
@dynamic imdb_id;
@dynamic language;
@dynamic name;
@dynamic rating;
@dynamic seriesDescription;
@dynamic status;
@dynamic tvdb_id;
@dynamic tvrage_id;
@dynamic totalseasons;
@dynamic tvRageLink;
@dynamic ended;
@dynamic runtime;
@dynamic network;
@dynamic airtime;
@dynamic airday;
@dynamic timezone;
@dynamic episodes;
@dynamic subscription;

- (void)updateAttributes:(NSDictionary *)attributes {
    self.banner = [attributes objectForKeyOrNil:@"banner"];
    self.country = [attributes objectForKeyOrNil:@"country"];
    self.started = [attributes objectForKeyOrNil:@"started"];
    self.imdb_id = [attributes objectForKeyOrNil:@"imdb_id"];
    self.language = [attributes objectForKeyOrNil:@"language"];
    self.name = [attributes objectForKeyOrNil:@"name"];
    self.rating = [attributes objectForKeyOrNil:@"rating"];
    self.seriesDescription = [attributes objectForKeyOrNil:@"seriesDescription"];
    self.tvdb_id = [attributes objectForKeyOrNil:@"tvdb_id"];
    self.tvrage_id = [attributes objectForKeyOrNil:@"tvrage_id"];
}

@end
