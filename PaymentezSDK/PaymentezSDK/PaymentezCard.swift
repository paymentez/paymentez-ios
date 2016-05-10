//
//  File.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 02/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation


enum PaymentezCardType
{
    case Visa
    case MasterCard
    case Amex
    case Diners
    case NotSupported
}
let REGEX_AMEX = "^3[47][0-9]{5,}$"
let REGEX_VISA = "^4[0-9]{6,}$"
let REGEX_MASTERCARD = "^5[1-5][0-9]{5,}$"
let REGEX_DINERS = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"


class PaymentezCard
{
    var cardReference:String?
    var type:String?
    var cardHolder:String?
    var termination:String?
    var expiryMonth:String?
    var expiryYear:String?
    var bin:String?
    
    static func getTypeCard(cardNumber:String) -> PaymentezCardType
    {
        if cardNumber.characters.count < 15  || cardNumber.characters.count > 16
        {
            return PaymentezCardType.NotSupported
        }
        let predicateAmex = NSPredicate(format: "%@", REGEX_AMEX)
        if predicateAmex.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.Amex
        }
        let predicateVisa = NSPredicate(format: "%@", REGEX_VISA)
        if predicateVisa.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.Visa
        }
        let predicateMC = NSPredicate(format: "%@", REGEX_MASTERCARD)
        if predicateMC.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.MasterCard
        }
        let predicateDiners = NSPredicate(format: "%@", REGEX_DINERS)
        if predicateDiners.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.Diners
        }
        return PaymentezCardType.NotSupported
        
        
    }
    
    
}