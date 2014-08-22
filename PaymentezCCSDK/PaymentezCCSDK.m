//
//  PaymentezCCSDK.m
//  Credit Card API Handler
//
//  Created by Gustavo Sotelo on 25/03/14.
//  Copyright (c) 2014 Paymentez. All rights reserved.
//

#import "PaymentezCCSDK.h"
#import "DeviceCollectorSDK.h"

@interface PaymentezCCSDK()<DeviceCollectorSDKDelegate, NSURLConnectionDelegate>
@property(nonatomic, strong) NSURLConnection *urlConnection;
@property(nonatomic, strong) NSMutableDictionary *_requestData;
@property(nonatomic, strong) NSMutableData *_urlResponse;
@property(nonatomic, strong) NSString *appCode;
@property(nonatomic, strong) NSString *method;
@property(nonatomic, strong) NSString *digestPassword;
@property(nonatomic, strong) NSString *digestUsername;
@property (nonatomic) DeviceCollectorSDK *deviceCollector;
@property(nonatomic, strong) NSString *appKey;
@end

@implementation PaymentezCCSDK
@synthesize apiConnection;
@synthesize _requestData;
@synthesize handler = _handler;
@synthesize isDev;
@synthesize deviceCollector = _deviceCollector;
@synthesize appCode;
@synthesize appKey;
@synthesize _urlResponse;
@synthesize digestUsername;
@synthesize digestPassword;
@synthesize urlConnection;
@synthesize method;

#pragma mark Create Manager

