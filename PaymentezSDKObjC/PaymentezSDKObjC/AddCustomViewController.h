//
//  AddCustomViewController.h
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 11/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaymentezSDK/PaymentezSDK-Swift.h>

@interface AddCustomViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong) PaymentezAddNativeViewController *paymentezAddVC;
@end
