//
//  PaymentezResponse.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

enum PaymentezSDKTypeAddError:Int
{
    
    case unauthorized = 0
    case insuficientParams = 1
    case invalidFormat = 2
    case operationNotAllowed = 3
    case invalidConfiguration = 4
}

enum PaymentezSDKDebitStatus
{
    case authorized
}

class PaymentezDebitResponse
{
    var transactionId = ""
    var status:PaymentezSDKDebitStatus?
    var statusDetail = ""
    var paymentDate:Date?
    var amount = 0.0
    var carrierData:[String:Any]?
    var cardData:[String:Any]?
    
    
}



@objc open class PaymentezSDKError:NSObject
{
    open var code = 500
    open var descriptionCode:String = "Internal Error"
    open var details:Any? = nil
    open var isVerify = false;
    open var verifyTrx = "";
    
    
    
    init(code:Int, description:String, details:Any?)
    {
        self.code = code
        self.descriptionCode = description
        self.details = details
        
    }
    
    open func shouldVerify()->Bool
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
    
    
    open func getVerifyTrx() ->String?
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
    
    fileprivate func convertStringToDictionary(_ text: String!) -> [String:Any]? {
        if let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers]) as? [String:Any]
                print(json)
                return json
            } catch let error as NSError  {
                print (error)
                print("Something went wrong with Params")
            }
        }
        return nil
    }
    
    
    static func createError(_ err:NSError) -> PaymentezSDKError
    {
        return PaymentezSDKError(code: 500, description: err.localizedDescription, details: err.debugDescription as Any?)
    }
    static func createError(_ code:Int, description:String, details:Any?) -> PaymentezSDKError
    {
        let arrDetails = details as? [String]
        if arrDetails?.count > 0 && code == 3
        {
            if arrDetails![0].range(of: "verify_transaction") != nil
            {
                return PaymentezSDKError.createError(code, description: description, details: details, shouldVerify:true, verifyTrx:arrDetails![0])
            }
        }
        return PaymentezSDKError(code: code, description: description, details: details)
    }
    static func createError(_ code:Int, description:String, details:Any?, shouldVerify:Bool, verifyTrx:String) -> PaymentezSDKError
    {
        let err = PaymentezSDKError(code: code, description: description, details: details)
        err.isVerify = true
        let d = err.convertStringToDictionary(verifyTrx)
        err.verifyTrx = (d!["verify_transaction"] as! String)
        return err
    }
}
