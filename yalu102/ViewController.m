//
//  ViewController.m
//  yalu102
//
//  Created by qwertyoruiop on 05/01/2017.
//  Copyright © 2017 kimjongcracks. All rights reserved.
//

#import "ViewController.h"
#import <mach-o/loader.h>
#import <sys/mman.h>
#import <mach/mach.h>
#include <sys/utsname.h>
#include <sys/time.h>
#include "offsets.h"
#include "exploit.h"
#include "common.h"

@interface ViewController ()
@end

@implementation ViewController
static ViewController *sharedController = nil;
static NSMutableString *output = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sharedController = self;
    
    struct utsname u = { 0 };
    uname(&u);
    LOG("sysname: %s\n", u.sysname);
    LOG("nodename: %s\n", u.nodename);
    LOG("release: %s\n", u.release);
    LOG("version: %s\n", u.version);
    LOG("machine: %s\n", u.machine);
    
    //set textview
    [self.outputView setEditable:NO];
    [self.outputView setSelectable:NO];
    [self.outputView setContentInset:UIEdgeInsetsMake(-5, 1, -5, -5)];
    [self.outputView setTextAlignment:NSTextAlignmentLeft];
    self.outputView.layoutManager.allowsNonContiguousLayout = NO;
    self.outputView.scrollEnabled = YES;
    self.outputView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    self.outputView.textContainer.lineFragmentPadding = 0;
    
    
    if (strstr(u.version, "hongs")) {
        [self.go setEnabled:NO];
        [self.go setTitle:@"already jailbroken" forState:UIControlStateNormal];
        LOG("jailbroken!");
       // LOG("nice!\n");
    }
}

- (IBAction)yalu102:(id)sender {
    /*
     we out here!
     */
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        init_offsets();
        [self.go setEnabled:NO];
        LOG("start jailbreak");
        if(exploit()){
            [self.go setTitle:@"already jailbroken!" forState:UIControlStateDisabled];
        }
        else
            [self.go setTitle:@"failed, try again!" forState:UIControlStateDisabled];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
        });
   // });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

// This intentionally returns nil if called before it's been created by a proper init
+(ViewController *)sharedController {
    return sharedController;
}

-(void)updateOutputView {
    [self updateOutputViewFromQueue:@NO];
}

-(void)updateOutputViewFromQueue:(NSNumber*)fromQueue {
    static BOOL updateQueued = NO;
    static struct timeval last = {0,0};
    static dispatch_queue_t updateQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        updateQueue = dispatch_queue_create("updateView", NULL);
    });
    
    dispatch_async(updateQueue, ^{
        struct timeval now;
        
        if (fromQueue.boolValue) {
            updateQueued = NO;
        }
        
        if (updateQueued) {
            return;
        }
        
        if (gettimeofday(&now, NULL)) {
            //LOG("gettimeofday failed");
            return;
        }
        
        uint64_t elapsed = (now.tv_sec - last.tv_sec) * 1000000 + now.tv_usec - last.tv_usec;
        // 30 FPS
        if (elapsed > 1000000/30) {
            updateQueued = NO;
            gettimeofday(&last, NULL);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.outputView.text = output;
                [self.outputView scrollRangeToVisible:NSMakeRange(self.outputView.text.length, 0)];
            });
        } else {
            NSTimeInterval waitTime = ((1000000/30) - elapsed) / 1000000.0;
            updateQueued = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(updateOutputViewFromQueue:) withObject:@YES afterDelay:waitTime];
            });
        }
    });
}

-(void)appendTextToOutput:(NSString *)text {
    if (self.outputView == nil) {
        return;
    }
    static NSRegularExpression *remove = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remove = [NSRegularExpression regularExpressionWithPattern:@"^\\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2}\\.\\d+[-\\d\\s]+\\S+\\[\\d+:\\d+\\]\\s+"
                                                           options:NSRegularExpressionAnchorsMatchLines error:nil];
        output = [NSMutableString new];
    });
    
    text = [remove stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@""];
    
    @synchronized (output) {
        [output appendString:text];
    }
    [self updateOutputView];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @synchronized(sharedController) {
        if (sharedController == nil) {
            sharedController = [super initWithCoder:aDecoder];
        }
    }
    self = sharedController;
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @synchronized(sharedController) {
        if (sharedController == nil) {
            sharedController = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        }
    }
    self = sharedController;
    return self;
}

- (id)init {
    @synchronized(sharedController) {
        if (sharedController == nil) {
            sharedController = [super init];
        }
    }
    self = sharedController;
    return self;
}

@end
