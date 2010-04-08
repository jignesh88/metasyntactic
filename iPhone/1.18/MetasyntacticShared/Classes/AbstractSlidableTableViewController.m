// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AbstractSlidableTableViewController.h"


@implementation AbstractSlidableTableViewController

- (BOOL) cacheTableViews {
  return NO;
}


- (void) moveTo:(UITableView*) newTableView finalFrame:(CGRect) finalFrame {
  UITableView* currentTableView = self.tableView;
  CGRect currentTableFrame = currentTableView.frame;
  CGRect newTableFrame = currentTableFrame;

  if (finalFrame.origin.x < 0) {
    // we're moving to the right
    newTableFrame.origin.x = newTableFrame.size.width;
  } else {
    // we're moving to the left
    newTableFrame.origin.x = -newTableFrame.size.width;
  }

  newTableView.frame = newTableFrame;
  [self.tableView.superview addSubview:newTableView];

  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
  [UIView beginAnimations:nil context:newTableView];
  {
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

    currentTableView.frame = finalFrame;
    newTableView.frame = currentTableFrame;
  }
  [UIView commitAnimations];
}


- (void) animationDidStop:(NSString*) animationID finished:(NSNumber*) finished context:(void*) context {
  UITableView* newTableView = context;
  CGRect frame = newTableView.frame;
  self.tableView = newTableView;
  newTableView.frame = frame;
  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void) moveBackward:(UITableView*) previousTableView {
  CGRect finalFrame = self.tableView.frame;
  finalFrame.origin.x = finalFrame.size.width;

  [self moveTo:previousTableView finalFrame:finalFrame];
}


- (void) moveForward:(UITableView*) nextTableView {
  CGRect finalFrame = self.tableView.frame;
  finalFrame.origin.x = -finalFrame.size.width;

  [self moveTo:nextTableView finalFrame:finalFrame];
}

@end
