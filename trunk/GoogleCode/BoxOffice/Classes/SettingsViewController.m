//
//  SettingsViewController.m
//  BoxOffice
//
//  Created by Cyrus Najmabadi on 4/30/08.
//  Copyright 2008 Metasyntactic. All rights reserved.
//

#import "SettingsViewController.h"
#import "ApplicationTabBarController.h"
#import "BoxOfficeAppDelegate.h"
#import "XmlParser.h"
#import "TextFieldEditorViewController.h"
#import "PickerEditorViewController.h"
#import "Utilities.h"
#import "CreditsViewController.h"
#import "Application.h"

@implementation SettingsViewController

@synthesize navigationController;
@synthesize currentLocationItem;
@synthesize activityIndicator;
@synthesize locationManager;

- (void) dealloc {
    self.navigationController = nil;
    self.currentLocationItem = nil;
    self.activityIndicator = nil;
    self.locationManager = nil;
    
    [super dealloc];
}

- (id) initWithNavigationController:(SettingsNavigationController*) controller {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = NSLocalizedString(@"Settings", nil);
        self.navigationController = controller;
        
        self.currentLocationItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CurrentPosition.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onCurrentLocationClicked:)] autorelease];

        self.navigationItem.leftBarButtonItem = currentLocationItem;
        
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    return self;
}

- (void) viewWillAppear:(BOOL) animated {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.model.activityView] autorelease];
}

- (void) onCurrentLocationClicked:(id) sender {
    self.activityIndicator = [[[ActivityIndicator alloc] initWithNavigationItem:self.navigationItem] autorelease];
    [self.activityIndicator start];
    
    [self.locationManager startUpdatingLocation];
}

- (void) stopActivityIndicator {
    [self.activityIndicator stop];    
    self.activityIndicator = nil;
}

- (void) locationManager:(CLLocationManager*) manager
     didUpdateToLocation:(CLLocation*) newLocation
            fromLocation:(CLLocation*) oldLocation {
    if (oldLocation != nil) {
        [locationManager stopUpdatingLocation];
        [self performSelectorInBackground:@selector(findPostalCodeBackgroundEntryPoint:) withObject:newLocation];
    }
}

- (void) findPostalCodeBackgroundEntryPoint:(CLLocation*) location {
    NSAutoreleasePool* autoreleasePool= [[NSAutoreleasePool alloc] init];
    
    [self findPostalCode:location];
    
    [autoreleasePool release];
}

- (NSString*) findUSPostalCode:(CLLocation*) location {
    CLLocationCoordinate2D coordinates = [location coordinate];
    double latitude = coordinates.latitude;
    double longitude = coordinates.longitude;
    NSString* urlString = [NSString stringWithFormat:@"http://ws.geonames.org/findNearbyPostalCodes?lat=%f&lng=%f&maxRows=1", latitude, longitude];
    
    XmlElement* geonamesElement = [Utilities downloadXml:urlString];
    XmlElement* codeElement = [geonamesElement element:@"code"];
    XmlElement* postalElement = [codeElement element:@"postalcode"];
    XmlElement* countryElement = [codeElement element:@"countryCode"];
    
    if ([@"CA" isEqual:countryElement.text]) {
        return nil;
    }
    
    return [postalElement text];
}
    
- (NSString*) findCAPostalCode:(CLLocation*) location {
    CLLocationCoordinate2D coordinates = [location coordinate];
    double latitude = coordinates.latitude;
    double longitude = coordinates.longitude;    
    NSString* urlString = [NSString stringWithFormat:@"http://geocoder.ca/?latt=%f&longt=%f&geoit=xml&reverse=Reverse+GeoCode+it", latitude, longitude];
    
    XmlElement* geodataElement = [Utilities downloadXml:urlString];
    XmlElement* postalElement = [geodataElement element:@"postal"];
    return [postalElement text];
}

- (void) findPostalCode:(CLLocation*) location {
    NSString* postalCode = [self findUSPostalCode:location];
    if (postalCode == nil) {
        postalCode = [self findCAPostalCode:location];
    }
        
    [self performSelectorOnMainThread:@selector(reportFoundPostalCode:) withObject:postalCode waitUntilDone:NO];
}

