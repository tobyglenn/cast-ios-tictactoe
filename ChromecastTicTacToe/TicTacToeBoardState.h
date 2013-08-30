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

#import <Foundation/Foundation.h>

/**
 * Possible states for a square in the Tic-Tac-Toe grid.
 */
typedef NS_ENUM(NSInteger, TicTacToeSquareState) {
  kTicTacToeSquareStateEmpty,
  kTicTacToeSquareStateX,
  kTicTacToeSquareStateO,
};

/**
 * The number of squares on one side of the board.
 */
const NSUInteger kTicTacToeBoardSize;

/**
 * Represents the current state of a Tic-Tac-Toe board.
 */
@interface TicTacToeBoardState : NSObject

/**
 * Updates the state at the given square.
 */
- (void)setState:(TicTacToeSquareState)state
  forSquareAtRow:(NSUInteger)row
          column:(NSUInteger)column;

/**
 * Returns the state of the given square.
 */
- (TicTacToeSquareState)stateForSquareAtRow:(NSUInteger)row
                                     column:(NSUInteger)column;

/**
 * Clears all moves from the board.
 */
- (void)clear;

@end
