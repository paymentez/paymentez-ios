//
//  PaymentezRequest.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 03/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation


class PaymentezRequest
{
    
    
    func makeRequest(urlToRequest:String, parameters:NSDictionary, responseCallback:(error:NSError?, responseData:AnyObject?) ->Void)
    {
        let url:NSURL? = NSURL(string: urlToRequest)
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL:url!)
        do
        {
            
            let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
            request.HTTPBody = data
        }
        catch {
            
        }
        request.HTTPMethod = "POST"
        
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
                    responseCallback(error: error, responseData:nil)
                }
                else
                {
                    print(json)
                    responseCallback(error: err, responseData:json)
                }
            }
            else
            {
                responseCallback(error: err, responseData:nil)
            }
        }
        task.resume()
    }
    
    
    
}