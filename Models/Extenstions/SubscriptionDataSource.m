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

#import "SubscriptionDataSource.h"
#import "Serie.h"

#import "OEGridViewCellIndicationLayer.h"

@import Quartz;
@import MagicalRecord;

@implementation Subscription (GridDataSource)

#pragma mark - CoverGridDataSourceItem

- (NSString *)imageUID {
    return self.serie.serieID.stringValue;
}

- (NSString *)imageRepresentationType {
    if (!self.serie.poster) {
        return IKImageBrowserNSImageRepresentationType;
    } else {
        return IKImageBrowserNSURLRepresentationType;
        //return IKImageBrowserPathRepresentationType;
    }
}

- (id)imageRepresentation {
    // If theres no poster in the entity, return a error
    if (!self.serie.poster) {
        return [NSImage imageNamed:@"posterArtPlaceholder"];
    }
    
    NSString *cacheDir = applicationCacheDirectory();
    NSString *imageName = [[self.serie.poster lastPathComponent] stringByDeletingPathExtension];// Remove "/poster" and ".jpg"
    NSString *imagePath = [[cacheDir stringByAppendingPathComponent:imageName] stringByAppendingPathExtension:@"png"];
    
    return [NSURL fileURLWithPath:imagePath isDirectory:NO];
}

- (NSString *)imageTitle {
    return self.serie.name;
}

- (NSString *)imageSubtitle {
    return @"";
}

- (NSInteger)gridStatus {
    return self.isEnabledValue ? OEGridViewCellIndicationTypeNone : OEGridViewCellIndicationTypeDropOn;
}

- (NSUInteger)gridRating {
    return self.serie.rating.unsignedIntegerValue;
}

- (void)setGridTitle:(NSString *)str {
}

- (void)setGridRating:(NSUInteger)newRating {
    DDLogInfo(@"Got a new rating (%ld stars) for show: %@ (%@)", newRating, self.serie.name, self.serie.serieID);
    
    self.serie.rating = @(newRating);
    [self.managedObjectContext MR_saveWithOptions:MRSaveParentContexts completion:nil];
}

- (BOOL)shouldIndicateDeletable {
    return false;
}

- (BOOL)shouldIndicateDownloadable {
    return false;
}

@end
