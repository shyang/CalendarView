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
    id _model;
    UILabel *_popoverLbl;
    UIImageView *_arrow;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bar];

        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [leftBtn setImage:[UIImage imageNamed:@"BackArrow"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftTapped) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:leftBtn];

        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [rightBtn setImage:[UIImage imageNamed:@"NextArrow"] forState:UIControlStateNormal];
        rightBtn.right = self.width;
        rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [rightBtn addTarget:self action:@selector(rightTapped) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:rightBtn];

        _monthLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftBtn.right, 0, rightBtn.left - leftBtn.right, bar.height / 2)];
        _monthLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _monthLbl.textAlignment = NSTextAlignmentCenter;
        _monthLbl.textColor = [UIColor colorWithRed:0.2667 green:0.5255 blue:0.7020 alpha:1];
        _monthLbl.backgroundColor = [UIColor clearColor];
        [bar addSubview:_monthLbl];

        _yearLbl = [[UILabel alloc] initWithFrame:CGRectMake(_monthLbl.left, _monthLbl.bottom, _monthLbl.width, bar.height / 2)];
        _yearLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _yearLbl.textAlignment = NSTextAlignmentCenter;
        _yearLbl.textColor = [UIColor lightGrayColor];
        _yearLbl.backgroundColor = [UIColor clearColor];
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
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor colorWithRed:0.2667 green:0.5255 blue:0.7020 alpha:1];
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
                lbl.userInteractionEnabled = YES;
                [lbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dayTapped:)]];
                [self addSubview:lbl];
                [_dayViews addObject:lbl];
            }
        }
        [self pickMonth:[NSDate date]];

        UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapped)];
        swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipLeft];

        UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapped)];
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

- (void)leftTapped {
    [self hidePopover];

    [UIView animateWithDuration:.2 animations:^{
        for (UIView *view in _dayViews) {
            view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self pickMonth:[_date previousMonth]];
    }];
}

- (void)rightTapped {
    [self hidePopover];

    [UIView animateWithDuration:.2 animations:^{
        for (UIView *view in _dayViews) {
            view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self pickMonth:[_date nextMonth]];
    }];
}

- (void)hidePopover {
    [_popoverLbl removeFromSuperview];
    _popoverLbl = nil;

    [_arrow removeFromSuperview];
    _arrow = nil;
}

- (void)showPopover:(NSString *)text at:(UIView *)view {
    _popoverLbl = [[UILabel alloc] init];
    _popoverLbl.backgroundColor = [UIColor colorWithRed:0.2667 green:0.5255 blue:0.7020 alpha:1];
    _popoverLbl.text = text;
    _popoverLbl.textAlignment = NSTextAlignmentCenter;
    _popoverLbl.numberOfLines = 2;
    _popoverLbl.layer.cornerRadius = 6;
    _popoverLbl.textColor = [UIColor whiteColor];
    _popoverLbl.font = [UIFont systemFontOfSize:10];
    _popoverLbl.size = CGRectInset([_popoverLbl textRectForBounds:CGRectInfinite limitedToNumberOfLines:2], -8, -4).size;
    _popoverLbl.centerX = view.centerX;
    if (_popoverLbl.left < 0) {
        _popoverLbl.left = 0;
    }
    if (_popoverLbl.right > self.width) {
        _popoverLbl.right = self.width;
    }
    _popoverLbl.bottom = view.top - 3;
    [self addSubview:_popoverLbl];

    _arrow = [[UIImageView alloc] initWithImage:[UIImage arrowImageWithSize:CGSizeMake(10, 5) direction:TTArrowDirectionDown color:_popoverLbl.backgroundColor]];
    _arrow.top = _popoverLbl.bottom;
    _arrow.centerX = _popoverLbl.centerX;
    [self addSubview:_arrow];
}

- (void)dayTapped:(UITapGestureRecognizer *)gesture {
    [self hidePopover];

    long day = gesture.view.tag;
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitYear | kCFCalendarUnitMonth fromDate:_date];
    NSString *key = [NSString stringWithFormat:@"%ld/%02ld/%02ld", (long)comps.year, (long)comps.month, day];
    NSString *text = _model[key];
    if (text) {
        if ([text isKindOfClass:[NSNumber class]]) {
            text = [SLGlobal format:[text doubleValue]];
        }
        [self showPopover:[NSString stringWithFormat:NSLocalizedString(@"还款金额\n%@", nil), text] at:gesture.view];
    }
}

- (void)pickMonth:(NSDate *)date {
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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
    for (int i = 0; i < [_dayViews count]; ++i) {
        UILabel *lbl = _dayViews[i];
        if (i < weekday - 1) {
            lbl.hidden = YES;
            continue;
        }
        lbl.hidden = NO;
        lbl.alpha = 1;

        long day = i - (weekday - 1) + 1;
        lbl.text = [NSString stringWithFormat:@"%ld", day];

        // four sytle of a day label: past or future, has repayment or not
        NSString *key = [NSString stringWithFormat:@"%ld/%02ld/%02ld", (long)comps.year, (long)comps.month, day];
        NSString *text = _model[key];
        lbl.tag = day; // to recontruct a date

        if ([_date compare:today] == NSOrderedDescending || (comps.year == compsToday.year && comps.month == compsToday.month && day > compsToday.day)) {
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = lbl.borderColor = [UIColor colorWithWhite:0.2667 alpha:1];
            if (text) {
                lbl.borderColor = lbl.textColor = [UIColor colorWithRed:0.2667 green:0.5255 blue:0.7020 alpha:1];
                lbl.layer.borderWidth = 3;
            } else {
                lbl.borderColor = lbl.textColor = [UIColor colorWithWhite:0.2667 alpha:1];
            }
        } else {
            lbl.layer.borderWidth = 0;
            if (text) {
                lbl.backgroundColor = [UIColor colorWithRed:0.2667 green:0.5255 blue:0.7020 alpha:1];
                lbl.textColor = [UIColor whiteColor];
            } else {
                lbl.backgroundColor = [UIColor colorWithRed:0.8627 green:0.8784 blue:0.8863 alpha:1];
                lbl.textColor = [UIColor colorWithWhite:0.5725 alpha:1];
            }
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
