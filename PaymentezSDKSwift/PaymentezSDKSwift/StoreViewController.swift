//
//  StoreViewController.swift
//  PaymentezSDKSwift
//
//  Created by Gustavo Sotelo on 08/09/17.
//  Copyright © 2017 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK



class StoreViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableV: UITableView!
    
    var paymentezRequestParameters:PaymentezDebitParameters?
    
    var selectedCard:PaymentezCard?
    
    var productTitles = ["Pozole Blanco", "Latte"]
    
    var productPrices = [80.0, 50.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableV.tableFooterView = UITableView()
        
        self.activityIndicator.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func placeOrder(_ sender: Any) {
        
        if self.selectedCard != nil
        {
            self.activityIndicator.startAnimating()
            var total = 0.0
            for p in self.productPrices
            {
                total = p + total
            }
            let paymentezDebit = PaymentezDebitParameters()
            paymentezDebit.buyerFiscalNumber = "232323-232323-232"
            let uuid = UUID().uuidString
            paymentezDebit.devReference = uuid
            paymentezDebit.uid = UserModel.uid
            paymentezDebit.email = UserModel.email
            paymentezDebit.productAmount = total
            paymentezDebit.token = self.selectedCard!.token!
            
            
            PaymentezSDKClient.debitCard(paymentezDebit, callback: { (error, trx) in
                if error != nil
                {
                    DispatchQueue.main.async(execute: {
                        self.activityIndicator.stopAnimating()
                        let alertC = UIAlertController(title: "Error", message: "code:\(String(describing: error?.code)),type:\(String(describing: error?.type)), status:\(String(describing: error?.descriptionData)), help:\(String(describing: error?.help))", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alertaction) in
                            
                        })
                        alertC.addAction(defaultAction)
                        self.present(alertC, animated: false, completion: nil)
                    })
                }
                else if let transaction = trx
                {
                    DispatchQueue.main.async(execute: {
                        self.activityIndicator.stopAnimating()
                        let alertC = UIAlertController(title: "Success", message: "transaction_id:\(String(describing: transaction.transactionId!)), status:\(String(describing: transaction.status!)), authcode:\(String(describing: transaction.authorizationCode)), carrier_code:\(String(describing: transaction.carrierCode))", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alertaction) in
                            
                        })
                        alertC.addAction(defaultAction)
                        
                        let defaultAction2 = UIAlertAction(title: "VERIFY", style: .default, handler: { (alertaction) in
                            let alertController = UIAlertController(title: "Verificar ", message: "Especifica el valor: Monto o valor", preferredStyle: .alert)
                            alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                                textField.placeholder = "Valor"
                            })
                            let verifyActionAmount = UIAlertAction(title: "Verificar por Monto", style: .default, handler: { (alertaction) in
                                PaymentezSDKClient.verifyWithAmount(transaction.transactionId!, uid: UserModel.uid, amount: Double((alertController.textFields?[0].text!)!)!, callback: { (error, attemptsRemaining, transaction) in
                                    
                                    if error == nil
                                    {
                                        let alertC = UIAlertController(title: "Vefificada", message: "trx:"+(transaction?.transactionId!)!, preferredStyle: UIAlertControllerStyle.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    else
                                    {
                                        let alertC = UIAlertController(title: "Error en Verificación", message: error?.description, preferredStyle: UIAlertControllerStyle.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    
                                })
                            })
                            let verifyActionAmount2 = UIAlertAction(title: "Verificar por Código", style: .default, handler: { (alertaction) in
                                PaymentezSDKClient.verifyWithCode(transaction.transactionId!, uid: UserModel.uid, verificationCode: (alertController.textFields?[0].text!)!, callback: { (error, attemptsRemaining, transaction) in
                                    
                                    if error == nil
                                    {
                                        let alertC = UIAlertController(title: "Vefificada", message: "trx:"+(transaction?.transactionId!)!, preferredStyle: UIAlertControllerStyle.alert)
                                        
                                        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                                        })
                                        alertC.addAction(defaultAction)
                                        self.present(alertC, animated: true
                                            , completion: {
                                                
                                        })
                                    }
                                    let alertC = UIAlertController(title: "Error en Verificación", message: error?.description, preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let defaultAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                                    })
                                    alertC.addAction(defaultAction)
                                    self.present(alertC, animated: true
                                        , completion: {
                                            
                                    })
                                    
                                })
                            })
                            let verifyClose = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alertaction) in
                                
                            })
                            alertController.addAction(verifyActionAmount)
                            alertController.addAction(verifyActionAmount2)
                            alertController.addAction(verifyClose)
                            self.present(alertController, animated: true
                                , completion: {
                                    
                            })
                        })
                        alertC.addAction(defaultAction2)
                        self.present(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
                
                
                
            })
            
            
            // debit
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
extension StoreViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1
        {
            self.performSegue(withIdentifier: "listViewController", sender: self)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
          return productPrices.count
        }
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell")
            
            cell?.textLabel?.text = self.productTitles[indexPath.row]
            cell?.detailTextLabel?.text = String(format: "$%.02f", self.productPrices[indexPath.row])
            return cell!
        }
        else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell")
            
            if selectedCard != nil
            {
                cell?.detailTextLabel?.text = "***" + (self.selectedCard?.termination!)!
                cell?.imageView?.image = self.selectedCard?.getCardTypeAsset()
            }
            else
            {
                cell?.textLabel?.text = "Forma de Pago"
                cell?.detailTextLabel?.text = "Selecciona"
            }
            return cell!
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalCell")
            
            var total = 0.0
            for p in self.productPrices
            {
                total = p + total
            }
            cell?.detailTextLabel?.text = String(format: "$%.02f", total)
            return cell!
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "listViewController"
        {
            let lVC = segue.destination as! ListCardsTableViewController
            lVC.cardSelectedDelegate = self
        }
        
    }
    
}



extension StoreViewController:CardSelectedDelegate
{
    func cardSelected(card: PaymentezCard?) {
        self.selectedCard = card
        self.tableV.reloadData()
    }
}
