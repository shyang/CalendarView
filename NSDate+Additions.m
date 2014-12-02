//
//  NSDate+Additions.m
//  SLMobile
//
//  Created by shaohua on 11/12/13.
//
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSDate *)nextMonth {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [NSDateComponents alloc];
    comps.month = 1;
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)previousMonth {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [NSDateComponents alloc];
    comps.month = -1;
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}

@end
