//
//  NSPDiaperTVC.h
//  NurserySmilesParent
//
//  Created by Adam Dossa on 19/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import <Parse/Parse.h>

@interface NSPDiaperTVC : PFQueryTableViewController
@property (nonatomic, strong) PFObject *child;
@property (nonatomic, strong) NSDate *queryDate;

@end
