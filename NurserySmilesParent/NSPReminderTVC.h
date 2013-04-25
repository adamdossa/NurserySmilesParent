//
//  NSPReminderTVC.h
//  NurserySmilesParent
//
//  Created by Adam Dossa on 24/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import <Parse/Parse.h>

@interface NSPReminderTVC : PFQueryTableViewController
@property (nonatomic, strong) PFObject *child;
@property (nonatomic, strong) NSDate *queryDate;

@end
