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

#import "TicTacToeBoardState.h"

const NSUInteger kTicTacToeBoardSize = 3;

@interface TicTacToeBoardState () {
  NSArray *_rows;
}

@end

@implementation TicTacToeBoardState

- (id)init {
  if (self = [super init]) {
    [self clear];
  }
  return self;
}

- (void)clear {
  NSMutableArray *rows = [NSMutableArray arrayWithCapacity:kTicTacToeBoardSize];
  for (NSUInteger rowIndex = 0; rowIndex < kTicTacToeBoardSize; ++rowIndex) {
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:kTicTacToeBoardSize];
    for (NSUInteger columnIndex = 0; columnIndex < kTicTacToeBoardSize; ++columnIndex) {
      NSNumber *number = [NSNumber numberWithInteger:kTicTacToeSquareStateEmpty];
      [columns addObject:number];
    }
    [rows addObject:columns];
  }
  _rows = rows;
}

- (void)setState:(TicTacToeSquareState)state
  forSquareAtRow:(NSUInteger)row
          column:(NSUInteger)column {
  NSNumber *number = [NSNumber numberWithInteger:state];
  NSMutableArray *columns = [_rows objectAtIndex:row];
  [columns replaceObjectAtIndex:column withObject:number];
}

- (TicTacToeSquareState)stateForSquareAtRow:(NSUInteger)row
                                     column:(NSUInteger)column {
  NSNumber *number = [[_rows objectAtIndex:row] objectAtIndex:column];
  return [number integerValue];
}

- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:[TicTacToeBoardState class]]) {
    return false;
  }
  TicTacToeBoardState *otherState = (TicTacToeBoardState *)object;
  for (NSUInteger row = 0; row < kTicTacToeBoardSize; ++row) {
    for (NSUInteger column = 0; column < kTicTacToeBoardSize; ++column) {
      if ([self stateForSquareAtRow:row column:column] !=
          [otherState stateForSquareAtRow:row column:column]) {
        return NO;
      }
    }
  }
  return YES;
}

@end
