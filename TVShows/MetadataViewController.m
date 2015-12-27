//
//  MetadataViewController.m
//  TVShows
//
//  Created by Lucas Casteletti on 12/25/15.
//  Copyright © 2015 Lucas Casteletti. All rights reserved.
//

#import "MetadataViewController.h"
#import "Serie.h"
#import "TheTVDB.h"

@implementation MetadataViewController

- (void)updateShowInfo:(Serie *)serie {
    
    if (!serie) {
        [self resetView];
        return;
    }
    
    // Get the poster
    [[TheTVDB sharedInstance] getPosterForShow:serie completionHandler:^(NSImage *poster, NSNumber *showID) {
        NSDictionary *selectedShow = [self.delegate selectedShow];
        
        if (selectedShow) {
            NSNumber *selectedObjectID = [[self.delegate selectedShow] objectForKey:@"tvdb_id"];
             
            // Only set the poster if the selected item id is equal to poster id.
            if ([selectedObjectID isEqualToNumber:showID]) {
                [self.showPoster setImage:poster];
            }
        }
    }];
    
    //    NSImage *ea = [NSImage imageNamed:@"ea"];
    //    [self.studioLogo setImage:ea];
    
    [self.showName setStringValue:(serie.name ?: @"")];
    [self.genre setStringValue:(serie.genre ?: @"")];
    [self.rating setDoubleValue:[serie.rating doubleValue]];// if rating is null doubleValue will return 0.
    [self.showDescription setString:(serie.seriesDescription ?: @"Description not avaible!")];
    
    NSString *runtime = (serie.runtime ? [[serie.runtime stringValue] stringByAppendingString:@" Min"] : @"");
    [self.showDuration setStringValue:runtime];
    
    if (serie.started) {
        NSInteger year = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:serie.started] year];
        [self.showYear setStringValue:[NSString stringWithFormat:@"%ld", year]];
    } else {
        [self.showYear setStringValue:@""];
    }
    
}

- (void)resetView {
    [self.showName setStringValue:@""];
    [self.genre setStringValue:@""];
    [self.rating setIntegerValue:0];
    [self.showDescription setString:@""];
    [self.showYear setStringValue:@""];
    [self.showDuration setStringValue:@""];
    [self.showPoster setImage:[NSImage imageNamed:@"posterArtPlaceholder"]];
    //[self.studioLogo setImage:nil];
}

- (void)toggleLoading:(BOOL)isLoading {
    if (isLoading) {
        [self.dataBox setHidden:YES];
        [self.loadingText setHidden:NO];
        [self.spinner setHidden:NO];
        [self.spinner startAnimation:nil];
    } else {
        [self.dataBox setHidden:NO];
        [self.loadingText setHidden:YES];
        [self.spinner setHidden:YES];
        [self.spinner stopAnimation:nil];
    }
}

@end
