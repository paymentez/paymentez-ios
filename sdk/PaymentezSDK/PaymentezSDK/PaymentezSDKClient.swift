//
//  CCAPI.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 02/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto






@objc(PaymentezSDKClient)
open class PaymentezSDKClient:NSObject
{
    
    static var  apiCode = ""
    static var  secretKey = ""
    static var enableTestMode = true
    static var request = PaymentezRequest(testMode: true)
    static var kountHandler = PaymentezSecure(testMode: true)
    static var scanner = PaymentezCardScan()
    
    @objc(setEnvironment:secretKey:testMode:)
    open static func setEnvironment(_ apiCode:String, secretKey:String, testMode:Bool)
    {
        self.apiCode = apiCode
        self.secretKey = secretKey
        self.enableTestMode = testMode
        self.request.testMode = testMode
        self.kountHandler.testMode = testMode
    }
    
    
    @objc
    open static func showAddViewControllerForUser(_ uid:String, email:String, presenter:UIViewController, callback:@escaping (_ error:PaymentezSDKError?, _ closed:Bool, _ added:Bool)->Void)
    {
        let vc = PaymentezAddViewController(callback: { (error, isClose, added) in
            
            callback(error, isClose, added)
            
        })
        presenter.present(vc, animated: true, completion: {
            PaymentezSecure.getIpAddress { (ipAddress) in
                DispatchQueue.main.sync
                {
                    
                    let sessionId = self.kountHandler.generateSessionId()
                    var parameters = ["application_code" : apiCode,
                        "uid" : uid,
                        "email" : email,
                        "session_id": sessionId]
                    let authTimestamp = generateAuthTimestamp()
                    let authToken = generateAuthToken(parameters as [String : Any], authTimestamp: authTimestamp)
                    parameters["auth_timestamp"] = authTimestamp
                    parameters["ip_address"] = ipAddress
                    parameters["auth_token"] = authToken
                    
                    kountHandler.collect(sessionId!) { (err) in
                        
                        if err == nil
                        {
                            
                            
                            
                            let url = self.request.getUrl("/api/cc/add/", parameters:parameters as NSDictionary)
                            
                            vc.loadUrl(url)
                            
                        }
                        else
                        {
                            callback(PaymentezSDKError.createError(err!), false, false)
                            
                        }
                    }
                    
                }
            }
        })
        
        
    }
    
    
    
    
    private static func addCardForUser(_ uid:String,
                                      email:String,
                                      expiryYear:Int,
                                      expiryMonth:Int,
                                      holderName:String,
                                      cardNumber:String,
                                      cvc:String,
                                      callback:@escaping (_ error:PaymentezSDKError?, _ added:Bool)->Void)
    {
        addCard(uid, email: email, expiryYear: expiryYear, expiryMonth: expiryMonth, holderName: holderName, cardNumber: cardNumber, cvc: cvc) { (error, added) in
            if error == nil{
                callback(nil, added)
            }
            
            
            
        }
    }
    
