//
//  Serie.m
//  TVShows
//
//  Created by Lucas on 25/05/15.
//  Copyright (c) 2015 Lucas Casteletti. All rights reserved.
//

#import "Serie.h"
#import "Episode.h"
#import "Subscription.h"

#import <MagicalRecord/MagicalRecord.h>
#import "NSDictionary+Extensions.h"

@implementation Serie

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
