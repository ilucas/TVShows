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

#import "GeneralPreferencesViewController.h"
#import "AppDelegate.h"
#import "LaunchAgent.h"

@interface GeneralPreferencesViewController ()
@property (nonatomic, assign) BOOL helperStatus;
@property (nonatomic, strong) NSUserDefaultsController *defaultsController;
@end

@implementation GeneralPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [[NSApp delegate] sharedUserDefaults];
    self.defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:defaults initialValues:@{@"checkDelay" : @0}];
    
    // Bind swtich status to self.helperStatus.
    [self.helperSwitch bind:@"checked" toObject:self withKeyPath:@"helperStatus" options:nil];
    self.helperStatus = [LaunchAgent loginItemIsEnabled];
    
    [self.checkDelay bind:@"selectedIndex" toObject:self.defaultsController withKeyPath:@"values.checkDelay" options:nil];
}

#pragma mark - Actions

- (IBAction)helperSwitch:(ITSwitch *)sender {
    bool status = [LaunchAgent enabledLoginItem:sender.checked];
    
    if (status == false) {
        [sender setChecked:false];
    }
}

- (IBAction)delayAction:(id)sender {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TVShows.Notification.DelayChanged"
                                                                   object:nil];
}

#pragma mark - Properties

- (void)setHelperStatus:(BOOL)helperStatus {
    _helperStatus = helperStatus;
    
    NSUserDefaults *userDefaults = [[NSApp delegate] sharedUserDefaults];
    [userDefaults setBool:helperStatus forKey:@"helperStatus"];
    
    if (helperStatus) {
        self.statusLabel.stringValue = @"TVShows is enabled";
    } else {
        self.statusLabel.stringValue = @"TVShows is disabled";
    }
}

@end