- (void)locationManager:(CLLocationManager*) manager
       didFailWithError:(NSError*) error {
    [locationManager stopUpdatingLocation];
    [self stopActivityIndicator];
}

- (BoxOfficeModel*) model {
    return [self.navigationController model];
}

- (BoxOfficeController*) controller {
    return [self.navigationController controller];
}

- (void) refresh {
    [self.tableView reloadData];
}

- (UITableViewCellAccessoryType) tableView:(UITableView*) tableView
          accessoryTypeForRowWithIndexPath:(NSIndexPath*) indexPath {
    NSInteger section = [indexPath section];
    
    if (section == 3) {
        return UITableViewCellAccessoryNone;
    } else {
        return UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 4;
}

- (NSInteger)               tableView:(UITableView*) tableView
                numberOfRowsInSection:(NSInteger) section {
    return 1;
}

- (UITableViewCell*)                tableView:(UITableView*) tableView
                        cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    
    NSInteger section = [indexPath section];
    
    if (section == 0) {
        cell.text = [[self model] postalCode];
    } else if (section == 1) {
        cell.text = [NSString stringWithFormat:NSLocalizedString(@"%d miles", nil), [[self model] searchRadius]];
    } else if (section == 2) {
        cell.text = NSLocalizedString(@"About", nil);
    } else {
        cell.text = NSLocalizedString(@"Donate", nil);
        cell.textColor = [Application commandColor];
        cell.textAlignment = UITextAlignmentCenter;
    }
    
    return cell;
}

- (NSString*)               tableView:(UITableView*) tableView
              titleForHeaderInSection:(NSInteger) section {
    if (section == 0) {
        return NSLocalizedString(@"Postal code", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Search radius", nil);
    }
    
    return nil; 
}

- (void)            tableView:(UITableView*) tableView
      didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    NSInteger section = [indexPath section];
    
    if (section == 0) {
        TextFieldEditorViewController* controller = 
        [[[TextFieldEditorViewController alloc] initWithController:self.navigationController
                                                         withTitle:NSLocalizedString(@"PostalCode", nil)
                                                        withObject:self
                                                      withSelector:@selector(onPostalCodeChanged:)
                                                          withText:[self.model postalCode]
                                                          withType:UIKeyboardTypeNumbersAndPunctuation] autorelease];
        
        [self.navigationController pushViewController:controller animated:YES];
    } else if (section == 1) {
        NSArray* values = [NSArray arrayWithObjects:
                           @"1", @"2", @"3", @"4", @"5", 
                           @"10", @"15", @"20", @"25", @"30",
                           @"35", @"40", @"45", @"50", nil];
        NSString* defaultValue = [NSString stringWithFormat:@"%d", [self.model searchRadius]];
        
        PickerEditorViewController* controller = 
        [[[PickerEditorViewController alloc] initWithController:self.navigationController
                                                      withTitle:NSLocalizedString(@"Search radius", nil)
                                                     withObject:self
                                                   withSelector:@selector(onSearchRadiusChanged:)
                                                     withValues:values
                                                   defaultValue:defaultValue] autorelease];
        
        [self.navigationController pushViewController:controller animated:YES];
    } else if (section == 2) {
        CreditsViewController* controller = [[[CreditsViewController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (section == 3) {
        [Application openBrowser:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=cyrusn%40stwing%2eupenn%2eedu&item_name=iPhone%20Apps%20Donations&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"];
    }
}

- (void) onPostalCodeChanged:(NSString*) postalCode {
    NSMutableString* trimmed = [NSMutableString string];
    for (NSInteger i = 0; i < [postalCode length]; i++) {
        unichar c = [postalCode characterAtIndex:i];
        if (isalnum(c)) {
            [trimmed appendString:[NSString stringWithCharacters:&c length:1]];
        }
    }
    
    [self.controller setPostalCode:trimmed];
    [self.tableView reloadData];
}

- (void) reportFoundPostalCode:(NSString*) postalCode {
    [self stopActivityIndicator];
    
    if ([Utilities isNilOrEmpty:postalCode]) {
        return;
    }
    
    [self onPostalCodeChanged:postalCode];
}

- (void) onSearchRadiusChanged:(NSString*) radius {
    [self.controller setSearchRadius:[radius intValue]];
    [self.tableView reloadData];
}

@end
