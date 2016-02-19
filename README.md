# RemotePushTrial
Simple Code Snippets with Comments for Enabling Push Notifications

Basic steps to enable push notifications from an iOS app is documented in this project. Most implementation contained in the AppDelegate.

A blog documenting the remote notification scenarios and how to handle them is here - http://gtlcodes.blogspot.in/2016/02/push-notifications-with-ios.html. 

As I understand, the Push Notifications system in iOS exists between the APNS and our iOS primarily. 

1) The iOS app gives basic app info to the OS, which it combines with some unique device identification and forms both as a request to send to APNS.
2) APNS on recognising this, sends back a token to the OS which then flows to the app. 
3) This token needs to be sent to the server that is dealing with the iOS app so that it can send this token with every push notification it wants to send to the app. 
4) With this token from the server request, APNS knows that it is a trusted server and knows where to forward the notification. 
5) The OS then receives it, sends to the right iOS app. 

We need to enable each of these steps in our app so that the transaction happens. 


This project,

1) Manages active(foreground and background) and inactive states <br>
2) Handles custom actions<br>
3) Is documented with inline comments and in the blog<br>
4) Tested in iOS 9.2. Written in Objective-C.<br>
5) Tested the server implementation with the wonderfully easy https://github.com/noodlewerk/NWPusher

Again, a blog documenting the remote notification scenarios and how to handle them is here - http://gtlcodes.blogspot.in/2016/02/push-notifications-with-ios.html. 

Known Issue:<br>
While the text input action shows a text box, I still haven't managed to get the right delegate fire up properly. Just for this case. 


