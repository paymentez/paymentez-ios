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
        
        paymentezAddVC = self.addPaymentezWidget(toView: self.addView, delegate: nil, uid:UserModel.uid, email:UserModel.email)
        
        /* Change Colors
        paymentezAddVC.baseFontColor = .orange
        paymentezAddVC.baseColor = .green
        paymentezAddVC.backgroundColor = .white
        paymentezAddVC.showLogo = false*/
      paymentezAddVC.baseFont = UIFont(name: "Helvetica-Neue", size: 12) ?? UIFont.systemFont(ofSize: 12)
        paymentezAddVC.nameTitle = "Nombre del Títular"
        
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
}
