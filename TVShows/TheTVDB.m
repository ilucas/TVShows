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

#import "TheTVDB.h"
#import <Ono/Ono.h>
#import "AFOnoResponseSerializer.h"
#import "AppSecretConstants.h"
#import "NSMutableDictionary+Extensions.h"
#import "Serie.h"

static NSString * const TVDBBaseURL = @"http://www.thetvdb.com";
static NSNumber * parseRating(NSString *rating);

@interface TheTVDB ()

@end

@implementation TheTVDB
@synthesize queue;

#pragma mark - LifeCycle

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setCanceled:NO];
        queue = [[NSOperationQueue alloc] init];
        //[queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)cancel {
    [self setCanceled:YES];
}

#pragma mark - Async request

- (void)searchShow:(NSString *)showName completionHandler:(void(^)(NSArray *result, NSError *error))handler {
    NSString *url = [TVDBBaseURL stringByAppendingPathComponent:@"/api/GetSeries.php"];
    NSDictionary *parameters = @{@"seriesname" : showName};
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray __block *result = [[NSMutableArray alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//Series" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
            [element.document.dateFormatter setDateFormat:@"yyyy-mm-dd"];
            
            [show addObject:[[element firstChildWithTag:@"seriesid"] numberValue] key:@"tvdb_id"];
            [show addObject:[[element firstChildWithTag:@"IMDB_ID"] stringValue] key:@"imdb_id"];
            [show addObject:[[element firstChildWithTag:@"FirstAired"] dateValue] key:@"started"];
            [show addObject:[[element firstChildWithTag:@"language"] stringValue] key:@"language"];
            [show addObject:[[element firstChildWithTag:@"SeriesName"] stringValue] key:@"name"];
            [show addObject:[[element firstChildWithTag:@"Overview"] stringValue] key:@"seriesDescription"];
            [show addObject:[[element firstChildWithTag:@"Network"] stringValue] key:@"network"];
            [show addObject:[[element firstChildWithTag:@"banner"] stringValue] key:@"banner"];
        
            [result addObject:[show copy]];
        }];
    
        if (!self.isCancelled)
            handler(result, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    //[operation start];
    [queue addOperation:operation];
}

- (void)getShow:(NSString *)showName completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    NSString *url = [TVDBBaseURL stringByAppendingPathComponent:@"/api/GetSeries.php"];
    NSDictionary *parameters = @{@"seriesname" : showName};
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//Series" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            *stop = YES; // Stop enumerating. we only need the first value.
            [element.document.dateFormatter setDateFormat:@"yyyy-mm-dd"];
            
            [show setObject:[[element firstChildWithTag:@"seriesid"] numberValue] forKey:@"tvdb_id"];
            [show setObject:([[element firstChildWithTag:@"IMDB_ID"] stringValue] ?: [NSNull null]) forKey:@"imdb_id"];
            [show setObject:[[element firstChildWithTag:@"FirstAired"] dateValue] forKey:@"started"];
            [show setObject:[[element firstChildWithTag:@"language"] stringValue] forKey:@"language"];
            [show setObject:[[element firstChildWithTag:@"SeriesName"] stringValue] forKey:@"name"];
            [show setObject:([[element firstChildWithTag:@"Overview"] stringValue] ?: [NSNull null]) forKey:@"seriesDescription"];
            [show setObject:([[element firstChildWithTag:@"Network"] stringValue] ?: [NSNull null]) forKey:@"network"];
            [show setObject:([[element firstChildWithTag:@"banner"] stringValue] ?: [NSNull null]) forKey:@"banner"];
        }];
        
        if (!self.isCancelled)
            handler(show, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    //[operation start];
    //[queue addOperation:operation];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)getShowWithIMDB:(NSString *)serieID completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    NSString *url = [TVDBBaseURL stringByAppendingPathComponent:@"/api/GetSeriesByRemoteID.php"];
    NSDictionary *parameters = @{@"imdbid" : serieID};
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *show = [[NSMutableDictionary alloc] init];
        
        [responseObject enumerateElementsWithXPath:@"//Series" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            *stop = YES; // Stop enumerating. we only need the first value.
            
            [show setObject:[[element firstChildWithTag:@"seriesid"] numberValue] forKey:@"tvdb_id"];
            [show setObject:[[element firstChildWithTag:@"IMDB_ID"] stringValue] forKey:@"imdb_id"];
            [show setObject:[[element firstChildWithTag:@"FirstAired"] stringValue] forKey:@"started"];
            [show setObject:[[element firstChildWithTag:@"language"] stringValue] forKey:@"language"];
            [show setObject:[[element firstChildWithTag:@"SeriesName"] stringValue] forKey:@"name"];
            [show setObject:[[element firstChildWithTag:@"Overview"] stringValue] forKey:@"seriesDescription"];
            [show setObject:[[element firstChildWithTag:@"Network"] stringValue] forKey:@"network"];
            [show setObject:[[element firstChildWithTag:@"banner"] stringValue] forKey:@"banner"];
        }];
        
        if (!self.isCancelled)
            handler(show, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    //[operation start];
    [queue addOperation:operation];
}

