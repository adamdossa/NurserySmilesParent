//
//  NSPDietTVC.m
//  NurserySmilesParent
//
//  Created by Adam Dossa on 19/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import "NSPDietTVC.h"

@interface NSPDietTVC ()

@end

@implementation NSPDietTVC
- (void) initVars
{
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Diet";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"type";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 5;
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

    [query orderByAscending:@"mealTime"];
    
    return query;
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
    NSString *mealType = [object objectForKey:@"mealType"];
    NSString *drinkType = [object objectForKey:@"drinkType"];
    NSString *mealAmount = [object objectForKey:@"mealAmount"];
    NSString *drinkAmount = [object objectForKey:@"drinkAmount"];
    NSString *str = [NSString stringWithFormat:@"%@: %@, %@: %@", mealType, mealAmount, drinkType, drinkAmount];
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12] constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    int height = size.height + 20;
    if (height < 40) {
        height = 40;
    }
    return height;
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"DietInfo";
    
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
    NSString *mealType = [object objectForKey:@"mealType"];
    NSString *drinkType = [object objectForKey:@"drinkType"];
    NSString *mealAmount = [object objectForKey:@"mealAmount"];
    NSString *drinkAmount = [object objectForKey:@"drinkAmount"];
    NSDate *mealTime = [object objectForKey:@"mealTime"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *mealTimeString = [dateFormatter stringFromDate:mealTime];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@, %@: %@", mealType, mealAmount, drinkType, drinkAmount];
    cell.detailTextLabel.text = [@"Time: " stringByAppendingString:mealTimeString];
    
    return cell;
}
@end
