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

#import <GCKFramework/GCKFramework.h>

/**
 * Player symbols.
 */
typedef NS_ENUM(char, TicTacToePlayer) {
  /** Player 'X'. */
  kPlayerX = 'X',
  /** Player 'O'. */
  kPlayerO = 'O'
};

/**
 * Possible endgame results.
 */
typedef NS_ENUM(NSInteger, GameResult) {
  /** This player won. */
  kResultYouWon,
  /** The opponent won. */
  kResultYouLost,
  /** The game resulted in a draw. */
  kResultDraw,
  /** One of the players abandoned the game before it was completed. */
  kResultAbandoned
};

/**
 * Delegate protocol for TicTacToeMessageStream.
 */
@protocol TicTacToeMessageStreamDelegate

/**
 * Called when a game has been successfully joined.
 *
 * @param player The symbol that was assigned to this player.
 * @param opponent The name of the opponent.
 */
- (void)didJoinGameAsPlayer:(TicTacToePlayer)player
          withOpponentNamed:(NSString *)opponent;

/**
 * Called when the game could not be joined.
 *
 * @param message The error message describing the failure.
 */
- (void)didFailToJoinWithErrorMessage:(NSString *)message;

/**
 * Called when a move is completed by either player.
 *
 * @param player The player that made the move.
 * @param row The board row of the move.
 * @param column The board column of the move.
 * @param isFinal If <code>YES</code>, no more moves are possible in this game.
 */
- (void)didReceiveMoveByPlayer:(TicTacToePlayer)player
                         atRow:(NSInteger)row
                        column:(NSInteger)column
                       isFinal:(BOOL)isFinal;

/**
 * Called when an error occurs during gameplay.
 *
 * @param message The error message.
 */
- (void)didReceiveErrorMessage:(NSString *)message;

/**
 * Called when the game has ended.
 *
 * @param result The result.
 * @param winningLocation The winning location: 0 indicates none; 1-3 indicates rows 1-3;
 * 4-6 indicates columns 1-3; 5 indicates diagonal from top-left corner; 6 indicates
 * diagonal from bottom-left corner.
 */
- (void)didEndGameWithResult:(GameResult)result
             winningLocation:(NSInteger)winningLocation;

@end

/**
 * A MessageStream implementation for a two-player TicTacToe game.
 */
@interface TicTacToeMessageStream : GCKMessageStream

@property(nonatomic, readonly) TicTacToePlayer player;

/**
 * Designated initializer. Constructs a TicTacToeMessageStream with the given delegate.
 *
 * @param delegate The delegate that will receive notifications.
 */
- (id)initWithDelegate:(id<TicTacToeMessageStreamDelegate>)delegate;

/**
 * Joins a new game.
 *
 * @param name The name of this player.
 * @return <code>YES</code> if the request was made, <code>NO</code> if it couldn't be sent.
 */
- (BOOL)joinGameWithName:(NSString *)name;

/**
 * Makes a move on the board.
 *
 * @param row The row of the move.
 * @param column The column of the move.
 * @return <code>YES</code> if the request was made, <code>NO</code> if it couldn't be sent.
 */
- (BOOL)makeMoveAtRow:(NSUInteger)xpos column:(NSUInteger)column;

/**
 * Leaves the current game. If a game is in progress this will forfeit the game.
 *
 * @return <code>YES</code> if the request was made, <code>NO</code> if it couldn't be sent.
 */
- (BOOL)leaveGame;

- (void)didReceiveMessage:(id)message;

- (void)didDetach;

@end
