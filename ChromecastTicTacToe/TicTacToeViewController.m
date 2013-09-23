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

#if !__has_feature(objc_arc)
#error This code requires ARC
#endif

#import "TicTacToeViewController.h"

#import "AppDelegate.h"
#import "TicTacToeBoardState.h"
#import "TicTacToeMessageStream.h"
#import "TicTacToeView.h"

#import <GCKFramework/GCKFramework.h>
//
// REPLACE THIS NAME IF YOUR RUNNING ON YOUR OWN RECEIVER!
//
static NSString * const kReceiverApplicationName = @"TicTacToe";

static const NSInteger kTagAlertOnly = 0;
static const NSInteger kTagPopViewControllerOnOK = 1;
static const NSInteger kTagPlayAgain = 2;

@interface TicTacToeViewController () <GCKApplicationSessionDelegate,
                                       TicTacToeMessageStreamDelegate,
                                       TicTacToeViewDelegate,
                                       UIAlertViewDelegate> {
  // Views.
  TicTacToeView *_ticTacToeView;
  UILabel *_gameStatusLabel;

  // Game state.
  BOOL _isXsTurn;
  BOOL _isGameInProgress;
  BOOL _isWaitingForMoveToBeSent;
  NSString *_opponentName;

  // Dongle state and communication.
  GCKApplicationSession *_session;
  GCKApplicationChannel *_channel;
  TicTacToeMessageStream *_messageStream;
}

@property(nonatomic, readonly) TicTacToePlayer player;
@property(nonatomic, readonly) TicTacToeBoardState *boardState;

@end

@implementation TicTacToeViewController

// Add all of the custom subviews and layout constraints to the empty view
// provided in the nib.
- (void)awakeFromNib {
  _isGameInProgress = NO;

  _ticTacToeView = [[TicTacToeView alloc] initWithFrame:CGRectZero];
  _ticTacToeView.translatesAutoresizingMaskIntoConstraints = NO;
  _ticTacToeView.delegate = self;
  [self.view addSubview:_ticTacToeView];

  _gameStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  _gameStatusLabel.font = [UIFont systemFontOfSize:17];
  _gameStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_gameStatusLabel];

  NSDictionary *viewsDictionary =
      NSDictionaryOfVariableBindings(_ticTacToeView, _gameStatusLabel);
  NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:2];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_ticTacToeView]-|"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
  [constraints addObjectsFromArray:
      [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_gameStatusLabel]-|"
                                              options:0
                                              metrics:nil
                                                views:viewsDictionary]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:
      @"V:|-[_ticTacToeView(300)]-[_gameStatusLabel]"
                                             options:0
                                             metrics:nil
                                               views:viewsDictionary]];
  [self.view addConstraints:constraints];

  _boardState = [[TicTacToeBoardState alloc] init];
  _ticTacToeView.board = _boardState;
}

// Start the remote application session when the view appears.
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self startSession];
}

// End the remote application session when the view disappears.
- (void)viewDidDisappear:(BOOL)animated {
  [self endSession];
  [super viewDidDisappear:animated];
}

// Begin the application session with the current device.
- (void)startSession {
  NSAssert(!_session, @"Starting a second session");
  NSAssert(self.device, @"device is nil");

  _session = [self createSession];
  _session.delegate = self;

  [_session startSessionWithApplication:kReceiverApplicationName argument:nil];
}

// End the current application session.
- (void)endSession {
  NSAssert(_session, @"Ending non-existent session");
  [_messageStream leaveGame];
  [_session endSession];
  _session = nil;
  _channel = nil;
  _messageStream = nil;
}

- (BOOL)isPlayersTurn {
  return (_isGameInProgress && ((_player == kPlayerX) == _isXsTurn));
}

// Show a message indicating that the game has finished, with an option to
// play again or leave.
- (void)showGameOverMessage:(NSString *)message {
  NSString *title = NSLocalizedString(@"Game over", nil);
  NSString *cancelButtonTitle = NSLocalizedString(@"I love you", nil);
  //NSString *playAgainButtonTitle = NSLocalizedString(@"Play again", nil);
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
  alert.tag = kTagPlayAgain;
  alert.delegate = self;
  [alert show];
}

// Show an alert message with only an "OK" button.
- (void)showAlertMessage:(NSString *)message
               withTitle:(NSString *)title
                     tag:(NSInteger)tag {
  NSString *okButtonTitle = NSLocalizedString(@"OK", nil);
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:okButtonTitle, nil];
  alert.tag = tag;
  alert.delegate = self;
  [alert show];
}

