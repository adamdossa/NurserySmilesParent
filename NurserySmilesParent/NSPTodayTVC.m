//
//  NSPTodayTVC.m
//  NurserySmilesParent
//
//  Created by Adam Dossa on 25/04/2013.
//  Copyright (c) 2013 Adam Dossa. All rights reserved.
//

#import "NSPTodayTVC.h"

@interface NSPTodayTVC ()

@end

@implementation NSPTodayTVC

- (NSDate*)day
{
    return [self boundaryForCalendarUnit:NSDayCalendarUnit];
}

- (NSDate*)boundaryForCalendarUnit:(NSCalendarUnit)calendarUnit
{
    NSDate *boundary;
    [[NSCalendar currentCalendar] rangeOfUnit:calendarUnit startDate:&boundary interval:NULL forDate:[NSDate date]];
    return boundary;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"AllDateSegue"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setChild:)]) {
            [segue.destinationViewController performSelector:@selector(setChild:) withObject:self.child];
        }
    }
    if ([segue.identifier isEqualToString:@"TodaySegue"]) {
        NSDate *queryDate = [self day];
        if ([segue.destinationViewController respondsToSelector:@selector(setChild:)]) {
            [segue.destinationViewController performSelector:@selector(setChild:) withObject:self.child];
        }
        if ([segue.destinationViewController respondsToSelector:@selector(setQueryDate:)]) {
            [segue.destinationViewController performSelector:@selector(setQueryDate:) withObject:queryDate];
        }        
    }
}

@end
