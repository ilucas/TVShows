//
//  Series.m
//  TVShows
//
//  Created by Lucas on 21/04/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

@import MagicalRecord;
#import "NSDictionary+Extensions.h"


@implementation Serie

@dynamic banner;
@dynamic country;
@dynamic firstAired;
@dynamic imdb_id;
@dynamic language;
@dynamic name;
@dynamic rating;
@dynamic seriesDescription;
@dynamic status;
@dynamic tvdb_id;
@dynamic tvrage_id;
@dynamic episodes;
@dynamic subscription;

- (void)updateAttributes:(NSDictionary *)attributes {
    self.banner = [attributes objectForKeyOrNil:@"banner"];
    self.country = [attributes objectForKeyOrNil:@"country"];
    self.firstAired = [attributes objectForKeyOrNil:@"firstAired"];
    self.imdb_id = [attributes objectForKeyOrNil:@"imdb_id"];
    self.language = [attributes objectForKeyOrNil:@"language"];
    self.name = [attributes objectForKeyOrNil:@"name"];
    self.rating = [attributes objectForKeyOrNil:@"rating"];
    self.seriesDescription = [attributes objectForKeyOrNil:@"seriesDescription"];
    self.status = [attributes objectForKeyOrNil:@"status"];
    self.tvdb_id = [attributes objectForKeyOrNil:@"tvdb_id"];
    self.tvrage_id = [attributes objectForKeyOrNil:@"tvrage_id"];
}

@end
