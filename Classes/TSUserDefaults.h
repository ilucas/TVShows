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

#import <Cocoa/Cocoa.h>


@interface TSUserDefaults : NSObject {

}

+ (BOOL) getBoolFromKey:(NSString *)key withDefault:(BOOL)defaultValue;
+ (void) setKey:(NSString *)key fromBool:(BOOL)value;

+ (float) getFloatFromKey:(NSString *)key withDefault:(float)defaultValue;
+ (void) setKey:(NSString *)key fromFloat:(float)value;

+ (unsigned int) getUnsignedIntFromKey:(NSString *)key withDefault:(int)defaultValue;
+ (void) setKey:(NSString *)key fromInt:(int)value;

+ (NSString *) getStringFromKey:(NSString *)key;
+ (void) setKey:(NSString *)key fromString:(NSString *)value;

+ (NSDate *) getDateFromKey:(NSString *)key;
+ (void) setKey:(NSString *)key fromDate:(NSDate *)value;

@end
