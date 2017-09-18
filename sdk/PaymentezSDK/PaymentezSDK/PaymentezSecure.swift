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
    var callback:((_ err:NSError?) -> Void)?
    
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
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    func collect(_ sessionId:String, callback:@escaping (_ err:NSError?) -> Void)
    {
        self.callback = callback
        self.deviceCollector.collect(sessionId)
    }
    
    func onCollectorStart() {
        
    }
    
    func onCollectorSuccess() {
        self.callback!(nil)
    }
    func onCollectorError(errorCode: Int32, withError error: NSError!) {
        
        self.callback!(error)
        
    }
    override func isEqual(_ anObject: Any?) -> Bool {
        return super.isEqual(anObject)
    }
    
    static func getIpAddress(_ callback:@escaping (_ ipAddress:String?)->Void)
    {
        var ip = "127.0.0.1"
        
        let completeUrl = "https://ccapi-stg.paymentez.com/api/cc/ip"
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
                ip = String(data: data!, encoding: String.Encoding.utf8)!
                
            }
            callback(ip)
        }
        task.resume()
    }
    
    
    
    
}
