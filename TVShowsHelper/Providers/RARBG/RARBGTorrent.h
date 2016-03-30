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

@import Foundation;
@import Mantle;

@interface RARBGTorrent : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic, nonnull) NSString *category;
@property (strong, nonatomic, nonnull) NSString *magnet;
@property (strong, nonatomic, nonnull) NSNumber *leechers;
@property (strong, nonatomic, nonnull) NSNumber *seeders;
@property (strong, nonatomic, nonnull) NSNumber *episode;
@property (strong, nonatomic, nonnull) NSNumber *season;
@property (strong, nonatomic, nonnull) NSString *title;

@end
