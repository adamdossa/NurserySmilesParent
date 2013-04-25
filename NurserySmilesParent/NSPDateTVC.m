//
//  NSPDateTVC.m
//  NurserySmilesParent
//
//  Created by Adam Dossa on 19/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import "NSPDateTVC.h"

@interface NSPDateTVC ()

@end

@implementation NSPDateTVC
{
    UIActivityIndicatorView *spinner;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *spinButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [self.navigationItem setRightBarButtonItem:spinButton animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Initialize our model
    if (![PFUser currentUser]) {
        return;
    }
    if (!self.child) {
        return;
    }
    PFObject *child = self.child;
    [spinner startAnimating];
    dispatch_queue_t q = dispatch_queue_create("table view loading queue", NULL);
    dispatch_async(q, ^{
        NSMutableArray *eventObjects = [[NSMutableArray alloc] init];
        NSArray *subTypes = @[@"DiaperChange",@"Milk",@"Comment",@"Diet",@"Sleep"];
        UIApplication *myApplication = [UIApplication sharedApplication];
        myApplication.networkActivityIndicatorVisible = TRUE;
        for (NSString *subType in subTypes) {
            PFQuery *query = [PFQuery queryWithClassName:subType];
            [query whereKey:@"child" equalTo:self.child];
            [eventObjects addObjectsFromArray:[query findObjects]];
        }
        myApplication.networkActivityIndicatorVisible = FALSE;
        NSMutableSet *uniqueDates = [[NSMutableSet alloc] init];

        for (PFObject *event in eventObjects) {
            NSDate *eventDate = [event objectForKey:@"date"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            NSString *eventDateString = [dateFormatter stringFromDate:eventDate];
            [uniqueDates addObject:[dateFormatter dateFromString:eventDateString]];
        }
        if (self.child == child) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                self.date = [NSArray arrayWithArray:[uniqueDates allObjects]];
                [self.tableView reloadData];
                
            });
        }
    });

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.date count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DateInfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *eventDateString = [dateFormatter stringFromDate:self.date[indexPath.item]];

    cell.textLabel.text = eventDateString;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"EventSegue"]) {
            NSDate *queryDate = self.date[indexPath.item];
            PFObject *child = self.child;
            if ([segue.destinationViewController respondsToSelector:@selector(setChild:)]) {
                [segue.destinationViewController performSelector:@selector(setChild:) withObject:child];
            }
            if ([segue.destinationViewController respondsToSelector:@selector(setQueryDate:)]) {
                [segue.destinationViewController performSelector:@selector(setQueryDate:) withObject:queryDate];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
