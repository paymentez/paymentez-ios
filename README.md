**

Payment SDK IOS
-----------------

**


----------
### Requirements 

*Version <= 1.4.x*
- iOS 9.0 or Later
- Xcode 9

*Version >= 1.5.x*
- iOS 9.0 or Later
- Xcode 10


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
CommonCrypto (Just for version 1.4)


**Project Configuration**
- ObjC in other linker flags in target
- lc++ in target other linker flags
- Disable Bitcode


----------
# INSTALLATION

**Carthage**

If you haven't already, install the latest version of [Carthage](https://github.com/Carthage/Carthage)

Add this to the Cartfile:

``` git "https://github.com/paymentez/paymentez-ios.git" ```

For Beta Versions:

``` git "https://github.com/paymentez/paymentez-ios.git" "master" ```


**ObjC configuration**

Set ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

In Build Phases -> Embed Frameworks Uncheck "Copy Only When Installing"

# **Manual Installation(Recommended)**









SDK is a dynamic framework ([More Info](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)) so you have to build each version for the desire target (simulator and device). To make the integration easy, you can follow these instructions in order to have just one Universal .framework file.

1. Build the SDK and create .framework files

This will create a /build folder where there are all the necesary .framework (simulator, iphoneos and universal)
 
- With Target PaymentSDK selected, build the project for any iOS Simulator.
- With Target PaymentSDK selected, build the project for a physical device.

After

- With the Target PaymentezSDK-Universal,  build the project for any iOS device. 
- Inside the group Products -> PaymentSDK.framework -> Show in finder
- Inside the the directory of PaymentSDK.framework, CMD+up
- You can see three groups, inside the group Release-iosuniversal, you'll find the PaymentSDK.framework

