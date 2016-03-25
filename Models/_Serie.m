// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Serie.m instead.

#import "_Serie.h"

const struct SerieAttributes SerieAttributes = {
	.airDay = @"airDay",
	.airTime = @"airTime",
	.contentRating = @"contentRating",
	.firstAired = @"firstAired",
	.genre = @"genre",
	.imdb = @"imdb",
	.lastUpdated = @"lastUpdated",
	.name = @"name",
	.network = @"network",
	.overview = @"overview",
	.poster = @"poster",
	.rating = @"rating",
	.runtime = @"runtime",
	.seasons = @"seasons",
	.serieID = @"serieID",
	.status = @"status",
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

	if ([key isEqualToString:@"lastUpdatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastUpdated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"ratingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"seasonsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"seasons"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"serieIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"serieID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic airDay;

@dynamic airTime;

@dynamic contentRating;

@dynamic firstAired;

@dynamic genre;

@dynamic imdb;

@dynamic lastUpdated;

- (int64_t)lastUpdatedValue {
	NSNumber *result = [self lastUpdated];
	return [result longLongValue];
}

- (void)setLastUpdatedValue:(int64_t)value_ {
	[self setLastUpdated:@(value_)];
}

- (int64_t)primitiveLastUpdatedValue {
	NSNumber *result = [self primitiveLastUpdated];
	return [result longLongValue];
}

- (void)setPrimitiveLastUpdatedValue:(int64_t)value_ {
	[self setPrimitiveLastUpdated:@(value_)];
}

@dynamic name;

@dynamic network;

@dynamic overview;

@dynamic poster;

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

@dynamic seasons;

- (int16_t)seasonsValue {
	NSNumber *result = [self seasons];
	return [result shortValue];
}

- (void)setSeasonsValue:(int16_t)value_ {
	[self setSeasons:@(value_)];
}

- (int16_t)primitiveSeasonsValue {
	NSNumber *result = [self primitiveSeasons];
	return [result shortValue];
}

- (void)setPrimitiveSeasonsValue:(int16_t)value_ {
	[self setPrimitiveSeasons:@(value_)];
}

@dynamic serieID;

- (int32_t)serieIDValue {
	NSNumber *result = [self serieID];
	return [result intValue];
}

- (void)setSerieIDValue:(int32_t)value_ {
	[self setSerieID:@(value_)];
}

- (int32_t)primitiveSerieIDValue {
	NSNumber *result = [self primitiveSerieID];
	return [result intValue];
}

- (void)setPrimitiveSerieIDValue:(int32_t)value_ {
	[self setPrimitiveSerieID:@(value_)];
}

@dynamic status;

@dynamic episodes;

- (NSMutableSet*)episodesSet {
	[self willAccessValueForKey:@"episodes"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"episodes"];

	[self didAccessValueForKey:@"episodes"];
	return result;
}

@dynamic subscription;

@end

