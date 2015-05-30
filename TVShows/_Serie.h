// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Serie.h instead.

@import CoreData;

extern const struct SerieAttributes {
	__unsafe_unretained NSString *airday;
	__unsafe_unretained NSString *airtime;
	__unsafe_unretained NSString *banner;
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *ended;
	__unsafe_unretained NSString *imdb_id;
	__unsafe_unretained NSString *language;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *network;
	__unsafe_unretained NSString *rating;
	__unsafe_unretained NSString *runtime;
	__unsafe_unretained NSString *seriesDescription;
	__unsafe_unretained NSString *started;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *timezone;
	__unsafe_unretained NSString *totalseasons;
	__unsafe_unretained NSString *tvRageLink;
	__unsafe_unretained NSString *tvdb_id;
	__unsafe_unretained NSString *tvrage_id;
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

@property (nonatomic, strong) NSString* airday;

//- (BOOL)validateAirday:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* airtime;

//- (BOOL)validateAirtime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* banner;

//- (BOOL)validateBanner:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* ended;

//- (BOOL)validateEnded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* imdb_id;

//- (BOOL)validateImdb_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* language;

//- (BOOL)validateLanguage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* network;

//- (BOOL)validateNetwork:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rating;

@property (atomic) float ratingValue;
- (float)ratingValue;
- (void)setRatingValue:(float)value_;

//- (BOOL)validateRating:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* runtime;

@property (atomic) int16_t runtimeValue;
- (int16_t)runtimeValue;
- (void)setRuntimeValue:(int16_t)value_;

//- (BOOL)validateRuntime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* seriesDescription;

//- (BOOL)validateSeriesDescription:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* started;

//- (BOOL)validateStarted:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* timezone;

//- (BOOL)validateTimezone:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* totalseasons;

@property (atomic) int16_t totalseasonsValue;
- (int16_t)totalseasonsValue;
- (void)setTotalseasonsValue:(int16_t)value_;

//- (BOOL)validateTotalseasons:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* tvRageLink;

//- (BOOL)validateTvRageLink:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* tvdb_id;

@property (atomic) int32_t tvdb_idValue;
- (int32_t)tvdb_idValue;
- (void)setTvdb_idValue:(int32_t)value_;

//- (BOOL)validateTvdb_id:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* tvrage_id;

@property (atomic) int16_t tvrage_idValue;
- (int16_t)tvrage_idValue;
- (void)setTvrage_idValue:(int16_t)value_;

//- (BOOL)validateTvrage_id:(id*)value_ error:(NSError**)error_;

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

- (NSString*)primitiveAirday;
- (void)setPrimitiveAirday:(NSString*)value;

- (NSString*)primitiveAirtime;
- (void)setPrimitiveAirtime:(NSString*)value;

- (NSString*)primitiveBanner;
- (void)setPrimitiveBanner:(NSString*)value;

- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;

- (NSDate*)primitiveEnded;
- (void)setPrimitiveEnded:(NSDate*)value;

- (NSString*)primitiveImdb_id;
- (void)setPrimitiveImdb_id:(NSString*)value;

- (NSString*)primitiveLanguage;
- (void)setPrimitiveLanguage:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveNetwork;
- (void)setPrimitiveNetwork:(NSString*)value;

- (NSNumber*)primitiveRating;
- (void)setPrimitiveRating:(NSNumber*)value;

- (float)primitiveRatingValue;
- (void)setPrimitiveRatingValue:(float)value_;

- (NSNumber*)primitiveRuntime;
- (void)setPrimitiveRuntime:(NSNumber*)value;

- (int16_t)primitiveRuntimeValue;
- (void)setPrimitiveRuntimeValue:(int16_t)value_;

- (NSString*)primitiveSeriesDescription;
- (void)setPrimitiveSeriesDescription:(NSString*)value;

- (NSDate*)primitiveStarted;
- (void)setPrimitiveStarted:(NSDate*)value;

- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;

- (NSString*)primitiveTimezone;
- (void)setPrimitiveTimezone:(NSString*)value;

- (NSNumber*)primitiveTotalseasons;
- (void)setPrimitiveTotalseasons:(NSNumber*)value;

- (int16_t)primitiveTotalseasonsValue;
- (void)setPrimitiveTotalseasonsValue:(int16_t)value_;

- (NSString*)primitiveTvRageLink;
- (void)setPrimitiveTvRageLink:(NSString*)value;

- (NSNumber*)primitiveTvdb_id;
- (void)setPrimitiveTvdb_id:(NSNumber*)value;

- (int32_t)primitiveTvdb_idValue;
- (void)setPrimitiveTvdb_idValue:(int32_t)value_;

- (NSNumber*)primitiveTvrage_id;
- (void)setPrimitiveTvrage_id:(NSNumber*)value;

- (int16_t)primitiveTvrage_idValue;
- (void)setPrimitiveTvrage_idValue:(int16_t)value_;

- (NSMutableSet*)primitiveEpisodes;
- (void)setPrimitiveEpisodes:(NSMutableSet*)value;

- (Subscription*)primitiveSubscription;
- (void)setPrimitiveSubscription:(Subscription*)value;

@end
