//
//  JMAppDelegate.m
//  HomeAutomationMac
//
//  Created by Jamie Maddocks on 01/12/2013.
//  Copyright (c) 2013 Chicken Studios. All rights reserved.
//

#import "JMAppDelegate.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <fcntl.h>    // File control definitions
#include <termios.h>  // POSIX terminal control definitions
#include <sys/ioctl.h>


@interface JMAppDelegate ()
@property (nonatomic) int port;
@property (nonatomic) NSNetService *netService;
@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;
@property (nonatomic) uint32_t bytesRead;
@property (nonatomic) uint32_t bytesToRead;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) BOOL dataIsNext;

@property (nonatomic) int serialPort;
@end

@implementation JMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.bytesRead = 0;
    self.dataIsNext = NO;
    [self openSerialConnectionToArduino];
    [self performSelectorInBackground:@selector(readFromArduino) withObject:nil];
    [self createNetworkSocket];
}

- (void)createNetworkSocket {
    CFSocketContext sock_context = {0, (__bridge void *)(self), NULL, NULL,  NULL};
    CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&socketCallback, &sock_context);
    
    static const int yes = 1;
    setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEADDR, (const void *)&yes, sizeof(yes));
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(0);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    
    if (CFSocketSetAddress(socket, (__bridge CFDataRef)address4) != kCFSocketSuccess) {
        NSLog(@"Failed to bind to address");
    }
    
    NSData *addr = (NSData *)CFBridgingRelease(CFSocketCopyAddress(socket));
    memcpy(&addr4, [addr bytes], [addr length]);
    [self setPort:ntohs(addr4.sin_port)];
    
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
    CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
    CFRelease(source4);
    
    [self publishService];
}

- (void)publishService {
    NSLog(@"tee");
    self.netService = [[NSNetService alloc] initWithDomain:@"" type:@"_arduinohomeauto._tcp" name:@"" port:self.port];
    [self.netService setDelegate:self];
    [self.netService publish];
}

- (void)connectedToInputStream:(NSInputStream *)iStream outputStream:(NSOutputStream *)oStream {
    [self setInputStream:iStream];
    [self setOutputStream:oStream];
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.inputStream open];
    [self.outputStream open];
    
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventHasBytesAvailable) {
        NSInputStream *stream = (NSInputStream *)aStream;
        
        while ([stream hasBytesAvailable]) {
            
            if (!_data) {
                _data = [[NSMutableData alloc] init];
            }
            if (self.dataIsNext == NO) {
                self.bytesRead += [stream read:((uint8_t *)&_bytesToRead)+self.bytesRead maxLength:4-self.bytesRead];
                
                if (self.bytesRead == 4) {
                    self.bytesToRead = ntohl(self.bytesToRead);
                    self.dataIsNext = YES;
                    self.bytesRead = 0;
                }
            } else {
                size_t len;
                uint8_t *buf = malloc(self.bytesToRead);
                len = [stream read:buf maxLength:self.bytesToRead];
                [self.data appendBytes:buf length:len];
                self.bytesRead += len;
                free(buf);
                if (self.bytesRead == self.bytesToRead) {
                    self.dataIsNext = NO;
                    self.bytesRead = 0;
                    self.bytesToRead = 0;
                    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
                    uint8_t *data = calloc(5, sizeof(uint8_t));
                    
                    uint8_t room = (uint8_t)[[dict objectForKey:@"room"] intValue];
                    uint8_t red = (uint8_t)[[[dict objectForKey:@"data"] objectForKey:@"red"] intValue];
                    uint8_t green = (uint8_t)[[[dict objectForKey:@"data"] objectForKey:@"green"] intValue];
                    uint8_t blue = (uint8_t)[[[dict objectForKey:@"data"] objectForKey:@"blue"] intValue];
                    uint8_t brightness = (uint8_t)[[[dict objectForKey:@"data"] objectForKey:@"brightness"] intValue];

                    memcpy(data, &room, 1);
                    memcpy(data+1, &red, 1);
                    memcpy(data+2, &green, 1);
                    memcpy(data+3, &blue, 1);
                    memcpy(data+4, &brightness, 1);
                    [self writeToArduino:data length:5];
                    free(data);
                    
                    
                    //NSLog(@"Data: %@", dict);
                    _data = [[NSMutableData alloc] init];
                    break;
                }
            }
            
        }
    }
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    NSLog(@"We published");
}

- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"Ready to publish");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed: %@", errorDict);
}

void socketCallback(CFSocketRef socket,
                    CFSocketCallBackType type,
                    CFDataRef address,
                    const void *data, void *info) {
    JMAppDelegate *appDelegate = (__bridge JMAppDelegate *)info;
    if (type == kCFSocketAcceptCallBack) {
        // on an accept the data is the native socket handle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        
        // create the read and write streams for the connection to the other process
        CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle,
                                     &readStream, &writeStream);
        if (NULL != readStream && NULL != writeStream) {
            CFReadStreamSetProperty(readStream,
                                    kCFStreamPropertyShouldCloseNativeSocket,
                                    kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream,
                                     kCFStreamPropertyShouldCloseNativeSocket,
                                     kCFBooleanTrue);
            [appDelegate connectedToInputStream:(__bridge NSInputStream *)readStream outputStream:(__bridge NSOutputStream *)writeStream];
            
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }
        if (readStream) CFRelease(readStream);
        if (writeStream) CFRelease(writeStream);
    
    }
}

#pragma mark Serial connection

-(void)openSerialConnectionToArduino {
    
    struct termios toptions;
    int fd;
    
    fd = open("/dev/tty.usbmodem1421", O_RDWR | O_NOCTTY | O_NDELAY);
    
    int iflags = TIOCM_DTR;
    //ioctl(fd, TIOCMBIS, &iflags);     // turn on DTR
    ioctl(fd, TIOCMBIC, &iflags);    // turn off DTR
    
    int status;
    ioctl(fd, TIOCMGET, &status);
    
    status &= ~TIOCM_DTR;
    ioctl(fd, TIOCMSET, &status);
    
    tcgetattr(fd, &toptions);
    
    speed_t brate = B9600; // let you override switch below if needed
    cfsetispeed(&toptions, brate);
    cfsetospeed(&toptions, brate);
    
    // 8N1
    toptions.c_cflag &= ~PARENB;
    toptions.c_cflag &= ~CSTOPB;
    toptions.c_cflag &= ~CSIZE;
    toptions.c_cflag |= CS8;
    // no flow control
    toptions.c_cflag &= ~CRTSCTS;
    
    toptions.c_cflag &= ~HUPCL; // disable hang-up-on-close to avoid reset
    
    toptions.c_cflag |= CREAD | CLOCAL;  // turn on READ & ignore ctrl lines
    toptions.c_iflag &= ~(IXON | IXOFF | IXANY); // turn off s/w flow ctrl
    
    toptions.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG); // make raw
    toptions.c_oflag &= ~OPOST; // make raw
    
    // see: http://unixwiz.net/techtips/termios-vmin-vtime.html
    toptions.c_cc[VMIN]  = 0;
    toptions.c_cc[VTIME] = 0;
    //toptions.c_cc[VTIME] = 20;
    
    tcsetattr(fd, TCSANOW, &toptions);
    tcsetattr(fd, TCSAFLUSH, &toptions);
    
    // When first creating connection DTR line is pulled and so we need to delay for arduino to boot
    sleep(2);
    
    [self setSerialPort:fd];
    NSLog(@"Connection opened");

}

- (void)readFromArduino {
    while (1) {
        //NSLog(@"WE are reading %d", self.serialPort);
        char alarm;
        size_t n = read(self.serialPort, &alarm, 1); // Read 1 character
        if (n == 1) {
            NSLog(@"%c", alarm);
            if (alarm == '1') {
                NSLog(@"Alarm has gone off");
                uint8_t data = '1';
                size_t n = [self.outputStream write:&data maxLength:1]; // Write 1 to show alarm has gone off
                if (n == 1) {
                }
            } else {
                
            }
        }
        
        sleep(1);
    }
}

- (void)writeToArduino:(uint8_t[])data length:(size_t)length {
    NSLog(@"We are writing");
    
    for (int i=0; i < length; ++i) {
        printf("%d\n", data[i]);
    }
    
    size_t n = write(self.serialPort, data, length);
    if (n != length) {
        NSLog(@"Didn't write full string");
    }
}

@end
