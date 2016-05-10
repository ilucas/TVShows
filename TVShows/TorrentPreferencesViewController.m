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

#import "TorrentPreferencesViewController.h"
#import "AppDelegate.h"

@interface TorrentPreferencesViewController ()
@property (weak, nonatomic) NSUserDefaults *defaults;
@end

@implementation TorrentPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaults = [[NSApp delegate] sharedUserDefaults];
    
    [self.torrentClient setMenu:[self torrentClientsMenu]];
}

#pragma mark - Actions

- (IBAction)torrentClient:(NSPopUpButton *)sender {
    NSMenuItem *item = self.torrentClient.selectedItem;
    [self.defaults setObject:@{@"client": item.title, @"identifier": item.representedObject} forKey:@"torrentClient"];
}

#pragma mark - Private

- (NSMenu *)torrentClientsMenu {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray<NSURL *> __block *applications = [NSMutableArray array];
    
    NSArray<NSURL *> *applicationDirectory = [fileManager URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask];
    
    [applicationDirectory enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL *stop) {
        NSArray<NSURL *> *content = [fileManager contentsOfDirectoryAtURL:obj
                                               includingPropertiesForKeys:nil
                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                    error:nil];
        [applications addObjectsFromArray:content];
    }];
    
    NSArray<NSString *> *supportedApps = @[@"Transmission.app", @"uTorrent.app", @"Vuze.app"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.lastPathComponent IN %@", supportedApps];
    
    [applications filterUsingPredicate:predicate];
    
    NSMenu *menu = [NSMenu new];
    
    NSMenuItem *defaultItem = [[NSMenuItem alloc] initWithTitle:@"System default" action:nil keyEquivalent:@""];
    defaultItem.representedObject = @"";
    
    [menu addItem:defaultItem];
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSString *selectedName = [self.defaults objectForKey:@"torrentClient"][@"client"];
    
    [applications enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL *stop) {
        NSBundle *appBundle = [NSBundle bundleWithURL:obj];
        NSString *appName = [[obj lastPathComponent] stringByDeletingPathExtension];
        
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.title = appName;
        item.representedObject = [appBundle bundleIdentifier];
        
        if ([appName isEqualToString:selectedName]) {
            [item setState:NSOnState];
        }
        
        [menu addItem:item];
    }];
    
    return menu;
}

@end
