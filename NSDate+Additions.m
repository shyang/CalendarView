//
//  NSDate+Additions.m
//  SLMobile
//
//  Created by shaohua on 11/12/13.
//
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSDate *)tomorrow {
    return [self dateByAddingDays:1 calendar:nil];
}

- (NSDate *)yesterday {
    return [self dateByAddingDays:-1 calendar:nil];
}

- (NSDate *)dateByAddingDays:(NSUInteger)days calendar:(NSCalendar *)calendar {
    if (!calendar) {
        calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    NSDateComponents *comps = [NSDateComponents alloc];
    comps.day = days;
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}

- (NSUInteger)day {
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar components:NSCalendarUnitDay fromDate:self].day;
}

- (NSUInteger)firstWeekdayInSameMonth {
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger day = [self day];
    NSDate *firstDay = day == 1 ? self : [self dateByAddingDays:1 - day calendar:calendar];
    return [calendar components:NSCalendarUnitWeekday fromDate:firstDay].weekday;
}

- (NSUInteger)daysInSameMonth {
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

@end