- (void)getShowWithEpisodeList:(NSNumber *)showid completionHandler:(void(^)(NSDictionary *result, NSError *error))handler {
    NSString *url = [TVDBBaseURL stringByAppendingFormat:@"/api/%@/series/%@/all/en.xml", TVDB_API_KEY, [showid stringValue]];
    NSError *error = nil;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:nil error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFOnoResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *show = [NSMutableDictionary dictionary];
        
        ONOXMLElement *serie = [responseObject firstChildWithXPath:@"//Series"];
        [serie.document.dateFormatter setDateFormat:@"yyyy-mm-dd"];
        
        [show addObject:[[serie firstChildWithTag:@"id"] numberValue] key:@"tvdb_id"];
        [show addObject:[[serie firstChildWithTag:@"Airs_DayOfWeek"] stringValue] key:@"airday"];
        [show addObject:[[serie firstChildWithTag:@"Airs_Time"] stringValue] key:@"airtime"];
        [show addObject:[[serie firstChildWithTag:@"ContentRating"] stringValue] key:@"contentRating"];
        [show addObject:[[serie firstChildWithTag:@"FirstAired"] dateValue] key:@"started"];
        [show addObject:[[serie firstChildWithTag:@"IMDB_ID"] stringValue] key:@"imdb_id"];
        [show addObject:[[serie firstChildWithTag:@"Language"] stringValue] key:@"language"];
        [show addObject:[[serie firstChildWithTag:@"Network"] stringValue] key:@"network"];
        [show addObject:[[serie firstChildWithTag:@"Overview"] stringValue] key:@"seriesDescription"];
        [show addObject:[[serie firstChildWithTag:@"Runtime"] numberValue] key:@"runtime"];
        [show addObject:[[serie firstChildWithTag:@"SeriesName"] stringValue] key:@"name"];
        [show addObject:[[serie firstChildWithTag:@"Status"] stringValue] key:@"status"];
        
        // Poster
        NSString *poster = [[serie firstChildWithTag:@"poster"] stringValue];
        if (![poster isEmpty]) {
            NSString *posterUrl = [TVDBBaseURL stringByAppendingPathComponent:@"banners"];
            [show addObject:[posterUrl stringByAppendingPathComponent:poster] key:@"poster"];
        }
        
        [show addObject:parseRating([[serie firstChildWithTag:@"Rating"] stringValue]) key:@"rating"];
        
        // Convert lastupdated (Unix Timestamp) to NSDate
        NSDate *lastUpdated = [NSDate dateWithTimeIntervalSince1970:[[[serie firstChildWithTag:@"lastupdated"] numberValue] intValue]];
        [show addObject:lastUpdated key:@"lastUpdate"];
        
        // Parse Genres
        NSMutableArray *genres = [[[[serie firstChildWithTag:@"Genre"] stringValue] componentsSeparatedByString:@"|"] mutableCopy];
        
        [genres removeObject:@""];// Remove empty strings
        [show addObject:[genres componentsJoinedByString:@", "] key:@"genre"];
        
        // Episodes
        NSMutableArray __block *episodes = [NSMutableArray array];
        [responseObject enumerateElementsWithXPath:@"//Episode" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            [element.document.dateFormatter setDateFormat:@"yyyy-mm-dd"];
            
            @autoreleasepool {
                NSMutableDictionary *ep = [NSMutableDictionary dictionary];
                
                [ep addObject:[[element firstChildWithXPath:@"id"] numberValue] key:@"episodeID"];
                [ep addObject:[[element firstChildWithXPath:@"EpisodeName"] stringValue] key:@"name"];
                [ep addObject:[[element firstChildWithXPath:@"EpisodeNumber"] numberValue] key:@"episode"];
                [ep addObject:[[element firstChildWithXPath:@"SeasonNumber"] numberValue] key:@"season"];
                
                [ep addObject:[[element firstChildWithXPath:@"absolute_number"] numberValue] key:@"number"];
                [ep addObject:[[element firstChildWithXPath:@"Overview"] stringValue] key:@"episodeDescription"];
                [ep addObject:[[element firstChildWithXPath:@"FirstAired"] dateValue] key:@"airDate"];
                [ep addObject:parseRating([[serie firstChildWithTag:@"Rating"] stringValue]) key:@"rating"];
                
                [episodes addObject:[ep copy]];
            }
        }];
        
        [show addObject:episodes key:@"episodes"];
        
        if (!self.isCancelled)
            handler(show, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!self.isCancelled)
            handler(nil, error);
    }];
    
    //[operation start];
    [queue addOperation:operation];
}

