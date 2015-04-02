/*
 *  This file is part of the TVShows 2 ("Phoenix") source code.
 *  http://github.com/victorpimentel/TVShows/
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "AppInfoConstants.h"

#import "TheTVDB.h"
#import "RegexKitLite.h"
#import "WebsiteFunctions.h"

#define TVDB_SEARCH @"http://www.thetvdb.com/api/GetSeries.php?seriesname=%@&language=all"

@implementation TheTVDB

+ (NSString *) applicationCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    basePath = [basePath stringByAppendingPathComponent:@"TVShows 2"];
    return [basePath stringByAppendingPathComponent:@"Cache"];
}

+ (NSString *) getIDForShow:(NSString *)showName
{
    NSString *seriesURL = [NSString stringWithFormat:TVDB_SEARCH,
                           [showName stringByReplacingOccurrencesOfRegex:@" " withString:@"+"]];
    NSString *seriesInfo = [WebsiteFunctions downloadStringFrom:seriesURL];
    
    // For now select the first show in the list that's returned.
    NSArray *tempArray = [seriesInfo componentsMatchedByRegex:@"(?!<seriesid>)(\\d|\n|\r)*?(?=</seriesid>)"];
    if ([tempArray count] >= 1) {
        return [tempArray objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (NSString *) getValueForKey:(NSString *)key withShowID:(NSString *)seriesID andShowName:(NSString *)show
{
    // TODO: Save the information returned for each series into the Cache.
    // TODO: Get the TVDB ID from the Subscriptions file.
    
    // Check to see if we already know the show's ID. If we don't then we need to search for it.
    if ([seriesID length] == 0 || [seriesID isEqualToString:@"(null)"] || [seriesID isEqualToString:@"0"]) {
        seriesID = [self getIDForShow:show];
    }
    
    // Only proceed if we received a series ID from somewhere above...
    if ([seriesID length] > 0 && ![seriesID isEqualToString:@"0"]) {
        // Now let's grab complete info for the show using our API key.
        // TODO: Grab the correct localization.
        NSString *seriesURL = [NSString stringWithFormat:@"http://www.thetvdb.com/api/%@/series/%@/en.xml",TVDB_API_KEY,seriesID];
        NSString *seriesInfo = [WebsiteFunctions downloadStringFrom:seriesURL];
        
        // Regex fun...
        key = [NSString stringWithFormat:@"<%@>(.|\n|\r)*?</%@>",key,key];
        NSArray *tempValue = [seriesInfo componentsMatchedByRegex:key];
        if ( [tempValue count] >= 1 ) {
            NSString *value = [tempValue objectAtIndex:0];
            value = [value stringByReplacingOccurrencesOfRegex:@"<(.+?)>" withString:@""];
            
            return value;
        } else {
            return NULL;
        }

    } else {
        return NULL;
    }
}

+ (NSArray *) getValuesForKey:(NSString *)key withShowID:(NSString *)seriesID andShowName:(NSString *)show
{
    // TODO: Save the information returned for each series into the Cache.
    // TODO: Get the TVDB ID from the Subscriptions file.
    // Quick dirty code mostly copied from the previous method, it should be refactored
    
    // Check to see if we already know the show's ID. If we don't then we need to search for it.
    if ([seriesID length] == 0 || [seriesID isEqualToString:@"(null)"] || [seriesID isEqualToString:@"0"]) {
        seriesID = [self getIDForShow:show];
    }
    
    // Only proceed if we received a series ID from somewhere above...
    if ([seriesID length] > 0 && ![seriesID isEqualToString:@"0"]) {
        // Now let's grab complete info for the show using our API key.
        // TODO: Grab the correct localization.
        NSString *seriesURL = [NSString stringWithFormat:@"http://www.thetvdb.com/api/%@/series/%@/all/en.xml",TVDB_API_KEY,seriesID];
        NSString *seriesInfo = [WebsiteFunctions downloadStringFrom:seriesURL];
        
        // Regex fun...
        key = [NSString stringWithFormat:@"<%@>(.|\n|\r)*?</%@>",key,key];
        NSArray *tempValues = [seriesInfo componentsMatchedByRegex:key];
        if ( [tempValues count] >= 1 ) {
            NSMutableArray *values = [[[NSMutableArray alloc] initWithCapacity:[tempValues count]] autorelease];
            
            for (NSString *value in tempValues) {
                [values addObject:[value stringByReplacingOccurrencesOfRegex:@"<(.+?)>" withString:@""]];
            }
            
            return values;
        } else {
            return NULL;
        }
        
    } else {
        return NULL;
    }
}

+ (NSString *) getShowStatus:(NSString *)showName withShowID:(NSString *)seriesID
{
    // Grab the show's status.
    NSString *status = [self getValueForKey:@"Status" withShowID:seriesID andShowName:showName];
    
    // If no known status was returned...
    if (status == NULL) {
        status = @"Unknown";
    }
    
    return status;
}

+ (NSDate *) getShowNextEpisode:(NSString *)showName withShowID:(NSString *)seriesID
{
    // Preset date formatter
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *now = [NSDate date];
    NSDate *date = nil;
    
    // Grab the show's dates for all episodes
    for (NSString *value in [self getValuesForKey:@"FirstAired" withShowID:seriesID andShowName:showName]) {
        
        date = [dateFormatter dateFromString:value];
        
        // The first date that is after now is the very first unaired episode
        if ([date isGreaterThan:now]) {
            return date;
        }
    }
    
    // There is no known unaired episode ::sadface::
    return nil;
}

+ (NSImage *) getPosterForShow:(NSString *)showName withShowID:(NSString *)seriesID withHeight:(float)height withWidth:(float)width
{
    // If the TVShows cache directory doesn't exist then create it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationCacheDirectory = [self applicationCacheDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationCacheDirectory isDirectory:NULL] ) {
        if (![fileManager createDirectoryAtPath:applicationCacheDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            LogError(@"Error creating application cache directory: %@",error);
            return nil;
        }
    }
    
    // If the image already exists then return the data, otherwise we need to download it.
    NSString *imagePath = [[[self applicationCacheDirectory] stringByAppendingPathComponent:showName] stringByAppendingFormat:@".jpg"];
    
    if ([fileManager fileExistsAtPath:imagePath]) {
        NSImage *sourceImage = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
        NSImage *finalImage = [[[NSImage alloc] initWithSize: NSMakeSize(width, height)] autorelease];
        
        NSSize originalSize = [sourceImage size];
        
        // Resize the cached image so that it fits the actual situation.
        [finalImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawInRect: NSMakeRect(0, 0, width, height)
                       fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height)
                      operation: NSCompositeSourceOver fraction: 1.0];
        [finalImage unlockFocus];
        
        return finalImage;
    } else {
        // Grab the URL of the show poster
        NSImage *sourceImage;
        NSString *posterURL = [self getValueForKey:@"poster" withShowID:seriesID andShowName:showName];
        
        // If a poster URL was returned, download the image.
        if (posterURL != NULL) {
            sourceImage = [[[NSImage alloc] initWithData:
                            [WebsiteFunctions downloadDataFrom:
                             [NSString stringWithFormat:@"http://thetvdb.com/banners/_cache/%@", posterURL]]] autorelease];
        } else {
            sourceImage = [[[NSImage alloc] initWithContentsOfFile:
                            [[NSBundle bundleWithIdentifier: TVShowsAppDomain] pathForResource: @"posterArtPlaceholder"
                                                                                        ofType: @"jpg"]] autorelease];
        }
        
        // Resize the show poster so that it scales smoothly and still fits the box.
        NSImage *resizedImage = [[[NSImage alloc] initWithSize: NSMakeSize(129, 187)] autorelease];
        NSImage *finalImage = [[[NSImage alloc] initWithSize: NSMakeSize(width, height)] autorelease];
        
        NSSize originalSize = [sourceImage size];
        
        [resizedImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawInRect: NSMakeRect(0, 0, 129, 187)
                       fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height)
                      operation: NSCompositeSourceOver fraction: 1.0];
        [resizedImage unlockFocus];
        
        // If a poster URL was returned, save the image so that it's not downloaded again.
        if (posterURL != NULL) {
            // Turn the NSImage into an NSData TIFFRepresentation. We do this since
            // it will always work, no matter what the source image's type is.
            NSData *imageData = [resizedImage TIFFRepresentation];

            // Now it's safe to turn the NSData into an NSBitmapImageRep...
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            
            // From BitmapImageRep we can turn it into anything we want. Here, we're using a JPEG.
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject: [NSNumber numberWithFloat:0.8]
                                                                   forKey: NSImageCompressionFactor];
            NSData *resizedData = [imageRep representationUsingType: NSJPEGFileType
                                                         properties: imageProps];
            
            // The conversion is done, so save it to the disk.
            [resizedData writeToFile:imagePath atomically:YES];
        }
        
        // Now we need to resize the image in memory one last time so that it fits the actual situation.
        [finalImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawInRect: NSMakeRect(0, 0, width, height)
                       fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height)
                      operation: NSCompositeSourceOver fraction: 1.0];
        [finalImage unlockFocus];
        
        return finalImage;
    }
}

+ (void) removePosterForShow:(NSString *)showName
{
    NSString *imagePath = [[[self applicationCacheDirectory] stringByAppendingPathComponent:showName] stringByAppendingFormat:@".jpg"];
    
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}
@end
