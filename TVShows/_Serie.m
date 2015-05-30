// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Serie.m instead.

#import "_Serie.h"

const struct SerieAttributes SerieAttributes = {
	.airday = @"airday",
	.airtime = @"airtime",
	.banner = @"banner",
	.country = @"country",
	.ended = @"ended",
	.imdb_id = @"imdb_id",
	.language = @"language",
	.name = @"name",
	.network = @"network",
	.rating = @"rating",
	.runtime = @"runtime",
	.seriesDescription = @"seriesDescription",
	.started = @"started",
	.status = @"status",
	.timezone = @"timezone",
	.totalseasons = @"totalseasons",
	.tvRageLink = @"tvRageLink",
	.tvdb_id = @"tvdb_id",
	.tvrage_id = @"tvrage_id",
};

const struct SerieRelationships SerieRelationships = {
	.episodes = @"episodes",
	.subscription = @"subscription",
};

@implementation SerieID
@end

@implementation _Serie

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Serie" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Serie";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Serie" inManagedObjectContext:moc_];
}

- (SerieID*)objectID {
	return (SerieID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"ratingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"runtimeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"runtime"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalseasonsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalseasons"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tvdb_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tvdb_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tvrage_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tvrage_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic airday;

@dynamic airtime;

@dynamic banner;

@dynamic country;

@dynamic ended;

@dynamic imdb_id;

@dynamic language;

@dynamic name;

@dynamic network;

@dynamic rating;

- (float)ratingValue {
	NSNumber *result = [self rating];
	return [result floatValue];
}

- (void)setRatingValue:(float)value_ {
	[self setRating:@(value_)];
}

- (float)primitiveRatingValue {
	NSNumber *result = [self primitiveRating];
	return [result floatValue];
}

- (void)setPrimitiveRatingValue:(float)value_ {
	[self setPrimitiveRating:@(value_)];
}

@dynamic runtime;

- (int16_t)runtimeValue {
	NSNumber *result = [self runtime];
	return [result shortValue];
}

- (void)setRuntimeValue:(int16_t)value_ {
	[self setRuntime:@(value_)];
}

- (int16_t)primitiveRuntimeValue {
	NSNumber *result = [self primitiveRuntime];
	return [result shortValue];
}

- (void)setPrimitiveRuntimeValue:(int16_t)value_ {
	[self setPrimitiveRuntime:@(value_)];
}

@dynamic seriesDescription;

@dynamic started;

@dynamic status;

@dynamic timezone;

@dynamic totalseasons;

- (int16_t)totalseasonsValue {
	NSNumber *result = [self totalseasons];
	return [result shortValue];
}

- (void)setTotalseasonsValue:(int16_t)value_ {
	[self setTotalseasons:@(value_)];
}

- (int16_t)primitiveTotalseasonsValue {
	NSNumber *result = [self primitiveTotalseasons];
	return [result shortValue];
}

- (void)setPrimitiveTotalseasonsValue:(int16_t)value_ {
	[self setPrimitiveTotalseasons:@(value_)];
}

@dynamic tvRageLink;

@dynamic tvdb_id;

- (int32_t)tvdb_idValue {
	NSNumber *result = [self tvdb_id];
	return [result intValue];
}

- (void)setTvdb_idValue:(int32_t)value_ {
	[self setTvdb_id:@(value_)];
}

- (int32_t)primitiveTvdb_idValue {
	NSNumber *result = [self primitiveTvdb_id];
	return [result intValue];
}

- (void)setPrimitiveTvdb_idValue:(int32_t)value_ {
	[self setPrimitiveTvdb_id:@(value_)];
}

@dynamic tvrage_id;

- (int16_t)tvrage_idValue {
	NSNumber *result = [self tvrage_id];
	return [result shortValue];
}

- (void)setTvrage_idValue:(int16_t)value_ {
	[self setTvrage_id:@(value_)];
}

- (int16_t)primitiveTvrage_idValue {
	NSNumber *result = [self primitiveTvrage_id];
	return [result shortValue];
}

- (void)setPrimitiveTvrage_idValue:(int16_t)value_ {
	[self setPrimitiveTvrage_id:@(value_)];
}

@dynamic episodes;

- (NSMutableSet*)episodesSet {
	[self willAccessValueForKey:@"episodes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"episodes"];

	[self didAccessValueForKey:@"episodes"];
	return result;
}

@dynamic subscription;

@end

