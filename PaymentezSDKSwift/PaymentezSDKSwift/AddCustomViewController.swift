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
        //PAYMENTEZ WIDGET CREATION
        
        self.addPaymentezWidget(toView: self.addView, delegate: nil, uid:UserModel.uid, email:UserModel.email)
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func addCard(_ sender:UIButton?)
    {
        
        
        if let validCard = self.paymentezAddVC.getValidCard() // CHECK IF THE CARD IS VALID, IF THERE IS A VALIDATION ERROR NIL VALUE WILL BE RETURNED
        {
            
            self.activityIndicator.startAnimating()
            sender?.isEnabled = false
            PaymentezSDKClient.add(validCard, uid: UserModel.uid, email: UserModel.email, callback: { (error, cardAdded) in
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
