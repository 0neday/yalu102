//
//  AppDelegate.h
//  yalu102
//
//  Created by qwertyoruiop on 05/01/2017.
//  Copyright © 2017 kimjongcracks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) NSPipe *combinedPipe;
@property (assign) int orig_stderr;
@property (assign) int orig_stdout;
@end

