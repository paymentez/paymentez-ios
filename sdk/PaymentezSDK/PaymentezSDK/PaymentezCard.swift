//
//  File.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 02/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation


public enum PaymentezCardType
{
    case visa
    case masterCard
    case amex
    case diners
    case notSupported
}
let REGEX_AMEX = "^3[47][0-9]{5,}$"
let REGEX_VISA = "^4[0-9]{6,}$"
let REGEX_MASTERCARD = "^5[1-5][0-9]{5,}$"
let REGEX_DINERS = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"


@objc open class PaymentezCard:NSObject
{
    open var cardReference:String?
    open var type:String?
    open var cardHolder:String?
    open var termination:String?
    open var expiryMonth:String?
    open var expiryYear:String?
    open var bin:String?
    
    open static func getTypeCard(_ cardNumber:String) -> PaymentezCardType
    {
        if cardNumber.characters.count < 15  || cardNumber.characters.count > 16
        {
            return PaymentezCardType.notSupported
        }
        let predicateAmex = NSPredicate(format: "SELF MATCHES %@", REGEX_AMEX)
        if predicateAmex.evaluate(with: cardNumber)
        {
            return PaymentezCardType.amex
        }
        let predicateVisa = NSPredicate(format: "SELF MATCHES %@", REGEX_VISA)
        if predicateVisa.evaluate(with: cardNumber)
        {
            return PaymentezCardType.visa
        }
        let predicateMC = NSPredicate(format: "SELF MATCHES %@", REGEX_MASTERCARD)
        if predicateMC.evaluate(with: cardNumber)
        {
            return PaymentezCardType.masterCard
        }
        let predicateDiners = NSPredicate(format: "SELF MATCHES %@", REGEX_DINERS)
        if predicateDiners.evaluate(with: cardNumber)
        {
            return PaymentezCardType.diners
        }
        return PaymentezCardType.notSupported
        
        
    }
    
    
}

@objc open class PaymentezTransaction:NSObject
{
    open var amount:Double?
    open var paymentDate: Date?
    open var status:NSNumber?
    open var statusDetail:NSNumber?
    open var transactionId:String?
    open var carrierData:[String:Any]?
    
    static func parseTransaction(_ data:Any?) ->PaymentezTransaction
    {
        let data = data as! [String:Any]
        let trx = PaymentezTransaction()
        trx.amount = data["amount"] as? Double
        trx.status = data["status"] as? Int as NSNumber?
        trx.statusDetail = data["status_detail"] as? Int as NSNumber?
        trx.transactionId = data["transaction_id"] as? String
        
        trx.carrierData = data["carrier_data"] as? [String:Any]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        if let paymentdate = (data["payment_date"] as? String)
        {
            trx.paymentDate = dateFormatter.date(from: paymentdate)
        }
        
        return trx
        
    }
}
