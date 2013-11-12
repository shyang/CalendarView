//
//  TTCalendarView.m
//  SLMobile
//
//  Created by shaohua on 11/12/13.
//
//

#import "TTCalendarView.h"
#import "NSDate+Additions.h"


@implementation TTCalendarView {
    NSMutableArray *_dayViews;
    UILabel *_monthLbl;
    UILabel *_yearLbl;
    NSDate *_date;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bar];

        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftBtn setImage:[UIImage imageNamed:@"BackArrow"] forState:UIControlStateNormal];
        leftBtn.borderColor = [UIColor blueColor];
        [leftBtn addTarget:self action:@selector(leftTapped) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:leftBtn];

        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [rightBtn setImage:[UIImage imageNamed:@"NextArrow"] forState:UIControlStateNormal];
        rightBtn.right = self.width;
        rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightBtn.borderColor = [UIColor blueColor];
        [rightBtn addTarget:self action:@selector(rightTapped) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:rightBtn];

        _monthLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftBtn.right, 0, rightBtn.left - leftBtn.right, bar.height / 2)];
        _monthLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _monthLbl.textAlignment = NSTextAlignmentCenter;
        [bar addSubview:_monthLbl];

        _yearLbl = [[UILabel alloc] initWithFrame:CGRectMake(_monthLbl.left, _monthLbl.bottom, _monthLbl.width, bar.height / 2)];
        _yearLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _yearLbl.textAlignment = NSTextAlignmentCenter;
        [bar addSubview:_yearLbl];

        UIView *weekDayView = [[UIView alloc] initWithFrame:CGRectMake(0, bar.bottom, self.width, 30)];
        weekDayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:weekDayView];

        for (int i = 0; i < 7; ++i) {
            CGFloat width = (self.width - 8) / 7;
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(4 + i * width, 0, width, weekDayView.height)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text = @[
                NSLocalizedString(@"周日", nil),
                NSLocalizedString(@"周一", nil),
                NSLocalizedString(@"周二", nil),
                NSLocalizedString(@"周三", nil),
                NSLocalizedString(@"周四", nil),
                NSLocalizedString(@"周五", nil),
                NSLocalizedString(@"周六", nil),
            ][i];
            lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [weekDayView addSubview:lbl];
        }

        _dayViews = [NSMutableArray array];
        CGFloat y = weekDayView.bottom;
        // each row 49, height 196, 245 or 294
        for (int i = 0; i < 6; ++i) {
            for (int j = 0; j < 7; ++j) {
                CGFloat width = (self.width - 8) / 7;
                UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                lbl.center = CGPointMake(4 + width * (j + 0.5), y + 49 * (i + 0.5));
                lbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                lbl.layer.cornerRadius = 17;
                lbl.borderColor = [UIColor grayColor];
                lbl.textAlignment = NSTextAlignmentCenter;
                [self addSubview:lbl];
                [_dayViews addObject:lbl];
            }
        }

        self.borderColor = [UIColor redColor];
        [self pickDate:[NSDate date]];
    }
    return self;
}

- (void)leftTapped {
    [self pickDate:[_date yesterday]];
}

- (void)rightTapped {
    [self pickDate:[_date tomorrow]];
}

- (void)pickDate:(NSDate *)date {
    _date = date;

    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:date];

    _yearLbl.text = [NSString stringWithFormat:@"%u", comps.year];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSString *lang = [[NSUserDefaults standardUserDefaults] stringForKey:kPersistPreferredLanguage];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:lang];
    _monthLbl.text = [formatter shortMonthSymbols][comps.month - 1];
    NSUInteger weekday = [date firstWeekdayInSameMonth];

    CGFloat height = 0;
    for (int i = 0; i < [_dayViews count]; ++i) {
        UILabel *lbl = _dayViews[i];
        if (i < weekday - 1) {
            lbl.hidden = YES;
            continue;
        }
        lbl.hidden = NO;
        NSUInteger day = i - (weekday - 1) + 1;
        lbl.text = [NSString stringWithFormat:@"%d", day];
        if (comps.day == day) {
            lbl.layer.borderWidth = 3;
        } else {
            lbl.layer.borderWidth = 1;
        }
        if (day > [date daysInSameMonth]) {
            lbl.hidden = YES;
        } else {
            height = lbl.bottom + 7; // (49 - 35) / 2
        }
    }
    self.height = height;
}

@end
