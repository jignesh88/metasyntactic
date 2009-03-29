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

#import "TicketsViewController.h"

#import "AbstractNavigationController.h"
#import "AppDelegate.h"
#import "Application.h"
#import "AttributeCell.h"
#import "ColorCache.h"
#import "DataProvider.h"
#import "DateUtilities.h"
#import "LookupResult.h"
#import "Model.h"
#import "Movie.h"
#import "Performance.h"
#import "SearchDatePickerViewController.h"
#import "StringUtilities.h"
#import "Theater.h"
#import "UITableViewCell+Utilities.h"
#import "Utilities.h"
#import "ViewControllerUtilities.h"
#import "WarningView.h"


@interface TicketsViewController()
@property (retain) Movie* movie;
@property (retain) Theater* theater;
@property (retain) NSArray* performances;
@end


@implementation TicketsViewController

@synthesize theater;
@synthesize movie;
@synthesize performances;

- (void) dealloc {
    self.theater = nil;
    self.movie = nil;
    self.performances = nil;

    [super dealloc];
}


- (Model*) model {
    return [Model model];
}


- (void) initializeData {
    NSArray* allPerformances =  [self.model moviePerformances:movie forTheater:theater];
    NSMutableArray* result = [NSMutableArray array];

    NSDate* now = [DateUtilities currentTime];

    for (Performance* performance in allPerformances) {
        if ([DateUtilities isToday:self.model.searchDate]) {
            NSDate* time = performance.time;

            // skip times that have already passed.
            if ([now compare:time] == NSOrderedDescending) {

                // except for times that are before 4 AM
                NSDateComponents* components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit
                                                                               fromDate:time];
                if (components.hour > 4) {
                    continue;
                }
            }
        }

        [result addObject:performance];
    }

    self.performances = result;
}


- (void) minorRefreshWorker {
}


- (void) majorRefreshWorker {
    [self initializeData];
    [self reloadTableViewData];
}


- (id) initWithController:(AbstractNavigationController*) navigationController_
                  theater:(Theater*) theater__
                    movie:(Movie*) movie__
                    title:(NSString*) title_ {
    if (self = [super initWithStyle:UITableViewStyleGrouped navigationController:navigationController_]) {
        self.theater = theater__;
        self.movie = movie__;
        self.title = title_;
    }

    return self;
}


- (void) loadView {
    [super loadView];

    UILabel* label = [ViewControllerUtilities viewControllerTitleLabel];
    label.text = self.title;

    self.navigationItem.titleView = label;
}


- (void) didReceiveMemoryWarningWorker {
    [super didReceiveMemoryWarningWorker];
    self.performances = nil;
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:[AppDelegate globalActivityView]] autorelease];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 3;
}


- (NSInteger)       tableView:(UITableView*) tableView
        numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        if (theater.phoneNumber.length == 0) {
            return 1;
        } else {
            return 2;
        }
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return performances.count;
    }

    return 0;
}


- (NSString*)       tableView:(UITableView*) tableView
      titleForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return nil;
    } else if (section == 2 && performances.count) {
        if ([DateUtilities isToday:self.model.searchDate]) {
            return NSLocalizedString(@"Today", nil);
        } else {
            return [DateUtilities formatFullDate:self.model.searchDate];
        }
    }

    return nil;
}


- (UIView*)        tableView:(UITableView*) tableView
      viewForFooterInSection:(NSInteger) section {
    if (section == 1) {
        if (performances.count > 0 ) {
            if ([self.model isStale:theater]) {
                return [WarningView viewWithText:[self.model showtimesRetrievedOnString:theater]];
            }
        }
    }

    return nil;
}

- (CGFloat)          tableView:(UITableView*) tableView
      heightForFooterInSection:(NSInteger) section {
    WarningView* view = (id)[self tableView:tableView viewForFooterInSection:section];
    if (view != nil) {
        return view.height;
    }

    return -1;
}


- (UITableViewCell*) showtimeCellForSection:(NSInteger) section
                                        row:(NSInteger) row {
    static NSString* reuseIdentifier = @"reuseIdentifier";

    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:reuseIdentifier] autorelease];

        cell.textAlignment = UITextAlignmentCenter;
        cell.font = [UIFont boldSystemFontOfSize:14];
    }

    Performance* performance = [performances objectAtIndex:row];

    if (performance.url.length == 0) {
        cell.textColor = [UIColor blackColor];
        cell.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (No Online Ticketing)", nil),
                     performance.timeString];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.textColor = [ColorCache commandColor];
        cell.text = [NSString stringWithFormat:NSLocalizedString(@"Order tickets for %@", nil),
                     performance.timeString];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    return cell;
}


