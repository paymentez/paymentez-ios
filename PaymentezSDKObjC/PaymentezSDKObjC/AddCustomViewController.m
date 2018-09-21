//
//  AddCustomViewController.m
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 11/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

#import "AddCustomViewController.h"
#import "UserModel.h"
#import <PaymentezSDK/PaymentezSDK-Swift.h>

@interface AddCustomViewController ()

@end

@implementation AddCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addPaymentezWidgetToView:self. addView delegate:self uid:"myuid" email:"myemail"]
    
    
   
    self.paymentezAddVC = [PaymentezSDKClient createAddWidget];
    [self addChildViewController:self.paymentezAddVC];
    self.paymentezAddVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.addView.frame.size.height);
    self.addView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.addView addSubview:self.paymentezAddVC.view];
    [self.paymentezAddVC didMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addCard:(UIButton*)sender {
    
    
    PaymentezCard *validCard = [self.paymentezAddVC getValidCard];
    if (validCard != nil)
    {
        
        [self.activityIndicator startAnimating];
        [sender setEnabled:FALSE];
        
        [PaymentezSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentezSDKError *error, PaymentezCard *cardAdded) {
            [sender setEnabled:YES];
            if(cardAdded != nil)
            {
                NSLog(@"%@",[cardAdded getJSONString]); // Print JSON sTRUCTURE
                dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Response" message:[NSString stringWithFormat:@"%@ Added, status:%@", cardAdded.termination, cardAdded.status] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:FALSE];
                }];
                [alertC addAction:alertAction];
                [self presentViewController:alertC animated:NO completion:nil];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"code:%i, description:%@ help:%@",error.code, error.description, error.help]  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popViewControllerAnimated:FALSE];
                    }];
                    [alertC addAction:alertAction];
                    [self presentViewController:alertC animated:NO completion:nil];
                });
            }
        }];
        
    }
    
}
- (IBAction)scanCard:(id)sender {
    
    [PaymentezSDKClient scanCard:self callback:^(BOOL userClosed, NSString *cardNumber, NSString *expiryDate, NSString *cvv, PaymentezCard *card) {
        
        if (!userClosed)
        {
            if (card != nil) // Handle card
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Response" message:[NSString stringWithFormat:@"%@ Card, cvv:%@, expiry:%@", card.termination, cvv, expiryDate] preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertC addAction:alertAction];
                    [self presentViewController:alertC animated:NO completion:nil];
                });
            }
                
        }
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
