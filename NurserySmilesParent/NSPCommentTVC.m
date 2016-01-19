//
//  NSPCommentTVC.m
//  NurserySmilesParent
//
//  Created by Adam Dossa on 19/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import "NSPCommentTVC.h"

@interface NSPCommentTVC ()

@end

@implementation NSPCommentTVC

- (void) initVars
{
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Comment";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"type";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
    }
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    [self initVars];
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initVars];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = nil;
    @try {
        object = [self objectAtIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        return 40;
    }
    NSString *str = (NSString*) [object objectForKey:@"comment"];
    //Need to set width depending on whether there is a photo indicator
    float width = 260;
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    int height = size.height + 20;
    if (height < 40) {
        height = 40;
    }
    return height;
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        return nil;
    }
    if (!self.parseClassName) {
        [self initVars];
    }
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"child" equalTo:self.child];
    [query whereKey:@"deleted" equalTo:[NSNumber numberWithInt:0]];
    if (self.queryDate) {
        [query whereKey:@"date" equalTo:self.queryDate];
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"commentTime"];
    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"CommentInfo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    // Configure the cell
    NSString *commentString = (NSString*) [object objectForKey:@"comment"];
    cell.textLabel.text = commentString;

    NSDate *commentTime = (NSDate*) [object objectForKey:@"commentTime"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:commentTime];
    cell.detailTextLabel.text = timeString;    
    
    PFFile *photo = [object objectForKey:@"photo"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (photo) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
//    [photo getDataInBackgroundWithBlock:^(NSData *result, NSError *error){
//        if (result) {
//            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//    }];
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"CommentPhotoSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
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
            if ([segue.identifier isEqualToString:@"CommentPhotoSegue"]) {
                PFObject *child = [self objectAtIndexPath:indexPath];
                if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:[child objectForKey:@"photo"]];
                }
            }
        }
    }
}


@end
