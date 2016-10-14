//
//  ViewController.m
//  ES3_1_RoundPoint
//
//  Created by michael on 13/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "ViewController.h"
#import "RoundPointView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view addSubview:[[RoundPointView alloc] initWithFrame:self.view.bounds]];
}

@end
