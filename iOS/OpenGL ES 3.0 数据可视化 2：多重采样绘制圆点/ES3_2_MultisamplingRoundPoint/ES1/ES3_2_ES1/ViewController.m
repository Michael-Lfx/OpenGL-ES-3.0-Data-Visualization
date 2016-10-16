//
//  ViewController.m
//  ES3_2_ES1
//
//  Created by michael on 15/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "ViewController.h"
#import "PointSmoothView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.view addSubview:[[PointSmoothView alloc] initWithFrame:[UIScreen mainScreen].bounds]];
}


@end
