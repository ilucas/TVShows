// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Episode.m instead.

#import "_Episode.h"

const struct EpisodeAttributes EpisodeAttributes = {
	.airDate = @"airDate",
	.episode = @"episode",
	.episodeDescription = @"episodeDescription",
	.episodeID = @"episodeID",
	.name = @"name",
	.number = @"number",
	.rating = @"rating",
	.season = @"season",
	.tvRageLink = @"tvRageLink",
};

const struct EpisodeRelationships EpisodeRelationships = {
	.serie = @"serie",
};

@implementation EpisodeID
@end

@implementation _Episode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Episode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Episode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Episode" inManagedObjectContext:moc_];
}

- (EpisodeID*)objectID {
	return (EpisodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"episodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"episode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"episodeIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"episodeID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"numberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"number"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"ratingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"seasonValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"season"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic airDate;

@dynamic episode;

- (int32_t)episodeValue {
	NSNumber *result = [self episode];
	return [result intValue];
}

- (void)setEpisodeValue:(int32_t)value_ {
	[self setEpisode:@(value_)];
}

- (int32_t)primitiveEpisodeValue {
	NSNumber *result = [self primitiveEpisode];
	return [result intValue];
}

- (void)setPrimitiveEpisodeValue:(int32_t)value_ {
	[self setPrimitiveEpisode:@(value_)];
}

@dynamic episodeDescription;

@dynamic episodeID;

- (float)episodeIDValue {
	NSNumber *result = [self episodeID];
	return [result floatValue];
}

- (void)setEpisodeIDValue:(float)value_ {
	[self setEpisodeID:@(value_)];
}

- (float)primitiveEpisodeIDValue {
	NSNumber *result = [self primitiveEpisodeID];
	return [result floatValue];
}

- (void)setPrimitiveEpisodeIDValue:(float)value_ {
	[self setPrimitiveEpisodeID:@(value_)];
}

@dynamic name;

@dynamic number;

- (int32_t)numberValue {
	NSNumber *result = [self number];
	return [result intValue];
}

- (void)setNumberValue:(int32_t)value_ {
	[self setNumber:@(value_)];
}

- (int32_t)primitiveNumberValue {
	NSNumber *result = [self primitiveNumber];
	return [result intValue];
}

- (void)setPrimitiveNumberValue:(int32_t)value_ {
	[self setPrimitiveNumber:@(value_)];
}

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

@dynamic season;

- (int32_t)seasonValue {
	NSNumber *result = [self season];
	return [result intValue];
}

- (void)setSeasonValue:(int32_t)value_ {
	[self setSeason:@(value_)];
}

- (int32_t)primitiveSeasonValue {
	NSNumber *result = [self primitiveSeason];
	return [result intValue];
}

- (void)setPrimitiveSeasonValue:(int32_t)value_ {
	[self setPrimitiveSeason:@(value_)];
}

@dynamic tvRageLink;

@dynamic serie;

@end

