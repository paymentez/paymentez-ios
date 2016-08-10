//
//  AddCustomViewController.m
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 11/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

#import "AddCustomViewController.h"
#import <PaymentezSDK/PaymentezSDK-Swift.h>

@interface AddCustomViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cardHolder;
@property (weak, nonatomic) IBOutlet UITextField *cardNumber;
@property (weak, nonatomic) IBOutlet UITextField *expiryMonth;
@property (weak, nonatomic) IBOutlet UITextField *expiryYear;
@property (weak, nonatomic) IBOutlet UITextField *cvcText;

@end

@implementation AddCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addCard:(id)sender {
    
    
    [PaymentezSDKClient addCardForUser:@"gus" email:@"gsotelo@paymentez.com" expiryYear:self.expiryYear.text.intValue expiryMonth:self.expiryMonth.text.intValue holderName:self.cardHolder.text cardNumber:self.cardNumber.text cvc:self.cvcText.text callback:^(PaymentezSDKError *error, BOOL added) {
        if(added)
        {
            NSLog(@"addedSuccesful");
        }
        else
        {
            if([error shouldVerify])
            {
                NSString *verifyTrx = [error getVerifyTrx];
                NSLog(@"%@", verifyTrx);
            }
        }
        
    }];
    [PaymentezSDKClient verifyWithCode:@"code" uid:@"your_uid" verificationCode:@"verfiy_Code" callback:^(PaymentezSDKError *error, NSInteger attempts, PaymentezTransaction *transaction) {
        
        if(transaction != nil)
        {
            //verified
        }
        else
        {
            if (attempts > 0)
            {
                //you still have attempts
            }
        }
        
    }];
    
    
}
- (IBAction)scanCard:(id)sender {
    
    [PaymentezSDKClient scanCard:self callback:^(BOOL cancelled, NSString *number, NSString *expiry, NSString *cvc) {
        if (!cancelled)
        {
            self.cardNumber.text = number;
            NSArray *expiryArray = [expiry componentsSeparatedByString: @"/"];
            self.expiryYear.text = expiryArray[1];
            self.expiryMonth.text = expiryArray[0];
            self.cvcText.text = cvc;
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
