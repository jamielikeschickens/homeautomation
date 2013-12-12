//
//  JMAppDelegate.m
//  HomeAutomation
//
//  Created by Jamie Maddocks on 27/11/2013.
//  Copyright (c) 2013 Jamie Maddocks. All rights reserved.
//

#import "JMAppDelegate.h"
#import <sys/socket.h>
#import <netinet/in.h>

@interface JMAppDelegate ()
@property (nonatomic) NSNetServiceBrowser *netService;
@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;
@end

@implementation JMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.netService = [[NSNetServiceBrowser alloc] init];
    [self.netService setDelegate:self];
    [self.netService searchForServicesOfType:@"_arduinohomeauto._tcp" inDomain:@""];
    
    return YES;
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    NSLog(@"Got netService %@ with hostname %@", aNetService, [aNetService hostName]);
    NSInputStream *i;
    NSOutputStream *o;
    [aNetService getInputStream:&i outputStream:&o];
    
    [self setInputStream:i];
    [self setOutputStream:o];

    
    [self.inputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    
    [self.inputStream open];
    [self.outputStream open];
    
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t data;
        [(NSInputStream *)aStream read:&data maxLength:1];
        if (data == '1') {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alarm!" message:@"Alarm has been tripped! HomeAutomation turret has been deployed" delegate:nil cancelButtonTitle:@"Okay!" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)writeDataToServer:(NSData *)data {
    //NSLog(@"Data length: %d", [data length]);
    uint32_t length = (uint32_t)htonl([data length]);
    //NSLog(@"htonl Length: %d", length);
    uint8_t *d = malloc(4 + [data length]);
    memcpy(d, &length, 4);
    memcpy(d+4, [data bytes], [data length]);
    
    [self.outputStream write:(uint8_t *)d maxLength:4+[data length]];
    free(d);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self.netService searchForServicesOfType:@"_arduinohomeauto._tcp" inDomain:@""];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
