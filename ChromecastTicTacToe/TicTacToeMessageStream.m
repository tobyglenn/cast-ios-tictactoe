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

#import "TicTacToeMessageStream.h"

static NSString * const kNamespace = @"com.google.chromecast.demo.tictactoe";

static NSString * const kKeyColumn = @"column";
static NSString * const kKeyCommand = @"command";
static NSString * const kKeyEndState = @"end_state";
static NSString * const kKeyEvent = @"event";
static NSString * const kKeyGameOver = @"game_over";
static NSString * const kKeyMessage = @"message";
static NSString * const kKeyName = @"name";
static NSString * const kKeyOpponent = @"opponent";
static NSString * const kKeyPlayer = @"player";
static NSString * const kKeyRow = @"row";
static NSString * const kKeyWinningLocation = @"winning_location";

static NSString * const kValueCommandJoin = @"join";
static NSString * const kValueCommandLeave = @"leave";
static NSString * const kValueCommandMove = @"move";

static NSString * const kValueEventEndgame = @"endgame";
static NSString * const kValueEventError = @"error";
static NSString * const kValueEventJoined = @"joined";
static NSString * const kValueEventMoved = @"moved";

static NSString * const kValueEndgameAbandoned = @"abandoned";
static NSString * const kValueEndgameDraw = @"draw";
static NSString * const kValueEndgameOWon = @"O-won";
static NSString * const kValueEndgameXWon = @"X-won";

static NSString * const kValuePlayerO = @"O";
static NSString * const kValuePlayerX = @"X";

@interface TicTacToeMessageStream () {
  BOOL _joined;
}

@property(nonatomic, strong, readwrite) id<TicTacToeMessageStreamDelegate> delegate;
@property(nonatomic, readwrite) TicTacToePlayer player;

@end

@implementation TicTacToeMessageStream

- (id)initWithDelegate:(id<TicTacToeMessageStreamDelegate>)delegate {
  if (self = [super initWithNamespace:kNamespace]) {
    _delegate = delegate;
    _joined = NO;
  }
  return self;
}

- (BOOL)joinGameWithName:(NSString *)name {
  NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
  [payload gck_setStringValue:kValueCommandJoin forKey:kKeyCommand];
  [payload gck_setStringValue:name forKey:kKeyName];

  return [self sendMessage:payload];
}

- (BOOL)makeMoveAtRow:(NSUInteger)row column:(NSUInteger)column {
  if ((row > 2) || (column > 2)) return NO;

  NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
  [payload gck_setStringValue:kValueCommandMove forKey:kKeyCommand];
  [payload gck_setIntegerValue:(NSInteger)row forKey:kKeyRow];
  [payload gck_setIntegerValue:(NSInteger)column forKey:kKeyColumn];

  return [self sendMessage:payload];
}

- (BOOL)leaveGame {
  NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
  [payload gck_setStringValue:kValueCommandLeave forKey:kKeyCommand];

  return [self sendMessage:payload];
}

- (void)didReceiveMessage:(id)message {
  NSDictionary *payload = message;

  NSString *event = [payload gck_stringForKey:kKeyEvent];
  if (!event) {
    NSLog(@"received invalid message: %@", [GCKJsonUtils writeJson:payload]);
    return;
  }

  if ([event isEqualToString:kValueEventJoined]) {
    NSString *playerValue = [payload gck_stringForKey:kKeyPlayer];
    TicTacToePlayer player;
    if ([playerValue isEqualToString:kValuePlayerO]) {
      player = kPlayerO;
    } else if ([playerValue isEqualToString:kValuePlayerX]) {
      player = kPlayerX;
    } else {
      NSLog(@"received invalid message: %@", [GCKJsonUtils writeJson:payload]);
      return;
    }
    NSString *opponentName = [payload gck_stringForKey:kKeyOpponent];

    _joined = YES;
    self.player = player;

    [self.delegate didJoinGameAsPlayer:player withOpponentNamed:opponentName];
  } else if ([event isEqualToString:kValueEventMoved]) {
    NSString *playerValue = [payload gck_stringForKey:kKeyPlayer];
    TicTacToePlayer player;
    if ([playerValue isEqualToString:kValuePlayerO]) {
      player = kPlayerO;
    } else if ([playerValue isEqualToString:kValuePlayerX]) {
      player = kPlayerX;
    } else {
      NSLog(@"received invalid message: %@", [GCKJsonUtils writeJson:payload]);
      return;
    }
    NSInteger row = [payload gck_integerForKey:kKeyRow];
    NSInteger column = [payload gck_integerForKey:kKeyColumn];
    if ((row > 2) || (column > 2)) {
      NSLog(@"received invalid message: %@", [GCKJsonUtils writeJson:payload]);
      return;
    }
    BOOL isFinal = [payload gck_boolForKey:kKeyGameOver];

    [self.delegate didReceiveMoveByPlayer:player atRow:row column:column isFinal:isFinal];
  } else if ([event isEqualToString:kValueEventError]) {
    NSString *errorMessage = [payload gck_stringForKey:kKeyMessage];
    if (!_joined) {
      [self.delegate didFailToJoinWithErrorMessage:errorMessage];
    } else {
      [self.delegate didReceiveErrorMessage:errorMessage];
    }
  } else if ([event isEqualToString:kValueEventEndgame]) {
    NSString *stateValue = [payload gck_stringForKey:kKeyEndState];

    GameResult result;
    if ([stateValue isEqualToString:kValueEndgameOWon]) {
      result = (self.player == kPlayerO) ? kResultYouWon : kResultYouLost;
    } else if ([stateValue isEqualToString:kValueEndgameXWon]) {
      result = (self.player == kPlayerX) ? kResultYouWon : kResultYouLost;
    } else if ([stateValue isEqualToString:kValueEndgameDraw]) {
      result = kResultDraw;
    } else if ([stateValue isEqualToString:kValueEndgameAbandoned]) {
      result = kResultAbandoned;
    } else {
      NSLog(@"received invalid message: %@", [GCKJsonUtils writeJson:payload]);
      return;
    }

    NSInteger winningLocation = [payload gck_integerForKey:kKeyWinningLocation];

    _joined = NO;
    [self.delegate didEndGameWithResult:result winningLocation:winningLocation];
  }
}

- (void)didDetach {
  _joined = NO;
}

@end
