//
//  JMLightViewController.m
//  HomeAutomation
//
//  Created by Jamie Maddocks on 27/11/2013.
//  Copyright (c) 2013 Jamie Maddocks. All rights reserved.
//

#import "JMAppDelegate.h"
#import "JMLightViewController.h"

@interface JMLightViewController ()
@property (nonatomic) UIColor *currentColor;
@end

@implementation JMLightViewController

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
    self.currentColor = self.colorView.backgroundColor;

}

- (void)shouldUpdateServer {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"lights" forKey:@"type"];
    [dict setObject:@(self.roomNumber) forKey:@"room"];
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [dataDict setObject:@(self.redSlider.value) forKey:@"red"];
    [dataDict setObject:@(self.greenSlider.value) forKey:@"green"];
    [dataDict setObject:@(self.blueSlider.value) forKey:@"blue"];
    [dataDict setObject:@(self.brightnessSlider.value) forKey:@"brightness"];
    [dict setObject:dataDict forKey:@"data"];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [(JMAppDelegate *)[[UIApplication sharedApplication] delegate] writeDataToServer:data];
}

- (IBAction)redSliderValueChanged:(id)sender {
    [self updateColorView];
    [self shouldUpdateServer];
}

- (IBAction)greenSliderValueChanged:(id)sender {
    [self updateColorView];
    [self shouldUpdateServer];
}

- (IBAction)blueSliderValueChanged:(id)sender {
    [self updateColorView];
    [self shouldUpdateServer];
}

- (void)updateColorView {
    [self.colorView setBackgroundColor:[UIColor colorWithRed:self.redSlider.value/255 green:self.greenSlider.value/255 blue:self.blueSlider.value/255 alpha:1.0]];
}

- (IBAction)brightnessSliderValueChanged:(id)sender {
    [self shouldUpdateServer];
}

- (IBAction)resetButtonPressed:(id)sender {
    [self.redSlider setValue:255 animated:YES];
    [self.greenSlider setValue:255 animated:YES];
    [self.blueSlider setValue:255 animated:YES];
    [self.brightnessSlider setValue:255 animated:YES];
    
    [self.redSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.greenSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.blueSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.brightnessSlider sendActionsForControlEvents:UIControlEventValueChanged];
    
    [self shouldUpdateServer];
}

- (IBAction)onOffSegmentPressed:(id)sender {
    if (self.onOffControl.selectedSegmentIndex == 0) {
        [self.redSlider setEnabled:YES];
        [self.greenSlider setEnabled:YES];
        [self.blueSlider setEnabled:YES];
        [self.brightnessSlider setEnabled:YES];
        [self.resetButton setEnabled:YES];
        
        [self.redSlider setValue:255 animated:YES];
        [self.greenSlider setValue:255 animated:YES];
        [self.blueSlider setValue:255 animated:YES];
        [self.brightnessSlider setValue:255 animated:YES];

    } else {
        [self.redSlider setEnabled:NO];
        [self.greenSlider setEnabled:NO];
        [self.blueSlider setEnabled:NO];
        [self.brightnessSlider setEnabled:NO];
        [self.resetButton setEnabled:NO];
        
        [self.redSlider setValue:0 animated:YES];
        [self.greenSlider setValue:0 animated:YES];
        [self.blueSlider setValue:0 animated:YES];
        [self.brightnessSlider setValue:0 animated:YES];
    }
    
    [self.redSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.greenSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.blueSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.brightnessSlider sendActionsForControlEvents:UIControlEventValueChanged];

    [self shouldUpdateServer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
