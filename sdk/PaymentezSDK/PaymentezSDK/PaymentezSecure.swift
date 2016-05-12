//
//  PaymentezSecure.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 04/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation
import UIKit

class PaymentezSecure: NSObject,DeviceCollectorSDKDelegate

{
    let targetUrlDev = "https://tst.kaptcha.com/logo.htm"
    let targetUrlProd = "https://ssl.kaptcha.com/logo.htm"
    let merchantId = "500005"
    let deviceCollector:DeviceCollectorSDK
    var testMode = true
    var callback:((err:NSError?) -> Void)?
    
    init(testMode:Bool)
    {
        if(testMode)
        {
            self.deviceCollector = DeviceCollectorSDK(debugOn: true)
            
            self.deviceCollector.setCollectorUrl(targetUrlDev)
        }
        else{
            self.deviceCollector = DeviceCollectorSDK(debugOn: false)
            
            self.deviceCollector.setCollectorUrl(targetUrlProd)
        }
        self.callback = nil
        super.init()
        self.deviceCollector.setDelegate(self)
        self.deviceCollector.setMerchantId(self.merchantId)
        
    }
    
    func generateSessionId() -> String!
    {
        return NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
    }
    
    func collect(sessionId:String, callback:(err:NSError?) -> Void)
    {
        self.callback = callback
        self.deviceCollector.collect(sessionId)
    }
    
    func onCollectorStart() {
        
    }
    
    func onCollectorSuccess() {
        self.callback!(err:nil)
    }
    func onCollectorError(errorCode: Int32, withError error: NSError!) {
        
        self.callback!(err:error)
        
    }
    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
    
    static func getIpAddress(callback:(ipAddress:String!)->Void)
    {
        var ip = "127.0.0.1"
        
        let completeUrl = "https://ccapi-stg.paymentez.com/api/cc/ip"
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
                ip = String(data: data!, encoding: NSUTF8StringEncoding)!
                
            }
            callback(ipAddress: ip)
        }
        task.resume()
    }
    
    
    
    
}