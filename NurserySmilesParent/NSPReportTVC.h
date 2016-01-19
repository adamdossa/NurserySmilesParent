//
//  NSPReportTVC.h
//  NurserySmilesParent
//
//  Created by Adam Dossa on 03/05/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSPReportTVC : UITableViewController
@property (nonatomic, strong) PFObject *child;
@property (nonatomic, strong) NSDate *queryDate;
@end
