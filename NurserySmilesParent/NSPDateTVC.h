//
//  NSPDateTVC.h
//  NurserySmilesParent
//
//  Created by Adam Dossa on 19/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSPDateTVC : UITableViewController
@property (nonatomic, strong) PFObject *child;
@property (nonatomic, strong) NSArray *date; //of NSDate
@end
