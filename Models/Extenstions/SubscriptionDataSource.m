//
//  SubscriptionDataSource.m
//  TVShows
//
//  Created by Lucas Casteletti on 1/24/16.
//  Copyright © 2016 Lucas Casteletti. All rights reserved.
//

#import "SubscriptionDataSource.h"
#import "Serie.h"

@import Quartz;

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
    //default = OEGridViewCellIndicationTypeNone
    //1, 3 = OEGridViewCellIndicationTypeProcessing
    //2 = OEGridViewCellIndicationTypeFileMissing
    
    return 0;
//    return self.isEnabledValue;
}

- (NSUInteger)gridRating {
    return self.serie.rating.unsignedIntegerValue;
}

- (void)setGridTitle:(NSString *)str {
    
}

- (void)setGridRating:(NSUInteger)newRating {
    DDLogInfo(@"Got a new rating (%ld stars) for show: %@", newRating, self.serie.name);
    
    self.serie.rating = @(newRating);
    [self.managedObjectContext save:nil];
}

- (BOOL)shouldIndicateDeletable {
    return false;
}

- (BOOL)shouldIndicateDownloadable {
    return false;
}

@end
