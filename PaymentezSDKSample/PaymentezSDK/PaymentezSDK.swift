//
//  CCAPI.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 02/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation
import CommonCrypto







class PaymentezSDK:NSObject
{
    
    static var  apiCode = ""
    static var  secretKey = ""
    static var enableTestMode = true
    static var request = PaymentezRequest(testMode: true)
    static var kountHandler = PaymentezSecure(testMode: true)
    static var scanner = PaymentezCardScan()
    
    static func setEnvironment(apiCode:String, secretKey:String, testMode:Bool)
    {
        self.apiCode = apiCode
        self.secretKey = secretKey
        self.enableTestMode = testMode
        self.request.testMode = testMode
        self.kountHandler.testMode = testMode
    }
    
    static func addCard(  uid:String!,
                         email:String!,
                         expiryYear:Int!,
                         expiryMonth:Int!,
                         holderName:String!,
                         cardNumber:String!,
                         cvc:String!,
                         callback:(error:PaymentezSDKError?, added:Bool)->Void
                         
                        
        
        

        )
    {
        PaymentezSecure.getIpAddress { (ipAddress) in
            dispatch_sync(dispatch_get_main_queue())
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
                    (typeError:PaymentezSDKTypeAddError.InsuficientParams, code: 0, description: "Card Not Supported", details: "number")
                    callback(error: PaymentezSDKError.createError(0, description: "Card Not Supported", details: "number" ) , added: false)
                }
                
                let sessionId = self.kountHandler.generateSessionId()
                var parameters = ["application_code" : apiCode,
                    "uid" : uid,
                    "email" : email,
                    "ip_address": ipAddress,
                    "session_id": sessionId]
                let authTimestamp = generateAuthTimestamp()
                let authToken = generateAuthToken(parameters, authTimestamp: authTimestamp)
                parameters["auth_timestamp"] = authTimestamp
                parameters["auth_token"] = authToken
                parameters["expiryYear"] = "\(expiryYear)"
                parameters["expiryMonth"] = "\(expiryMonth)"
                parameters["holderName"] = holderName
                parameters["number"] = cardNumber
                parameters["cvc"] = cvc
                parameters["card_type"] = typeCard
                
                kountHandler.collect(sessionId) { (err) in
                    
                    if err == nil
                    {
                        self.request.makeRequest("/api/cc/add/creditcard", parameters: parameters) { (error, statusCode, responseData) in
                            
                            print(error)
                            print(responseData)
                            
                            if error == nil
                            {
                                
                                if statusCode! != 200
                                {
                                    let dataR = responseData as! [String:AnyObject]
                                    let err = PaymentezSDKError.createError(dataR["code"] as! Int, description: dataR["description"] as! String, details: dataR["details"])
                                    callback(error: err, added: false)
                                    
                                }
                                else
                                {
                                    callback(error: nil, added: true)
                                }
                            }
                            else
                            {
                                callback(error: PaymentezSDKError.createError(error!), added: false)
                            }
                            
                        }
                    }
                    else
                    {
                        
                    }
                }
                
            }
        }
        
    }
    
    static func listCards(uid:String!, callback:(error:PaymentezSDKError?, cardList:[PaymentezCard]?) ->Void)
    {
        var parameters = ["application_code" : apiCode,
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters, authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        self.request.makeRequestGet("/api/cc/list/", parameters: parameters) { (error, statusCode, responseData) in
            
            print(error)
            print(responseData)
            
            if error == nil
            {
                let cardsArray = responseData as! [[String:AnyObject]]
                var responseCards = [PaymentezCard]()
                
                for card in cardsArray
                {
                    let pCard = PaymentezCard()
                    pCard.bin = "\(card["bin"]!)"
                    pCard.cardReference = "\(card["card_reference"]!)"
                    pCard.cardHolder = "\(card["name"]!)"
                    pCard.expiryMonth = "\(card["expiry_month"]!)"
                    pCard.expiryYear = "\(card["expiry_year"]!)"
                    pCard.termination = "\(card["termination"]!)"
                    pCard.type = "\(card["type"]!)"
                    responseCards.append(pCard)
                }
                
                callback(error:nil,cardList: responseCards)
                
            }
            else
            {
               callback(error: PaymentezSDKError.createError(error!),cardList: nil)
            }
            
        }
    }
    
    static func deleteCard(uid:String, cardReference:String, callback:(error:PaymentezSDKError?, wasDeleted:Bool!) ->Void)
    {
        var parameters = ["application_code" : apiCode,
                          "card_reference" : cardReference,
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters, authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        
        self.request.makeRequest("/api/cc/delete/", parameters:parameters) { (error, statusCode, responseData) in
            print(responseData)
            print(error)
            if error == nil
            {
                if statusCode! != 200
                {
                    let dataR = (responseData as! [String:AnyObject])["errors"] as! [[String:AnyObject]]
                    callback(error: PaymentezSDKError.createError(dataR[0]["code"] as! Int, description: dataR[0]["description"] as! String, details: dataR[0]["details"] as! String), wasDeleted: false)
                }
                else
                {
                    callback(error: nil, wasDeleted: true)
                }
            }
            else
            {
                if statusCode! == 200
                {
                    callback(error: nil, wasDeleted: true)
                }
                else
                {
                    callback(error: PaymentezSDKError.createError(error!), wasDeleted: false)
                }
            }
        }
    }
    
    static func debitCard(parameters:PaymentezDebitParameters!, callback: (error:PaymentezSDKError?, transaction:PaymentezTransaction?) ->Void)
    {
        
        PaymentezSecure.getIpAddress { (ipAddress) in
            dispatch_sync(dispatch_get_main_queue())
            {
                var parametersDic = parameters.toDict()
                parametersDic["application_code"] = apiCode
                let sessionId = self.kountHandler.generateSessionId()
                parametersDic["session_id"] = sessionId
                parametersDic["ip_address"] = ipAddress
                
                let authTimestamp = generateAuthTimestamp()
                let autToken = generateAuthToken(parametersDic, authTimestamp: authTimestamp)
                parametersDic["auth_timestamp"] = authTimestamp
                parametersDic["auth_token"] = autToken
                parametersDic["buyer_fiscal_number"] = parameters.buyerFiscalNumber
                
                self.request.makeRequest("/api/cc/debit/", parameters: parametersDic, responseCallback: { (error, statusCode, responseData) in
                    print(responseData)
                    print(statusCode)
                    if error == nil
                    {
                        if statusCode == 200
                        {
                            let response = PaymentezTransaction.parseTransaction(responseData as! [String:AnyObject])
                            
                            callback(error: nil, transaction: response)
                            
                            
                            
                        }
                        else
                        {
                            let dataR = (responseData as! [String:AnyObject])
                            let errorPa =  PaymentezSDKError.createError(dataR["code"] as! Int, description: dataR["description"] as! String, details: dataR["details"] as! String)
                            
                            callback(error:errorPa, transaction: nil)
                            
                        }
                    }
                    else
                    {
                        callback(error: PaymentezSDKError.createError(error!), transaction:nil)
                    }
                    
                    
                })
                
                
            }
            
            
        }
        
        
        
        
        
    }
    
    static func verifyWithCode(transactionId:String!, uid:String!, verificationCode:String!, callback:(error:PaymentezSDKError?, attemptsRemaining:Int?, transaction:PaymentezTransaction?)->Void)
    
    {
        var parameters = ["application_code" : apiCode,
                          "transaction_id" : transactionId,
                          "value": verificationCode,
                          "type": "BY_AUTH_CODE",
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters, authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        
        self.request.makeRequest("/api/cc/verify/", parameters: parameters) { (error, statusCode, responseData) in
            print(error)
            print(statusCode)
            print(responseData)
            if error == nil
            {
                if statusCode == 200
                {
                    let transaction = PaymentezTransaction.parseTransaction(responseData)
                    callback(error:nil, attemptsRemaining: nil, transaction: transaction)
                }
                else
                {
                    let dataR = (responseData as! [String:AnyObject])["errors"] as! [[String:AnyObject]]
                    
                    let err =  PaymentezSDKError.createError(dataR[0]["code"] as! Int, description: dataR[0]["description"] as! String, details: dataR[0]["details"])
                    if err.code == 7 && err.description != "InvalidTransaction"{
                        let det = err.details as! [String:AnyObject]
                        let attempts = det["attempts"] as! Int
                        callback(error:err, attemptsRemaining: attempts , transaction: nil)
                    }
                    callback(error:err, attemptsRemaining: nil , transaction: nil)
                }
            }
            
            
        }
    }
    static func verifyWithAmount(transactionId:String!, uid:String!, amount:Double!, callback:(error:PaymentezSDKError?, attemptsRemaining:Int?, transaction:PaymentezTransaction?)->Void)
        
    {
        var parameters = ["application_code" : apiCode,
                          "transaction_id" : transactionId,
                          "value": String(format: "%.2f", amount),
                          "type" : "BY_AMOUNT",
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters, authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        
        self.request.makeRequest("/api/cc/verify/", parameters: parameters) { (error, statusCode, responseData) in
            print(error)
            print(statusCode)
            print(responseData)
            if error == nil
            {
                if statusCode == 200
                {
                    let transaction = PaymentezTransaction.parseTransaction(responseData)
                    callback(error:nil, attemptsRemaining: nil, transaction: transaction)
                }
                else
                {
                    let dataR = (responseData as! [String:AnyObject])["errors"] as! [[String:AnyObject]]
                    
                    let err =  PaymentezSDKError.createError(dataR[0]["code"] as! Int, description: dataR[0]["description"] as! String, details: dataR[0]["details"])
                    if err.code == 7 && err.description != "InvalidTransaction"{
                        let det = err.details as! [String:AnyObject]
                        let attempts = det["attempts"] as! Int
                        callback(error:err, attemptsRemaining: attempts , transaction: nil)
                    }
                    callback(error:err, attemptsRemaining: nil , transaction: nil)
                }
            }
            
            
        }
    }
    
    
    static private func generateAuthTimestamp() -> String
    {
        let timestamp = (NSDate()).timeIntervalSince1970
        
        return "\(timestamp.hashValue)"
    }
    
    static private func generateAuthToken(parameters:[String:AnyObject], authTimestamp:String!) -> String
    {
        let paramsDict = Array(parameters.keys).sort({$0 < $1})
        var paramsString = ""
        for paramName in paramsDict
        {
            let value = (parameters[paramName] as! String).stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            paramsString += "\(paramName)=\(value!)&"
        }
        
        paramsString = paramsString + authTimestamp + "&" + secretKey
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
    
    
    static func scanCard(presenterViewController:UIViewController, callback:(userCancelled:Bool!, number:String?, expiry:String?, cvv:String?) ->Void)
    
        {
           self.scanner.showScan(presenterViewController) { (infoCard) in
            
                if infoCard == nil
                {
                    callback(userCancelled: true, number: nil, expiry: nil, cvv: nil)
                }
                else
                {
                    callback(userCancelled: false, number: infoCard!.cardNumber, expiry: String(format: "%02i/%i",infoCard!.expiryMonth, infoCard!.expiryYear), cvv: infoCard!.cvv)
                    
                }
            
            }
        
    }
    
    
    
}
