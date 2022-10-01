//
//  PaymentAddNativeViewController.swift
//  PaymentSDK
//
//  Created by Gustavo Sotelo on 31/08/17.
//  Copyright © 2017 Payment. All rights reserved.
//

import UIKit


@objc public protocol PaymentCardAddedDelegate
{
    func cardAdded(_ error: PaymentSDKError?, _ cardAdded: PaymentCard?)
    @objc optional func viewClosed()
}

open class PaymentAddNativeViewController: UIViewController {
    
    open var backgroundColor: UIColor? = .white {
        didSet {
            setupColor()
        }
    }
    
    open var baseColor = PaymentStyle.baseBaseColor {
        didSet {
            setupColor()
        }
    }
    
    open var baseFont = PaymentStyle.font {
        didSet {
            setupColor()
        }
    }
    
    open var baseFontColor: UIColor? = .black {
        didSet {
            setupColor()
        }
    }
    
    var bundle = Bundle(for: PaymentCard.self)
    var titleString: String  = "Add Card".localized
    open var isModal: Bool = false
    
    open var showLogo: Bool = true {
        didSet {
            self.PaymentLogo.isHidden = !self.showLogo
        }
    }
    
    let buttonMessage = ["off": "Continue without code".localized, "on": "Continue with NIP".localized]
    
    private var showNip = true {
        didSet {
            self.toggleNip(show: showNip) // show
        }
    }
    
    private var showTuya = false {
        didSet {
            self.toggleTuya(show: self.showTuya)
        }
    }
    
    private var showOtp = false {
        didSet{
            if self.showOtp{
                self.useSMSButton.isHidden = false
            } else {
                self.useSMSButton.isHidden = true
            }
        }
    }
    
    let paymentCard: PaymentCard = PaymentCard()
    
    var uid: String!
    var email: String!
    
