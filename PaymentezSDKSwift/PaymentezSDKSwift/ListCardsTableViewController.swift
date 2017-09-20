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
        
        MyBackendLib.listCard(uid: "1234") { (cardList) in
            self.cardList = cardList!
            self.tableView.reloadData();
        }
        
        
        
        /*PaymentezSDKClient.listCards(UserModel.uid) { (error, cardList) in
            
            if error == nil
            {
                self.cardList = cardList!
                
                
            }
            
            
        }*/
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
    
    // MARK: - Navigation

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let card = self.cardList[(indexPath as NSIndexPath).row]
        var actions = [UITableViewRowAction]()
        if card.status == "review"
        {
            let editAction = UITableViewRowAction(style: .normal, title: "Verify amount") { (rowAction, indexPath) in
                
                //DEV BACKEND WITH VERIFY WITH AMOUNT
            }
            editAction.backgroundColor = .blue
            
            let editAction2 = UITableViewRowAction(style: .normal, title: "Verify code") { (rowAction, indexPath) in
               
                //DEV BACKEND WITH VERIFY WITH CODE
                
            }
            editAction2.backgroundColor = .gray
            actions.append(editAction)
            actions.append(editAction2)
        }
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            let card = self.cardList[(indexPath as NSIndexPath).row]
            
            //DEV BACKEND CALL WITH DELETE CARD

        }
        deleteAction.backgroundColor = .red
        actions.append(deleteAction)
        return actions
    }
    
   
    
    
}