+(PaymentezCCSDK *)sdkManagerWithDevConf:(BOOL)isDev withAppCode:(NSString*)appCode andAppKey:(NSString*)appKey digestUsername:(NSString*)digestUsername digestPassword:(NSString*)digestPassword
{
    static PaymentezCCSDK *sdkM = nil;
    sdkM = [[PaymentezCCSDK alloc]init];
    sdkM.isDev = isDev;
    sdkM.appCode = appCode;
    sdkM.appKey = appKey;
    sdkM.digestPassword = digestPassword;
    sdkM.digestUsername = digestUsername;
    sdkM._requestData = [[NSMutableDictionary alloc] init];
    return sdkM;
}
+(PaymentezCCSDK *)sdkManager{
    static PaymentezCCSDK *sdkM = nil;
    sdkM = [[PaymentezCCSDK alloc]init];
    //sdkM._requestData = [[NSMutableDictionary alloc] init];
    return sdkM;
}
#pragma mark Paymentez API Methods
-(void) addCard:(NSString*)userId email:(NSString*)email completionHandler:(void (^)(NSDictionary  *response, NSError*))handler
{
    self.method = @"add";
    self.handler = handler;
    NSString *sessionID = [self generateSessionID];
    NSString *url;
    if (isDev)
        url = [URL_DEV stringByAppendingString:@"/api/cc/add/"];
    else
        url = [URL_PROD stringByAppendingString:@"/api/cc/add/"];
    NSString *authTimestamp = [self generateAuthTimestamp];
    NSString *parameters = [NSString stringWithFormat:@"application_code=%@&email=%@&session_id=%@&uid=%@",  self.appCode, [self urlEncodeUsingEncoding:email], sessionID, userId];
    NSString *authToken = [self generateAuthTokenPaymentez:authTimestamp withParameters:parameters];
    NSString *stringData = [NSString stringWithFormat:@"?application_code=%@&email=%@&uid=%@&session_id=%@&auth_timestamp=%@&auth_token=%@",  self.appCode, email, userId, sessionID, authTimestamp, authToken];
    [[self _requestData] setValue:[url stringByAppendingString:[stringData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:@"url"];
    [[self deviceCollector] collect:sessionID];
    
}
-(NSString*) generateAuthTokenPaymentez:(NSString*)authTimestamp withParameters:(NSString*)parameters
{
    NSString *plain = [parameters stringByAppendingString:[NSString stringWithFormat:@"&%@&%@", authTimestamp, self.appKey]];
    //NSLog(@"PLAIN:%@",plain);
    NSData *dataIn = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
    NSString *hash=[macOut description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hash;
}
-(NSString*) generateAuthTimestamp
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%lu", (long)timestamp];
    //return @"1395938809639";
}
-(NSString *)urlEncodeUsingEncoding:(NSString*)unencodedString {
	NSString *encoded = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                            NULL,
                                                                            (CFStringRef)unencodedString,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                            kCFStringEncodingUTF8
                                                                            ));
    return encoded;
}
- (void) listCards:(NSString * )userId completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    self.method = @"list";
    self.handler = handler;
    NSString *url;
    if (isDev)
        url = [URL_DEV stringByAppendingString:@"/api/cc/list/"];
    else
        url = [URL_PROD stringByAppendingString:@"/api/cc/list/"];
    NSString *authTimestamp = [self generateAuthTimestamp];
    NSString *parameters = [NSString stringWithFormat:@"application_code=%@&uid=%@",  self.appCode, userId];
    NSString *authToken = [self generateAuthTokenPaymentez:authTimestamp withParameters:parameters];
    NSString *completeParameters = [NSString stringWithFormat:@"?application_code=%@&uid=%@&auth_timestamp=%@&auth_token=%@",  self.appCode, userId, authTimestamp, authToken];
    url = [url stringByAppendingString:[completeParameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
   NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

- (void) debitCard:(NSString * )cardReference amount:(NSNumber*)amount description:(NSString*)description devReference:(NSString*)devReference userId:(NSString*)userId email:(NSString*)email ipaddress:(NSString*)ipaddress completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    [self debitCard:cardReference amount:amount description:description devReference:devReference userId:userId email:email sellerId:nil ipaddress:ipaddress shippingStreet:nil shippingNumber:nil shippingCity:nil shippingZip:nil shippingState:nil shippingDistrict:nil shippingAdditionalInfo:nil completionHandler:handler];
}
// seller_id, shipping_street, shipping_house_number, shipping_city, shipping_zip, shipping_state, shipping_district, shipping_additional_address_info
- (void) debitCard:(NSString * )cardReference amount:(NSNumber*)amount description:(NSString*)description devReference:(NSString*)devReference userId:(NSString*)userId email:(NSString*)email sellerId:(NSString*)sellerId ipaddress:(NSString*)ipaddress shippingStreet:(NSString*)shippingStreet shippingNumber:(NSString*)shippingNumber shippingCity:(NSString*)shippingCity shippingZip:(NSString*)shippingZip shippingState:(NSString*)shippingState shippingDistrict:(NSString*)shippingDistrict shippingAdditionalInfo:(NSString*)shippingAdditionalInfo completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    //shipping_additional_address_info
    
    
    self.method = @"debit";
    self.handler = handler;
    NSString *sessionID = [self generateSessionID];
    NSString *url;
    if (isDev)
        url = [URL_DEV stringByAppendingString:@"/api/cc/debit/"];
    else
        url = [URL_PROD stringByAppendingString:@"/api/cc/debit/"];
    NSString *authTimestamp = [self generateAuthTimestamp];
    
    NSDictionary *params;
    @try{
    params =   @{ @"application_code"     : self.appCode,
                                        @"card_reference" : cardReference,
                                        @"dev_reference": devReference,
                                        @"email" :   [self urlEncodeUsingEncoding:email],
                                        @"ip_address": ipaddress,
                                        @"product_amount": [NSString stringWithFormat:@"%.02f",[amount floatValue]],
                                        @"product_description": [self urlEncodeUsingEncoding:description],
                                        @"session_id":sessionID,
                                        @"uid": userId,
             
                                };
    }
    @catch (NSException *e)
    {
        NSLog(@"%@",e);
        NSError *error = [NSError errorWithDomain:@"com.paymentez.ErrorParameters" code:61 userInfo:[NSDictionary dictionaryWithObject:@"one or more mandatory parameters are sent as nil" forKey:@"message"]];
        handler(nil,error);
        return;
    }
    NSMutableDictionary *parametersDict = [params mutableCopy];
    if (sellerId)
        [parametersDict setObject:sellerId forKey:@"seller_id"];
    if (shippingStreet)
        [parametersDict setObject:shippingStreet forKey:@"shipping_street"];
    if (shippingNumber)
        [parametersDict setObject:shippingNumber forKey:@"shipping_number"];
    if (shippingCity)
        [parametersDict setObject:shippingCity forKey:@"shipping_city"];
    if (shippingZip)
        [parametersDict setObject:shippingZip forKey:@"shipping_zip"];
    if (shippingState)
        [parametersDict setObject:shippingState forKey:@"shipping_state"];
    if (shippingDistrict)
        [parametersDict setObject:shippingDistrict forKey:@"shipping_district"];
    if (shippingAdditionalInfo)
        [parametersDict setObject:shippingAdditionalInfo forKey:@"shipping_additional_address_info"];
    
    NSArray *keys  = [[parametersDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[parametersDict objectForKey:obj1] compare:[parametersDict objectForKey:obj2]];
    }];
    NSString *parametersStr = @"";
    int n= 0;
    keys = [[parametersDict allKeys]
     sortedArrayUsingSelector:
     @selector(caseInsensitiveCompare:)];
    
    for(NSString *key in keys)
    {
        if (n == 0)
            parametersStr = [parametersStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key, [parametersDict objectForKey:key]]];
        else
            parametersStr = [parametersStr stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key, [parametersDict objectForKey:key]]];
        n++;
    }
    NSString *authToken = [self generateAuthTokenPaymentez:authTimestamp withParameters:parametersStr];
    NSString *completeParameters = [parametersStr stringByAppendingString:[NSString stringWithFormat:@"&auth_token=%@&auth_timestamp=%@",authToken, authTimestamp]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest setHTTPMethod: @"POST"];
    NSData *requestBodyData = [completeParameters dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody: requestBodyData];
    [[self _requestData] setValue:urlRequest forKey:@"urlRequest"];
    [[self _requestData] setValue:@"debit" forKey:@"method"];
    [[self deviceCollector] collect:sessionID];
    
}

