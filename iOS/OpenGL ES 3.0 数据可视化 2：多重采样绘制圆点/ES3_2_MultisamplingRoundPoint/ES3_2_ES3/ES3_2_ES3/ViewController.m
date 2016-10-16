//
//  ViewController.m
//  ES3_2_ES3
//
//  Created by michael on 16/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "ViewController.h"
#import "ES3MultisamplingRoundPoint.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = [[ES3MultisamplingRoundPoint alloc] initWithFrame:self.view.bounds];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
