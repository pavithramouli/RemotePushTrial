//
//  ViewController.h
//  RemotePushTrial
//
//  Created by Pavithramouli on 15/02/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *pushDataReceived;
@property (weak, nonatomic) IBOutlet UITextField *pushStatus;

-(void)handleTextInput:(NSString *) textInput;

@end

