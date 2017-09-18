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
    
    @IBOutlet weak var addView: UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var paymentezAddVC:PaymentezAddNativeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentezAddVC = PaymentezSDKClient.createAddWidget()
        self.addChildViewController(paymentezAddVC)
        paymentezAddVC.view.frame = CGRect(x: 0, y: 0, width: self.addView.bounds.width, height: self.addView.frame.size.height)
        self.addView.translatesAutoresizingMaskIntoConstraints = true
        
        self.addView.addSubview(paymentezAddVC.view)
        paymentezAddVC.didMove(toParentViewController: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        
 
        /*self.present(paymentezAddVC, animated: true) {
            
        }*/
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCard(_ sender:UIButton?)
    {
        
        if let validCard = self.paymentezAddVC.getValidCard()
        {
            
            self.activityIndicator.startAnimating()
            sender?.isEnabled = false
            PaymentezSDKClient.createToken(validCard, uid: UserModel.uid, email: UserModel.email, callback: { (error, cardAdded) in
                self.activityIndicator.stopAnimating()
                sender?.isEnabled = true
                if cardAdded != nil
                {
                    DispatchQueue.main.async(execute: {
                        let alertC = UIAlertController(title: "Response", message: "card "+cardAdded!.termination!+"  status:"+cardAdded!.status!, preferredStyle: UIAlertControllerStyle.alert)

                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                            
                            self.navigationController?.popViewController(animated: false)
                        })
                        alertC.addAction(defaultAction)
                        self.present(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        let alertC = UIAlertController(title: "Error", message: "error: "+error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertC.addAction(defaultAction)
                        self.present(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
                
            })
        }
        
//        self.activityIndicator.startAnimating()
//        PaymentezSDKClient.addCard("gus", email: "gsotelo@paymentez.com", expiryYear: Int(self.expiryYear.text!), expiryMonth: Int(self.expiryMonth.text!), holderName: self.cardHolder.text!, cardNumber: self.cardNumber.text!, cvc: self.cvcText.text) { (error, added) in
//            self.activityIndicator.stopAnimating()
//            if error != nil
//            {
//                print(error?.code)
//                print(error?.descriptionCode)
//                print(error?.details)
//                if error!.shouldVerify() // if the card should be verified
//                {
//                    self.verifyButton.isHidden = false
//                    print(error?.getVerifyTrx())
//                    DispatchQueue.main.async(execute: {
//                        let alertC = UIAlertController(title: "error \(error!.code)", message: "Should verify: \(error!.getVerifyTrx())", preferredStyle: UIAlertControllerStyle.alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertC.addAction(defaultAction)
//                        self.present(alertC, animated: true
//                            , completion: {
//                                
//                        })
//                    })
//                }
//                else
//                {
//                    DispatchQueue.main.async(execute: {
//                        let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.descriptionCode)", preferredStyle: UIAlertControllerStyle.alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertC.addAction(defaultAction)
//                        self.present(alertC, animated: true
//                            , completion: {
//                                
//                        })
//                    })
//                }
//            }
//            else
//            {
//                if added
//                {
//                    print("ADDED SUCCESSFUL")
//                    DispatchQueue.main.async(execute: {
//                        let alertC = UIAlertController(title: "Success", message: "card added", preferredStyle: UIAlertControllerStyle.alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertC.addAction(defaultAction)
//                        self.present(alertC, animated: true
//                            , completion: {
//                                
//                        })
//                    })
//                }
//            }
//        }
    }
    @IBAction func scanCard(_ sender:AnyObject?)
    {
        /*
        PaymentezSDKClient.scanCard(self) { (userCancelled, number, expiry, cvv) in
            if userCancelled
            {
                print("user cancelled scan");
            }
            else
            {
                self.cardNumber.text = number
                self.cvcText.text = cvv
                let expiryArray =  expiry?.components(separatedBy: "/") // format 03/2018
                self.expiryMonth.text = expiryArray![0]
                self.expiryYear.text = expiryArray![1]
            }
        }
 */
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
