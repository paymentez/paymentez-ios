    //
    //  MyBackendLib.swift
    //  PaymentezSDKSwift
    //
    //  Created by Gustavo Sotelo on 19/09/17.
    //  Copyright © 2017 Paymentez. All rights reserved.
    //
    
    import Foundation
    import PaymentezSDK
    
    class MyBackendLib
    {
        static let myBackendUrl = "https://example-paymentez-backend.herokuapp.com/"
        static func listCard(uid:String, callback:@escaping (_ cardList:[PaymentezCard]?) ->Void)
        {
            let parameters = ["uid": uid] as [String:Any]
            makeRequestGet("get-cards", parameters: parameters as NSDictionary) { (error, statusCode, responseData) in
                
                
                var responseCards = [PaymentezCard]()
                if error == nil
                {
                    let responseObj = responseData as! NSDictionary
                    let cardsArray = responseObj["cards"] as! [[String:Any]]
                    
                    
                    for card in cardsArray
                    {
                        let pCard = PaymentezCard()
                        let expiration_date = (card["expiration_date"] as! String).components(separatedBy: "/")
                        pCard.bin = "\(card["bin"]!)"
                        pCard.token = "\(card["token"]!)"
                        pCard.cardHolder = "\(card["name"]!)"
                        pCard.expiryMonth = Int((expiration_date[0]))
                        pCard.expiryYear = Int((expiration_date[1]))
                        pCard.termination = "\(card["number"]!)"
                        pCard.status = "\(card["status"]!)"
                        responseCards.append(pCard)
                    }
                    
                    callback(responseCards)
                    
                }
                else
                {
                    callback(responseCards)
                }
                
            }
        }
        static func makeRequestGet(_ urlToRequest:String, parameters:NSDictionary, responseCallback:@escaping (_ error:NSError?, _ statusCode:Int?,_ responseData:Any?) ->Void)
        {
            var completeUrl = self.myBackendUrl + urlToRequest
            var bodyData = ""
            for (key,value) in parameters{
                let scapedKey = (key as! String).addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed)!
                let scapedValue = (value as! String).addingPercentEncoding(
                    withAllowedCharacters: .urlHostAllowed)!
                bodyData += "\(scapedKey)=\(scapedValue)&"
            }
            completeUrl += "?" + bodyData
            let url:URL? = URL(string: completeUrl)
            let session = URLSession.shared
            
            var request = URLRequest(url:url!)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request){ data, resp, err in
                
                if err == nil
                {
                    var json:Any? = nil
                    
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                    }
                    catch {
                        
                    }
                    
                    if json == nil{
                        let error = NSError(domain: "JSON", code: 400, userInfo: ["parsing" : false])
                        print ("parsing json error")
                        responseCallback(error, 400,nil)
                    }
                    else
                    {
                        
                        
                        responseCallback(err as NSError?, (resp as! HTTPURLResponse).statusCode, json)
                    }
                }
                else
                {
                    responseCallback(err as NSError?, 400, nil)
                }
            }
            task.resume()
        }
    }
