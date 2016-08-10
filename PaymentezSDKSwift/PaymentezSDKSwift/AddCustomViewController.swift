//
//  AddCustomViewController.swift
//  PaymentezSDKSwift
//
//  Created by Gustavo Sotelo on 12/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK

class AddCustomViewController: UIViewController {
    
    @IBOutlet weak var cardHolder: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var expiryMonth: UITextField!
    @IBOutlet weak var expiryYear: UITextField!
    @IBOutlet weak var cvcText: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.verifyButton.hidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCard(sender:AnyObject?)
    {
        self.activityIndicator.startAnimating()
        PaymentezSDKClient.addCard("gus", email: "gsotelo@paymentez.com", expiryYear: Int(self.expiryYear.text!), expiryMonth: Int(self.expiryMonth.text!), holderName: self.cardHolder.text!, cardNumber: self.cardNumber.text!, cvc: self.cvcText.text) { (error, added) in
            self.activityIndicator.stopAnimating()
            if error != nil
            {
                print(error?.code)
                print(error?.descriptionCode)
                print(error?.details)
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
            else
            {
                if added
                {
                    print("ADDED SUCCESSFUL")
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertC = UIAlertController(title: "Success", message: "card added", preferredStyle: UIAlertControllerStyle.Alert)
                        
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
    @IBAction func scanCard(sender:AnyObject?)
    {
        PaymentezSDKClient.scanCard(self) { (userCancelled, number, expiry, cvv) in
            if userCancelled
            {
                print("user cancelled scan");
            }
            else
            {
                self.cardNumber.text = number
                self.cvcText.text = cvv
                let expiryArray =  expiry?.componentsSeparatedByString("/") // format 03/2018
                self.expiryMonth.text = expiryArray![0]
                self.expiryYear.text = expiryArray![1]
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
