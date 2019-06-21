#import <Foundation/Foundation.h>

@interface ChallengeParameters : NSObject {
}
@property (nonatomic, retain) NSString *threeDSServerTransactionID;
@property (nonatomic, retain) NSString *acsTransactionID;
@property (nonatomic, retain) NSString *acsRefNumber;
@property (nonatomic, retain) NSString *acsSignedContent;

+ (ChallengeParameters *) createCopy:(ChallengeParameters *)origParams;

@end
