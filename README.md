
**

Paymentez SDK IOS
-----------------

**


----------
**Requirements**

- iOS 9.0 or Later
- Xcode 8




**Framework Dependencies:**

Accelerate
AudioToolbox
AVFoundation
CoreGraphics
CoreMedia
CoreVideo
Foundation
MobileCoreServices
OpenGLES
QuartzCore
Security
UIKit
CommonCrypto


**Project Configuration**
-ObjC in other linker flags in target
-lc++ in target other linker flags


----------
**INSTALLATION**



**Carthage**

If you haven't already, install the latest version of [Carthage](https://github.com/Carthage/Carthage)

Add this to the Cartfile:

``` git "https://github.com/paymentez/paymentez-ios.git" ```

This will add also InputMask framework so you can added to your project

**ObjC configuration**

Set ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

In Build Phases -> Embed Frameworks Uncheck "Copy Only When Installing"

**Manual Installation**

PaymentezSDK is a dynamic framework ([More Info](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)) so you have to build each version for the desire target (simulator and device). To make the integration easy, you can follow these instructions in order to have just one Universal .framework file.

1. Build the SDK and create .framework files

- If you want build yourself the SDK or you are using a new/beta version of Xcode . Download the project from github and run the following script inside the root folder

    ```
    sh package.sh

    ```
    This will create a /build folder where there are all the necesary .framework (simulator, iphoneos and universal)
    

