//
//  PaymentezAddViewController.swift
//  PaymentezSDK
//
//  Created by Gustavo Sotelo on 11/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit

class PaymentezAddViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var urlToLoad = ""
    var callback:((error:PaymentezSDKError?, isClose:Bool, added:Bool) -> Void)? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    init(callback:(error:PaymentezSDKError?, isClose:Bool, added:Bool) -> Void)
    {
        
        self.urlToLoad = ""
        self.callback = callback
        let privatePath : NSString? = NSBundle.mainBundle().privateFrameworksPath
        if privatePath != nil {
            let path = privatePath!.stringByAppendingPathComponent("PaymentezSDK.framework")
            let bundle =  NSBundle(path: path)
            super.init(nibName: "PaymentezAddViewController", bundle: bundle)
        }
        else
        {
            super.init()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        
        // Do any additional setup after loading the view.
    }
    
    func loadUrl(urlToLoad:String)
    {
        self.urlToLoad = urlToLoad
        let url:NSURL? = NSURL(string: self.urlToLoad)
        let request = NSMutableURLRequest(URL:url!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeAction(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { 
            self.callback!(error: nil, isClose: true, added: false)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityIndicator.startAnimating()
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        let urlLoaded = self.webView.request?.URL?.absoluteString
        if urlLoaded!.rangeOfString("save") != nil
        {
            let cookieJar = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            let cookieJarForUrl = (cookieJar.cookiesForURL(NSURL(string: urlLoaded!)!))
            for cookie in cookieJarForUrl!
            {
                if cookie.name == "pmntz_error_message"
                {
                    var error:PaymentezSDKError
                    if cookie.value.rangeOfString("verify") != nil
                    {
                        error = PaymentezSDKError.createError(3, description: "System Error", details: [cookie.value])
                    }
                    else
                    {
                        error = PaymentezSDKError.createError(3, description: "System Error", details: cookie.value)
                    }
                    
                    
                    self.dismissViewControllerAnimated(true) {
                        self.callback!(error: error, isClose: false, added: false)
                    }
                    
                }
                else if cookie.name == "pmntz_add_success"
                {
                    
                    if cookie.value == "success" || cookie.value == "true"
                    {
                        self.dismissViewControllerAnimated(true) {
                            self.callback!(error: nil, isClose: false, added: true)
                        }
                    }
                    else
                    {
                        self.dismissViewControllerAnimated(true) {
                            self.callback!(error: PaymentezSDKError.createError(3, description: "System Error", details: "Could not add card"), isClose: false, added: false)
                        }
                    }
                }
            }
        }
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
