// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Episode.h instead.

@import CoreData;

extern const struct EpisodeAttributes {
	__unsafe_unretained NSString *airDate;
	__unsafe_unretained NSString *downloaded;
	__unsafe_unretained NSString *episode;
	__unsafe_unretained NSString *episodeID;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *number;
	__unsafe_unretained NSString *overview;
	__unsafe_unretained NSString *rating;
	__unsafe_unretained NSString *season;
} EpisodeAttributes;

extern const struct EpisodeRelationships {
	__unsafe_unretained NSString *serie;
} EpisodeRelationships;

@class Serie;

@interface EpisodeID : NSManagedObjectID {}
@end

@interface _Episode : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) EpisodeID* objectID;

@property (nonatomic, strong) NSDate* airDate;

//- (BOOL)validateAirDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* downloaded;

@property (atomic) BOOL downloadedValue;
- (BOOL)downloadedValue;
- (void)setDownloadedValue:(BOOL)value_;

//- (BOOL)validateDownloaded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* episode;

@property (atomic) int32_t episodeValue;
- (int32_t)episodeValue;
- (void)setEpisodeValue:(int32_t)value_;

//- (BOOL)validateEpisode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* episodeID;

@property (atomic) int32_t episodeIDValue;
- (int32_t)episodeIDValue;
- (void)setEpisodeIDValue:(int32_t)value_;

//- (BOOL)validateEpisodeID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* number;

@property (atomic) int32_t numberValue;
- (int32_t)numberValue;
- (void)setNumberValue:(int32_t)value_;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* overview;

//- (BOOL)validateOverview:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* rating;

@property (atomic) float ratingValue;
- (float)ratingValue;
- (void)setRatingValue:(float)value_;

//- (BOOL)validateRating:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* season;

@property (atomic) int32_t seasonValue;
- (int32_t)seasonValue;
- (void)setSeasonValue:(int32_t)value_;

//- (BOOL)validateSeason:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Serie *serie;

//- (BOOL)validateSerie:(id*)value_ error:(NSError**)error_;

@end

@interface _Episode (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveAirDate;
- (void)setPrimitiveAirDate:(NSDate*)value;

- (NSNumber*)primitiveDownloaded;
- (void)setPrimitiveDownloaded:(NSNumber*)value;

- (BOOL)primitiveDownloadedValue;
- (void)setPrimitiveDownloadedValue:(BOOL)value_;

- (NSNumber*)primitiveEpisode;
- (void)setPrimitiveEpisode:(NSNumber*)value;

- (int32_t)primitiveEpisodeValue;
- (void)setPrimitiveEpisodeValue:(int32_t)value_;

- (NSNumber*)primitiveEpisodeID;
- (void)setPrimitiveEpisodeID:(NSNumber*)value;

- (int32_t)primitiveEpisodeIDValue;
- (void)setPrimitiveEpisodeIDValue:(int32_t)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveNumber;
- (void)setPrimitiveNumber:(NSNumber*)value;

- (int32_t)primitiveNumberValue;
- (void)setPrimitiveNumberValue:(int32_t)value_;

- (NSString*)primitiveOverview;
- (void)setPrimitiveOverview:(NSString*)value;

- (NSNumber*)primitiveRating;
- (void)setPrimitiveRating:(NSNumber*)value;

- (float)primitiveRatingValue;
- (void)setPrimitiveRatingValue:(float)value_;

- (NSNumber*)primitiveSeason;
- (void)setPrimitiveSeason:(NSNumber*)value;

- (int32_t)primitiveSeasonValue;
- (void)setPrimitiveSeasonValue:(int32_t)value_;

- (Serie*)primitiveSerie;
- (void)setPrimitiveSerie:(Serie*)value;

@end
