//
//  ViewController.m
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 10/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

#import "ViewController.h"
#import <PaymentezSDK/PaymentezSDK-Swift.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *amountTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)debitAction:(id)sender {
    PaymentezDebitParameters *parameters = [[PaymentezDebitParameters alloc] init];
    parameters.cardReference = self.cardReference;
    parameters.productAmount = [self.amountTextfield.text doubleValue];
    parameters.productDescription = @"Test";
    parameters.devReference = @"1234";
    parameters.vat = 0.10;
    parameters.email = @"gsotelo@paymentez.com";
    parameters.uid = @"gus";
    [PaymentezSDKClient debitCard:parameters    callback:^(PaymentezSDKError *error, PaymentezTransaction *transaction) {
       if ( error == nil)
       {
           NSString *message = [NSString stringWithFormat:@"%@", transaction.transactionId];
           dispatch_async(dispatch_get_main_queue(), ^{
               UIAlertController * alert=   [UIAlertController
                                             alertControllerWithTitle:@"Info"
                                             message:message
                                             preferredStyle:UIAlertControllerStyleAlert];
               
               UIAlertAction* ok = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
               
               [alert addAction:ok];
               [self presentViewController:alert animated:YES completion:nil];
           });
       }
    }];
}

@end
