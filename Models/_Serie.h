// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Serie.h instead.

@import CoreData;

extern const struct SerieAttributes {
	__unsafe_unretained NSString *airDay;
	__unsafe_unretained NSString *airTime;
	__unsafe_unretained NSString *contentRating;
	__unsafe_unretained NSString *firstAired;
	__unsafe_unretained NSString *genre;
	__unsafe_unretained NSString *imdb;
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *network;
	__unsafe_unretained NSString *overview;
	__unsafe_unretained NSString *poster;
	__unsafe_unretained NSString *rating;
	__unsafe_unretained NSString *runtime;
	__unsafe_unretained NSString *seasons;
	__unsafe_unretained NSString *serieID;
	__unsafe_unretained NSString *status;
} SerieAttributes;

extern const struct SerieRelationships {
	__unsafe_unretained NSString *episodes;
	__unsafe_unretained NSString *subscription;
} SerieRelationships;

@class Episode;
@class Subscription;

@interface SerieID : NSManagedObjectID {}
@end

@interface _Serie : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SerieID* objectID;

@property (nonatomic, strong) NSString* airDay;

//- (BOOL)validateAirDay:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* airTime;

//- (BOOL)validateAirTime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* contentRating;

//- (BOOL)validateContentRating:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* firstAired;

//- (BOOL)validateFirstAired:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* genre;

//- (BOOL)validateGenre:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* imdb;

//- (BOOL)validateImdb:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lastUpdated;

@property (atomic) int64_t lastUpdatedValue;
- (int64_t)lastUpdatedValue;
- (void)setLastUpdatedValue:(int64_t)value_;

//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* network;

//- (BOOL)validateNetwork:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* overview;

//- (BOOL)validateOverview:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* poster;

//- (BOOL)validatePoster:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rating;

@property (atomic) float ratingValue;
- (float)ratingValue;
- (void)setRatingValue:(float)value_;

//- (BOOL)validateRating:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* runtime;

//- (BOOL)validateRuntime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* seasons;

@property (atomic) int16_t seasonsValue;
- (int16_t)seasonsValue;
- (void)setSeasonsValue:(int16_t)value_;

//- (BOOL)validateSeasons:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* serieID;

@property (atomic) int32_t serieIDValue;
- (int32_t)serieIDValue;
- (void)setSerieIDValue:(int32_t)value_;

//- (BOOL)validateSerieID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *episodes;

- (NSMutableSet*)episodesSet;

@property (nonatomic, strong) Subscription *subscription;

//- (BOOL)validateSubscription:(id*)value_ error:(NSError**)error_;

@end

@interface _Serie (EpisodesCoreDataGeneratedAccessors)
- (void)addEpisodes:(NSSet*)value_;
- (void)removeEpisodes:(NSSet*)value_;
- (void)addEpisodesObject:(Episode*)value_;
- (void)removeEpisodesObject:(Episode*)value_;

@end

@interface _Serie (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveAirDay;
- (void)setPrimitiveAirDay:(NSString*)value;

- (NSString*)primitiveAirTime;
- (void)setPrimitiveAirTime:(NSString*)value;

- (NSString*)primitiveContentRating;
- (void)setPrimitiveContentRating:(NSString*)value;

- (NSDate*)primitiveFirstAired;
- (void)setPrimitiveFirstAired:(NSDate*)value;

- (NSString*)primitiveGenre;
- (void)setPrimitiveGenre:(NSString*)value;

- (NSString*)primitiveImdb;
- (void)setPrimitiveImdb:(NSString*)value;

- (NSNumber*)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSNumber*)value;

- (int64_t)primitiveLastUpdatedValue;
- (void)setPrimitiveLastUpdatedValue:(int64_t)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveNetwork;
- (void)setPrimitiveNetwork:(NSString*)value;

- (NSString*)primitiveOverview;
- (void)setPrimitiveOverview:(NSString*)value;

- (NSString*)primitivePoster;
- (void)setPrimitivePoster:(NSString*)value;

- (NSNumber*)primitiveRating;
- (void)setPrimitiveRating:(NSNumber*)value;

- (float)primitiveRatingValue;
- (void)setPrimitiveRatingValue:(float)value_;

- (NSString*)primitiveRuntime;
- (void)setPrimitiveRuntime:(NSString*)value;

- (NSNumber*)primitiveSeasons;
- (void)setPrimitiveSeasons:(NSNumber*)value;

- (int16_t)primitiveSeasonsValue;
- (void)setPrimitiveSeasonsValue:(int16_t)value_;

- (NSNumber*)primitiveSerieID;
- (void)setPrimitiveSerieID:(NSNumber*)value;

- (int32_t)primitiveSerieIDValue;
- (void)setPrimitiveSerieIDValue:(int32_t)value_;

- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;

- (NSMutableSet*)primitiveEpisodes;
- (void)setPrimitiveEpisodes:(NSMutableSet*)value;

- (Subscription*)primitiveSubscription;
- (void)setPrimitiveSubscription:(Subscription*)value;

@end
