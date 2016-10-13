//
//  ViewController.m
//  ES3_0_ClearColor
//
//  Created by michael on 13/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "ViewController.h"
#include "MyView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:[[MyView alloc] initWithFrame:self.view.bounds]];
}

@end