/*
-(void) debitCardWithRequest:(NSURLRequest *)request
{
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
 
}
*/
- (void) deleteCard:(NSString * )cardReference userId:(NSString*)userId completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    self.method = @"delete";
    self.handler = handler;
    NSString *url;
    if (isDev)
        url = [URL_DEV stringByAppendingString:@"/api/cc/delete/"];
    else
        url = [URL_PROD stringByAppendingString:@"/api/cc/delete/"];
    NSString *authTimestamp = [self generateAuthTimestamp];
    NSString *parameters = [NSString stringWithFormat:@"application_code=%@&card_reference=%@&uid=%@",  self.appCode, cardReference, userId];
    NSString *authToken = [self generateAuthTokenPaymentez:authTimestamp withParameters:parameters];
    NSString *completeParameters =[NSString stringWithFormat:@"application_code=%@&card_reference=%@&uid=%@&auth_timestamp=%@&auth_token=%@",  self.appCode, cardReference, userId, authTimestamp, authToken];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *requestBodyData = [completeParameters dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody: requestBodyData];
    [urlRequest setHTTPMethod: @"POST"];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];}

- (NSString*) generateSessionID
{
    NSUUID  *uuid = [NSUUID UUID];
    NSLog(@"UUID: %@", [uuid UUIDString]);
    NSString *uuidstring = [uuid UUIDString];
    NSString *sessionId = [uuidstring stringByReplacingOccurrencesOfString:@"-" withString:@""];;
    NSRange range = NSMakeRange(0,1);
    NSLog(@"%@",sessionId);
    return [sessionId stringByReplacingCharactersInRange:range withString:@"i"];
}
- (void) generateSessionIDWithCollect:(BOOL)devConf completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
   self._requestData = [[NSMutableDictionary alloc] init];
   self.handler = handler;
    self.isDev = devConf;
    NSString *sessionID = [self generateSessionID];
    [[self _requestData] setValue:sessionID forKey:@"session_id"];
    [[self deviceCollector] collect:sessionID];
}

- (DeviceCollectorSDK *) deviceCollector {
    if (!_deviceCollector) {
        if ([self isDev])
        _deviceCollector = [[DeviceCollectorSDK alloc] initWithDebugOn:YES ];
        else
            _deviceCollector = [[DeviceCollectorSDK alloc] initWithDebugOn:NO ];
        if (![self isDev])
            [_deviceCollector setCollectorUrl:DC_TARGET_URL];
        else
            [_deviceCollector setCollectorUrl:DC_TARGET_URL_DEV];
        [_deviceCollector setMerchantId:DC_MERCHANT_ID];
        [_deviceCollector setDelegate:self];
        NSMutableArray *skipList = [[NSMutableArray alloc]init];
        [skipList addObject:DC_COLLECTOR_DEVICE_ID];
        [self.deviceCollector setSkipList:skipList];
    }
    return _deviceCollector;
} // end deviceCollector
- (void)onCollectorStart {
    //[self addStatusMessage:@"Collector Started"];
}

-(void)onCollectorSuccess {
    
    if ([self.method isEqualToString:@"add"])
    {
        self.handler(self._requestData,nil);
    }
    if([self.method isEqualToString:@"debit"])
    {
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:(NSMutableURLRequest*)[self._requestData objectForKey:@"urlRequest"] delegate:self];
    }
    else
    {
        self.handler(self._requestData, nil);
    }
    /*if ([method isEqualToString:@"debit"])
    {
        [self debitCardWithRequest:(NSURLRequest*)[self._requestData objectForKey:@"urlRequest"]];
    }*/
    //[self addStatusMessage:@"Collector Finished"];
    //[self addStatusMessage:@"All Done"];
}

- (void) onCollectorError:(int)errorCode withError:(NSError *)error {
    self.handler(nil,error);
    /*[self addStatusMessage:
     [NSString stringWithFormat:@"Collector finished with error: %@, error code %d",
      [error description], errorCode]];*/
}
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self._urlResponse = [[NSMutableData alloc] init];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.handler(nil,error);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self._urlResponse appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}
/*
-(NSString*) getIPAddress {
    id myhost =[NSClassFromString(@"NSHost") performSelector:@selector(currentHost)];
    if (myhost) {
        for (NSString* address in [myhost performSelector:@selector(addresses)]) {
            if ([address rangeOfString:@"::"].location == NSNotFound) {
                return address;
            }
        }
    }
    
    return @"127.0.0.1";
}
*/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError *myError = nil;
    if([self.method  isEqual: @"delete"])
    {
        NSDictionary *res = [NSDictionary dictionaryWithObject:@"OK" forKey:@"Response"];
        self.handler(res,nil);
    }
    else
    {
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self._urlResponse options:NSJSONReadingMutableLeaves error:&myError];
        
        self.handler(res,myError);
    }
    
}
-(void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *digestCredential = [NSURLCredential credentialWithUser:self.digestUsername password:self.digestPassword persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:digestCredential forAuthenticationChallenge:challenge];
}

@end
