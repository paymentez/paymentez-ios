//
//  ListCardsTableViewController.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 09/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import UIKit
import PaymentezSDK

class ListCardsTableViewController: UITableViewController {

    var cardList = [PaymentezCard]()
    var cardSelected = ""
    override func viewDidLoad() {
        super.viewDidLoad()
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshTable()

    }
    func refreshTable()
    {
        self.cardList.removeAll()
        PaymentezSDKClient.listCards("test") { (error, cardList) in
            
            if error == nil
            {
                self.cardList = cardList!
                self.tableView.reloadData()
            }
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cardList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath)
        
        let card = self.cardList[indexPath.row]
        cell.textLabel!.text = card.termination!
        cell.detailTextLabel!.text = card.cardReference!
        // Configure the cell...

        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let card  = self.cardList[indexPath.row]
        self.cardSelected = card.cardReference!
        self.performSegueWithIdentifier("debitSegue", sender: self)
        
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "debitSegue"
        
        {
            let vc = segue.destinationViewController as! ViewController
            vc.cardReference = self.cardSelected
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    @IBAction func addAction(sender:AnyObject?)
    {
       
        PaymentezSDKClient.showAddViewControllerForUser("test", email: "gsotelo@paymentez.com", presenter: self) { (error, closed, added) in
            
            if closed // user closed
            {
                
            }
            else if added // was added
            {
                print("ADDED SUCCESSFUL")
                dispatch_async(dispatch_get_main_queue(), {
                    let alertC = UIAlertController(title: "Success", message: "card added", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertC.addAction(defaultAction)
                    self.presentViewController(alertC, animated: true
                        , completion: {
                            self.refreshTable()
                    })
                })
                
                
                
            }
            else if error != nil //there was an error
            {
                print(error?.code)
                print(error?.description)
                print(error?.details)
                if error!.shouldVerify() // if the card should be verified
                {
                    print(error?.getVerifyTrx())
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertC = UIAlertController(title: "error \(error!.code)", message: "Should verify: \(error!.getVerifyTrx())", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertC.addAction(defaultAction)
                        self.presentViewController(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.descriptionCode)", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertC.addAction(defaultAction)
                        self.presentViewController(alertC, animated: true
                            , completion: {
                                
                        })
                    })
                }
            }
            
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let card = self.cardList[indexPath.row]
            PaymentezSDKClient.deleteCard("test", cardReference: card.cardReference!, callback: { (error, wasDeleted) in
                if wasDeleted
                {
                    //self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    self.refreshTable()
                }
                else
                {
                    if error != nil
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertC = UIAlertController(title: "error \(error!.code)", message: "\(error!.description)", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alertC.addAction(defaultAction)
                            self.presentViewController(alertC, animated: true
                                , completion: {
                                    
                            })
                        })
                    }
                    
                }
            })
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }

}
