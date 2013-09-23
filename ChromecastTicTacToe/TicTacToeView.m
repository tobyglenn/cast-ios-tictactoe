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

#import "TicTacToeView.h"

#import "TicTacToeBoardState.h"

@interface TicTacToeView () {
  TicTacToeWinType _winType;
  NSUInteger _winIndex;
}

@end

static inline CGFloat RowHeightFromRect(CGRect rect) {
  return rect.size.height / kTicTacToeBoardSize;
}

static inline CGFloat ColumnWidthFromRect(CGRect rect) {
  return rect.size.width / kTicTacToeBoardSize;
}

@implementation TicTacToeView

- (void)setBoard:(TicTacToeBoardState *)board {
  _board = board;
  [self setNeedsDisplay];
}

- (void)showWinningStrikethroughOfType:(TicTacToeWinType)winType
                               atIndex:(NSUInteger)index {
  _winType = winType;
  _winIndex = index;
  [self setNeedsDisplay];
}

#pragma mark - Touch events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  for (UITouch *touch in touches) {
    // Respond only to single taps.
    if (touch.tapCount == 1) {
      CGPoint location = [touch locationInView:self];
      NSInteger row = (NSInteger)(location.y / RowHeightFromRect(self.frame));
      NSInteger column = (NSInteger)(location.x / ColumnWidthFromRect(self.frame));
      NSAssert(0 <= row && row < (NSInteger)kTicTacToeBoardSize,
               @"Row out of range: %ld", (long) row);
      NSAssert(0 <= column && column < (NSInteger)kTicTacToeBoardSize,
               @"Column out of range: %ld", (long) column);

      id<TicTacToeViewDelegate> receiver = self.delegate;
      [receiver didTapTicTacToeView:self
                              atRow:(NSUInteger)row
                             column:(NSUInteger)column];
    }
  }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
  [[UIColor whiteColor] setFill];
  UIRectFill(rect);

  // The play area is square, so we draw in the largest centered square
  // possible in the given rect.
  CGFloat sideLength = MIN(rect.size.width, rect.size.height);
  CGFloat xOffset = (rect.size.width - sideLength) / 2.0f;
  CGFloat yOffset = (rect.size.height - sideLength) / 2.0f;
  CGRect gridRect = CGRectMake(rect.origin.x + xOffset,
                               rect.origin.y + yOffset,
                               sideLength,
                               sideLength);

  CGContextRef context = UIGraphicsGetCurrentContext();
  [self drawGridInRect:gridRect context:context];

  if (!self.board) {
    return;
  }

  for (NSUInteger row = 0; row < kTicTacToeBoardSize; ++row) {
    for (NSUInteger column = 0; column < kTicTacToeBoardSize; ++column) {
      TicTacToeSquareState state = [self.board stateForSquareAtRow:row
                                                            column:column];
      switch (state) {
        case kTicTacToeSquareStateX:
          [self drawXInRect:gridRect atRow:row column:column context:context];
          break;

        case kTicTacToeSquareStateO:
          [self drawOInRect:gridRect atRow:row column:column context:context];
          break;

        default:
          // Don't draw anything for an empty square.
          break;
      }
    }
  }

  [self drawWinStrikethroughInRect:rect context:context];
}

// Draws a square grid with evenly spaced lines such that there are
// kTicTacToeBoardSize rows and columns of squares.
- (void)drawGridInRect:(CGRect)rect context:(CGContextRef)context {
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetLineWidth(context, 2.0);
  CGContextBeginPath(context);

  // Row dividers.
  CGFloat rowHeight = RowHeightFromRect(rect);
  for (NSUInteger row = 1; row < kTicTacToeBoardSize; ++row) {
    CGFloat rowY = (rowHeight * row) + CGRectGetMinY(rect);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), rowY);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), rowY);
  }
  // Column dividers.
  CGFloat columnWidth = ColumnWidthFromRect(rect);
  for (NSUInteger column = 1; column < kTicTacToeBoardSize; ++column) {
    CGFloat rowX = (columnWidth * column) + CGRectGetMinX(rect);
    CGContextMoveToPoint(context, rowX, CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, rowX, CGRectGetMaxY(rect));
  }

  CGContextStrokePath(context);
}

