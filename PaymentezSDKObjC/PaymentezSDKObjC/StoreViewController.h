//
//  StoreViewController.h
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
//  Copyright © 2017 Paymentez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaymentezSDK/PaymentezSDK-Swift.h>
#import "ListCardsViewController.h"


@interface StoreViewController : UIViewController <CardSelectedDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@end
