//
//  ViewController.m
//  RemotePushTrial
//
//  Created by Pavithramouli on 15/02/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize pushDataReceived,pushStatus;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextInput:) name:@"TextInputNotification" object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)handleTextInput:(NSString *) textInput{
    pushDataReceived.text = textInput;
    pushStatus.text = @"Text detected";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
