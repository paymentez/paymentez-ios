//
//  ViewController.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 27/04/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK

class ViewController: UIViewController {
    @IBOutlet weak var amountTextfield: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var verifyButton: UIButton!
    var cardReference = "22"
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        
    }
    @IBAction func debitAction(sender: AnyObject) {
        self.activityIndicator.startAnimating()
        let parameters = PaymentezDebitParameters()
        parameters.cardReference = self.cardReference
        parameters.productAmount = Double(self.amountTextfield.text!)!
        parameters.productDescription = "Test"
        parameters.devReference = "1234"
        parameters.vat = 0.10
        parameters.email = "gsotelo@paymentez.com"
        parameters.uid = "gus"
        PaymentezSDKClient.debitCard(parameters) { (error, transaction) in
            self.activityIndicator.stopAnimating()
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
            else
            {
                if error!.shouldVerify() // if the card should be verified
                {
                    self.verifyButton.hidden = false
                    print(error?.getVerifyTrx())
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertC = UIAlertController(title: "error \(error!.code)", message: "Should verify: \(error!.getVerifyTrx())", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertC.addAction(defaultAction)
                        self.presentViewController(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.descriptionCode)", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertC.addAction(defaultAction)
                        self.presentViewController(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

