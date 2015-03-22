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

#import "CacheDelegate.h"
#import "AppInfoConstants.h"

@implementation CacheDelegate

@synthesize window;

#pragma mark -
#pragma mark Xcode Example Functions
// Returns the Application Support directory for TVShows 2
- (NSString *) applicationSupportDirectory
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"TVShows 2"];
}

// Creates, retains, and returns the managed object model for the application
- (NSManagedObjectModel *) managedObjectModel
{

    if (managedObjectModel) return managedObjectModel;
    
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:
                           [NSArray arrayWithObject:
                            [NSBundle bundleWithIdentifier: CurrentBundleDomain]]];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.  This 
// implementation will create and return a coordinator, having added the 
// store for the application to it.  (The directory for the store is created, 
// if necessary.)
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        LogCritical(@"%@:%@ No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
        if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            LogCritical(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
        }
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"Cache"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:url
                                                        options:nil
                                                          error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }   

    return persistentStoreCoordinator;
}

// Returns the managed object context for the application 
- (NSManagedObjectContext *) managedObjectContext
{

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

// Returns the NSUndoManager for the application.  In this case, the manager
// returned is that of the managed object context for the application.
- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Send the save: message to the application's managed object context.
// Any encountered errors are presented to the user.
- (void) saveAction
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        LogCritical(@"%@:%@ unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

@end
