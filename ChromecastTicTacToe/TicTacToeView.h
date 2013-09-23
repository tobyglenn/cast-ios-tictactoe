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

@class TicTacToeBoardState;

typedef NS_ENUM(NSInteger, TicTacToeWinType) {
  kTicTacToeWinTypeNone,
  kTicTacToeWinTypeRow,
  kTicTacToeWinTypeColumn,
  kTicTacToeWinTypeDiagonalFromTopLeft,
  kTicTacToeWinTypeDiagonalFromBottomLeft
};

@protocol TicTacToeViewDelegate;


// Shows a simple Tic-Tac-Toe board.
@interface TicTacToeView : UIView

@property(nonatomic, weak) id<TicTacToeViewDelegate> delegate;

@property(nonatomic, strong) TicTacToeBoardState *board;

// Shows the strikethrough line that indicates a win. Use kTicTacToeWinTypeNone
// to clear. The index is the row for the row type, the column for the column
// type, and ignored for the other types.
- (void)showWinningStrikethroughOfType:(TicTacToeWinType)winType
                               atIndex:(NSUInteger)index;

@end

@protocol TicTacToeViewDelegate <NSObject>

// Callback when a Tic-Tac-Toe square is tapped.
- (void)didTapTicTacToeView:(TicTacToeView *)view
                      atRow:(NSUInteger)row
                     column:(NSUInteger)column;

@end
