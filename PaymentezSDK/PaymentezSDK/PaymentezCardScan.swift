//
//  PaymentezCardScan.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation

class PaymentezCardScan:NSObject, CardIOPaymentViewControllerDelegate
{
    
    //MARK - CardIO
    var viewController:UIViewController?
    
    var callback:((infoCard:CardIOCreditCardInfo?)->Void)?
    var scanVc:CardIOPaymentViewController?
    
    override init()
    {
        super.init()
        self.scanVc = CardIOPaymentViewController(paymentDelegate: self)
    }
    
    func showScan(vc:UIViewController, callback:(infoCard:CardIOCreditCardInfo?)->Void)
    
    {
        self.callback = callback
        vc.presentViewController(self.scanVc!, animated: true, completion: nil)
        
    }
    
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        self.scanVc?.dismissViewControllerAnimated(true, completion: nil)
        callback!(infoCard: nil)
        
    }
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        self.scanVc?.dismissViewControllerAnimated(true, completion: nil)
        callback!(infoCard:cardInfo)
        
    }
}