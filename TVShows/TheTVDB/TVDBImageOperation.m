/*
 *  This file is part of the TVShows source code.
 *  http://github.com/ilucas/TVShows
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

#import "TVDBImageOperation.h"
#import "TVDBManager.h"

@import Mantle;
@import libextobjc;
@import CocoaLumberjack;

@implementation TVDBImageOperation

+ (nullable instancetype)requestImage:(NSString *)imageName
           CompletionBlockWithSuccess:(nullable void (^)(TVDBImageOperation *operation, NSImage *poster))success
                              failure:(nullable void (^)(TVDBImageOperation *operation, NSError *error))failure {
    
    NSString *url = [@"https://www.thetvdb.com/banners/" stringByAppendingPathComponent:imageName];
    
    NSError *serializationError;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:url
                                                                                parameters:nil
                                                                                     error:&serializationError];
    
    if (serializationError) {
        DDLogError(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, serializationError);
    }
    
    TVDBImageOperation *operation = [[TVDBImageOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    operation.imageName = imageName;
    
    // Check if there's a cached image.
    NSImage *cachedImage = [operation cachedImage];
    
    if (cachedImage) {
        [operation cancel];
        success(operation, cachedImage);
    } else {
        [operation setCompletionBlockWithSuccess:success failure:failure];
    }
    
    return operation;
}

#pragma mark - 

- (nullable NSImage *)cachedImage {
    // If the TVShows cache directory doesn't exist then create it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDir = applicationCacheDirectory();
    
    NSError *error = nil;
    
    if (![fileManager fileExistsAtPath:cacheDir isDirectory:NO]) {
        if (![fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:&error]) {
            DDLogError(@"%s [Line %d]: Error creating application cache directory: %@", __PRETTY_FUNCTION__, __LINE__, error);
            return nil;
        }
    }
    
    // If the image already exists then return the data, otherwise we need to download it.
    NSString *imagePath = [[cacheDir stringByAppendingPathComponent:self.imageName] stringByAppendingFormat:@".png"];
    
    if ([fileManager fileExistsAtPath:imagePath]) {
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    }
    
    return nil;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(TVDBImageOperation *, NSImage *))success
                              failure:(void (^)(TVDBImageOperation *, NSError *))failure {
    @weakify(self)
    [super setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // If a poster URL was returned, save the image so that it's not downloaded again.
        
        // Turn the NSImage into an NSData TIFFRepresentation. We do this since
        // it will always work, no matter what the source image's type is.
        NSData __block *imageData = [responseObject TIFFRepresentation];
        
        @strongify(self)
        NSString *imageName = [[self.imageName lastPathComponent] stringByDeletingPathExtension];// Remove "/poster" and ".jpg"
        NSString *imagePath = [[applicationCacheDirectory() stringByAppendingPathComponent:imageName] stringByAppendingPathExtension:@"png"];
        
        // Convert and save the image in a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Now it's safe to turn the NSData into an NSBitmapImageRep...
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            
            // From BitmapImageRep we can turn it into anything we want. Here, we're using a PNG.
            NSData *finalData = [imageRep representationUsingType:NSPNGFileType properties:@{NSImageProgressive: @TRUE}];
            
            // The conversion is done, so save it to the disk.
            [finalData writeToFile:imagePath atomically:YES];
        });
        
        if (success) {
            success(self, responseObject);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failure) {
            @strongify(self)
            failure(self, self.error);
        }
    }];
}

@end
