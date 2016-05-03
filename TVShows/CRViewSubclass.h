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

@import Cocoa;

IB_DESIGNABLE
@interface CRViewSubclass : NSView

@property (nonatomic, strong) NSColor *startingColor;
@property (nonatomic, strong) NSColor *endingColor;
@property (assign) CGFloat angle;

@property (nonatomic, strong) NSColor *topBorderColor;
@property (nonatomic, strong) NSColor *bottomBorderColor;

@end