- Or if you prefer you can download pre-compilled .framework files from [Releases](https://github.com/globalpayredeban/globalpayredeban-ios/releases)


2. Drag the PaymentSDK.framework To your project and check "Copy Files if needed".

In Target->General : Add PaymentSDK.framework to Frameworks, Libraries, and Embedded Content

In Target->Build Settings : Validate Workspace should be YES

3. Update the Build Settings with

Set ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

In Build Phases -> Embed Frameworks Uncheck "Copy Only When Installing"

4. If you use the Universal version and you want to upload to the appstore. Add Run Script Phase: Target->Build Phases -> + ->New Run Script Phase. And paste the following. Make sure that this build phase is added after Embed Frameworks phase.
```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/PaymentSDK.framework/install_dynamic.sh"
```

----------
**Usage**

Importing Swift

import PaymentSDK

Setting up your app inside AppDelegate->didFinishLaunchingWithOptions. You should use the Payment Client Credentials (Just ADD enabled)

PaymentSDKClient.setEnvironment("AbiColApp", secretKey: "2PmoFfjZJzjKTnuSYCFySMfHlOIBz7", testMode: true)


# Types of implementation

There are 3 ways to present the Add Card Form:

1. As a Widget in a Custom View
2. As a Viewcontroller Pushed to your UINavigationController
3. As a ViewController  presented in Modal

The AddCard Form includes: Card io scan, and card validation.

## Show AddCard Widget

In order to create a widget you should create a PaymentAddNativeController from the PaymentSDKClient. Then add it to the UIView that will be the container of the Payment Form. The min height should be 300 px, and whole screen as width (270px without payment logo)

**Note:**  *When you are using the Payment Form as Widget. The Client custom ViewController will be responsible for the layout and synchronization (aka Spinner or loading)*

The widget can scan with your phones camera the credit card data using card.io.


```swift
let paymentAddVC = self.addPaymentWidget(toView: self.addView, delegate: nil, uid:UserModel.uid, email:UserModel.email)

```

Objc

```objc


[self addPaymentWidgetToView:self. addView delegate:self uid:@"myuid" email:@"myemail"];

```
Retrive the valid credit card from the PaymentAddNativeController (Widget):

```swift
if let validCard = paymentAddVC.getValidCard() // CHECK IF THE CARD IS VALID, IF THERE IS A VALIDATION ERROR NIL VALUE WILL BE RETURNED
{
sender?.isEnabled = false
PaymentSDKClient.createToken(validCard, uid: UserModel.uid, email: UserModel.email, callback: { (error, cardAdded) in

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
PaymentCard *validCard = [self.paymentAddVC getValidCard];
if (validCard != nil) // Check if it is avalid card
{

[PaymentSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentSDKError *error, PaymentCard *cardAdded) {
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
## Pushed to your NavigationController


```swift
self.navigationController?.pushPaymentViewController(delegate: self, uid: UserModel.uid, email: UserModel.email)

```

Objc

```objc


[self.navigationController pushPaymentViewControllerWithDelegate:self uid:@"myuid" email:@"mymail@mail.com"]`;
```

## Present as Modal


```swift
self.presentPaymentViewController(delegate: self, uid: "myuid", email: "myemail@email.com")

```

Objc

```objc

[self presentPaymentViewControllerWithDelegate:self uid:@"myuid" email:@"myemail@email.com"];
```


###  PaymentCardAddedDelegate Protocol

If you present the Form as a viewcontroller (push and modal)  you must implement the PaymetnezCardAddedDelegate Protocol in order to handle the states or actions inside the Viewcontroller. If you are using Widget implementation you can handle the actions as described above.

```swift
protocol PaymentCardAddedDelegate
{
func cardAdded(_ error:PaymentSDKError?, _ cardAdded:PaymentCard?)
func viewClosed()
}
```
`func cardAdded(_ error:PaymentSDKError?, _ cardAdded:PaymentCard?)`  is called whenever there is an error or a card is added.

`func viewClosed()`  Whenever the modal is closed


### Scan Card
If you want to do the scan yourself, using card.io

```swift
PaymentSDKClient.scanCard(self) { (closed, number, expiry, cvv, card) in
if !closed // user did not closed the scan card dialog
{
if card != nil  // paymentcard object to handle the data
{

}
})
```

-ObjC
```objc
[PaymentSDKClient scanCard:self callback:^(BOOL userClosed, NSString *cardNumber, NSString *expiryDate, NSString *cvv, PaymentCard *card) {

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
let card = PaymentCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")

if card != nil  // A valid card was created
{
PaymentSDKClient.add(card, uid: "69123", email: "gsotelo@globalpay.com", callback: { (error, cardAdded) in

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
PaymentCard *validCard = [PaymentCard createCardWithCardHolder:@"Gustavo Sotelo" cardNumber:@"4111111111111111" expiryMonth:10 expiryYear:2020 cvc:@"123"];
if (validCard != nil) // Check if it is avalid card
{

[PaymentSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentSDKError *error, PaymentCard *cardAdded) {
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
let sessionId = PaymentSDKClient.getSecureSessionId()
```
Objc

```objc
NSString *sessionId = [PaymentSDKClient getSecureSessionId];
```

### Utils

Get Card Assets

```swift
let card = PaymentCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")
if card != nil  // A valid card was created
{
let image = card.getCardTypeAsset()

}
```

Get Card Type (Just Amex, Mastercard, Visa, Diners)
```swift
let card = PaymentCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")
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

### Customize Look & Feel 


You can customize widget colors sample 

```swift
paymentAddVC.baseFontColor = .white
paymentAddVC.baseColor = .green
paymentAddVC.backgroundColor = .white
paymentAddVC.showLogo = false
paymentAddVC.baseFont = UIFont(name: "Your Font", size: 12) ?? UIFont.systemFont(ofSize: 12)

```

The customizable elements of the form are the following:

- `baseFontColor` : The color of the font of the fields
- `baseColor`: Color of the lines and titles of the fields
- `backgroundColor`: Background color of the widget
- `showLogo`: Enable or disable Payment Logo 
- `baseFont`: Font of the entire form
- `nameTitle`: String for the custom placeholder for the Name Field
- `cardTitle`: String for the custom placeholder for the Card Field
- `invalidCardTitle` String for the error message when a card number is invalid


### Building and Running the PaymentSwift

Before you can run the PaymentStore application, you need to provide it with your APP_CODE, APP_SECRET_KEY and a sample backend.

1. If you haven't already and APP_CODE and APP_SECRET_KEY, please ask your contact on Payment Team for it.
2. Replace the `PAYMENT_APP_CODE` and `PAYMENT_APP_SECRET_KEY` in your AppDelegate as shown in Usage section
3.  Head to https://github.com/paymentez/example-java-backend and click "Deploy to Heroku" (you may have to sign up for a Heroku account as part of this process). Provide your Paymentez Server Credentials APP_CODE and  APP_SECRET_KEY fields under 'Env'. Click "Deploy for Free".
4. Replace the `BACKEND_URL` variable in the MyBackendLib.swift (inside the variable myBackendUrl) with the app URL Heroku provides you with (e.g. "https://my-example-app.herokuapp.com")
5. Replace the variables (uid and email) in UserModel.swift  with your own user id reference