- (UITableViewCell*) commandCellForRow:(NSInteger) row {
#ifdef IPHONE_OS_VERSION_3
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                    reuseIdentifier:nil] autorelease];
#else
    AttributeCell* cell = [[[AttributeCell alloc] init] autorelease];
#endif


    if (row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Map", @"This string should try to be short.  So abbreviations are acceptable. It's a verb that means 'open a map to the currently listed address'");
        cell.detailTextLabel.text = [self.model simpleAddressForTheater:theater];
    } else {
        cell.textLabel.text = NSLocalizedString(@"Call", @"This string should try to be short.  So abbreviations are acceptable. It's a verb that means 'to make a phonecall'");
        cell.detailTextLabel.text = theater.phoneNumber;
    }

    return cell;
}


- (UITableViewCell*) infoCellForRow:(NSInteger) row {
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];

    cell.textAlignment = UITextAlignmentCenter;
    cell.font = [UIFont boldSystemFontOfSize:14];
    cell.textColor = [ColorCache commandColor];

    if (row == 0) {
        cell.text = NSLocalizedString(@"E-mail listings", @"This string must it on a button half the width of the screen.  It means 'email the theater listings to a friend'");
    } else {
        cell.text = NSLocalizedString(@"Change date", nil);
    }

    return cell;
}


- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        return [self commandCellForRow:indexPath.row];
    } else if (indexPath.section == 1) {
        return [self infoCellForRow:indexPath.row];
    } else if (indexPath.section == 2 || indexPath.section == 3) {
        return [self showtimeCellForSection:indexPath.section row:indexPath.row];
    }

    return nil;
}


- (void) didSelectCommandAtRow:(NSInteger) row {
    if (row == 0) {
        [Application openMap:theater.mapUrl];
    } else if (row == 1) {
        [Application makeCall:theater.phoneNumber];
    }
}


- (void) didSelectShowtimeAtRow:(NSInteger) row {
    Performance* performance = [performances objectAtIndex:row];

    if (performance.url.length == 0) {
        return;
    }

    [abstractNavigationController pushBrowser:performance.url animated:YES];
}


- (void) didSelectEmailListings {
    NSString* subject = [NSString stringWithFormat:@"%@ - %@",
                                movie.canonicalTitle,
                                [DateUtilities formatFullDate:self.model.searchDate]];
    NSMutableString* body = [NSMutableString string];

    [body appendString:@"<p>"];
    [body appendString:theater.name];
    [body appendString:@"<br/>"];
    [body appendString:@"<a href=\""];
    [body appendString:theater.mapUrl];
    [body appendString:@"\">"];
    [body appendString:[self.model simpleAddressForTheater:theater]];
    [body appendString:@"</a>"];

    [body appendString:@"<p>"];
    [body appendString:movie.canonicalTitle];
    [body appendString:@"<br/>"];

    [body appendString:[Utilities generateShowtimeLinks:self.model
                                                  movie:movie
                                                theater:theater
                                           performances:performances]];

    [self openMailWithSubject:subject body:body];
}


- (void) didSelectInfoCellAtRow:(NSInteger) row {
    if (row == 0) {
        [self didSelectEmailListings];
    } else {
        [self changeDate];
    }
}


- (void) onDataProviderUpdateSuccess:(LookupResult*) lookupResult context:(id) array {
    if (updateId != [[array objectAtIndex:0] intValue]) {
        return;
    }

    NSDate* searchDate = [array lastObject];

    NSArray* lookupResultPerformances = [[lookupResult.performances objectForKey:theater.name] objectForKey:movie.canonicalTitle];

    if (lookupResultPerformances.count == 0) {
        NSString* text =
        [NSString stringWithFormat:
         NSLocalizedString(@"No listings found for '%@' at '%@' on %@", @"No listings found for 'The Dark Knight' at 'Regal Meridian 6' on 5/18/2008"),
         movie.canonicalTitle,
         theater.name,
         [DateUtilities formatShortDate:searchDate]];

        [self onDataProviderUpdateFailure:text context:array];
    } else {
        // find the up to date version of this theater and movie
        self.theater = [lookupResult.theaters objectAtIndex:[lookupResult.theaters indexOfObject:theater]];
        self.movie = [lookupResult.movies objectAtIndex:[lookupResult.movies indexOfObject:movie]];

        [super onDataProviderUpdateSuccess:lookupResult context:array];
    }
}


- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        [self didSelectCommandAtRow:indexPath.row];
    } else if (indexPath.section == 1) {
        [self didSelectInfoCellAtRow:indexPath.row];
    } else if (indexPath.section == 2) {
        [self didSelectShowtimeAtRow:indexPath.row];
    }
}

@end