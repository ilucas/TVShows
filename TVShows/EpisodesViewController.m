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

#import "EpisodesViewController.h"
#import "Serie.h"
#import "TheTVDB.h"

@interface EpisodesViewController ()

@end

@implementation EpisodesViewController

- (void)awakeFromNib {
    self.episodesList = [NSMutableArray array];
    
    NSSortDescriptor *episodeSorter = [NSSortDescriptor sortDescriptorWithKey:@"episode" ascending:NO];
    NSSortDescriptor *seasonSorter = [NSSortDescriptor sortDescriptorWithKey:@"season" ascending:NO];
    
    [self.episodesArrayController setSortDescriptors:@[seasonSorter, episodeSorter]];
}

- (void)updateEpisodes:(NSArray <TVDBEpisode *> *)episodes {
    [self resetView];
    [self.episodesArrayController addObjects:episodes];
    [self.episodesArrayController rearrangeObjects];
    [self.tableView reloadData];
}

- (void)resetView {
    NSRange range = NSMakeRange(0, [self.episodesArrayController.arrangedObjects count]);
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
    
    [self.episodesArrayController removeObjectsAtArrangedObjectIndexes:indexes];
    [self.episodesList removeAllObjects];
    [self.tableView reloadData];
    [self.episodesButtons selectCellWithTag:0];
}

#pragma mark - Propertie

- (NSArray<TVDBEpisode *> *)selectedEpisodes {
    return [self.episodesArrayController selectedObjects];
}

#pragma mark - Actions

- (IBAction)selectNextAired:(id)sender {
    [self.tableView setEnabled:NO];
}

- (IBAction)selectOtherEpisode:(id)sender {
    [self.tableView setEnabled:YES];
}

@end