// Draws a Tic-Tac-Toe "X" in the given row and column.
- (void)drawXInRect:(CGRect)rect
              atRow:(NSUInteger)row
             column:(NSUInteger)column
            context:(CGContextRef)context {
  CGRect xRect = [self rectForSquareInRect:rect atRow:row column:column];
  xRect = CGRectInset(xRect, 10, 10);

  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetLineWidth(context, 1.0);
  CGContextBeginPath(context);

  CGContextMoveToPoint(context, CGRectGetMinX(xRect), CGRectGetMinY(xRect));
  CGContextAddLineToPoint(context, CGRectGetMaxX(xRect), CGRectGetMaxY(xRect));
  CGContextMoveToPoint(context, CGRectGetMinX(xRect), CGRectGetMaxY(xRect));
  CGContextAddLineToPoint(context, CGRectGetMaxX(xRect), CGRectGetMinY(xRect));

  CGContextStrokePath(context);
}

// Draws a Tic-Tac-Toe "O" in the given row and column.
- (void)drawOInRect:(CGRect)rect
              atRow:(NSUInteger)row
             column:(NSUInteger)column
            context:(CGContextRef)context {
  CGRect oRect = [self rectForSquareInRect:rect atRow:row column:column];
  oRect = CGRectInset(oRect, 10, 10);

  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  CGContextSetLineWidth(context, 1.0);
  CGContextBeginPath(context);

  CGContextAddEllipseInRect(context, oRect);

  CGContextStrokePath(context);
}

// Returns the rect for the Tic-Tac-Toe square at the given row and column in a
// Tic-Tac-Toe grid of the given size.
- (CGRect)rectForSquareInRect:(CGRect)rect
                        atRow:(NSUInteger)row
                       column:(NSUInteger)column {
  CGFloat rowHeight = RowHeightFromRect(rect);
  CGFloat columnWidth = ColumnWidthFromRect(rect);

  return CGRectMake(rect.origin.x + (column * columnWidth),
                    rect.origin.y + (row * rowHeight),
                    columnWidth,
                    rowHeight);
}

// Draws the winning line strikethrough in the grid.
- (void)drawWinStrikethroughInRect:(CGRect)rect context:(CGContextRef)context {
  CGPoint startPoint, endPoint;
  switch (_winType) {
    case kTicTacToeWinTypeRow: {
      CGFloat rowHeight = RowHeightFromRect(rect);
      CGFloat rowCenter = (_winIndex * rowHeight) + (rowHeight / 2);
      startPoint = CGPointMake(CGRectGetMinX(rect), rowCenter);
      endPoint = CGPointMake(CGRectGetMaxX(rect), rowCenter);
      break;
    }

    case kTicTacToeWinTypeColumn: {
      CGFloat columnWidth = ColumnWidthFromRect(rect);
      CGFloat columnCenter = (_winIndex * columnWidth) + (columnWidth / 2);
      startPoint = CGPointMake(columnCenter, CGRectGetMinY(rect));
      endPoint = CGPointMake(columnCenter, CGRectGetMaxY(rect));
      break;
    }

    case kTicTacToeWinTypeDiagonalFromTopLeft:
      startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
      endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
      break;

    case kTicTacToeWinTypeDiagonalFromBottomLeft:
      startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
      endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
      break;

    default:
      return;
  }

  [[UIColor redColor] setStroke];
  CGContextSetLineWidth(context, 4.0);
  CGContextBeginPath(context);

  CGContextMoveToPoint(context, startPoint.x, startPoint.y);
  CGContextAddLineToPoint(context, endPoint.x, endPoint.y);

  CGContextStrokePath(context);
}

@end
