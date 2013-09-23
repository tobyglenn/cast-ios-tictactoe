cast-ios-tictactoe
==================

This iOS Tic Tac Toe shows basic comminication via channels to a javacript
program running in Chromecast and how to create/end/resume/destroy a session.

To build this:

(1) In the Xcode project, correct the path to your copy of the GCKFramework.framework. One way to do this:

(1.a) The left column of Xcode project window should show the File Navigator, and the right column should show the File Inspector.

(1.b) Select GCKFramework.framework in the Frameworks group in the File Navigator.

(1.c) in the File Inspector click the icon on the far right, just below the Location popup dialog item. It will give you an 'Open' dialog box where you can navigate to the your copy of GCKFramework.framework .

(2) To install the app on a device, you must edit bundle identifier in TicTacToe-Info.plist from com.google.${PRODUCT_NAME:rfc1034identifier} - replace the 'com.google' with the identifier you registered with Apple in https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action
 
 
 NOTES - Please replace the AppID in TicTacToeViewController.m
 
 HINTS - You can run one copy on a device and annother in the simulator to show off multi-user.