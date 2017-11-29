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
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Response" message:[NSString stringWithFormat:@"%@ Added, status:%@", cardAdded.termination, cardAdded.status] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:FALSE];
                }];
                [alertC addAction:alertAction];
                [self presentViewController:alertC animated:NO completion:nil];
            }
        }];
        
    }
    
}
- (IBAction)scanCard:(id)sender {
    
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
