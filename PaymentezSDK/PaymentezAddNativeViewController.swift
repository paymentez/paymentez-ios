//
//  PaymentezAddNativeViewController.swift
//  PaymentezSDK
//
//  Created by Gustavo Sotelo on 31/08/17.
//  Copyright © 2017 Paymentez. All rights reserved.
//

import UIKit


@objc public protocol PaymentezCardAddedDelegate
{
    func cardAdded(_ error:PaymentezSDKError?, _ cardAdded:PaymentezCard?)
}

open class PaymentezAddNativeViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cardField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var cvcField: SkyFloatingLabelTextField!
    @IBOutlet weak var expirationField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var cvcImageView: UIImageView!
    
    var cardMaskedDelegate: MaskedTextFieldDelegate!
    var expirationMaskedDelegate: MaskedTextFieldDelegate!
    var cvcMaskedField: MaskedTextFieldDelegate!
    
    var cardMask:Mask = try! Mask(format: "[0000]-[0000]-[0000]-[0009]")
    var expirationMask:Mask = try! Mask(format: "[00]/[00]")
    var cvcMask:Mask = try! Mask(format: "[0009]")
    
    var baseFont = UIFont()
    var bundle = Bundle(for: PaymentezCard.self)
    var baseColor = UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0)
    
    
    var paymentezCard:PaymentezCard? = PaymentezCard()
    
    @objc var isWidget:Bool = true
    
    @objc public var addDelegate:PaymentezCardAddedDelegate?
    
    
    var cardType:PaymentezCardType =  PaymentezCardType.notSupported {
        didSet {
            

            // change card
            if self.cardType == PaymentezCardType.amex
            {
                self.cardImageView.image = UIImage(named:"stp_card_amex", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named:"stp_card_cvc_amex", in: self.bundle, compatibleWith: nil)
            }
            else if self.cardType == PaymentezCardType.masterCard
            {
                self.cardImageView.image = UIImage(named:"stp_card_mastercard", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named:"stp_card_cvc", in: self.bundle, compatibleWith: nil)
            }
            else if self.cardType == PaymentezCardType.visa
            {
                self.cardImageView.image = UIImage(named:"stp_card_visa", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named:"stp_card_cvc", in: self.bundle, compatibleWith: nil)
            }
            else if self.cardType == PaymentezCardType.diners
            {
                self.cardImageView.image = UIImage(named:"stp_card_diners", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named:"stp_card_cvc", in: self.bundle, compatibleWith: nil)
            }
            else if self.cardType == PaymentezCardType.discover
            {
                self.cardImageView.image = UIImage(named:"stp_card_discover", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named:"stp_card_cvc", in: self.bundle, compatibleWith: nil)
            }
            else if self.cardType == PaymentezCardType.jcb
            {
                self.cardImageView.image = UIImage(named:"stp_card_jcb", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named:"stp_card_cvc", in: self.bundle, compatibleWith: nil)
            }
            else {
                self.cardImageView.image = UIImage(named: "stp_card_unknown", in: self.bundle, compatibleWith: nil)
                self.cvcImageView.image = UIImage(named: "stp_card_cvc", in: self.bundle, compatibleWith: nil)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @objc public init(isWidget:Bool)
    {
        self.isWidget = isWidget
        
        let privatePath : NSString? = Bundle.main.privateFrameworksPath as NSString?
        if privatePath != nil {
            let path = privatePath!.appendingPathComponent("PaymentezSDK.framework")
            let bundle =  Bundle(path: path)
            super.init(nibName: "PaymentezAddNativeViewController", bundle: bundle)
        }
        else
        {
            super.init()
        }
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override open func viewWillAppear(_ animated: Bool) {
        
        if self.isWidget
        {
            self.addButton.isHidden = true
        }
        else
        {
            self.addButton.isHidden = false
        }
        
        
        cardField.selectedLineColor = baseColor
        nameField.selectedLineColor = baseColor
        expirationField.selectedLineColor = baseColor
        cvcField.selectedLineColor = baseColor
        
        cardField.selectedTitleColor = baseColor
        nameField.selectedTitleColor = baseColor
        expirationField.selectedTitleColor = baseColor
        cvcField.selectedTitleColor = baseColor
        
        
        
        //Localized String
        nameField.placeholder = "Name of Cardholder".localized
        cardField.placeholder = "Card Number".localized
        expirationField.placeholder = "Expiration (MM/YY)".localized
        cvcField.placeholder = "CVC/CVV"
        
        
        //Masked Delegates
        
        self.cardMaskedDelegate = MaskedTextFieldDelegate(format: "[0000]-[0000]-[0000]-[0009]")
        self.cardMaskedDelegate.listener = self
        self.cardField.delegate = cardMaskedDelegate
        
        self.expirationMaskedDelegate = MaskedTextFieldDelegate(format: "[00]/[00]")
        self.expirationMaskedDelegate.listener = self
        self.expirationField.delegate = expirationMaskedDelegate
        
        self.cvcMaskedField = MaskedTextFieldDelegate(format: "[0000]")
        self.cvcMaskedField.listener = self
        self.cvcField.delegate = cvcMaskedField
        
        super.viewWillAppear(animated)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     @objc open func getValidCard()->PaymentezCard?
    {
        self.paymentezCard?.cardHolder = self.nameField.text
        if self.cvcField.text == nil || self.cvcField.text == ""
        {
            return nil
        }
        self.paymentezCard?.cvc = self.cvcField.text!
        if self.paymentezCard?.cardHolder != nil && self.paymentezCard?.cardNumber != nil && self.paymentezCard?.cvc != nil && self.paymentezCard?.expiryMonth != nil && self.paymentezCard?.expiryYear != nil
        {
            if !PaymentezSDKClient.enableTestMode && self.cardType == .notSupported
            {
                return nil
            }
            return self.paymentezCard
        }
        return nil
    }
    
    @IBAction func scanCard(_ sender: Any) {
        PaymentezSDKClient.scanCard(self) { (closed, number, expiry, cvv) in
            if !closed
            {
                let result: Mask.Result = self.cardMask.apply(
                    toText: CaretString(
                        string: number!,
                        caretPosition: number!.endIndex
                    ),
                    autocomplete: true // you may consider disabling autocompletion for your case
                )
                let resultEx: Mask.Result = self.expirationMask.apply(
                    toText: CaretString(
                        string: expiry!,
                        caretPosition: expiry!.endIndex
                    ),
                    autocomplete: true // you may consider disabling autocompletion for your case
                )
                let resultCvv: Mask.Result = self.cvcMask.apply(
                    toText: CaretString(
                        string: cvv!,
                        caretPosition: cvv!.endIndex
                    ),
                    autocomplete: true // you may consider disabling autocompletion for your case
                )
                
                
                self.cardField.text = result.formattedText.string
                
                self.expirationField.text = resultEx.formattedText.string
                self.cvcField.text = resultCvv.formattedText.string
                self.paymentezCard?.cvc = self.cvcField.text
                
                self.paymentezCard?.cardNumber = self.cardField.text?.replacingOccurrences(of: "-", with: "")
                self.cardType = PaymentezCard.getTypeCard((self.paymentezCard?.cardNumber)!)
                let valExp = self.expirationField.text!.components(separatedBy: "/")
                if valExp.count > 1
                {
                    let expiryYear = Int(valExp[1])! + 2000
                    let expiryMonth = valExp[0]
                    self.paymentezCard?.expiryYear =  "\(expiryYear)"
                    self.paymentezCard?.expiryMonth =  expiryMonth
                }
            }
        }
    }

    
    @IBAction func addCard(_ sender: Any) {
        
        if !isWidget
        {
            if let validCard = self.getValidCard()
            {
                
                
                PaymentezSDKClient.add(validCard, uid: "69123", email: "gsotelo@paymentez.com", callback: { (error, cardAdded) in
                    
                    self.addDelegate?.cardAdded(error, cardAdded)
                })
            }

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension PaymentezAddNativeViewController: MaskedTextFieldDelegateListener
{
    public func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        
        if textField == self.cardField
        {
            self.cardField.errorMessage = ""
            self.cardType = PaymentezCard.getTypeCard(value)
            self.paymentezCard?.cardNumber = self.cardField.text?.replacingOccurrences(of: "-", with: "")
            
        }
        if textField == self.expirationField
        {
            self.expirationField.errorMessage = ""
            if complete
            {
                if PaymentezCard.validateExpDate(self.expirationField.text!)
                {
                    let valExp = self.expirationField.text!.components(separatedBy: "/")
                    if valExp.count > 1
                    {
                        let expiryYear = Int(valExp[1])! + 2000
                        
                        self.paymentezCard?.expiryYear =  "\(expiryYear)"
                        self.paymentezCard?.expiryMonth = valExp[0]
                    }
                }
                else
                {
                    self.paymentezCard?.expiryYear = nil
                    self.paymentezCard?.expiryMonth = nil
                    self.expirationField.errorMessage = "Invalid Date".localized
                }
                
            }
            
        }
        if textField == self.cvcField
        {
            self.cvcField.errorMessage = ""
            if complete
            {
                if (value.characters.count != 3 && self.cardType != .amex) || (value.characters.count != 4 && self.cardType == .amex)
                {
                    self.cvcField.errorMessage = "Invalid".localized
                    self.paymentezCard?.cvc = nil
                }
                else
                {
                    self.paymentezCard?.cvc = value
                }
            }
        }
        
    }
}
