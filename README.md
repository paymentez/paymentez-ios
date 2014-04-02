ccapi-lib-ios
=============

#CCAPI Library for iOS

##Contents:
-TestLibrary:  is an application example that uses the Paymentez CCAPI.
-PaymentezCCDK: SDK for Paymentez CC API
-DeviceCollectorLibrary: Kount IOS Library

##Installation:
1.- Include Kount IOS library (DeviceCollectoryLibrary folder) for help please check documentation :iOS_mobile_sdk_guide_v2.5
2.- Include the SDK manager (PaymentezCCDK folder) 


##Usage:
###Initialization
```
 PaymentezCCSDK *apiManager = [PaymentezCCSDK sdkManagerWithDevConf:true withAppCode:@"ST-MX" andAppKey:@"vgVfq0kLZveGIdD9ljGjPtt6ieYtIQ" digestUsername:@"PREPAID" digestPassword:@"Ere68ttPklFTn89xZIhFYcqC5X8HX3Ob5qgbEkfjNfCLkud3wY"];
```
###Add
```
 [apiManager addCard:@"1234" email:@"martin.mucito@gmail.com" completionHandler:^(NSDictionary *response, NSError *error) {
        NSLog(@"response:%@",response);
        NSLog(@"error:%@",error);
        if(!error)
        {
            NSString *url = (NSString*)[response objectForKey:@"url"];
            NSLog(@"%@", url);
            NSURL *nsUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            
            [self.webView loadRequest:request];
            
        }
    }];
```
### List
```
apiManager listCards:@"1234" completionHandler:^(NSDictionary *response, NSError *error) {
        NSLog(@"response:%@",response);
        NSLog(@"error:%@",error);
        
        if(!error)
        {
            
            //handle response
            
        }
    }];

```
### DEBIT

```
[apiManager debitCard:self.card_reference amount:[NSNumber numberWithFloat:10.0] description:@"test" devReference:@"1234567" userId:@"1234" email:@"martin.mucito@gmail.com" completionHandler:^(NSDictionary *response, NSError *error) {
        NSLog(@"response:%@",response);
        NSLog(@"error:%@",error);
        
        if(!error)
        {
            
            // success handle
            
        }
    }];
```
### Delete

```
[apiManager deleteCard:self.card_reference userId:@"1234" completionHandler:^(NSDictionary *response, NSError *error) {
        NSLog(@"response:%@",response);
        NSLog(@"error:%@",error);
        
        if(!error)
        {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"%@",error ]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];

```
### Generate SESSION ID WITH COLLECT
```
[apiManager generateSessionIDWithCollect:YES completionHandler:^(NSDictionary *response, NSError *error) {
        NSLog(@"response:%@",response);
        NSLog(@"error:%@",error);
        if(!error)
        {
            NSString *sessionId = (NSString*)[response objectForKey:@"sessionId"];
            
        }
    }];
```
First Parameter YES for dev environment, NO for production