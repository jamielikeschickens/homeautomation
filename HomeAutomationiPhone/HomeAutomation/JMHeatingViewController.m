//
//  JMHeatingViewController.m
//  HomeAutomation
//
//  Created by Jamie Maddocks on 27/11/2013.
//  Copyright (c) 2013 Jamie Maddocks. All rights reserved.
//

#import "JMHeatingViewController.h"

@interface JMHeatingViewController ()

@end

@implementation JMHeatingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView setContentSize:CGSizeMake(320, 600)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
