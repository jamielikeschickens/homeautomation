//
//  JMLightViewController.h
//  HomeAutomation
//
//  Created by Jamie Maddocks on 27/11/2013.
//  Copyright (c) 2013 Jamie Maddocks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMLightViewController : UIViewController

@property (nonatomic) IBOutlet UIView *colorView;
@property (nonatomic) IBOutlet UISlider *redSlider;
@property (nonatomic) IBOutlet UISlider *greenSlider;
@property (nonatomic) IBOutlet UISlider *blueSlider;
@property (nonatomic) IBOutlet UISlider *brightnessSlider;
@property (nonatomic) IBOutlet UISegmentedControl *onOffControl;
@property (nonatomic) IBOutlet UIButton *resetButton;
@property (nonatomic) NSUInteger roomNumber;

- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)onOffSegmentPressed:(id)sender;
- (IBAction)redSliderValueChanged:(id)sender;
- (IBAction)greenSliderValueChanged:(id)sender;
- (IBAction)blueSliderValueChanged:(id)sender;
- (IBAction)brightnessSliderValueChanged:(id)sender;


@end
