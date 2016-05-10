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


@objc public class PaymentezCard:NSObject
{
    public var cardReference:String?
    public var type:String?
    public var cardHolder:String?
    public var termination:String?
    public var expiryMonth:String?
    public var expiryYear:String?
    public var bin:String?
    
    public static func getTypeCard(cardNumber:String) -> PaymentezCardType
    {
        if cardNumber.characters.count < 15  || cardNumber.characters.count > 16
        {
            return PaymentezCardType.NotSupported
        }
        let predicateAmex = NSPredicate(format: "SELF MATCHES %@", REGEX_AMEX)
        if predicateAmex.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.Amex
        }
        let predicateVisa = NSPredicate(format: "SELF MATCHES %@", REGEX_VISA)
        if predicateVisa.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.Visa
        }
        let predicateMC = NSPredicate(format: "SELF MATCHES %@", REGEX_MASTERCARD)
        if predicateMC.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.MasterCard
        }
        let predicateDiners = NSPredicate(format: "SELF MATCHES %@", REGEX_DINERS)
        if predicateDiners.evaluateWithObject(cardNumber)
        {
            return PaymentezCardType.Diners
        }
        return PaymentezCardType.NotSupported
        
        
    }
    
    
}

@objc public class PaymentezTransaction:NSObject
{
    public var amount:Double?
    public var paymentDate: NSDate?
    public var status:Int?
    public var statusDetail:Int?
    public var transactionId:String?
    public var carrierData:[String:AnyObject]?
    
    static func parseTransaction(data:AnyObject?) ->PaymentezTransaction
    {
        _ = data as! [String:AnyObject]
        let trx = PaymentezTransaction()
        trx.amount = data!["amount"] as? Double
        trx.status = data!["status"] as? Int
        trx.statusDetail = data!["status_detail"] as? Int
        trx.transactionId = data!["transaction_id"] as? String
        
        trx.carrierData = data!["carrier_data"] as? [String:AnyObject]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        trx.paymentDate = dateFormatter.dateFromString(data!["payment_date"] as! String)
        return trx
        
    }
}