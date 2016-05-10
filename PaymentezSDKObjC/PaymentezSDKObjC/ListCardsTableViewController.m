//
//  ListCardsTableViewController.m
//  PaymentezSDKObjC
//
//  Created by Gustavo Sotelo on 10/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

#import "ListCardsTableViewController.h"
#import "ViewController.h"
#import <PaymentezSDK/PaymentezSDK-Swift.h>

@interface ListCardsTableViewController ()
@property (nonatomic, strong) NSMutableArray *cardList;
@end

@implementation ListCardsTableViewController


- (NSMutableArray*) getCardList
{
    if (_cardList == nil)
    {
        _cardList = [[NSMutableArray alloc] init];
    }
    return _cardList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [PaymentezSDKClient listCards:@"gus" callback:^(PaymentezSDKError * error, NSArray<PaymentezCard *> * list) {
        if(error == nil)
        {
            self.cardList = [list mutableCopy];
            [self.tableView reloadData];
        }
    } ];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.cardList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell" forIndexPath:indexPath];
    PaymentezCard *card = self.cardList[indexPath.row];
    cell.textLabel.text = card.termination;
    cell.detailTextLabel.text = card.cardReference;
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentezCard *card = self.cardList[indexPath.row];
    self.cardReference = card.cardReference;
    [self performSegueWithIdentifier:@"debitSegue" sender:self];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    ViewController *vc = (ViewController*)segue.destinationViewController;
    vc.cardReference  = self.cardReference;
    
}


@end
