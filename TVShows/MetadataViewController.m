/*
 *  This file is part of the TVShows source code.
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

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
    [[TVDBManager manager] poster:serie completionBlock:^(NSImage * _Nonnull poster, NSNumber * _Nonnull serieID) {
        TVDBSerie *selectedShow = [self.delegate selectedShow];
        
        if (selectedShow) {
            NSNumber *selectedObjectID = selectedShow.serieID;
            
            // Only set the poster if the selected item id is equal to poster id.
            if ([selectedObjectID isEqualToNumber:serieID]) {
                [self.showPoster setImage:poster];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        DDLogError(@"Poster request fail: %@", error);
    }];
    
    //    NSImage *ea = [NSImage imageNamed:@"ea"];
    //    [self.studioLogo setImage:ea];
    
    [self.showName setStringValue:(serie.name ?: @"")];
    [self.genre setStringValue:(serie.genre ?: @"")];
    [self.rating setDoubleValue:[serie.rating doubleValue]];// if rating is null doubleValue will return 0.
    [self.showDescription setString:(serie.overview ?: @"Description not avaible!")];
    
    NSString *runtime = (serie.runtime ? [serie.runtime stringByAppendingString:@" Min"] : @"");
    [self.showDuration setStringValue:runtime];
    
    if (serie.firstAired) {
        NSInteger year = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:serie.firstAired] year];
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
    
    [self toggleLoading:NO];
}

- (void)toggleLoading:(BOOL)isLoading {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        NSLog(@"toggleLoading");
        if (isLoading) {
            [self.dataBox setHidden:YES];
            [self.loadingText setHidden:NO];
            [self.spinner setHidden:NO];
            [self.spinner startAnimation:nil];
            NSLog(@"toggleLoading TRUE");
        } else {
            [self.dataBox setHidden:NO];
            [self.loadingText setHidden:YES];
            [self.spinner setHidden:YES];
            [self.spinner stopAnimation:nil];
            NSLog(@"toggleLoading FALSE");
        }
    
    
    
        
    });

}

@end