- Or if you prefer you can download pre-compilled .framework files from [Releases](https://github.com/paymentez/paymentez-ios/releases)

2. Drag the PaymentezSDK.framework (preferably Universal version) To your project and check "Copy Files if needed".

    In Target->General : Add PaymentezSDK.framework to Embeeded Libraries and Linked Frameworks and  Libraries
    
    ![Example](https://s3.amazonaws.com/cdn.paymentez.com/apps/ios/tutorial2.gif)


3. Update the Build Settings with

    Set ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

    In Build Phases -> Embed Frameworks Uncheck "Copy Only When Installing"

![Example](https://s3.amazonaws.com/cdn.paymentez.com/apps/ios/tutorial3.gif)


4. If you use the Universal version and you want to upload to the appstore. Add Run Script Phase: Target->Build Phases -> + ->New Run Script Phase. And paste the following. Make sure that this build phase is added after Embed Frameworks phase.
    ```
    bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/PaymentezSDK.framework/install_dynamic.sh"
    ```
    ![Example](https://s3.amazonaws.com/cdn.paymentez.com/apps/ios/tutorial4.gif)
----------
**Usage**

Importing Swift

import PaymentezSDK

Setting up your app inside AppDelegate->didFinishLaunchingWithOptions. You should use the Paymentez Client Credentials (Just ADD enabled)

PaymentezSDKClient.setEnvironment("AbiColApp", secretKey: "2PmoFfjZJzjKTnuSYCFySMfHlOIBz7", testMode: true)


###Show AddCard Widget

In order to create a widget you should create a PaymentezAddNativeController from the PaymentezSDKClient. Then add it to the UIView that will be the container of the add form. The min height should be 160 px

The widget can scan with your phones camera the credit card data using card.io.
![Example](https://developers.paymentez.com/wp-content/uploads/2017/10/ios-example.png)

```swift
let paymentezAddVC = PaymentezSDKClient.createAddWidget()
self.addChildViewController(paymentezAddVC)
paymentezAddVC.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.addView.frame.size.height)
self.addView.translatesAutoresizingMaskIntoConstraints = true
self.addView.addSubview(paymentezAddVC.view)
paymentezAddVC.didMove(toParentViewController: self)
```

Objc

```objc
self.paymentezAddVC = [PaymentezSDKClient createAddWidget];
[self addChildViewController:self.paymentezAddVC];
self.paymentezAddVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.addView.frame.size.height);
self.addView.translatesAutoresizingMaskIntoConstraints = YES;
[self.addView addSubview:self.paymentezAddVC.view];
[self.paymentezAddVC didMoveToParentViewController:self];

```
Retrive the valid credit card from the PaymentezAddNativeController (Widget):

```swift
if let validCard = paymentezAddVC.getValidCard() // CHECK IF THE CARD IS VALID, IF THERE IS A VALIDATION ERROR NIL VALUE WILL BE RETURNED
{
sender?.isEnabled = false
PaymentezSDKClient.createToken(validCard, uid: UserModel.uid, email: UserModel.email, callback: { (error, cardAdded) in

if cardAdded != nil // handle the card status
{
}
else if error != nil //handle the error
{
}
})
}
```

Objc
```objc
PaymentezCard *validCard = [self.paymentezAddVC getValidCard];
if (validCard != nil) // Check if it is avalid card
{

[PaymentezSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentezSDKError *error, PaymentezCard *cardAdded) {
[sender setEnabled:YES];
if(cardAdded != nil) // handle the card status
{

}
else  //handle the error
{

}
}];
}
```


### Scan Card
If you want to do the scan yourself, using card.io

```swift
PaymentezSDKClient.scanCard(self) { (closed, number, expiry, cvv, card) in
if !closed // user did not closed the scan card dialog
{
if card != nil  // paymentezcard object to handle the data
{

}
})
```

-ObjC
```objc
[PaymentezSDKClient scanCard:self callback:^(BOOL userClosed, NSString *cardNumber, NSString *expiryDate, NSString *cvv, PaymentezCard *card) {

if (!userClosed) //user did not close the scan card dialog
{
if (card != nil) // Handle card
{

}

}
}];
```

### Add Card (Only PCI Integrations)

For custom form integrations
Fields required
+ cardNumber: card number as a string without any separators, e.g. 4111111111111111.
+ cardHolder: cardholder name.
+ expuryMonth: integer representing the card's expiration month, 01-12.
+ expiryYear: integer representing the card's expiration year, e.g. 2020.
+ cvc: card security code as a string, e.g. '123'.

```swift
let card = PaymentezCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")

if card != nil  // A valid card was created
{
PaymentezSDKClient.add(card, uid: "69123", email: "gsotelo@paymentez.com", callback: { (error, cardAdded) in

if cardAdded != nil
{
//the request was succesfully sent, you should check the cardAdded status
}

})
}
else
{
//handle invalid card
}
```

ObjC

```objc
PaymentezCard *validCard = [PaymentezCard createCardWithCardHolder:@"Gustavo Sotelo" cardNumber:@"4111111111111111" expiryMonth:10 expiryYear:2020 cvc:@"123"];
if (validCard != nil) // Check if it is avalid card
{

[PaymentezSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentezSDKError *error, PaymentezCard *cardAdded) {
[sender setEnabled:YES];
if(cardAdded != nil) // handle the card status
{

}
else  //handle the error
{

}
}];
}

```


### Secure Session Id

Debit actions should be implemented in your own backend. For security reasons we provide a secure session id generation, for kount fraud systems. This will collect the device information in background

```swift
let sessionId = PaymentezSDKClient.getSecureSessionId()
```
Objc

```objc
NSString *sessionId = [PaymentezSDKClient getSecureSessionId];
```

### Utils

Get Card Assets

```swift
let card = PaymentezCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")
if card != nil  // A valid card was created
{
let image = card.getCardTypeAsset()

}
```

Get Card Type
```swift
let card = PaymentezCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")
if card != nil  // A valid card was created
{
switch(card.cardType)
{
case .amex:
case .masterCard:
case .visa:
case .diners:
default:
//not supported action
}

}
```

### Building and Running the PaymentezSwift

Before you can run the PaymentezStore application, you need to provide it with your APP_CODE, APP_SECRET_KEY and a sample backend.

1. If you haven't already and APP_CODE and APP_SECRET_KEY, please ask your contact on Paymentez Team for it.
2. Replace the `PAYMENTEZ_APP_CODE` and `PAYMENTEZ_APP_SECRET_KEY` in your AppDelegate as shown in Usage section
3. Head to https://github.com/paymentez/example-java-backend and click "Deploy to Heroku" (you may have to sign up for a Heroku account as part of this process). Provide your Paymentez Server Credentials APP_CODE and  APP_SECRET_KEY fields under 'Env'. Click "Deploy for Free".
4. Replace the `BACKEND_URL` variable in the MyBackendLib.swift (inside the variable myBackendUrl) with the app URL Heroku provides you with (e.g. "https://my-example-app.herokuapp.com")
5. Replace the variables (uid and email) in UserModel.swift  with your own user id reference