     private static func addCard(_ uid:String!,
                         email:String!,
                         expiryYear:Int!,
                         expiryMonth:Int!,
                         holderName:String!,
                         cardNumber:String!,
                         cvc:String!,
                         callback:@escaping (_ error:PaymentezSDKError?, _ added:Bool)->Void
                         
                        
        
        

        )
    {
        PaymentezSecure.getIpAddress { (ipAddress) in
            DispatchQueue.main.sync
            {
                var typeCard = ""
                switch PaymentezCard.getTypeCard(cardNumber)
                {
                case .amex:
                    typeCard = "ax"
                case .visa:
                    typeCard = "vi"
                case .masterCard:
                    typeCard = "mc"
                case .diners:
                    typeCard = "di"
                default:
                   // (typeError:PaymentezSDKTypeAddError.insuficientParams, code: 0, description: "Card Not Supported", details: "number")
                    callback(PaymentezSDKError.createError(0, description: "Card Not Supported", details: "number" ) , false)
                }
                
                let sessionId = self.kountHandler.generateSessionId()
                var parameters = ["application_code" : apiCode,
                    "uid" : uid,
                    "email" : email,
                    "ip_address": ipAddress,
                    "session_id": sessionId]
                let authTimestamp = generateAuthTimestamp()
                let authToken = generateAuthToken(parameters as [String : Any], authTimestamp: authTimestamp)
                parameters["auth_timestamp"] = authTimestamp
                parameters["auth_token"] = authToken
                parameters["expiryYear"] = "\(expiryYear)"
                parameters["expiryMonth"] = "\(expiryMonth)"
                parameters["holderName"] = holderName
                parameters["number"] = cardNumber
                parameters["cvc"] = cvc
                parameters["card_type"] = typeCard
                
                kountHandler.collect(sessionId!) { (err) in
                    
                    if err == nil
                    {
                        self.request.makeRequest("/api/cc/add/creditcard", parameters: parameters as NSDictionary) { (error, statusCode, responseData) in
                            
                            
                            if error == nil
                            {
                                
                                if statusCode! != 200
                                {
                                    let dataR = responseData as! [String:Any]
                                    
                                    let err = PaymentezSDKError.createError(dataR["code"] as! Int, description: dataR["description"] as! String, details: dataR["details"])
                                    callback(err, false)
                                    
                                }
                                else
                                {
                                    callback(nil, true)
                                }
                            }
                            else
                            {
                                callback(PaymentezSDKError.createError(error!), false)
                            }
                            
                        }
                    }
                    else
                    {
                        callback(PaymentezSDKError.createError(err!), false)
                        
                    }
                }
                
            }
        }
        
    }

    
    open static func listCards(_ uid:String!, callback:@escaping (_ error:PaymentezSDKError?, _ cardList:[PaymentezCard]?) ->Void)
    {
        var parameters = ["application_code" : apiCode,
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters as [String : Any], authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        self.request.makeRequestGet("/api/cc/list/", parameters: parameters as NSDictionary) { (error, statusCode, responseData) in
            
            
            
            if error == nil
            {
                let cardsArray = responseData as! [[String:Any]]
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
                
                callback(nil,responseCards)
                
            }
            else
            {
               callback(PaymentezSDKError.createError(error!),nil)
            }
            
        }
    }
    
    open static func deleteCard(_ uid:String, cardReference:String, callback:@escaping (_ error:PaymentezSDKError?, _ wasDeleted:Bool) ->Void)
    {
        var parameters = ["application_code" : apiCode,
                          "card_reference" : cardReference,
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters as [String : Any], authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        
        self.request.makeRequest("/api/cc/delete/", parameters:parameters as NSDictionary) { (error, statusCode, responseData) in
            
            if error == nil
            {
                if statusCode! != 200
                {
                    let dataR = (responseData as! [String:Any])["errors"] as! [[String:Any]]
                    callback(PaymentezSDKError.createError(dataR[0]["code"] as! Int, description: dataR[0]["description"] as! String, details: dataR[0]["details"] as! String), false)
                }
                else
                {
                    callback(nil, true)
                }
            }
            else
            {
                if statusCode! == 200
                {
                    callback(nil, true)
                }
                else
                {
                    callback(PaymentezSDKError.createError(error!), false)
                }
            }
        }
    }
    
    open static func debitCard(_ parameters:PaymentezDebitParameters, callback: @escaping (_ error:PaymentezSDKError?, _ transaction:PaymentezTransaction?) ->Void)
    {
        
        PaymentezSecure.getIpAddress { (ipAddress) in
            DispatchQueue.main.sync
            {
                var parametersDic = parameters.allParamsDict()
                var requireDict = parameters.requiredDict()
                parametersDic["application_code"] = apiCode
                let sessionId = self.kountHandler.generateSessionId()
                parametersDic["session_id"] = sessionId 
                parametersDic["ip_address"] = ipAddress 
                
                requireDict["application_code"] = apiCode 
                requireDict["session_id"] = sessionId 
                requireDict["ip_address"] = ipAddress 
                
                let authTimestamp = generateAuthTimestamp()
                let autToken = generateAuthToken(requireDict, authTimestamp: authTimestamp)
                parametersDic["auth_timestamp"] = authTimestamp 
                parametersDic["auth_token"] = autToken 
                kountHandler.collect(sessionId!) { (err) in
                    
                    if err == nil
                    {
                        self.request.makeRequest("/api/cc/debit/", parameters: parametersDic as NSDictionary, responseCallback: { (error, statusCode, responseData) in
                            
                            if error == nil
                            {
                                if statusCode == 200
                                {
                                    let response = PaymentezTransaction.parseTransaction(responseData as! [String:Any])
                                    print(response.status)
                                    if response.statusDetail == 11
                                    {
                                        
                                        let error = PaymentezSDKError.createError(3, description: "System Error", details: ["{\"verify_transaction\": \"\(response.transactionId!)\"}"], shouldVerify: true, verifyTrx: "{\"verify_transaction\": \"\(response.transactionId!)\"}")
                                        callback(error, response)
                                    }
                                    else
                                    {
                                        callback(nil, response)
                                    }
                                    
                                    
                                }
                                else
                                {
                                    do {
                                        var dataR = (responseData as! [String:Any])
                                        if dataR["errors"] != nil
                                        {
                                            dataR = dataR["errors"] as! [String:Any]
                                        }
                                        let errorPa =  PaymentezSDKError.createError(dataR["code"] as! Int, description: dataR["description"] as! String, details: dataR["details"])
                                        
                                        callback(errorPa, nil)
                                    }
                                    
                                }
                            }
                            else
                            {
                                callback(PaymentezSDKError.createError(error!), nil)
                            }
                            
                            
                        })
                    }
                    else
                    {
                        callback(PaymentezSDKError.createError(err!), nil)
                    }
                }
                
                
                
                
            }
            
            
        }
        
        
        
        
        
    }
    
    @objc open static func verifyWithCode(_ transactionId:String, uid:String, verificationCode:String, callback:@escaping (_ error:PaymentezSDKError?, _ attemptsRemaining:Int, _ transaction:PaymentezTransaction?)->Void)
    
    {
        var parameters = ["application_code" : apiCode,
                          "transaction_id" : transactionId,
                          "value": verificationCode,
                          "type": "BY_AUTH_CODE",
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters as [String : Any], authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        
        self.request.makeRequest("/api/cc/verify/", parameters: parameters as NSDictionary) { (error, statusCode, responseData) in
            
            if error == nil
            {
                if statusCode == 200
                {
                    let transaction = PaymentezTransaction.parseTransaction(responseData)
                    callback(nil, 0, transaction)
                }
                else
                {
                    let dataR = (responseData as! [String:Any])["errors"] as! [[String:Any]]
                    
                    let err =  PaymentezSDKError.createError(dataR[0]["code"] as! Int, description: dataR[0]["description"] as! String, details: dataR[0]["details"])
                    if err.code == 7 && err.description != "InvalidTransaction"{
                        let det = err.details as! [String:Any]
                        let attempts = det["attempts"] as! Int
                        callback(err, attempts , nil)
                    }
                    callback(err, 0 , nil)
                }
            }
            
            
        }
    }
    
    open static func verifyWithAmount(_ transactionId:String, uid:String, amount:Double, callback:@escaping (_ error:PaymentezSDKError?, _ attemptsRemaining:Int, _ transaction:PaymentezTransaction?)->Void)
        
    {
        var parameters = ["application_code" : apiCode,
                          "transaction_id" : transactionId,
                          "value": String(format: "%.2f", amount),
                          "type" : "BY_AMOUNT",
                          "uid" : uid]
        let authTimestamp = generateAuthTimestamp()
        let authToken = generateAuthToken(parameters as [String : Any], authTimestamp: authTimestamp)
        parameters["auth_token"] = authToken
        parameters["auth_timestamp"] = authTimestamp
        
        self.request.makeRequest("/api/cc/verify/", parameters: parameters as NSDictionary) { (error, statusCode, responseData) in
            
            if error == nil
            {
                if statusCode == 200
                {
                    let transaction = PaymentezTransaction.parseTransaction(responseData)
                    callback(nil, 0, transaction)
                }
                else
                {
                    let dataR = (responseData as! [String:Any])["errors"] as! [[String:Any]]
                    
                    let err =  PaymentezSDKError.createError(dataR[0]["code"] as! Int, description: dataR[0]["description"] as! String, details: dataR[0]["details"])
                    if err.code == 7 && err.description != "InvalidTransaction"{
                        let det = err.details as! [String:Any]
                        let attempts = det["attempts"] as! Int
                        callback(err, attempts , nil)
                    }
                    callback(err, 0 , nil)
                }
            }
            
            
        }
    }
    
    
    static fileprivate func generateAuthTimestamp() -> String
    {
        let timestamp = (Date()).timeIntervalSince1970
        
        return "\(timestamp.hashValue)"
    }
    
    static fileprivate func generateAuthToken(_ parameters:[String:Any], authTimestamp:String!) -> String
    {
        let paramsDict = Array(parameters.keys).sorted(by: {$0 < $1})
        var paramsString = ""
        for paramName in paramsDict
        {
            let value = (parameters[paramName] as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            paramsString += "\(paramName)=\(value!)&"
        }
        
        paramsString = paramsString + authTimestamp + "&" + secretKey
        
        let dataIn = paramsString.data(using: String.Encoding.utf8)!
        let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256((dataIn as NSData).bytes, CC_LONG(dataIn.count), res?.mutableBytes.assumingMemoryBound(to: UInt8.self))
        var hash:String = res!.description
        hash = hash.replacingOccurrences(of: " ", with: "")
        hash = hash.replacingOccurrences(of: "<", with: "")
        hash = hash.replacingOccurrences(of: ">", with: "")
        //print(hash)
        return hash
        
    }
    
   
    
    
    @objc open static func scanCard(_ presenterViewController:UIViewController, callback:@escaping (_ userCancelled:Bool, _ number:String?, _ expiry:String?, _ cvv:String?) ->Void)
    
        {
           self.scanner.showScan(presenterViewController) { (infoCard) in
            
                if infoCard == nil
                {
                    callback(true, nil, nil, nil)
                }
                else
                {
                    callback(false, infoCard!.cardNumber, String(format: "%02i/%i",infoCard!.expiryMonth, infoCard!.expiryYear), infoCard!.cvv)
                    
                }
            
            }
        
    }
    
    
    
}
