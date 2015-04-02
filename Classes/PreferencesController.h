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

#import <PreferencePanes/PreferencePanes.h>
#import <Cocoa/Cocoa.h>
#import "MBSliderButton.h"


@interface PreferencesController : NSObject
{
    // Section headings
    IBOutlet NSBox *generalBoxTitle;
    IBOutlet NSBox *downloadBoxTitle;
    IBOutlet NSBox *growlBoxTitle;
    IBOutlet NSBox *updateBoxTitle;
    
    // General Settings
    IBOutlet NSTextField *namingConventionText;
    IBOutlet NSPopUpButton *namingConventionMenu;
    IBOutlet NSButton *showMenuBarIcon;
    
    // Download Preferences
    IBOutlet MBSliderButton *isEnabledControl;
    IBOutlet NSImageView *TVShowsAppImage;
    
    IBOutlet NSTextField *episodeCheckText;
    IBOutlet NSPopUpButton *episodeCheckDelay;
    
    IBOutlet NSTextField *downloadLocationText;
    IBOutlet NSPopUpButton *downloadLocationMenu;
    
    IBOutlet NSButton *autoOpenDownloadedFiles;
    IBOutlet NSButton *sortInFolders;
    IBOutlet NSButton *sortInSeasonFolders;
    IBOutlet NSButton *autoSelectHDVersion;
    IBOutlet NSButton *useAdditionalSourcesHD;
    IBOutlet NSButton *preferMagnets;
    
    // Growl Settings
    IBOutlet NSTextField *growlNotifyText;
    IBOutlet NSButton *growlNotifyEpisode;
    IBOutlet NSButton *growlNotifyApplication;
    
    // Application Update Preferences
    IBOutlet NSButton *checkNowButton;
    IBOutlet NSButton *checkForUpdates;
    IBOutlet NSButton *autoInstallNewUpdates;
    IBOutlet NSButton *downloadBetaVersions;
    IBOutlet NSButton *includeSystemInformation;
}

#pragma mark -
#pragma mark General
- init;
- (void) awakeFromNib;
- (void) setDefaultUserDefaults;
- (void) loadSavedDefaults;
- (IBAction) showMenuBarIconDidChange:(id)sender;
- (IBAction) namingConventionDidChange:(id)sender;

#pragma mark -
#pragma mark Download Preferences
- (void) enabledControlDidChange:(BOOL)isEnabled;
- (IBAction) episodeCheckDelayDidChange:(id)sender;
- (void) buildDownloadLocationMenu;
- (NSMenu *) downloadLocationMenu;
- (void) selectOtherDownloadFolder:(id)sender;
- (void) openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (IBAction) autoOpenDownloadedFilesDidChange:(id)sender;
- (IBAction) sortInFoldersDidChange:(id)sender;
- (IBAction) sortInSeasonFoldersDidChange:(id)sender;
- (IBAction) autoSelectHDVersionDidChange:(id)sender;
- (IBAction) useAdditionalSourcesHDDidChange:(id)sender;
- (IBAction) preferMagnetsDidChange:(id)sender;

#pragma mark -
#pragma mark Growl Notification Preferences
- (IBAction) growlNotifyEpisodeDidChange:(id)sender;
- (IBAction) growlNotifyApplicationDidChange:(id)sender;

#pragma mark -
#pragma mark Application Update Preferences
- (IBAction) checkForUpdatesDidChange:(id)sender;
- (IBAction) autoInstallNewUpdatesDidChange:(id)sender;
- (IBAction) downloadBetaVersionsDidChange:(id)sender;
- (IBAction) includeSystemInformationDidChange:(id)sender;

#pragma mark -
#pragma mark Launch Agent Methods
- (NSString *) launchAgentPath;
- (void) unloadLaunchAgent;
- (void) loadLaunchAgent;
- (void) updateLaunchAgent;
- (void) saveLaunchAgentPlist;

@end
