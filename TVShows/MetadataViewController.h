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

@import Cocoa;

@class Serie;
@class TVDBSerie;

@protocol MetadataViewDelegate <NSObject>

- (TVDBSerie *)selectedShow;

@end

@interface MetadataViewController : NSViewController

@property (weak, nonatomic) IBOutlet id <MetadataViewDelegate> delegate;

@property (weak) IBOutlet NSBox *dataBox;
@property (weak) IBOutlet NSImageView *showPoster;
@property (weak) IBOutlet NSTextField *showName;
@property (weak) IBOutlet NSTextField *showYear;
@property (weak) IBOutlet NSTextField *showDuration;
@property (weak) IBOutlet NSLevelIndicator *rating;
@property (weak) IBOutlet NSTextField *genre;
@property (unsafe_unretained) IBOutlet NSTextView *showDescription;
@property (weak) IBOutlet NSImageView *studioLogo;

@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSTextField *loadingText;

- (IBAction)openMoreInfoURL:(id)sender;

- (void)toggleLoading:(BOOL)isLoading;
- (void)updateShowInfo:(Serie *)serie;
- (void)resetView;

@end
