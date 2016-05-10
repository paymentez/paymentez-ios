//
//  CCAPI.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 02/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation
import CommonCrypto



enum PaymentezSDKTypeError:Int
{
    
    case Unauthorized = 0
    case InsuficientParams = 1
    case InvalidFormat = 2
    case OperationNotAllowed = 3
    case InvalidConfiguration = 4
}

class PaymentezSDKResponse
{
    var typeError:PaymentezSDKTypeError?
    var code:Int?
    var description:String?
    var details:String?
    

    
    init(typeError:PaymentezSDKTypeError?, code:Int, description:String, details:String)
    {
        self.typeError = typeError
        self.code = code
        self.description = description
        self.details = details
    
    }
}

class PaymentezSDK
{
    
    static var  apiCode = ""
    static var  secretKey = ""
    static var enableTestMode = true
    static var request = PaymentezRequest()
    
    public static func setEnvironment(apiCode:String, secretKey:String, testMode:Bool)
    {
        self.apiCode = apiCode
        self.secretKey = secretKey
        self.enableTestMode = testMode
    }
    
    public static func addCard(  uid:String,
                         email:String,
                         expiryYear:Int,
                         expiryMonth:Int,
                         holderName:String,
                         cardNumber:String,
                         cvc:String,
                         callback:(response: PaymentezSDKResponse!)->Void
                         
                        
        
        

        )
    {
        
        var typeCard = ""
        switch PaymentezCard.getTypeCard(cardNumber)
        {
            case .Amex:
                typeCard = "ax"
            case .Visa:
                typeCard = "vi"
            case .MasterCard:
                typeCard = "mc"
            case .Diners:
                typeCard = "di"
            default:
                let resp = PaymentezSDKResponse(typeError:PaymentezSDKTypeError.InsuficientParams, code: 0, description: "Card Not Supported", details: "number")
                callback(response: resp)
        }
        
        let sessionId = "123123"
        var parameters = ["application_code" : apiCode,
                          "uid" : uid,
                          "email" : email,
                          "ip_address": "",
                          "expiryYear" : "\(expiryYear)",
                          "expiryMonth" : "\(expiryMonth)",
                          "holderName" : holderName,
                          "number": cardNumber,
                          "cvc": cvc,
                          "card_type": typeCard,
                          "session_id": sessionId]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters, authTimestamp: authTimestamp)
        parameters["auth_timestamp"] = authTimestamp
        parameters["auth_token"] = authToken
        
        //request.makeRequest("/api/cc/add/creditcard", parameters: parameters, responseCallback: (error: NSError?, responseData: AnyObject?))
        
        
        
        
    }
    
    
    
    static private func generateAuthTimestamp() -> String
    {
        let timestamp = (NSDate()).timeIntervalSince1970
        return String(format:"%lu", timestamp)
    }
    
    static private func generateAuthToken(parameters:[String:AnyObject], authTimestamp:String!) -> String
    {
        let paramsDict = Array(parameters.keys).sort({$0 < $1})
        var paramsString = ""
        for paramName in paramsDict
        {
            paramsString += "\(paramName)=\(parameters[paramName])"
        }
        paramsString = paramsString + authTimestamp + secretKey
        print(paramsString)
        let dataIn = paramsString.dataUsingEncoding(NSUTF8StringEncoding)!
        let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(dataIn.bytes, CC_LONG(dataIn.length), UnsafeMutablePointer(res!.mutableBytes))
        var hash:String = res!.description
        hash = hash.stringByReplacingOccurrencesOfString(" ", withString: "")
        hash = hash.stringByReplacingOccurrencesOfString("<", withString: "")
        hash = hash.stringByReplacingOccurrencesOfString(">", withString: "")
        print(hash)
        return hash
        
    }
    
    
}
