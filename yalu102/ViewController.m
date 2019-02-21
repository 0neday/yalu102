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

#include "offsets.h"
#include "exploit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    struct utsname u = { 0 };
    uname(&u);
    if (strstr(u.version, "hongs")) {
        [go setEnabled:NO];
        [go setTitle:@"already jailbroken" forState:UIControlStateDisabled];
    }
}
- (IBAction)yalu102:(id)sender {
    /*
     we out here!
     */
    init_offsets();
    if(exploit()){
        [go setEnabled:NO];
        [go setTitle:@"already jailbroken!" forState:UIControlStateDisabled];
    }
    else
        [go setTitle:@"failed, try again!" forState:UIControlStateDisabled];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
