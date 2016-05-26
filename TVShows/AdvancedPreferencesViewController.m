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

#import "AdvancedPreferencesViewController.h"
#import "AppDelegate.h"

NSMenuItem *menuItemWithTitleTag(NSString *title, NSInteger tag) {
    NSMenuItem *item = [NSMenuItem new];
    item.title = title;
    item.tag = tag;
    return item;
}

@import CocoaLumberjack;

@interface AdvancedPreferencesViewController ()
@property (nonatomic, strong) NSUserDefaultsController *defaultsController;
@end

@implementation AdvancedPreferencesViewController

- (void)viewDidLoad {
    NSUserDefaults *defaults = [[NSApp delegate] sharedUserDefaults];
    self.defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:defaults initialValues:nil];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItem:menuItemWithTitleTag(@"Off", DDLogLevelOff)];
    [menu addItem:menuItemWithTitleTag(@"Error", DDLogLevelError)];
    [menu addItem:menuItemWithTitleTag(@"Warning", DDLogLevelWarning)];
    [menu addItem:menuItemWithTitleTag(@"Info", DDLogLevelInfo)];
    [menu addItem:menuItemWithTitleTag(@"Debug", DDLogLevelDebug)];
    [menu addItem:menuItemWithTitleTag(@"All", DDLogLevelAll)];
    
    NSInteger selectedTag = [defaults integerForKey:@"logLevel"];
    [[menu itemWithTag:selectedTag] setState:NSOnState];
    
    [self.logLevelPopMenu setMenu:menu];
    
    [super viewDidLoad];
}

@end
