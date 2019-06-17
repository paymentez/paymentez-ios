@protocol MerchantTransaction;
@class UiCustomization;
@class ConfigParameters;

@protocol Merchant

- (void) initialize:(ConfigParameters *) configParameters
    locale:(NSLocale *)locale
    uiCustomization:(UiCustomization *) uiCustomization;

- (id<MerchantTransaction>) createTransaction:(NSString *)paymentSystemId;

- (id<MerchantTransaction>) createTransaction:(NSString *)paymentSystemId messageVersion:(NSString *)messageVersion;

- (void) cleanup;

- (NSString *) getSDKVersion;

- (NSArray *) getWarnings;

@end
