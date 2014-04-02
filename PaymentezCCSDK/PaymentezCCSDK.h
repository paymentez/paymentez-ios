//
//  PaymentezCCSDK.h
//  Credit Card API methods
//
//  Created by Gustavo Sotelo on 25/03/14.
//  Copyright (c) 2014 Paymentez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#define URL_PROD @"https://pmntzsec.paymentez.com"
#define URL_DEV @"https://pmntzsec-stg.paymentez.com"


#define PAYMENTEZ_API_DIGEST @"PM2.0-API" //REPLACE WITH YOUR DIGEST

// KOUNT
#define DC_TARGET_URL_DEV @"https://tst.kaptcha.com/logo.htm"
#define DC_TARGET_URL @"https://ssl.kaptcha.com/logo.htm"
#define DC_MERCHANT_ID @"500005"



@interface PaymentezCCSDK  : NSObject
@property (copy) void (^handler)(NSDictionary *, NSError *);
@property(nonatomic, strong) NSURLConnection *apiConnection;
@property(nonatomic, assign) BOOL isDev;

+(PaymentezCCSDK *)sdkManager;
+(PaymentezCCSDK *)sdkManagerWithDevConf:(BOOL)isDev withAppCode:(NSString*)appCode andAppKey:(NSString*)appKey digestUsername:(NSString*)digestUsername digestPassword:(NSString*)digestPassword;
-(void) addCard:(NSString*)userId email:(NSString*)email completionHandler:(void (^)(NSDictionary *,NSError*))handler;
-(void) listCards:(NSString * )userId completionHandler:(void (^)(NSDictionary*, NSError*))handler;
-(void) debitCard:(NSString * )cardReference amount:(NSNumber*)amount description:(NSString*)description devReference:(NSString*)devReference userId:(NSString*)userId email:(NSString*)email completionHandler:(void (^)(NSDictionary*, NSError*))handler;
-(void) deleteCard:(NSString * )cardReference userId:(NSString*)userId completionHandler:(void (^)(NSDictionary*, NSError*))handler;
- (void) generateSessionIDWithCollect:(BOOL)isDev completionHandler:(void (^)(NSDictionary*, NSError*))handler;

@end
