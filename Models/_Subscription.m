// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Subscription.m instead.

#import "_Subscription.h"

const struct SubscriptionAttributes SubscriptionAttributes = {
	.filters = @"filters",
	.isEnabled = @"isEnabled",
	.lastDownloaded = @"lastDownloaded",
	.quality = @"quality",
};

const struct SubscriptionRelationships SubscriptionRelationships = {
	.serie = @"serie",
};

@implementation SubscriptionID
@end

@implementation _Subscription

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Subscription";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:moc_];
}

- (SubscriptionID*)objectID {
	return (SubscriptionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isEnabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isEnabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic filters;

@dynamic isEnabled;

- (BOOL)isEnabledValue {
	NSNumber *result = [self isEnabled];
	return [result boolValue];
}

- (void)setIsEnabledValue:(BOOL)value_ {
	[self setIsEnabled:@(value_)];
}

- (BOOL)primitiveIsEnabledValue {
	NSNumber *result = [self primitiveIsEnabled];
	return [result boolValue];
}

- (void)setPrimitiveIsEnabledValue:(BOOL)value_ {
	[self setPrimitiveIsEnabled:@(value_)];
}

@dynamic lastDownloaded;

@dynamic quality;

@dynamic serie;

@end

