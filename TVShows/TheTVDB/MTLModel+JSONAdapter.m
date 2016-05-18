/*
 *  This file is part of the TVShows source code.
 *  http://github.com/ilucas/TVShows
 *
 *  TVShows is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with TVShows. If not, see <http://www.gnu.org/licenses/>.
 */

#import "MTLModel+JSONAdapter.h"

@implementation MTLModel (JSONAdapter)

+ (id)modelFromJSONDictionary:(NSDictionary *)JSONDictionary error:(NSError **)error {
    return [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:JSONDictionary error:error];
}

+ (NSArray *)modelsFromJSONArray:(NSArray *)JSONArray error:(NSError **)error {
    return [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:JSONArray error:error];
}

@end
