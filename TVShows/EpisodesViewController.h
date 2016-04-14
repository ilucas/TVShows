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
@import MagicalRecord;

@class Serie;
@class TVDBSerie;
@class TVDBEpisode;

@interface EpisodesViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSMatrix *episodesButtons;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak, nonatomic) IBOutlet NSArrayController *episodesArrayController;
@property (strong, nonatomic) NSMutableArray<TVDBEpisode *> *episodesList;
@property (weak, readonly) NSArray <TVDBEpisode *> *selectedEpisodes;

- (void)updateEpisodes:(NSArray <TVDBEpisode *> *)episodes;
- (void)resetView;

- (IBAction)selectNextAired:(id)sender;
- (IBAction)selectOtherEpisode:(id)sender;

@end
