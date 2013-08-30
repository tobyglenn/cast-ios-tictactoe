// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>

@class GCKDevice;
@class GCKApplicationSession;
@class TicTacToeBoardState;
@class TicTacToeMessageStream;

// A view controller which connects to and joins a Tic-Tac-Toe game instance on
// a Cast device, displays the game board, and allows the user to play the game
// on the Cast device using this device as a controller.
//
// This view controller must be instantiated in a nib file as a view controller
// containing only an empty UIView.
@interface TicTacToeViewController : UIViewController

@property(nonatomic, strong) GCKDevice *device;

@end

@interface TicTacToeViewController (Testing)

// Creates a GCKApplicationSession to talk to a cast device. Tests can
// override this method to inject a mock session.
- (GCKApplicationSession *)createSession;

// Creates a TicTacToeMessageStream to talk to a TicTacToe app instance on a
// cast device. Tests can override this method to inject a mock stream.
- (TicTacToeMessageStream *)createMessageStream;

// The name of the current user playing the game on this device.
- (NSString *)currentUserName;

// Shows an alert message. This is used internally for all alert messages,
// which allows tests to easily check the important parts of the alerts.
- (void)showAlertMessage:(NSString *)message
               withTitle:(NSString *)title
                     tag:(NSInteger)tag;

// True if the current player can play.
- (BOOL)isPlayersTurn;

// Once the game has been joined, the player on this device.
- (char)player;

// The current state of the board.
- (TicTacToeBoardState *)boardState;

+ (void)decodeWinningLocationFrom:(NSInteger)value
                        toWinType:(NSInteger *)winType
                            index:(NSInteger *)index;

@end
