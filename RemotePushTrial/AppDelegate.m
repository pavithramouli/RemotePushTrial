//
//  AppDelegate.m
//  RemotePushTrial
//
//  Created by Pavithramouli on 15/02/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    bool isDeviceRegisteredForPushNotifications; // can help with app-specific actions. Not mandatory.
    NSUserDefaults *userDefaults;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    userDefaults = [NSUserDefaults standardUserDefaults];
    [self setupAppForPushNotificationsWithLaunchOptions:launchOptions forCurrentApplication:application];
    
    return YES;
}

#pragma mark Push Notification Handlers
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
{
    NSLog(@"Registering done for remote notifications");
    
    // Though we can block APNS registration after the first time, Apple recommends we do it at every app launch. So, we check and send device token to server every time.
    // apparently we don't incur overhead with this. If the OS has the details it returns it immediately.
   
    NSLog(@"Initial Device Registration for push notifications with APNS...");
    [[UIApplication sharedApplication] registerForRemoteNotifications]; // Register for remote notifications.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{
    NSLog(@"Device Registration with APNS successful, bundle identifier: %@, mode: %@, device token: %@",[NSBundle.mainBundle bundleIdentifier], [self environmentMode], token);
    
    const void *devTokenBytes = [token bytes];
    isDeviceRegisteredForPushNotifications = true;
    [userDefaults setObject:@"true" forKey:@"PushRegistrationStatus"];
    [userDefaults synchronize];
    [self sendProviderDeviceToken:devTokenBytes]; // custom method
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register with APNS for connection trust: %@", error);
}


 // Use this method alone if the app can manage responding to that notification.
 // For example, we may want to perform some UI updates or network fetches just based on the notification. Call a custom method before exiting this method.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"Received remote notification -- %@", userInfo);
    
    //DEBUG -- This alert view is just for debug purposes. Please remove when transition is smooth.
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                       message:@"Received remote notification. So perform necessary actions here if needed."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    
    // the following logic is custom too. Not mandatory.
    application.applicationIconBadgeNumber = 0; //0 hides the badge

}

 
 // Use this method if the app needs to manage interactive push actions without interactive text input.
 // Call a custom method before exiting this method.
 // Can be a network fetch, UI update, etc.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
{
    NSLog(@"Received push notification: %@, identifier: %@", notification, identifier); // iOS 8+
    
    if([identifier isEqualToString:@"ANY_CUSTOM_IDENTIFIER"]){
        // do any custom actions.
    }
 
    completionHandler();
}


// This method works only with iOS 9+
// Use this method if the app needs to manage interactive push actions "with" interactive text input.
// Call a custom method before exiting this method.
// Can be a network fetch, UI update, etc.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    
    NSLog(@"Got the notification as %@",userInfo);
    NSLog(@"Also got the input %@", responseInfo[UIUserNotificationActionResponseTypedTextKey]);

    if([identifier isEqualToString:@"ANY_CUSTOM_IDENTIFIER"]){
        // Call a custom method to handle actions.
    }
    else{
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"TextInputNotification" object:responseInfo[UIUserNotificationActionResponseTypedTextKey]];
    }
    
    completionHandler();

}

