// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Subscription.h instead.

@import CoreData;

extern const struct SubscriptionAttributes {
	__unsafe_unretained NSString *filters;
	__unsafe_unretained NSString *isEnabled;
	__unsafe_unretained NSString *lastDownloaded;
	__unsafe_unretained NSString *quality;
} SubscriptionAttributes;

extern const struct SubscriptionRelationships {
	__unsafe_unretained NSString *serie;
} SubscriptionRelationships;

@class Serie;

@class NSObject;

@interface SubscriptionID : NSManagedObjectID {}
@end

@interface _Subscription : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SubscriptionID* objectID;

@property (nonatomic, strong) id filters;

//- (BOOL)validateFilters:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isEnabled;

@property (atomic) BOOL isEnabledValue;
- (BOOL)isEnabledValue;
- (void)setIsEnabledValue:(BOOL)value_;

//- (BOOL)validateIsEnabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastDownloaded;

//- (BOOL)validateLastDownloaded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* quality;

@property (atomic) float qualityValue;
- (float)qualityValue;
- (void)setQualityValue:(float)value_;

//- (BOOL)validateQuality:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Serie *serie;

//- (BOOL)validateSerie:(id*)value_ error:(NSError**)error_;

@end

@interface _Subscription (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveFilters;
- (void)setPrimitiveFilters:(id)value;

- (NSNumber*)primitiveIsEnabled;
- (void)setPrimitiveIsEnabled:(NSNumber*)value;

- (BOOL)primitiveIsEnabledValue;
- (void)setPrimitiveIsEnabledValue:(BOOL)value_;

- (NSDate*)primitiveLastDownloaded;
- (void)setPrimitiveLastDownloaded:(NSDate*)value;

- (NSNumber*)primitiveQuality;
- (void)setPrimitiveQuality:(NSNumber*)value;

- (float)primitiveQualityValue;
- (void)setPrimitiveQualityValue:(float)value_;

- (Serie*)primitiveSerie;
- (void)setPrimitiveSerie:(Serie*)value;

@end