// Show a message indicating that an error occurred, which can optionally pop
// the view controller when "OK" is tapped.
- (void)showErrorMessage:(NSString *)message
    popViewControllerOnOK:(BOOL)popViewControllerOnOK {
  NSString *title = NSLocalizedString(@"Error", nil);
  NSInteger tag = popViewControllerOnOK ?
      kTagPopViewControllerOnOK : kTagAlertOnly;
  [self showAlertMessage:message
               withTitle:title
                     tag:tag];
}

#pragma mark - Unit test state and injection methods

- (GCKApplicationSession *)createSession {
  return [[GCKApplicationSession alloc] initWithContext:appDelegate.context
                                                 device:self.device];
}

- (TicTacToeMessageStream *)createMessageStream {
  return [[TicTacToeMessageStream alloc] initWithDelegate:self];
}

- (NSString *)currentUserName {
  return [appDelegate userName];
}

#pragma mark - UIAlertViewDelegate

// Responds to an alert view being dismissed. Depending on the tag, pops this
// view controller, starts a new game, or just lets the alert be dismissed and
// does nothing.
- (void)alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
  switch (alertView.tag) {
    case kTagPopViewControllerOnOK:
      [self.navigationController popViewControllerAnimated:YES];
      break;

    case kTagPlayAgain:
      if (buttonIndex == 1) {
        [_messageStream joinGameWithName:[self currentUserName]];
        _gameStatusLabel.text = NSLocalizedString(@"Waiting for opponent\u2026",
                                                  nil);
        [self.boardState clear];
        [_ticTacToeView showWinningStrikethroughOfType:kTicTacToeWinTypeNone
                                               atIndex:0];
      } else {
        [self.navigationController popViewControllerAnimated:YES];
      }
      break;

    default:
      // Do nothing, the alert can just be dismissed.
      break;
  }
}

#pragma mark - GCKApplicationSessionDelegate

// When connected to the session, attempt to join the game if the channel was
// successfully established, or show an error if there is no channel.
- (void)applicationSessionDidStart {
  _channel = _session.channel;
  if (!_channel) {
    NSString *message = NSLocalizedString(@"Could not establish channel.", nil);
    [self showErrorMessage:message popViewControllerOnOK:YES];
    [_session endSession];
  }

  _messageStream = [self createMessageStream];
  if ([_channel attachMessageStream:_messageStream]) {
    if (_messageStream.messageSink) {
      if (20 < _channel.sendBufferAvailableBytes) {
        if ([_messageStream joinGameWithName:[self currentUserName]]) {
          NSLog(@"Couldn't join game.");
        }
      } else {
        NSLog(@"_channel.sendBufferAvailableBytes:%d too small.",
              _channel.sendBufferAvailableBytes);
      }
    } else {
      NSLog(@"Can't send messages.");
    }
  } else {
    NSLog(@"Couldn't attachMessageStream.");
  }

  _gameStatusLabel.text = NSLocalizedString(@"Waiting for opponent\u2026", nil);
}

// Show an error indicating that the game could not be started.
- (void)applicationSessionDidFailToStartWithError:
    (GCKApplicationSessionError *)error {
  NSLog(@"castApplicationSessionDidFailToStartWithError: %@",
        [error localizedDescription]);
  _messageStream = nil;
  NSString *message = NSLocalizedString(@"Could not start game.", nil);
  [self showErrorMessage:message popViewControllerOnOK:YES];
}

// If there is an error, show it; otherwise, just nil out the message stream.
- (void)applicationSessionDidEndWithError:
    (GCKApplicationSessionError *)error {
  NSLog(@"castApplicationSessionDidEndWithError: %@", error);
  _messageStream = nil;
  if (error) {
    NSString *message = NSLocalizedString(@"Lost connection.", nil);
    [self showErrorMessage:message popViewControllerOnOK:YES];
  }
}

#pragma mark - TicTacToeMessageStreamDelegate

// When the game has been joined, update the current player to whichever player
// we joined as, update the game state to a new game, and keep track of the
// opponent's name.
- (void)didJoinGameAsPlayer:(TicTacToePlayer)player
          withOpponentNamed:(NSString *)opponent {
  _player = player;
  _opponentName = opponent;

  _isXsTurn = YES;
  _isWaitingForMoveToBeSent = NO;
  _isGameInProgress = YES;

  [self.boardState clear];
  if (player == kPlayerX) {
    _gameStatusLabel.text = NSLocalizedString(@"Joined game as X", nil);
  } else {
    _gameStatusLabel.text = NSLocalizedString(@"Joined game as O", nil);
  }
}

