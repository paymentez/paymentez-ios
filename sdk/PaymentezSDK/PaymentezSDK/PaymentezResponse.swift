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
    public var isVerify = false;
    public var verifyTrx = "";
    
    
    
    init(code:Int, description:String, details:AnyObject?)
    {
        self.code = code
        self.descriptionCode = description
        self.details = details
        
    }
    
    public func shouldVerify()->Bool
    {
        return isVerify
        /*
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
        */
        
    }
    
    
    public func getVerifyTrx() ->String?
    {
        return verifyTrx;
        /*
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
        }*/
        
    }
    
    private func convertStringToDictionary(text: String!) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: [.AllowFragments, .MutableContainers]) as? [String:AnyObject]
                print(json)
                return json
            } catch let error as NSError  {
                print (error)
                print("Something went wrong with Params")
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
        let arrDetails = details as? [String]
        if arrDetails?.count > 0 && code == 3
        {
            if arrDetails![0].rangeOfString("verify_transaction") != nil
            {
                return PaymentezSDKError.createError(code, description: description, details: details, shouldVerify:true, verifyTrx:arrDetails![0])
            }
        }
        return PaymentezSDKError(code: code, description: description, details: details)
    }
    static func createError(code:Int, description:String, details:AnyObject?, shouldVerify:Bool, verifyTrx:String) -> PaymentezSDKError
    {
        let err = PaymentezSDKError(code: code, description: description, details: details)
        err.isVerify = true
        let d = err.convertStringToDictionary(verifyTrx)
        err.verifyTrx = (d!["verify_transaction"] as! String)
        return err
    }
}