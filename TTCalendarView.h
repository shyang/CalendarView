//
//  TTCalendarView.h
//  SLMobile
//
//  Created by shaohua on 11/12/13.
//
//

#import <UIKit/UIKit.h>

@protocol TTCalendarViewDelegate

- (void)didPickDate:(NSString *)date; // date in format 2014-01-01
- (void)didPickNextMonth;
- (void)didPickPreviousMonth;

@end


@interface TTCalendarView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly) NSDate *date; // always day 1 of a month

- (void)setObject:(id)item;

@end
