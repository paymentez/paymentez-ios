# ccapi-ios-example

**

Paymentez SDK IOS
-----------------

** 


----------
**Requirements**

 - iOS 9.0 or Later
 - Xcode 7
 
 


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

InputMask -> https://github.com/RedMadRobot/input-mask-ios
 
 **Project Configuration**
-ObjC in other linker flags in target
-lc++ in target other linker flags


----------
**INSTALLATION**

 1. Build Project PaymentezSDK with the desire configuration simulator or device
 2. Drag PaymentezSDK.framework to your project
 3. Add PaymentezSDK.framework to Embeeded Libraries
 
**Carthage**

If you haven't already, install the latest version of [Carthage](https://github.com/Carthage/Carthage)

Add this to the Cartfile:

``` git "https://github.com/paymentez/paymentez-ios.git" ```

This will add also InputMask framework so you can added to your project

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

### Scan Card
If you want to do the scan yourself.

```swift
PaymentezSDKClient.scanCard(self) { (closed, number, expiry, cvv) in
            if !closed // user did not closed the scan card dialog
            {
            })
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
 	PaymentezSDKClient.createToken(card, uid: "69123", email: "gsotelo@paymentez.com", callback: { (error, cardAdded) in
            
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


### Secure Session Id

Debit actions should be implemented in your own backend. For security reasons we provide a secure session id generation, for kount fraud systems. This will collect the device information in background

```swift
        let sessionId = PaymentezSDKClient.getSecureSessionId()
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
