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
@import Quartz;

typedef enum {
    GridViewCellIndicationTypeNone,
    GridViewCellIndicationTypeEnded,
    GridViewCellIndicationTypeDisabled,
    GridViewCellIndicationTypeProcessing,
    GridViewCellIndicationTypeFileMissing,
} GridViewCellIndicationType;

@interface GridViewCellIndicationLayer : CALayer

@property (nonatomic, assign) GridViewCellIndicationType type;

@end
