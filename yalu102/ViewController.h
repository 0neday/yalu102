//
//  ViewController.h
//  yalu102
//
//  Created by qwertyoruiop on 05/01/2017.
//  Copyright © 2017 kimjongcracks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton* go;
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (readonly) ViewController *sharedController;

- (IBAction)yalu102:(id)sender;
+(ViewController*)sharedController;
- (void)appendTextToOutput:(NSString*)text;
@end

