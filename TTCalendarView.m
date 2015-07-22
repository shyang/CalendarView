//
//  TTCalendarView.m
//  SLMobile
//
//  Created by shaohua on 11/12/13.
//
//

#import "NSDate+Additions.h"
#import "TTCalendarView.h"

@implementation TTCalendarView {
    NSMutableArray *_dayViews;
    UILabel *_monthLbl;
    UILabel *_yearLbl;
    NSDate *_date;
    id _model;
    long _pickDay;
}

#define kDotViewTag 13325325
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bar];

        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftBtn setImage:[UIImage imageNamed:@"BackArrow"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(onLeftTapped) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:leftBtn];

        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [rightBtn setImage:[UIImage imageNamed:@"NextArrow"] forState:UIControlStateNormal];
        rightBtn.right = self.width;
        rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [rightBtn addTarget:self action:@selector(onRightTapped) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:rightBtn];

        _monthLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftBtn.right, 0, rightBtn.left - leftBtn.right, bar.height / 2)];
        _monthLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _monthLbl.textAlignment = NSTextAlignmentCenter;
        _monthLbl.textColor = [UIColor blackColor];
        _monthLbl.backgroundColor = [UIColor clearColor];
        _monthLbl.font = [UIFont systemFontOfSize:13];
        [bar addSubview:_monthLbl];

        _yearLbl = [[UILabel alloc] initWithFrame:CGRectMake(_monthLbl.left, _monthLbl.bottom, _monthLbl.width, bar.height / 2)];
        _yearLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _yearLbl.textAlignment = NSTextAlignmentCenter;
        _yearLbl.textColor = [UIColor lightGrayColor];
        _yearLbl.backgroundColor = [UIColor clearColor];
        _yearLbl.font = [UIFont systemFontOfSize:13];
        [bar addSubview:_yearLbl];

        UIView *weekDayView = [[UIView alloc] initWithFrame:CGRectMake(0, bar.bottom, self.width, 30)];
        weekDayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:weekDayView];

        for (int i = 0; i < 7; ++i) {
            CGFloat width = (self.width - 8) / 7;
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(4 + i * width, 0, width, weekDayView.height)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"][i];
            lbl.font = [UIFont systemFontOfSize:12];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor lightGrayColor];
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
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.userInteractionEnabled = YES;
                lbl.font = [UIFont boldSystemFontOfSize:13];
                lbl.layer.masksToBounds = YES; // for ios 7.1
                [lbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDayTapped:)]];
                [self addSubview:lbl];
                [_dayViews addObject:lbl];

                UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(15, 26, 5, 5)];
                dotView.tag = kDotViewTag;
                dotView.layer.cornerRadius = 2.5;
                [lbl addSubview:dotView];
            }
        }
        [self pickMonth:[NSDate date]];

        UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onRightTapped)];
        swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipLeft];

        UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onLeftTapped)];
        swipRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipRight];

        // app specific
        UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.width - 10, 1)];
        sepLine.backgroundColor = [UIColor lightGrayColor];
        sepLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        sepLine.bottom = self.height - 10;
        [self addSubview:sepLine];
    }
    return self;
}

#pragma mark - Private
- (void)onLeftTapped {
    [UIView animateWithDuration:.2 animations:^{
        for (UIView *view in _dayViews) {
            view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self pickMonth:[_date previousMonth]];
        [self pickDay:_pickDay];
    }];

    if ([_delegate respondsToSelector:@selector(didPickPreviousMonth)]) {
        [_delegate didPickPreviousMonth];
    }
}

- (void)onRightTapped {
    [UIView animateWithDuration:.2 animations:^{
        for (UIView *view in _dayViews) {
            view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self pickMonth:[_date nextMonth]];
        [self pickDay:_pickDay];
    }];

    if ([_delegate respondsToSelector:@selector(didPickNextMonth)]) {
        [_delegate didPickNextMonth];
    }
}

- (void)onDayTapped:(UITapGestureRecognizer *)gesture {
    _pickDay = gesture.view.tag;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitYear | kCFCalendarUnitMonth fromDate:_date];
    NSString *key = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)comps.year, (long)comps.month, _pickDay];

    [self pickDay:_pickDay];

    if ([_delegate respondsToSelector:@selector(didPickDate:)]) {
        [_delegate didPickDate:key];
    }
}

- (void)pickDay:(long)day {
    for (UILabel *dayLbl in _dayViews) {
        dayLbl.backgroundColor = dayLbl.tag == day ? [UIColor colorWithWhite:0.8980 alpha:1] : [UIColor clearColor];
    }
}

- (void)pickMonth:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay fromDate:date];
    if (comps.day == 1) {
        _date = date;
    } else {
        NSDateComponents *backToDay1 = [[NSDateComponents alloc] init];
        backToDay1.day = 1 - comps.day;
        _date = [calendar dateByAddingComponents:backToDay1 toDate:date options:0]; // always the first day of a month
    }

    _yearLbl.text = [NSString stringWithFormat:@"%ld", (long)comps.year];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    _monthLbl.text = [formatter shortMonthSymbols][comps.month - 1];
    long weekday = [calendar components:NSWeekdayCalendarUnit fromDate:_date].weekday;

    NSDate *today = [NSDate date];
    NSDateComponents *compsToday = [calendar components:kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay fromDate:today];

    NSUInteger totalDays = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:_date].length;

    CGFloat height = 0;
    for (int i = 0; i < _dayViews.count; ++i) {
        UILabel *lbl = _dayViews[i];
        if (i < weekday - 1) {
            lbl.hidden = YES;
            lbl.tag = 0;
            continue;
        }
        lbl.hidden = NO;
        lbl.alpha = 1;

        long day = i - (weekday - 1) + 1;
        lbl.text = [NSString stringWithFormat:@"%ld", day];

        // four sytle of a day label: past or future, has repayment or not
        NSString *key = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)comps.year, (long)comps.month, day];
        id text = _model[key];
        lbl.tag = day; // to recontruct a date

        if (comps.year == compsToday.year && comps.month == compsToday.month && day == compsToday.day) {
            lbl.textColor = [UIColor colorWithRed:0.0196 green:0.7216 blue:0.5608 alpha:1]; // green
        } else {
            lbl.textColor = [UIColor colorWithWhite:0.2667 alpha:1];
        }

        if ([_date compare:today] == NSOrderedDescending || (comps.year == compsToday.year && comps.month == compsToday.month && day >= compsToday.day)) {
            [lbl viewWithTag:kDotViewTag].backgroundColor = text ? [UIColor colorWithRed:0.9529 green:0.6471 blue:0.2118 alpha:1] : [UIColor clearColor]; // orange
        } else { // before
            [lbl viewWithTag:kDotViewTag].backgroundColor = text ? [UIColor colorWithRed:0.4784 green:0.5216 blue:0.5529 alpha:1] : [UIColor clearColor]; // gray
        }

        if (day > totalDays) {
            lbl.hidden = YES;
        } else {
            height = lbl.bottom + 7; // (49 - 35) / 2
        }
    }
    self.height = height + 20; // this extra padding is app specific

    if ([self.superview isKindOfClass:[UITableView class]] && [(UITableView *)self.superview tableHeaderView] == self) {
        [(UITableView *)self.superview setTableHeaderView:self];
    }
}

#pragma mark - Public
- (void)setObject:(id)item {
    _model = item;
    [self pickMonth:_date];
}

@end
