//
//  ListCardsTableViewController.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 09/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK

protocol CardSelectedDelegate
{
    func cardSelected(card:PaymentezCard?)
}

class ListCardsTableViewController: UITableViewController {

    var cardList = [PaymentezCard]()
    var cardSelectedDelegate:CardSelectedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshTable()

    }
    func refreshTable()
    {
        self.cardList.removeAll()
        PaymentezSDKClient.listCards(UserModel.uid) { (error, cardList) in
            
            if error == nil
            {
                self.cardList = cardList!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cardList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
        
        let card = self.cardList[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = "****" + card.termination!
        cell.detailTextLabel!.text = "\(card.expiryMonth!)/\(card.expiryYear!)"
        cell.imageView?.image = card.getCardTypeAsset()
        // Configure the cell...

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let card  = self.cardList[(indexPath as NSIndexPath).row]
        self.cardSelectedDelegate?.cardSelected(card: card)
        self.navigationController?.popViewController(animated: true)
        //self.performSegue(withIdentifier: "debitSegue", sender: self)
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    @IBAction func addAction(_ sender:AnyObject?)
    {
        /*PaymentezSDKClient.showAddViewWidget("123gux", email: "guxsotelo@gmail.com", presenter: self) {(error, closed, added) in
            
        }*/
       
//        PaymentezSDKClient.showAddViewControllerForUser("123gux", email: "guxsotelo@gmail.com", presenter: self) { (error, closed, added) in
//            
//            if closed // user closed
//            {
//                self.refreshTable()
//            }
//            else if added // was added
//            {
//                print("ADDED SUCCESSFUL")
//                DispatchQueue.main.async(execute: {
//                    let alertC = UIAlertController(title: "Success", message: "card added", preferredStyle: UIAlertControllerStyle.alert)
//                    
//                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alertC.addAction(defaultAction)
//                    self.present(alertC, animated: true
//                        , completion: {
//                            self.refreshTable()
//                    })
//                })
//                
//                
//                
//            }
//            else if error != nil //there was an error
//            {
//                print(error?.code)
//                print(error?.description)
//                print(error?.details)
//                print(error?.getVerifyTrx())
//                if error!.shouldVerify() // if the card should be verified
//                {
//                    print(error?.getVerifyTrx())
//                    DispatchQueue.main.async(execute: {
//                        let alertC = UIAlertController(title: "error \(error!.code)", message: "Should verify: \(error!.getVerifyTrx())", preferredStyle: UIAlertControllerStyle.alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertC.addAction(defaultAction)
//                        self.present(alertC, animated: true
//                            , completion: {
//                                
//                        })
//                    })
//                    self.performSegue(withIdentifier: "verifySegue", sender:self)
//                }
//                else
//                {
//                    DispatchQueue.main.async(execute: {
//                        let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.details)", preferredStyle: UIAlertControllerStyle.alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alertC.addAction(defaultAction)
//                        self.present(alertC, animated: true
//                            , completion: {
//                                
//                        })
//                    })
//                }
//            }
//            
//        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let card = self.cardList[(indexPath as NSIndexPath).row]
        var actions = [UITableViewRowAction]()
        if card.status == "review"
        {
            let editAction = UITableViewRowAction(style: .normal, title: "Verify amount") { (rowAction, indexPath) in
                
                
            }
            editAction.backgroundColor = .blue
            
            let editAction2 = UITableViewRowAction(style: .normal, title: "Verify code") { (rowAction, indexPath) in
               
                
            }
            editAction2.backgroundColor = .gray
            actions.append(editAction)
            actions.append(editAction2)
        }
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            let card = self.cardList[(indexPath as NSIndexPath).row]
            PaymentezSDKClient.deleteCard(UserModel.uid, card: card, callback: { (error, wasDeleted) in
                if wasDeleted
                {
                    //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    self.refreshTable()
                }
                else
                {
                    if error != nil
                    {
                        DispatchQueue.main.async(execute: {
                            let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.description)", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(defaultAction)
                            self.present(alertC, animated: true
                                , completion: {
                                    
                            })
                        })
                    }
                    
                }
            })

        }
        deleteAction.backgroundColor = .red
        actions.append(deleteAction)
        return actions
    }
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let card = self.cardList[(indexPath as NSIndexPath).row]
            PaymentezSDKClient.deleteCard(UserModel.uid, card: card, callback: { (error, wasDeleted) in
                if wasDeleted
                {
                    //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    self.refreshTable()
                }
                else
                {
                    if error != nil
                    {
                        DispatchQueue.main.async(execute: {
                            let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.description)", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(defaultAction)
                            self.present(alertC, animated: true
                                , completion: {
                                    
                            })
                        })
                    }
                    
                }
            })
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }*/
    
    
}

