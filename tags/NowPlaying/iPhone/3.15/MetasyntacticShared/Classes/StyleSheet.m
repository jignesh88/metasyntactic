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

#import "StyleSheet.h"

#import "UIColor+Utilities.h"

@interface StyleSheet()
@property BOOL disabled;
@end


@implementation StyleSheet

static StyleSheet* styleSheet;

+ (void) initialize {
  if (self == [StyleSheet class]) {
    styleSheet = [[StyleSheet alloc] init];
  }
}

@synthesize disabled;

- (void) dealloc {
  self.disabled = NO;
  [super dealloc];
}


+ (void) enableTheming {
  styleSheet.disabled = NO;
}


+ (void) disableTheming {
  styleSheet.disabled = YES;
}


+ (UIBarStyle) barStyleFromString:(NSString*) string {
  if ([@"UIBarStyleBlack" isEqual:string]) {
    return UIBarStyleBlack;
  } else {
    return UIBarStyleDefault;
  }
}


+ (UIBarStyle) navigationBarStyle {
  return [self barStyleFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UINavigationBarStyle"]];
}


+ (UIBarStyle) searchBarStyle {
  return [self barStyleFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISearchBarStyle"]];
}


+ (UIBarStyle) toolBarStyle {
  return [self barStyleFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIToolBarStyle"]];
}


+ (BOOL) toolBarTranslucent {
  return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIToolBarTranslucent"] boolValue];
}


+ (UIColor*) tableViewGroupedHeaderColor {
  return [UIColor fromHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UITableViewGroupedHeaderColor"]];
}


+ (UIColor*) tableViewGroupedFooterColor {
  return [UIColor fromHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UITableViewGroupedFooterColor"]];
}


- (UIColor*) navigationBarTintColor {
  if (self.disabled) {
    return nil;
  }

  return [UIColor fromHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UINavigationBarTintColor"]];
}


+ (UIColor*) navigationBarTintColor {
  return [styleSheet navigationBarTintColor];
}


- (UIColor*) segmentedControlTintColor {
  if (self.disabled) {
    return nil;
  }

  return [UIColor fromHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISegmentedControlTintColor"]];
}


+ (UIColor*) segmentedControlTintColor {
  return [styleSheet segmentedControlTintColor];
}


- (UIColor*) searchBarTintColor {
  if (self.disabled) {
    return nil;
  }

  return [UIColor fromHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISearchBarTintColor"]];
}


+ (UIColor*) searchBarTintColor {
  return [styleSheet searchBarTintColor];
}


+ (UIColor*) actionButtonTextColor {
  return [UIColor fromHexString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ActionButtonTextColor"]];
}


+ (UIStatusBarStyle) statusBarStyle {
  id value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarStyle"];
  if ([@"UIStatusBarStyleBlackOpaque" isEqual:value]) {
    return UIStatusBarStyleBlackOpaque;
  } else if ([@"UIStatusBarStyleBlackTranslucent" isEqual:value]) {
    return UIStatusBarStyleBlackTranslucent;
  } else {
    return UIStatusBarStyleDefault;
  }
}

@end