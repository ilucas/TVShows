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

#import "TSUserDefaults.h"
#import "AppInfoConstants.h"


// Setup CFPreference variables
CFStringRef prefAppDomain = (CFStringRef)TVShowsAppDomain;

@implementation TSUserDefaults

// Modified from the Perian prefPane source code
// Original version: http://svn.perian.org/trunk/CPFPerianPrefPaneController.m
+ (BOOL) getBoolFromKey:(NSString *)key withDefault:(BOOL)defaultValue
{
    Boolean ret, exists = FALSE;
    
    ret = CFPreferencesGetAppBooleanValue((CFStringRef)key, prefAppDomain, &exists);
    
    return exists ? ret : defaultValue;
}

+ (void) setKey:(NSString *)key fromBool:(BOOL)value
{
    CFPreferencesSetAppValue((CFStringRef)key, value ? kCFBooleanTrue : kCFBooleanFalse, prefAppDomain);
    CFPreferencesSynchronize(prefAppDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

+ (float) getFloatFromKey:(NSString *)key withDefault:(float)defaultValue
{
    CFPropertyListRef value;
    float ret = defaultValue;
    
    value = CFPreferencesCopyAppValue((CFStringRef)key, prefAppDomain);
    if(value && CFGetTypeID(value) == CFNumberGetTypeID())
        CFNumberGetValue(value, kCFNumberFloatType, &ret);
    
    if(value)
        CFRelease(value);
    
    return ret;
}

+ (void) setKey:(NSString *)key fromFloat:(float)value
{
    CFNumberRef numRef = CFNumberCreate(NULL, kCFNumberFloatType, &value);
    CFPreferencesSetAppValue((CFStringRef)key, numRef, prefAppDomain);
    CFRelease(numRef);
    
    CFPreferencesSynchronize(prefAppDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

+ (unsigned int) getUnsignedIntFromKey:(NSString *)key withDefault:(int)defaultValue
{
    int ret; Boolean exists = FALSE;
    
    ret = CFPreferencesGetAppIntegerValue((CFStringRef)key, prefAppDomain, &exists);
    
    return exists ? ret : defaultValue;
}

+ (void) setKey:(NSString *)key fromInt:(int)value
{
    CFNumberRef numRef = CFNumberCreate(NULL, kCFNumberIntType, &value);
    CFPreferencesSetAppValue((CFStringRef)key, numRef, prefAppDomain);
    CFRelease(numRef);
    
    CFPreferencesSynchronize(prefAppDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

+ (NSString *) getStringFromKey:(NSString *)key
{
    CFPropertyListRef value;
    
    value = CFPreferencesCopyAppValue((CFStringRef)key, prefAppDomain);
    
    if(value) {
        CFMakeCollectable(value);
        [(id)value autorelease];
        
        if (CFGetTypeID(value) != CFStringGetTypeID())
            return nil;
    }
    
    return (NSString*)value;
}

+ (void) setKey:(NSString *)key fromString:(NSString *)value
{
    CFPreferencesSetAppValue((CFStringRef)key, value, prefAppDomain);
    CFPreferencesSynchronize(prefAppDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

+ (NSDate *) getDateFromKey:(NSString *)key
{
    CFPropertyListRef value;
    NSDate *ret = nil;
    
    value = CFPreferencesCopyAppValue((CFStringRef)key, prefAppDomain);
    if(value && CFGetTypeID(value) == CFDateGetTypeID())
        ret = [[(NSDate *)value retain] autorelease];
    
    if(value)
        CFRelease(value);
    
    return ret;
}

+ (void) setKey:(NSString *)key fromDate:(NSDate *)value
{
    CFPreferencesSetAppValue((CFStringRef)key, value, prefAppDomain);
    CFPreferencesSynchronize(prefAppDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

@end
