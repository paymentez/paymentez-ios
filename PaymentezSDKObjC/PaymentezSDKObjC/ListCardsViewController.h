//
//  ListCardsViewController.h
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
//  Copyright © 2017 Paymentez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PaymentezSDK/PaymentezSDK-Swift.h>

@protocol CardSelectedDelegate

- (void) cardSelected:(PaymentezCard*)card;
@end

@interface ListCardsViewController : UITableViewController<PaymentezCardAddedDelegate>
@property (strong) id<CardSelectedDelegate>cardSelectedDelegate;
@property (strong) NSMutableArray *cardList;
@end
