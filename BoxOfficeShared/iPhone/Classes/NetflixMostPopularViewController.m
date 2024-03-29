// Copyright 2010 Cyrus Najmabadi
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#import "NetflixMostPopularViewController.h"

#import "NetflixMostPopularMoviesViewController.h"

@interface NetflixMostPopularViewController()
@property (retain) NSDictionary* titleToCount;
@end


@implementation NetflixMostPopularViewController

@synthesize titleToCount;

- (void) dealloc {
  self.titleToCount = nil;

  [super dealloc];
}


- (id) init {
  if ((self = [super initWithStyle:UITableViewStylePlain])) {
    self.title = LocalizedString(@"Most Popular", nil);
  }

  return self;
}


- (void) onBeforeReloadTableViewData {
  [super onBeforeReloadTableViewData];
  NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
  for (NSString* title in [NetflixRssCache mostPopularTitles]) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    {
      NSInteger count = [[NetflixRssCache cache] movieCountForRSSTitle:title];
      if (count > 0) {
        [dictionary setObject:[NSNumber numberWithInteger:count] forKey:title];
      }
    }
    [pool release];
  }
  self.titleToCount = dictionary;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
  return MAX([[NetflixRssCache mostPopularTitles] count], 1);
}


- (NSInteger)     tableView:(UITableView*) tableView
      numberOfRowsInSection:(NSInteger) section {
  NSString* title = [[NetflixRssCache mostPopularTitles] objectAtIndex:section];
  NSNumber* count = [titleToCount objectForKey:title];

  return count == nil ? 0 : 1;
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
  static NSString* reuseIdentifier = @"reuseIdentifier";

  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumFontSize = 12;
  }

  NSString* title = [[NetflixRssCache mostPopularTitles] objectAtIndex:indexPath.section];
  NSNumber* count = [titleToCount objectForKey:title];

  cell.textLabel.text = [NSString stringWithFormat:LocalizedString(@"%@ (%@)", nil), title, count];

  return cell;
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
  NSString* title = [[NetflixRssCache mostPopularTitles] objectAtIndex:indexPath.section];

  NetflixMostPopularMoviesViewController* controller = [[[NetflixMostPopularMoviesViewController alloc] initWithCategory:title] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
  if (section == 0 && titleToCount.count == 0) {
    if ([[OperationQueue operationQueue] hasPriorityOperations]) {
      return LocalizedString(@"Downloading data", nil);
    }

    return [NetflixCache noInformationFound];
  }

  return nil;
}

@end
