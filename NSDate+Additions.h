//
//  NSDate+Additions.h
//  SLMobile
//
//  Created by shaohua on 11/12/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

- (NSDate *)tomorrow;
- (NSDate *)yesterday;
- (NSUInteger)firstWeekdayInSameMonth;
- (NSUInteger)daysInSameMonth;

@end
