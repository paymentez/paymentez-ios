//
//  PaymentezRequest.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 03/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation

@objc open class PaymentezDebitParameters:NSObject

{
    open var uid = ""
    open var cardReference = ""
    open var productAmount = 0.0
    open var productDescription = ""
    open var devReference = ""
    open var vat = 0.0
    open var email = ""
    open var productDiscount = 0.0
    open var installments = 1
    open var buyerFiscalNumber = ""
    open var sellerId = ""
    open var shippingStreet = ""
    open var shippingHouseNumber = ""
    open var shippingCity = ""
    open var shippingZip = ""
    open var shippingState = ""
    open var shippingCountry = ""
    open var shippingDistrict = ""
    open var shippingAdditionalAddressInfo = ""
    
    public override init()
    {
        
    }
    
    func requiredDict() -> [String:Any]
    {
        var dic = [String:Any]()
        dic["card_reference"] =  self.cardReference
        dic["product_amount"] = String(format: "%.2f", self.productAmount)
        dic["product_description"] = self.productDescription
        dic["dev_reference"] = self.devReference
        dic["vat"] = String(format: "%.2f", self.vat)
        dic["email"] = self.email
        dic["uid"] = self.uid
        if productDiscount > 0.0
        {
            dic["product_discount"] = String(format: "%.2f", self.productDiscount)
        }
        if self.installments > 1
        {
            dic["installments"] = self.installments 
        }
        
        return dic
        
    }
    func allParamsDict() -> [String:Any]
    {
        var dic = [String:Any]()
        dic["card_reference"] =  self.cardReference 
        dic["product_amount"] = String(format: "%.2f", self.productAmount) 
        dic["product_description"] = self.productDescription 
        dic["dev_reference"] = self.devReference 
        dic["vat"] = String(format: "%.2f", self.vat) 
        dic["email"] = self.email 
        dic["uid"] = self.uid 
        if productDiscount > 0.0
        {
            dic["product_discount"] = String(format: "%.2f", self.productDiscount) 
        }
        if self.installments > 1
        {
            dic["installments"] = self.installments 
        }
        if self.buyerFiscalNumber != ""{dic["buyer_fiscal_number"] = self.buyerFiscalNumber }
        if self.sellerId != ""{dic["seller_id"] = self.sellerId }
        if self.shippingStreet != ""{dic["shipping_street"] = self.shippingStreet }
        if self.shippingHouseNumber != ""{dic["shipping_house_number"] = self.shippingHouseNumber }
        if self.shippingCity != ""{dic["shipping_city"] = self.shippingCity }
        if self.shippingZip != ""{dic["shipping_zip"] = self.shippingZip }
        if self.shippingState != ""{dic["shipping_state"] = self.shippingState }
        if self.shippingCountry != ""{dic["shipping_country"] = self.shippingCountry }
        if self.shippingDistrict != ""{dic["shipping_district"] = self.shippingDistrict }
        if self.shippingAdditionalAddressInfo != ""{dic["shipping_additional_address_info"] = self.shippingAdditionalAddressInfo }
        return dic
    }
 
}

class PaymentezRequest
{
    let testUrl = "https://ccapi-stg.paymentez.com"
    let prodUrl = "https://ccapi.paymentez.com"
    var testMode = false
    init(testMode:Bool!)
    {
        
    }
    func getUrl(_ base:String, parameters:NSDictionary) -> String
    {
        var completeUrl = self.testUrl + base
        if !testMode{
            completeUrl = self.prodUrl + base
        }
        completeUrl += "?" + encodeParamsGet(parameters)
        return completeUrl
    }
    func encodeParams(_ parameters:NSDictionary) ->Data?
    {
        var bodyData = ""
        for (key,value) in parameters{
            let scapedKey = (key as! String).addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed)!
            let scapedValue = (value as! String).addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed)!
            bodyData += "\(scapedKey)=\(scapedValue)&"
        }
        print(bodyData)
        return bodyData.data(using: String.Encoding.utf8, allowLossyConversion: true)
    }
    func encodeParamsGet(_ parameters:NSDictionary) -> String!
    {
        var bodyData = ""
        for (key,value) in parameters{
            let scapedKey = (key as! String).addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed)!
            let scapedValue = (value as! String).addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed)!
            bodyData += "\(scapedKey)=\(scapedValue)&"
        }
        
        return bodyData
    }
    func makeRequest(_ urlToRequest:String, parameters:NSDictionary, responseCallback:@escaping (_ error:NSError?, _ statusCode:Int?,_ responseData:Any?) ->Void)
    {
        var completeUrl = self.testUrl + urlToRequest
        if !testMode{
            completeUrl = self.prodUrl + urlToRequest
        }
        
        let url:URL? = URL(string: completeUrl)
        let session = URLSession.shared
        
        var request = URLRequest(url:url!)
        print(url)
        /*do
        {
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
            request.HTTPBody = data
        }
        catch {
            
        }
        */
        request.httpMethod = "POST"
        request.httpBody = encodeParams(parameters)
        
        let task = session.dataTask(with: request){
            data, resp, err in
            print(data)
            if err == nil
            {
                var json:Any? = nil
                
                do{
                    json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                    print(json)
                }
                catch {
                    
                }
                
                if json == nil{
                    let error = NSError(domain: "JSON", code: 400, userInfo: ["parsing" : false])
                    print ("parsing json error")
                    if resp != nil
                    {
                        
                        responseCallback(error, (resp as! HTTPURLResponse).statusCode,nil)
                    }
                    else
                    {
                        responseCallback(error, 400,nil)
                    }
                }
                else
                {
                    
                    print(json)
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
    func makeRequestGet(_ urlToRequest:String, parameters:NSDictionary, responseCallback:@escaping (_ error:NSError?, _ statusCode:Int?,_ responseData:Any?) ->Void)
    {
        var completeUrl = self.testUrl + urlToRequest
        if !testMode{
            completeUrl = self.prodUrl + urlToRequest
        }
        completeUrl += "?" + encodeParamsGet(parameters)
        let url:URL? = URL(string: completeUrl)
        let session = URLSession.shared
        
        var request = URLRequest(url:url!)
        /*do
         {
         
         let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
         request.HTTPBody = data
         }
         catch {
         
         }
         */
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