#pragma mark Custom Push Notification Handlers
- (void)setupAppForPushNotificationsWithLaunchOptions:(NSDictionary*)applicationLaunchOptions forCurrentApplication:(UIApplication*)application{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PushRegistrationStatus"]) {
        isDeviceRegisteredForPushNotifications = [[userDefaults stringForKey:@"PushRegistrationStatus"] boolValue]; //can use this bool for any app-specific actions.
    }
    
    // iOS 8+
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        NSLog(@"Registering permissions for push notifications...");
        
        // Register the supported interaction types.
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        // Create actionable actions. Not needed in case of simple notifications. Skip and set up UIUserNotificationSettings directly
        UIMutableUserNotificationAction *anyCustomAction =[[UIMutableUserNotificationAction alloc] init];
        anyCustomAction.identifier = @"ANY_CUSTOM_IDENTIFIER";// The identifier that you use internally to handle the action.
        anyCustomAction.title = @"Accept";// The localized title of the action button.
        anyCustomAction.activationMode = UIUserNotificationActivationModeBackground;// Specifies whether the app must be in the foreground to perform the action.
        anyCustomAction.destructive = NO;// Destructive actions are highlighted appropriately to indicate their nature.
        anyCustomAction.authenticationRequired = NO;// Indicates whether user authentication is required to perform the action.
        
        // This is an actionable action which shows a text input to respond to the notification
        UIMutableUserNotificationAction *replyAction = [[UIMutableUserNotificationAction alloc]init];
        replyAction.identifier = @"REPLY_IDENTIFIER";
        replyAction.title = @"Reply";
        replyAction.activationMode =UIUserNotificationActivationModeForeground;
        replyAction.destructive = NO;
        replyAction.authenticationRequired = NO;
        replyAction.behavior = UIUserNotificationActionBehaviorTextInput; //This sets up the action as a textinput action
        
        // Create a category of notification
        // Multiple sets of actions can be associated with a category.
        // Can create multiple categories too
        UIMutableUserNotificationCategory *customCategory =[[UIMutableUserNotificationCategory alloc] init];
        customCategory.identifier = @"CUSTOM_CATEGORY"; // Identifier to include in your push payload and local notification
        
        // Set the actions to display in the default context
        [customCategory setActions:@[anyCustomAction, replyAction]
                        forContext:UIUserNotificationActionContextDefault];
        
        // Set the actions to display in a minimal context
        [customCategory setActions:@[anyCustomAction]
                        forContext:UIUserNotificationActionContextMinimal];
        
        // Can create multiple categories too
        NSSet *categories = [NSSet setWithObjects:customCategory, nil];
        
        // Associate the types and categories for the notifications
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:categories]; //set categories as nil for simple notifications
        
        // Register the app for these settings
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
        
        //The following section is necessary to deal with notifications when the app is inactive, i.e. neither in foreground or in background. (App killed)
        NSLog(@"%@",[applicationLaunchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]);
        // This key is only set by the OS when the app is inactive. And the push notification action opens up the app.
        // No other delegate is fired in this scenario. So handle all custom actions here too
        if ([applicationLaunchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
            
            NSLog(@"Received notification when app was inactive. So perform necessary actions here if needed.");
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                               message:@"Opened app through push notification's Open option. App was actually not in background or foreground. So perform necessary actions here if needed."
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
            
            // call custom code to handle notification related here.
            application.applicationIconBadgeNumber = 0; // or [[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] applicationIconBadgeNumber] -1
        }
        else{
            // could be or need not be applicable with notifications. Purely app-specific scenarios.
            NSLog(@"Normal app launch");
            UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                               message:@"Normal app launch."
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [theAlert show];
          
        }
        
    }
    else{ // <iOS 8.0
         NSLog(@"Registering device for push notifications...");
        [UIApplication.sharedApplication registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound];
    }

}

// Custom method to send the token returned from APNS for a particular instance of the app running on the device
// This is necessary for the server to establish trust with APNS for each notification it wants to send through APNS
-(void)sendProviderDeviceToken:(const void *)devTokenBytes{
    
    //custom logic to share this with server
    //with iOS 9+, the old token in case of fresh app installs are found to be valid as well as the new tokens. Need to handle tokens properly to ensure that there are no wrong or duplicate keys in the server.
    //this seems to be not documented by Apple very well as of iOS 9.2. Need to check back if changes are announced.
}

// Will help with debugging push related issues
- (NSString *)environmentMode
{
#if DEBUG
    return @"Development (sandbox)";
#else
    return @"Production";
#endif
}

#pragma mark UIApplication Handlers

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
