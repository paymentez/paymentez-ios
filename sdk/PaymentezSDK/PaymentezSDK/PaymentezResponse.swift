//
//  PaymentezResponse.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation
enum PaymentezSDKTypeAddError:Int
{
    
    case Unauthorized = 0
    case InsuficientParams = 1
    case InvalidFormat = 2
    case OperationNotAllowed = 3
    case InvalidConfiguration = 4
}

enum PaymentezSDKDebitStatus
{
    case Authorized
}

class PaymentezDebitResponse
{
    var transactionId = ""
    var status:PaymentezSDKDebitStatus?
    var statusDetail = ""
    var paymentDate:NSDate?
    var amount = 0.0
    var carrierData:[String:AnyObject]?
    var cardData:[String:AnyObject]?
    
    
}



@objc public class PaymentezSDKError:NSObject
{
    public var code = 500
    public var descriptionCode:String = "Internal Error"
    public var details:AnyObject? = nil
    
    
    
    init(code:Int, description:String, details:AnyObject?)
    {
        self.code = code
        self.descriptionCode = description
        self.details = details
        
    }
    
    public func shouldVerify()->Bool
    {
        if self.code == 3
        {
            let arrDetails = self.details as? [String]
            if arrDetails?.count > 0
            {
                let d = convertStringToDictionary(arrDetails![0])
                if d == nil
                {
                    return false
                }
                let verifyTrx = (d!["verify_transaction"] as? String) != nil
                return verifyTrx
            }
        }
        return false
        
    }
    
    
    public func getVerifyTrx() ->String?
    {
        if !shouldVerify()
        {
            return nil
        }
        else
        {
            let arrDetails = self.details as? [String]
            if arrDetails?.count > 0
            {
                let d = convertStringToDictionary(arrDetails![0])
                return (d!["verify_transaction"] as! String)
            }

            return nil
        }
        
    }
    private func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    
    static func createError(err:NSError) -> PaymentezSDKError
    {
        return PaymentezSDKError(code: 500, description: err.localizedDescription, details: err.debugDescription)
    }
    static func createError(code:Int, description:String, details:AnyObject?) -> PaymentezSDKError
    {
        return PaymentezSDKError(code: code, description: description, details: details)
    }
}