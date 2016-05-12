//
//  VerifyViewController.swift
//  PaymentezSDKSwift
//
//  Created by Gustavo Sotelo on 12/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK

class VerifyViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transactionId: UITextField!
    @IBOutlet weak var verifyCodetxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func verifyTrx(sender: AnyObject) {
        self.activityIndicator.startAnimating()
        PaymentezSDKClient.verifyWithCode(self.transactionId.text!, uid: "test", verificationCode: self.verifyCodetxt.text!) { (error, attemptsRemaining, transaction) in
            self.activityIndicator.stopAnimating()
            if transaction != nil
            {
                print ("verified")
            }
            else
            {
                if attemptsRemaining > 0 //
                {
                    print("you have attempts remaining")
                }
                if error != nil
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
}
