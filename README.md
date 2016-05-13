
**

Paymentez SDK IOS
-----------------

** 


----------
**Requirements**

 - iOS 8.3 or Later
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
 
 **Project Configuration**
-ObjC in other linker flags in target
-lc++ in target other linker flags


----------
**INSTALLATION**

 1. Drag PaymentezSDK.framework to your project
 2. Add PaymentezSDK.framework to Embeeded Libraries
 3. (For Objc-C) Set Build Options -> Embeeded Content containts Swift Code -> Yes
 
 


----------
**Usage**

Importing Objc

    #import <PaymentezSDK/PaymentezSDK-Swift.h>

Importing Swift

    import PaymentezSDK

Setting up your app,. inside AppDelegate->didFinishLaunchingWithOptions

    PaymentezSDKClient.setEnvironment("AbiColApp", secretKey: "2PmoFfjZJzjKTnuSYCFySMfHlOIBz7", testMode: true)


Sample app shows all the methods available


> Written with [StackEdit](https://stackedit.io/).