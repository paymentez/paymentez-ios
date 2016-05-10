//
//  ViewController.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 27/04/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var amountTextfield: UITextField!
    var cardReference = "22"
    override func viewDidLoad() {
        super.viewDidLoad()
        
       /*PaymentezSDK.addCard("1234567893", email: "gsotelo@paymentez.com", expiryYear: 2018, expiryMonth: 9, holderName: "Gustavo Sotelo", cardNumber: "4111111111111111", cvc: "123") { (error, added) in
            print (error)
            
            if error != nil
            {
                if error!.shouldVerify()
                {
                    let trx = error!.getVerifyTrx()
                    PaymentezSDK.verifyWithCode(trx, uid: "1234567893", verificationCode: "1234" , callback: { (error, attemptsRemaining, transaction) in
                        
                        if error != nil
                        {
                            
                        }
                        
                        
                    })
                }
            }
            
        }*/
        
        /*PaymentezSDK.verifyWithCode("CB-5964", uid: "1234567893", verificationCode: "003361" , callback: { (error, attemptsRemaining, response) in
            
            if error != nil
            {
                
            }
            
            
        })*/
        /*let trx = "CB-5931"
        PaymentezSDK.verifyWithCode(trx, uid: "1234567893", verificationCode: "1234" , callback: { (error, response) in
         
        })*/
        // Do any additional setup after loading the view, typically from a nib.
      /*PaymentezSecure.getIpAddress { (ipAddress) in
        print(ipAddress)
        }*/
       /*PaymentezSDK.cardList("gus") { (err, cardList) in
                print(cardList)
        }*/
       /* PaymentezSDK.verifyWithCode("CB-5819", uid: "abi", verificationCode: "12345") { (error, response) in
            print(response)
        }*/
        
        
        /*PaymentezSDK.deleteCard("1234567893", cardReference: "8179362525771533233") { (error, wasDeleted) in
            
            if error != nil
            {
                print(error?.description)
            }
        }*/
       /* PaymentezSDK.addCard("gus", email: "gsotelo@paymentez.com", expiryYear: 2018, expiryMonth: 9, holderName: "Gustavo Sotelo", cardNumber: "4111111111111111", cvc: "123") { (error, added) in
            print (error)
            

            
        }*/
 
        
    }
    @IBAction func debitAction(sender: AnyObject) {
        let parameters = PaymentezDebitParameters()
        parameters.cardReference = self.cardReference
        parameters.productAmount = Double(self.amountTextfield.text!)!
        parameters.productDescription = "Test"
        parameters.devReference = "1234"
        parameters.vat = 0.10
        parameters.email = "gsotelo@paymentez.com"
        parameters.uid = "gus"
        PaymentezSDK.debitCard(parameters) { (error, transaction) in
            
            if error == nil
            {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertC = UIAlertController(title: "Success", message: "transaction_id:\(transaction?.transactionId), status:\(transaction?.status)", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertC.addAction(defaultAction)
                    self.presentViewController(alertC, animated: true
                        , completion: {
                            
                    })
                })
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

