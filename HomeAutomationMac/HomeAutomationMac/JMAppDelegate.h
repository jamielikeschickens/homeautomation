//
//  JMAppDelegate.h
//  HomeAutomationMac
//
//  Created by Jamie Maddocks on 01/12/2013.
//  Copyright (c) 2013 Chicken Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JMAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceDelegate, NSStreamDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
