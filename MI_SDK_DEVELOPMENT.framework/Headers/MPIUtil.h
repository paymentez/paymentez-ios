#ifndef MPIUtil_h
#define MPIUtil_h

@interface MPIUtil : NSObject

+ (NSString *) asPostMessage:(NSDictionary *) json;
+ (NSMutableString *) digestValueString:(NSDictionary *) json withKeys:(NSArray *)keys;
+ (NSMutableDictionary *) stringToJSON:(NSString *)str withKeys:(NSArray *)keys;
+ (NSString *) getPublicKeyString:(NSString *) path;
+ (NSString *) getPrivateKeyString:(NSString *) path;
@end
#endif /* MPIUtil_h */