    let mainView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        
        stackView.backgroundColor = .clear
        return stackView
    }()
    let nameView: UIStackView = {
        let stackView = UIStackView()
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        return stackView
    }()
    let cardNumberView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    let verificationView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    let tuyaView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.spacing = 10
        return stackView
    }()
    let otpNipView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    
    let cardField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Card Number".localized
        field.keyboardType = .numberPad
        return field
    }()
    let cvcField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "CVC/CVV"
        field.keyboardType = .numberPad
        return field
    }()
    let expirationField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Expiration (MM/YY)".localized
        field.keyboardType = .numberPad
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let nameField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Name of Cardholder".localized
        return field
    }()
    
    //TUYA Elements
    
    let documentField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Document Identifier".localized
        field.keyboardType = .numberPad
        return field
    }()
    
    let nipField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "NIP".localized
        field.keyboardType = .numberPad
        field.isSecureTextEntry = true
        return field
    }()
    
    let useSMSButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(PaymentStyle.baseBaseColor, for: .normal)
        btn.clipsToBounds = true
        btn.setTitle("Continue without code".localized, for: .normal)
        btn.titleLabel?.font = PaymentStyle.fontSmall
        //btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let smsMessageField: UITextView = {
        let txtView = UITextView()
        txtView.text = "Validate this operation using a temporal unique code that will be sent by SMS or E-email registered at Tuya.".localized
        txtView.isEditable = false
        txtView.textAlignment = .center
        txtView.isSelectable = false
        txtView.isScrollEnabled = false
        txtView.isHidden = true
        txtView.font = PaymentStyle.fontExtraSmall
        txtView.textColor = PaymentStyle.baseFontColor
        txtView.backgroundColor = PaymentStyle.baseBaseColor
        return txtView
    }()
    
    private let PaymentLogo : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"logo_Payment_black", in: Bundle(for: PaymentCard.self), compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let logoView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"stp_card_unknown", in: Bundle(for: PaymentCard.self), compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    let cvcImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"stp_card_cvc", in: Bundle(for: PaymentCard.self), compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = baseColor
        btn.tintColor = baseFontColor
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.setTitle("Add Card".localized, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let sp = UIActivityIndicatorView(style: .whiteLarge)
        sp.color = baseColor
        sp.translatesAutoresizingMaskIntoConstraints = false
        sp.hidesWhenStopped = true
        sp.startAnimating()
        return sp
    }()
    
    lazy var spinnerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor?.withAlphaComponent(0.8)
        return view
    }()
    
    // SWITCH
    @objc var isWidget: Bool = false
    
    //DELEGATE
    @objc public var delegate: PaymentCardAddedDelegate?
    
    //MASK DELEGATES
    var cardMaskedDelegate: MaskedTextFieldDelegate!
    var expirationMaskedDelegate: MaskedTextFieldDelegate!
    var cvcMaskedField: MaskedTextFieldDelegate!
    var nameMask: MaskedTextFieldDelegate!
    var documentMask: MaskedTextFieldDelegate!
    var nipMaskedField: MaskedTextFieldDelegate!
    
    //MASK
    var cardMask:Mask = try! Mask(format: "[0000]-[0000]-[0000]-[0009]")
    var expirationMask:Mask = try! Mask(format: "[00]/[00]")
    var cvcMask:Mask = try! Mask(format: "[0009]")
    
    
    var cardType: PaymentCardType =  PaymentCardType.notSupported {
        didSet {
            
            self.paymentCard.cardType = self.cardType
            DispatchQueue.main.async {
                // change card
                if self.cardType == .notSupported {
                    self.logoView.image = UIImage(named: "stp_card_unknown", in: self.bundle, compatibleWith: nil)
                    self.cvcImageView.image = UIImage(named: "stp_card_cvc", in: self.bundle, compatibleWith: nil)
                }
            }
            
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @objc public init(uid: String, email: String) {
        super.init(nibName: nil, bundle: nil)
        self.uid = uid
        self.email = email
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: View Setup Methods
    private func setupViews(){
        setupColor()
        setupMask()
        setupAddPresentation()
        setupViewLayouts()
    }
    
    private func setupColor(){
        self.view.backgroundColor = backgroundColor
        spinnerView.backgroundColor = backgroundColor?.withAlphaComponent(0.8)
        
        //SETUP COLOR
        cardField.selectedLineColor = baseColor
        nameField.selectedLineColor = baseColor
        expirationField.selectedLineColor = baseColor
        cvcField.selectedLineColor = baseColor
        documentField.selectedLineColor = baseColor
        nipField.selectedTitleColor = baseColor
        
        cardField.backgroundColor = backgroundColor
        nameField.backgroundColor = backgroundColor
        expirationField.backgroundColor = backgroundColor
        cvcField.backgroundColor = backgroundColor
        documentField.backgroundColor = backgroundColor
        nipField.backgroundColor = backgroundColor
        mainView.backgroundColor = backgroundColor
        cvcImageView.backgroundColor = backgroundColor
        cardNumberView.backgroundColor = backgroundColor
        addButton.backgroundColor = baseColor
        spinner.color = baseColor
        
        cardField.textColor = baseFontColor
        nameField.textColor = baseFontColor
        expirationField.textColor = baseFontColor
        documentField.textColor = baseFontColor
        nipField.textColor = baseFontColor
        cvcField.textColor = baseFontColor
        addButton.tintColor = baseFontColor
        
        cardField.font = baseFont
        nameField.font = baseFont
        expirationField.font = baseFont
        cvcField.font = baseFont
        documentField.font = baseFont
        nipField.font = baseFont
        
    }
    
    private func setupMask(){
        //SETUP MASK
        self.cardMaskedDelegate = MaskedTextFieldDelegate(format: "[0000]-[0000]-[0000]-[0009]")
        self.cardMaskedDelegate.listener = self
        self.cardField.delegate = cardMaskedDelegate
        
        self.expirationMaskedDelegate = MaskedTextFieldDelegate(format: "[00]/[00]")
        self.expirationMaskedDelegate.listener = self
        self.expirationField.delegate = expirationMaskedDelegate
        
        self.cvcMaskedField = MaskedTextFieldDelegate(format: "[0000]")
        self.cvcMaskedField.listener = self
        self.cvcField.delegate = cvcMaskedField
        
        self.nipMaskedField = MaskedTextFieldDelegate(format: "[0000]")
        self.nipMaskedField.listener = self
        
        self.nipField.delegate = nipMaskedField
        
        
        self.nameField.addTarget(self, action:#selector(self.textfieldDidChange(_:)), for: .editingChanged)
        
        documentMask = MaskedTextFieldDelegate(format:"[-------------------------------------------]")
        documentMask.listener = self
        self.documentField.delegate = documentMask
        
        
    }
    
    private func setupAddPresentation(){
        guard !self.isWidget else {
            self.addButton.isHidden = true
            return
        }
        //CONFIGURE ADDBUTTON
        self.title = self.titleString
        self.addButton.isHidden = false
        self.addButton.addTarget(self, action: #selector(self.addCard(_:)), for: .touchUpInside)
        self.view.addSubview(self.addButton)
        
        //self.addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        self.addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.addButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        self.addButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        
        // Create close button
        if isModal {
            let barBtn = UIBarButtonItem(image: UIImage(named:"icon_close", in: self.bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(close(_:)))
            barBtn.tintColor = PaymentStyle.baseFontColor
            self.navigationItem.rightBarButtonItem = barBtn
        }
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //Configure Spinner
        
        self.spinnerView.addSubview(self.spinner)
        
        
        
    }
    private func setupViewLayouts(){
        //SETUP nameView
        self.nameView.addArrangedSubview(self.nameField)
        
        //SETUP cardNumberView
        
        self.cardNumberView.addArrangedSubview(self.logoView)
        self.cardNumberView.addArrangedSubview(self.cardField)
        
        self.logoView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        self.logoView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        //self.logoView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        //SETUP VERIFICATIONVIEW
        
        self.verificationView.addArrangedSubview(self.expirationField)
        self.verificationView.addArrangedSubview(self.cvcImageView)
        self.verificationView.addArrangedSubview(self.cvcField)
        self.expirationField.widthAnchor.constraint(equalTo: self.verificationView.widthAnchor, multiplier: 0.5).isActive = true
        self.cvcImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        //SETUP TUYA VIEW
        
        self.useSMSButton.addTarget(self, action: #selector(dismissNip(_:)), for: .touchUpInside)
        self.otpNipView.addArrangedSubview(self.nipField)
        self.otpNipView.addArrangedSubview(self.useSMSButton)
        
        
        self.tuyaView.addArrangedSubview(self.documentField)
        self.tuyaView.addArrangedSubview(self.otpNipView)
        self.tuyaView.addArrangedSubview(self.smsMessageField)
        
        
        
        // ADD SUBVIEWS
        self.mainView.addArrangedSubview(self.nameView)
        self.mainView.addArrangedSubview(self.cardNumberView)
        self.mainView.addArrangedSubview(self.verificationView)
        if showLogo{
            self.mainView.addArrangedSubview(self.PaymentLogo)
        }
        self.view.addSubview(self.mainView)
        
        //SETUP MAIN VIEW
        if isWidget {
            self.mainView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
            // self.mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        } else{
            self.addButton.topAnchor.constraint(equalTo: self.mainView.bottomAnchor, constant: 10).isActive = true
            
            
            self.view.addSubview(self.spinnerView)
            
            self.spinnerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
            self.spinnerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 1).isActive = true
            self.spinnerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -1).isActive = true
            self.spinnerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
            
            self.spinner.centerXAnchor.constraint(equalTo: self.spinnerView.centerXAnchor).isActive = true
            self.spinner.centerYAnchor.constraint(equalTo: self.spinnerView.centerYAnchor).isActive = true
            self.spinner.heightAnchor.constraint(equalToConstant: 100 ).isActive = true
            self.spinner.widthAnchor.constraint(equalToConstant: 100 ).isActive = true
            //self.mainView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        }
        
        if #available(iOS 11.0, *) {
            self.mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            self.mainView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        }
        self.mainView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        self.mainView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
    }
    
    private func toggleTuya(show:Bool){
        
        if !show {
            // dismiss
            self.tuyaView.isHidden = true
            self.verificationView.isHidden = false
            self.mainView.insertArrangedSubview(self.verificationView, at: 2)
            self.tuyaView.removeFromSuperview()
        } else {
            // show
            //
            self.tuyaView.isHidden = false
            self.verificationView.isHidden = true
            self.mainView.insertArrangedSubview(self.tuyaView, at: 2)
            self.verificationView.removeFromSuperview()
            self.showNip = true
        }
    }
    
    
    @objc func dismissNip(_ sender:Any){
        self.showNip = false
    }
    
    @objc func showNip(_ sender:Any){
        self.showNip = true
    }
    
    
    private func toggleNip(show:Bool){
        if !show {
            // dismiss
            self.useSMSButton.setTitle(buttonMessage["on"], for: .normal)
            self.nipField.isHidden = true
            self.smsMessageField.isHidden = false
            self.useSMSButton.removeTarget(self, action: #selector(dismissNip(_:)), for: .touchUpInside)
            self.useSMSButton.addTarget(self, action: #selector(showNip(_:)), for: .touchUpInside)
        } else if show{
            // show
            //
            self.useSMSButton.setTitle(buttonMessage["off"], for: .normal)
            self.smsMessageField.isHidden = true
            self.nipField.isHidden = false
            self.useSMSButton.removeTarget(self, action: #selector(showNip(_:)), for: .touchUpInside)
            self.useSMSButton.addTarget(self, action: #selector(dismissNip(_:)), for: .touchUpInside)
        }
    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Card Validation Methods
    
    private func validateCard(_ cardNumber:String) {
        PaymentCard.validate(cardNumber: self.cardField.text!.replacingOccurrences(of: "-", with: "")) { (brand: PaymentBrand?) in
            guard let brand = brand else { return }
            DispatchQueue.main.async {
                self.cardType = brand.type
                self.logoView.image = UIImage(named: brand.imagePath, in: Bundle(for: PaymentCard.self), compatibleWith: nil)
                let cvcImagePath = brand.type == .amex ? "stp_card_cvc_amex" : "stp_card_cvc"
                self.cvcImageView.image = UIImage(named:cvcImagePath, in: Bundle(for: PaymentCard.self), compatibleWith: nil)
                self.toggleTuya(show: brand.type == .alkosto || brand.type == .exito)
            }
        }
    }
    
    @objc open func getValidCard() -> PaymentCard? {
        if self.paymentCard.cardType == .notSupported {
            return nil
        }
        guard let _ = self.paymentCard.cardHolder else {
            self.nameField.errorMessage = "Invalid".localized
            return nil
        }
        guard let _ = self.paymentCard.cardNumber else {
            self.cardField.errorMessage = "Invalid Card Number".localized
            return nil
        }
        if self.cardType == .alkosto || self.cardType == .exito  //tarjetas tuya
        {
            if showNip{
                guard let _ = self.paymentCard.nip  else {
                    self.nipField.errorMessage = "Invalid".localized
                    return nil
                }
            }
            guard let _ = self.paymentCard.fiscalNumber else {
                self.documentField.errorMessage = "Invalid".localized
                return nil
            }
            
            return self.paymentCard
            
        } else { // las demás
            guard let _ = self.paymentCard.cvc else {
                self.cvcField.errorMessage = "Invalid".localized
                return nil
            }
            guard let _ = self.paymentCard.expiryMonth else {
                self.expirationField.errorMessage = "Invalid Date".localized
                return nil
            }
            guard let _ = self.paymentCard.expiryYear else {
                self.expirationField.errorMessage = "Invalid Date".localized
                return nil
            }
            return self.paymentCard
        }
    }
    
    //MARK: Actions
    
    @objc func close(_ sender:Any){
        self.dismiss(animated: true) {
            self.delegate?.viewClosed?()
        }
    }
    
    @objc func addCard(_ sender: Any) {
        self.view.endEditing(true)
        guard !isWidget, let uid  = self.uid, let email = self.email else { return }
        if let validCard = self.getValidCard() {
            self.showSpinner()
            PaymentSDKClient.add(validCard, uid: uid, email: email, callback: { [weak self] (error, cardAdded) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.hideSpinner()
                    if self.isModal {
                        self.dismiss(animated: true, completion: {
                            self.delegate?.cardAdded(error, cardAdded)
                        })
                    } else {
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.cardAdded(error, cardAdded)
                    }
                }
            })
        } else {
            self.delegate?.cardAdded(PaymentSDKError.createError(403, description: "Card Not Supported", help: "Change Number", type:nil), nil)
        }
    }
    
}

extension PaymentAddNativeViewController: MaskedTextFieldDelegateListener {
    public func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        
        if textField == self.cardField {
            self.cardField.errorMessage = ""
            self.paymentCard.cardNumber = self.cardField.text?.replacingOccurrences(of: "-", with: "")
            if value.count >= 6  && value.count <= 16 && self.cardType == .notSupported { // check bin
                self.validateCard(value)
                if value.count < 14 {
                    self.cardField.errorMessage = "Invalid".localized
                }
            } else if value.count < 6 {
                self.cardType = .notSupported
                self.cardField.errorMessage = "Invalid".localized
                self.toggleTuya(show:false)
                
            }
            if value.count < 14 {
                self.cardField.errorMessage = "Invalid".localized
            }
            
            
        }
        if textField == self.expirationField
        {
            self.expirationField.errorMessage = ""
            if complete
            {
                if PaymentCard.validateExpDate(self.expirationField.text!)
                {
                    let valExp = self.expirationField.text!.components(separatedBy: "/")
                    if valExp.count > 1
                    {
                        let expiryYear = Int(valExp[1])! + 2000
                        
                        self.paymentCard.expiryYear =  "\(expiryYear)"
                        self.paymentCard.expiryMonth = valExp[0]
                    }
                }
                else
                {
                    self.paymentCard.expiryYear = nil
                    self.paymentCard.expiryMonth = nil
                    self.expirationField.errorMessage = "Invalid Date".localized
                }
                
            }
            
        }
        if textField == self.cvcField
        {
            self.cvcField.errorMessage = ""
            if (value.count != 3 && self.cardType != .amex) || (value.count != 4 && self.cardType == .amex)
            {
                self.cvcField.errorMessage = "Invalid".localized
                self.paymentCard.cvc = nil
            }
            else
            {
                self.paymentCard.cvc = value
            }
        }
        if textField == self.documentField{
            self.paymentCard.fiscalNumber = self.documentField.text
        }
        if textField == self.nipField {
            self.nipField.errorMessage = ""
            if value.count != 4{
                self.nipField.errorMessage = "Invalid".localized
                self.paymentCard.nip = nil
            } else {
                self.paymentCard.nip  = self.nipField.text
            }
            
        }
        
        if textField == self.documentField{
            self.documentField.errorMessage = ""
            if value.count > 3{
                self.paymentCard.fiscalNumber = value
            } else {
                self.documentField.errorMessage = "Invalid".localized
                self.paymentCard.fiscalNumber = nil
            }
        }
        
    }
}
// MARK: TextField Didchange
extension PaymentAddNativeViewController {
    
    func cancelEditing(){
        self.nameField.resignFirstResponder()
        self.cardField.resignFirstResponder()
        self.cvcField.resignFirstResponder()
        self.expirationField.resignFirstResponder()
        self.documentField.resignFirstResponder()
        self.nipField.resignFirstResponder()
        
    }
    
    @objc func textfieldDidChange(_ sender:Any){
        
        if sender as? SkyFloatingLabelTextField == self.nameField{
            guard let value = self.nameField.text else {
                return
            }
            self.nameField.errorMessage = ""
            if value.count > 4{
                self.paymentCard.cardHolder = value
            } else {
                self.nameField.errorMessage = "Invalid".localized
                self.paymentCard.cardHolder = nil
            }
        }
        
    }
}

extension PaymentAddNativeViewController {
    
    func showSpinner() {
        if !isWidget {
            DispatchQueue.main.async {
                self.spinnerView.isHidden = false
            }
            
        }
    }
    
    func hideSpinner(){
        DispatchQueue.main.async {
            self.spinnerView.isHidden = true
        }
        
    }
}