// Dispaly an error indicating that the game couldn't be started.
- (void)didFailToJoinWithErrorMessage:(NSString *)message {
  [self showErrorMessage:message popViewControllerOnOK:YES];
}

// Display the error message.
- (void)didReceiveErrorMessage:(NSString *)message {
  _isWaitingForMoveToBeSent = NO;
  [self showErrorMessage:message popViewControllerOnOK:NO];
}

// When the move is received, update the board state with the move, and update
// the game state so that it is the other player's turn.
- (void)didReceiveMoveByPlayer:(TicTacToePlayer)player
                         atRow:(NSInteger)row
                        column:(NSInteger)column
                       isFinal:(BOOL)isFinal {
  _isWaitingForMoveToBeSent = NO;
  TicTacToeSquareState newState = ((player == kPlayerX)
                                   ? kTicTacToeSquareStateX
                                   : kTicTacToeSquareStateO);
  _isXsTurn = !(player == kPlayerX);
  [self.boardState setState:newState forSquareAtRow:(NSUInteger)row column:(NSUInteger)column];
  [_ticTacToeView setNeedsDisplay];
}

// Update the game board to show the winning strikethrough if there is a winner,
// and show an alert indicating if the player won, lost, or the game was a draw.
- (void)didEndGameWithResult:(GameResult)result
             winningLocation:(NSInteger)winningLocation {
  switch (result) {
    case kResultYouWon:
    case kResultYouLost: {
      _isGameInProgress = NO;
      TicTacToeWinType winType;
      NSInteger index;
      [[self class] decodeWinningLocationFrom:winningLocation
                                    toWinType:&winType
                                        index:&index];
      [_ticTacToeView showWinningStrikethroughOfType:winType
                                             atIndex:(NSUInteger)index];
      NSString *message;
      if (result == kResultYouWon) {
        message = NSLocalizedString(@"I couldn't ask for anything better than to lose to my beauty! look up at the screen", nil);
      } else {
        message = NSLocalizedString(@"You lost! Play again?", nil);
      }
      [self showGameOverMessage:message];
      _gameStatusLabel.text = @"";
      break;
    }

    case kResultDraw: {
      NSString *message = NSLocalizedString(@"Nobody wins, again.", nil);
      [self showGameOverMessage:message];
      _gameStatusLabel.text = @"";
      break;
    }

    case kResultAbandoned: {
      NSString *title = NSLocalizedString(@"Opponent ran away", nil);
      NSString *message = NSLocalizedString(@"It may feel hollow and empty, "
                                            @"but a win by default is still a "
                                            @"win!",
                                            nil);
      [self showAlertMessage:message
                   withTitle:title
                         tag:kTagPopViewControllerOnOK];
      break;
    }
  }
  [_messageStream leaveGame];
}

// Converts the message stream representation of a win, which is a single
// integer, to a TicTacToeWinType and (if necessary) the index at which that
// win type applies.
+ (void)decodeWinningLocationFrom:(NSInteger)value
                        toWinType:(TicTacToeWinType *)winType
                            index:(NSInteger *)index {
  if ((value >= 0) && (value <= 2)) {
    *winType = kTicTacToeWinTypeRow;
    *index = value;
  } else if ((value >= 3) && (value <= 5)) {
    *winType = kTicTacToeWinTypeColumn;
    *index = value - 3;
  } else if (value == 6) {
    *winType = kTicTacToeWinTypeDiagonalFromTopLeft;
  } else if (value == 7) {
    *winType = kTicTacToeWinTypeDiagonalFromBottomLeft;
  } else {
    *winType = kTicTacToeWinTypeNone;
  }
}

#pragma mark - TicTacToeViewDelegate

// Respond to the tap by sending the move if it is valid (i.e. it is the
// player's turn, and the tapped square is empty).
- (void)didTapTicTacToeView:(TicTacToeView *)view
                      atRow:(NSUInteger)row
                     column:(NSUInteger)column {
  if (![self isPlayersTurn] || _isWaitingForMoveToBeSent) {
    return;
  }

  TicTacToeSquareState state = [self.boardState stateForSquareAtRow:row
                                                             column:column];
  if (state == kTicTacToeSquareStateEmpty) {
    [_messageStream makeMoveAtRow:row column:column];
    _isWaitingForMoveToBeSent = YES;
  }
}

@end
