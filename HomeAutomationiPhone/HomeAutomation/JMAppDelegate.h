//
//  JMAppDelegate.h
//  HomeAutomation
//
//  Created by Jamie Maddocks on 27/11/2013.
//  Copyright (c) 2013 Jamie Maddocks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMAppDelegate : UIResponder <UIApplicationDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)writeDataToServer:(NSData *)data;

@end
