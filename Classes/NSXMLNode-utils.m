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

#import "NSXMLNode-utils.h"


@implementation NSXMLNode (utils)

- (NSXMLNode *)childNamed:(NSString *)name
{
    NSEnumerator *e = [[self children] objectEnumerator];
    
    NSXMLNode *node;
    while ((node = [e nextObject])) 
        if ([[node name] isEqualToString:name])
            return node;
    
    return nil;
}

- (NSArray *)childrenAsStrings
{
    NSMutableArray *ret = [[NSMutableArray arrayWithCapacity:
                            [[self children] count]] retain];
    NSEnumerator *e = [[self children] objectEnumerator];
    NSXMLNode *node;
    while ((node = [e nextObject]))
        [ret addObject:[node stringValue]];
    
    return [ret autorelease];
}

@end
