//
//  ViewController.m
//  CalendarView
//
//  Created by shaohua on 31/03/2017.
//  Copyright © 2017 syang. All rights reserved.
//

#import "ViewController.h"
#import "TTCalendarView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TTCalendarView *calenderView = [[TTCalendarView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 320)];
    calenderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:calenderView];
}


@end