- (void)getPosterForShow:(Serie *)serie completionHandler:(void(^)(NSImage *poster, NSNumber *showID))handler {
    // If theres no poster in the entity, return a error
    if (!serie.poster) {
        NSImage *placeholder = [NSImage imageNamed:@"posterArtPlaceholder"];
        handler(placeholder, serie.tvdb_id);
        return;
    }
    
    // If the TVShows cache directory doesn't exist then create it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDir = applicationCacheDirectory();
    
    NSError *error = nil;
    
    if (![fileManager fileExistsAtPath:cacheDir isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:&error]) {
            DDLogError(@"Error creating application cache directory: %@",error);
            if (handler) {
                NSImage *placeholder = [NSImage imageNamed:@"posterArtPlaceholder"];
                handler(placeholder, serie.tvdb_id);
                return;
            }
        }
    }
    
    // If the image already exists then return the data, otherwise we need to download it.
    NSString *imagePath = [[cacheDir stringByAppendingPathComponent:[serie.tvdb_id stringValue]] stringByAppendingFormat:@".png"];
    
    if ([fileManager fileExistsAtPath:imagePath]) {
        NSImage *sourceImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
        
        if (handler)
            handler(sourceImage, serie.tvdb_id);
    } else {
        NSError *error = nil;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:serie.poster parameters:nil error:&error];
        
        // Specifies that the existing cached data should be used to satisfy the request, regardless of its age or expiration date.
        // If there is no existing data in the cache corresponding the request, the data is loaded from the originating source.
        //[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // If a poster URL was returned, save the image so that it's not downloaded again.
            
            // Turn the NSImage into an NSData TIFFRepresentation. We do this since
            // it will always work, no matter what the source image's type is.
            NSData __block *imageData = [responseObject TIFFRepresentation];
            
            // Convert and save the image in a background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // Now it's safe to turn the NSData into an NSBitmapImageRep...
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                
                // From BitmapImageRep we can turn it into anything we want. Here, we're using a PNG.
                NSData *finalData = [imageRep representationUsingType:NSPNGFileType properties:@{NSImageProgressive: @TRUE}];
                
                // The conversion is done, so save it to the disk.
                [finalData writeToFile:imagePath atomically:YES];
            });
            
            if (handler)
                handler(responseObject, serie.tvdb_id);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (handler) {
                NSImage *placeholder = [NSImage imageNamed:@"posterArtPlaceholder"];
                handler(placeholder, serie.tvdb_id);
            }
        }];
        
        //[operation start];
        //[queue addOperation:operation];
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
}

#pragma mark - Private

static NSNumber *parseRating(NSString *rating) {
    NSDecimalNumber *decimalRating = [NSDecimalNumber decimalNumberWithString:rating];
    float finalRating = [decimalRating floatValue] / 2;// TVDB Rating is up to 10, we divide by 2 to have a 5 stars reating.
    
    if (isnan(finalRating)) finalRating = 0.0;// set 0 to finalRating if the value is not a number.
    
    return [NSNumber numberWithFloat:finalRating];
}

@end
