//
//  NSPReportTVC.m
//  NurserySmilesParent
//
//  Created by Adam Dossa on 03/05/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import "NSPReportTVC.h"

@interface NSPReportTVC ()
@property (nonatomic, strong) NSMutableDictionary *eventDict;
@end

@implementation NSPReportTVC
{
    UIActivityIndicatorView *spinner;
    NSArray *subTypes;
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
    subTypes = @[@"Reminder",@"DiaperChange",@"Milk",@"Diet",@"Sleep",@"Comment"];
    [self.navigationItem setRightBarButtonItem:spinButton animated:YES];
}

- (NSMutableDictionary*) eventDict
{
    if (!_eventDict) {
        _eventDict = [[NSMutableDictionary alloc] init];
    }
    return _eventDict;
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
    dispatch_queue_t q = dispatch_queue_create("report view loading queue", NULL);
    dispatch_async(q, ^{
        UIApplication *myApplication = [UIApplication sharedApplication];
        myApplication.networkActivityIndicatorVisible = TRUE;
        for (NSString *subType in subTypes) {
            PFQuery *query = [PFQuery queryWithClassName:subType];
            [query whereKey:@"child" equalTo:self.child];
            [query whereKey:@"deleted" equalTo:[NSNumber numberWithInt:0]];
            
            if (self.queryDate) {
                [query whereKey:@"date" equalTo:self.queryDate];
            }
            
            [self.eventDict setObject:[query findObjects] forKey:subType];
        }
        myApplication.networkActivityIndicatorVisible = FALSE;
        if (self.child == child) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
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
    return [[self.eventDict allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *events = self.eventDict[subTypes[section]];
    return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportInfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSArray *events = self.eventDict[subTypes[indexPath.section]];
    PFObject *event = (PFObject*) events[indexPath.item];
    NSArray *details = [self getTextForEvent:event];
    cell.textLabel.text = (NSString*) details[0];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:(NSDate*) details[1]];
    cell.detailTextLabel.text = timeString;
    //If it is a comment w/ photo we add a detail disclosure
    if ([[event parseClassName] isEqualToString:@"Comment"]) {
        PFFile *photo = [event objectForKey:@"photo"];
        if (photo) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ReportPhotoSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        UITableViewCell *tableCell = (UITableViewCell*) sender;
        if (!(tableCell.accessoryType == UITableViewCellAccessoryNone)) {
            if ([segue.identifier isEqualToString:@"ReportPhotoSegue"]) {
                NSArray *events = self.eventDict[subTypes[indexPath.section]];
                PFObject *event = (PFObject*) events[indexPath.item];
                if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:[event objectForKey:@"photo"]];
                }
            }
        }
    }
}

- (NSArray *) getTextForEvent: (PFObject*) event
{
    NSMutableArray *eventText = [[NSMutableArray alloc] init];
    if ([[event parseClassName] isEqualToString:@"DiaperChange"]) {
        NSString *typeString = (NSString*)[event objectForKey:@"type"];
        NSNumber *cream = (NSNumber*)[event objectForKey:@"cream"];
        int creamBool = [cream intValue];
        if (creamBool > 0) {
            typeString = [typeString stringByAppendingString:@": Cream Used"];
        }
        [eventText addObject:typeString];
        [eventText addObject:(NSDate*)[event objectForKey:@"startTime"]];
    }
    if ([[event parseClassName] isEqualToString:@"Milk"]) {
        NSNumber *ounces = (NSNumber*)[event objectForKey:@"ounces"];
        NSString *ouncesString = (NSString*)[NSString stringWithFormat:@"Ounces %2.2f",[ounces doubleValue]];
        [eventText addObject:ouncesString];
        [eventText addObject:(NSDate*)[event objectForKey:@"startTime"]];
    }
    if ([[event parseClassName] isEqualToString:@"Diet"]) {
        NSString *mealType = (NSString*)[event objectForKey:@"mealType"];
        NSString *drinkType = (NSString*)[event objectForKey:@"drinkType"];
        NSString *mealAmount = (NSString*)[event objectForKey:@"mealAmount"];
        NSString *drinkAmount = (NSString*)[event objectForKey:@"drinkAmount"];
        NSString *text = [NSString stringWithFormat:@"%@: %@, %@: %@", mealType, mealAmount, drinkType, drinkAmount];
        [eventText addObject:text];
        [eventText addObject:(NSDate*)[event objectForKey:@"mealTime"]];
    }
    if ([[event parseClassName] isEqualToString:@"Sleep"]) {
        NSNumber *duration = (NSNumber*) [event objectForKey:@"duration"];
        NSString *durationString = [self stringFromTimeInterval:[duration doubleValue]];
        NSString *text = [@"Duration: " stringByAppendingString:durationString];
        [eventText addObject:text];
        [eventText addObject:(NSDate*)[event objectForKey:@"startTime"]];
    }
    if ([[event parseClassName] isEqualToString:@"Reminder"]) {
        NSString *reminderText = (NSString*) [event objectForKey:@"reminderText"];
        NSString *text = [@"Please bring: " stringByAppendingString:reminderText];
        [eventText addObject:text];
        [eventText addObject:(NSDate*)[event objectForKey:@"date"]];
    }
    if ([[event parseClassName] isEqualToString:@"Comment"]) {
        NSString *commentString = (NSString*) [event objectForKey:@"comment"];;
        [eventText addObject:commentString];
        [eventText addObject:(NSDate*)[event objectForKey:@"commentTime"]];

    }
    return eventText;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return subTypes[section];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *event = nil;
    @try {
        NSArray *events = self.eventDict[subTypes[indexPath.section]];
        event = (PFObject*) events[indexPath.item];
    }
    @catch (NSException *exception) {
        return 40;
    }
    NSArray *details = [self getTextForEvent:event];
    NSString *str = (NSString*) details[0];
    //Need to set width depending on whether there is a photo indicator
    float width = 240;
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    int height = size.height + 20;
    if (height < 40) {
        height = 40;
    }
    return height;
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
