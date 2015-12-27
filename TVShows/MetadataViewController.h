//
//  MetadataViewController.h
//  TVShows
//
//  Created by Lucas Casteletti on 12/25/15.
//  Copyright © 2015 Lucas Casteletti. All rights reserved.
//

@import Cocoa;

@class Serie;

@protocol MetadataViewDelegate <NSObject>

- (NSDictionary  *)selectedShow;

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

- (void)toggleLoading:(BOOL)isLoading;
- (void)updateShowInfo:(Serie *)serie;
- (void)resetView;

@end
