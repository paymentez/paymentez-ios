//
//  PaymentezRequest.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 03/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation

@objc public class PaymentezDebitParameters:NSObject

{
    public var uid = ""
    public var cardReference = ""
    public var productAmount = 0.0
    public var productDescription = ""
    public var devReference = ""
    public var vat = 0.0
    public var email = ""
    public var productDiscount = 0.0
    public var installments = 1
    public var buyerFiscalNumber = ""
    public var sellerId = ""
    public var shippingStreet = ""
    public var shippingHouseNumber = ""
    public var shippingCity = ""
    public var shippingZip = ""
    public var shippingState = ""
    public var shippingCountry = ""
    public var shippingDistrict = ""
    public var shippingAdditionalAddressInfo = ""
    
    public override init()
    {
        
    }
    
    func requiredDict() -> [String:AnyObject]
    {
        var dic = [String:AnyObject]()
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
    func allParamsDict() -> [String:AnyObject]
    {
        var dic = [String:AnyObject]()
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
        if self.buyerFiscalNumber != ""{dic["buyer_fiscal_number"] = self.buyerFiscalNumber}
        if self.sellerId != ""{dic["seller_id"] = self.sellerId}
        if self.shippingStreet != ""{dic["shipping_street"] = self.shippingStreet}
        if self.shippingHouseNumber != ""{dic["shipping_house_number"] = self.shippingHouseNumber}
        if self.shippingCity != ""{dic["shipping_city"] = self.shippingCity}
        if self.shippingZip != ""{dic["shipping_zip"] = self.shippingZip}
        if self.shippingState != ""{dic["shipping_state"] = self.shippingState}
        if self.shippingCountry != ""{dic["shipping_country"] = self.shippingCountry}
        if self.shippingDistrict != ""{dic["shipping_district"] = self.shippingDistrict}
        if self.shippingAdditionalAddressInfo != ""{dic["shipping_additional_address_info"] = self.shippingAdditionalAddressInfo}
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
    func getUrl(base:String, parameters:NSDictionary) -> String
    {
        var completeUrl = self.testUrl + base
        if !testMode{
            completeUrl = self.prodUrl + base
        }
        completeUrl += "?" + encodeParamsGet(parameters)
        return completeUrl
    }
    func encodeParams(parameters:NSDictionary) ->NSData?
    {
        var bodyData = ""
        for (key,value) in parameters{
            let scapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            let scapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            bodyData += "\(scapedKey)=\(scapedValue)&"
        }
        print(bodyData)
        return bodyData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    }
    func encodeParamsGet(parameters:NSDictionary) -> String!
    {
        var bodyData = ""
        for (key,value) in parameters{
            let scapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            let scapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            bodyData += "\(scapedKey)=\(scapedValue)&"
        }
        
        return bodyData
    }
    func makeRequest(urlToRequest:String, parameters:NSDictionary, responseCallback:(error:NSError?, statusCode:Int?,responseData:AnyObject?) ->Void)
    {
        var completeUrl = self.testUrl + urlToRequest
        if !testMode{
            completeUrl = self.prodUrl + urlToRequest
        }
        
        let url:NSURL? = NSURL(string: completeUrl)
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL:url!)
        /*do
        {
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
            request.HTTPBody = data
        }
        catch {
            
        }
        */
        request.HTTPMethod = "POST"
        request.HTTPBody = encodeParams(parameters)
        
        let task = session.dataTaskWithRequest(request) { (data:NSData?, resp:NSURLResponse?, err:NSError?) -> Void in
            
            if err == nil
            {
                var json:AnyObject? = nil
                
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                }
                catch {
                    
                }
                
                if json == nil{
                    let error = NSError(domain: "JSON", code: 400, userInfo: ["parsing" : false])
                    print ("parsing json error")
                    if resp != nil
                    {
                        
                        responseCallback(error: error, statusCode:(resp as! NSHTTPURLResponse).statusCode,responseData:nil)
                    }
                    else
                    {
                        responseCallback(error: error, statusCode:400,responseData:nil)
                    }
                }
                else
                {
                    
                    print(json)
                    responseCallback(error: err, statusCode: (resp as! NSHTTPURLResponse).statusCode, responseData:json)
                }
            }
            else
            {
                responseCallback(error: err, statusCode: 400, responseData:nil)
            }
        }
        task.resume()
    }
    func makeRequestGet(urlToRequest:String, parameters:NSDictionary, responseCallback:(error:NSError?, statusCode:Int?,responseData:AnyObject?) ->Void)
    {
        var completeUrl = self.testUrl + urlToRequest
        if !testMode{
            completeUrl = self.prodUrl + urlToRequest
        }
        completeUrl += "?" + encodeParamsGet(parameters)
        let url:NSURL? = NSURL(string: completeUrl)
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL:url!)
        /*do
         {
         
         let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
         request.HTTPBody = data
         }
         catch {
         
         }
         */
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request) { (data:NSData?, resp:NSURLResponse?, err:NSError?) -> Void in
            
            if err == nil
            {
                var json:AnyObject? = nil
                
                do{
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                }
                catch {
                    
                }
                
                if json == nil{
                    let error = NSError(domain: "JSON", code: 400, userInfo: ["parsing" : false])
                    print ("parsing json error")
                    responseCallback(error: error, statusCode:400,responseData:nil)
                }
                else
                {
                    
                    
                    responseCallback(error: err, statusCode: (resp as! NSHTTPURLResponse).statusCode, responseData:json)
                }
            }
            else
            {
                responseCallback(error: err, statusCode: 400, responseData:nil)
            }
        }
        task.resume()
    }
    
    
    
    
    
}