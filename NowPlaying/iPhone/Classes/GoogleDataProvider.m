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

#import "GoogleDataProvider.h"

#import "Application.h"
#import "DateUtilities.h"
#import "FileUtilities.h"
#import "LocaleUtilities.h"
#import "Location.h"
#import "LookupResult.h"
#import "Model.h"
#import "Movie.h"
#import "NetworkUtilities.h"
#import "NowPlaying.pb.h"
#import "Performance.h"
#import "StringUtilities.h"
#import "Theater.h"
#import "Utilities.h"
#import "XmlElement.h"

@interface GoogleDataProvider()
@property (retain) NSCalendar* calendar;
@property (retain) NSDateComponents* dateComponents;
@end


@implementation GoogleDataProvider

@synthesize calendar;
@synthesize dateComponents;

- (void) dealloc {
    self.calendar = nil;
    self.dateComponents = nil;

    [super dealloc];
}


+ (GoogleDataProvider*) providerWithModel:(Model*) model {
    return [[[GoogleDataProvider alloc] initWithModel:model] autorelease];
}


- (NSDictionary*) processMovies:(NSArray*) movies {
    NSMutableDictionary* movieIdToMovieMap = [NSMutableDictionary dictionary];

    for (MovieProto* movieProto in movies) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        {
            NSString* identifier = movieProto.identifier;
            NSString* title = movieProto.title;
            NSString* rating = movieProto.rawRating;
            NSInteger length = movieProto.length;
            NSString* synopsis = movieProto.description;
            NSArray* genres =  [[movieProto.genre stringByReplacingOccurrencesOfString:@"_" withString:@" "] componentsSeparatedByString:@"/"];
            NSArray* directors = movieProto.directorList;
            NSArray* cast = movieProto.castList;
            NSString* releaseDateString = movieProto.releaseDate;
            NSDate* releaseDate = [DateUtilities parseIS08601Date:releaseDateString];

            NSString* imdbAddress = @"";
            if (movieProto.iMDbUrl.length > 0) {
                imdbAddress = [NSString stringWithFormat:@"http://www.imdb.com/title/%@", movieProto.iMDbUrl];
            }

            Movie* movie = [Movie movieWithIdentifier:identifier
                                                title:title
                                               rating:rating
                                               length:length
                                          releaseDate:releaseDate
                                          imdbAddress:imdbAddress
                                               poster:@""
                                             synopsis:synopsis
                                               studio:@""
                                            directors:directors
                                                 cast:cast
                                               genres:genres];

            [movieIdToMovieMap setObject:movie forKey:identifier];
        }
        [pool release];
    }

    return movieIdToMovieMap;
}


- (BOOL) hasTimeSuffix:(NSString*) time {
    return [time hasSuffix:@"am"] || [time hasSuffix:@"pm"];
}


- (BOOL) is24HourTime:(NSArray*) times {
    for (NSString* time in times) {
        if (time.length != 5 || [time rangeOfString:@":"].location != 2) {
            return NO;
        }
    }

    return YES;
}


- (BOOL) is12HourTime:(NSArray*) times {
    for (NSString* time in times) {
        if ([time rangeOfString:@":"].length == 0) {
            return NO;
        }
    }

    return YES;
}


- (NSArray*) process24HourTimes:(NSArray*) times {
    NSMutableArray* result = [NSMutableArray array];

    for (NSString* time in times) {
        NSInteger hour = [[time substringToIndex:2] intValue];
        NSInteger minute = [[time substringFromIndex:3] intValue];

        [dateComponents setHour:hour];
        [dateComponents setMinute:minute];

        NSDate* date = [calendar dateFromComponents:dateComponents];

        [result addObject:date];
    }

    return result;
}


- (id) processUnknownTime:(NSString*) showtime {
     if (![showtime hasSuffix:@"am"] && ![showtime hasSuffix:@"pm"]) {
         showtime = [NSString stringWithFormat:@"%@pm", showtime];
     }

    NSDate* date = [DateUtilities dateWithNaturalLanguageString:showtime];
    if (date == nil) {
        return [NSNull null];
    }

    return date;
}


- (NSArray*) process12HourTimes:(NSArray*) times {
    // walk backwards from the end.  switch the time when we see an AM/PM marker
    NSMutableArray* reverseArray = [NSMutableArray array];

    BOOL isPM;
    for (NSInteger i = times.count - 1; i >= 0; i--) {
        NSString* time = [times objectAtIndex:i];

        if ([self hasTimeSuffix:time]) {
            isPM = [time hasSuffix:@"pm"];

            // trim off the suffix
            time = [time substringToIndex:time.length - 2];
        }

        NSRange range = [time rangeOfString:@":"];

        NSInteger hour = [[time substringToIndex:range.location] intValue];
        NSInteger minute = [[time substringFromIndex:range.location + 1] intValue];

        if (isPM && hour < 12) {
            hour += 12;
        } else if (!isPM && hour == 12) {
            hour = 0;
        }

        [dateComponents setHour:hour];
        [dateComponents setMinute:minute];

        NSDate* date = [calendar dateFromComponents:dateComponents];

        [reverseArray addObject:date];
    }

    NSMutableArray* result = [NSMutableArray array];
    for (NSInteger i = reverseArray.count - 1; i >= 0; i--) {
        [result addObject:[reverseArray objectAtIndex:i]];
    }

    return result;
}


- (NSArray*) processUnknownTimes:(NSArray*) times {
    NSMutableArray* result = [NSMutableArray array];
    for (NSString* time in times) {
        [result addObject:[self processUnknownTime:time]];
    }
    return result;
}


- (NSArray*) processTimes:(NSArray*) showtimes {
    if (showtimes.count == 0) {
        return [NSArray array];
    }

    NSMutableArray* times = [NSMutableArray array];
    for (ShowtimeProto* showtime in showtimes) {
        [times addObject:showtime.time];
    }

    if ([self is24HourTime:times]) {
        return [self process24HourTimes:times];
    } else if ([self is12HourTime:times] && [self hasTimeSuffix:times.lastObject]) {
        return [self process12HourTimes:times];
    } else {
        return [self processUnknownTimes:times];
    }
}


- (void) processMovieAndShowtimes:(TheaterListingsProto_TheaterAndMovieShowtimesProto_MovieAndShowtimesProto*) movieAndShowtimes
                movieIdToMovieMap:(NSDictionary*) movieIdToMovieMap
                  performancesMap:(NSMutableDictionary*) performancesMap {
    NSString* movieId = movieAndShowtimes.movieIdentifier;
    NSString* movieTitle = [[movieIdToMovieMap objectForKey:movieId] canonicalTitle];

    NSMutableArray* performances = [NSMutableArray array];

    NSArray* showtimes = movieAndShowtimes.showtimes.showtimesList;
    NSArray* times = [self processTimes:showtimes];

    if (showtimes.count == times.count) {
        for (NSInteger i = 0; i < showtimes.count; i++) {
            ShowtimeProto* showtime = [showtimes objectAtIndex:i];
            id time = [times objectAtIndex:i];
            if (time == [NSNull null]) {
                continue;
            }

            NSString* url = showtime.url;

            if ([url hasPrefix:@"m="]) {
                url = [NSString stringWithFormat:@"http://iphone.fandango.com/tms.asp?a=11586&%@", url];
            }

            Performance* performance = [Performance performanceWithTime:time
                                                                    url:url];

            [performances addObject:performance.dictionary];
        }

        [performancesMap setObject:performances forKey:movieTitle];
    }
}


- (NSMutableDictionary*) processMovieAndShowtimesList:(NSArray*) movieAndShowtimesList
                                    movieIdToMovieMap:(NSDictionary*) movieIdToMovieMap {
    NSMutableDictionary* performancesMap = [NSMutableDictionary dictionary];

    for (TheaterListingsProto_TheaterAndMovieShowtimesProto_MovieAndShowtimesProto* movieAndShowtimes in movieAndShowtimesList) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        {
            [self processMovieAndShowtimes:movieAndShowtimes
                         movieIdToMovieMap:movieIdToMovieMap
                           performancesMap:performancesMap];
        }
        [pool release];
    }

    return performancesMap;
}


- (void) processTheaterAndMovieShowtimes:(TheaterListingsProto_TheaterAndMovieShowtimesProto*) theaterAndMovieShowtimes
                                theaters:(NSMutableArray*) theaters
                            performances:(NSMutableDictionary*) performances
              synchronizationInformation:(NSMutableDictionary*) synchronizationInformation
                     originatingLocation:(Location*) originatingLocation
                            theaterNames:(NSArray*) theaterNames
                       movieIdToMovieMap:(NSDictionary*) movieIdToMovieMap {
    TheaterProto* theater = theaterAndMovieShowtimes.theater;
    NSString* name = theater.name;
    if (name.length == 0) {
        return;
    }

    if (theaterNames.count > 0  && ![theaterNames containsObject:name]) {
        return;
    }

    NSString* identifier = theater.identifier;
    NSString* address =    theater.streetAddress;
    NSString* city =       theater.city;
    NSString* state =      theater.state;
    NSString* postalCode = theater.postalCode;
    NSString* country =    theater.country;
    NSString* phone =      theater.phone;
    double latitude =      theater.latitude;
    double longitude =     theater.longitude;

    NSArray* movieAndShowtimesList = theaterAndMovieShowtimes.movieAndShowtimesList;

    NSMutableDictionary* movieToShowtimesMap = [self processMovieAndShowtimesList:movieAndShowtimesList
                                                                movieIdToMovieMap:movieIdToMovieMap];

    if (movieToShowtimesMap.count == 0) {
        return;
    }
    [synchronizationInformation setObject:[DateUtilities today] forKey:name];
    [performances setObject:movieToShowtimesMap forKey:name];

    Location* location = [Location locationWithLatitude:latitude
                                              longitude:longitude
                                                address:address
                                                   city:city
                                                  state:state
                                             postalCode:postalCode
                                                country:country];

    [theaters addObject:[Theater theaterWithIdentifier:identifier
                                                  name:name
                                           phoneNumber:phone
                                              location:location
                                   originatingLocation:originatingLocation
                                           movieTitles:movieToShowtimesMap.allKeys]];
}


- (NSArray*) processTheaterAndMovieShowtimes:(NSArray*) theaterAndMovieShowtimes
                         originatingLocation:(Location*) originatingLocation
                                theaterNames:(NSArray*) theaterNames
                           movieIdToMovieMap:(NSDictionary*) movieIdToMovieMap {
    NSMutableArray* theaters = [NSMutableArray array];
    NSMutableDictionary* performances = [NSMutableDictionary dictionary];
    NSMutableDictionary* synchronizationInformation = [NSMutableDictionary dictionary];

    for (TheaterListingsProto_TheaterAndMovieShowtimesProto* proto in theaterAndMovieShowtimes) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        {
            [self processTheaterAndMovieShowtimes:proto
                                         theaters:theaters
                                     performances:performances
                       synchronizationInformation:synchronizationInformation
                              originatingLocation:originatingLocation
                                     theaterNames:theaterNames
                                movieIdToMovieMap:movieIdToMovieMap];
        }
        [pool release];
    }

    return [NSArray arrayWithObjects:theaters, performances, synchronizationInformation, nil];
}


- (LookupResult*) processTheaterListings:(TheaterListingsProto*) element
                     originatingLocation:(Location*) originatingLocation
                            theaterNames:(NSArray*) theaterNames {
    self.calendar = [NSCalendar currentCalendar];
    self.dateComponents = [[[NSDateComponents alloc] init] autorelease];

    NSArray* movieProtos = element.moviesList;
    NSArray* theaterAndMovieShowtimes = element.theaterAndMovieShowtimesList;

    NSDictionary* movieIdToMovieMap = [self processMovies:movieProtos];

    NSArray* theatersAndPerformances = [self processTheaterAndMovieShowtimes:theaterAndMovieShowtimes
                                                         originatingLocation:originatingLocation
                                                                theaterNames:theaterNames
                                                           movieIdToMovieMap:movieIdToMovieMap];

    NSMutableArray* movies = [NSMutableArray arrayWithArray:movieIdToMovieMap.allValues];
    NSMutableArray* theaters = [theatersAndPerformances objectAtIndex:0];
    NSMutableDictionary* performances = [theatersAndPerformances objectAtIndex:1];
    NSMutableDictionary* synchronizationInformation = [theatersAndPerformances objectAtIndex:2];

    return [LookupResult resultWithMovies:movies
                                 theaters:theaters
                             performances:performances
               synchronizationInformation:synchronizationInformation];
}


- (LookupResult*) lookupLocation:(Location*) location
                      searchDate:(NSDate*) searchDate
                    theaterNames:(NSArray*) theaterNames {
    if (location.postalCode == nil) {
        return nil;
    }

    NSString* country = location.country.length == 0 ? [LocaleUtilities isoCountry]
                                                     : location.country;


    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                   fromDate:[DateUtilities today]
                                                                     toDate:searchDate
                                                                    options:0];
    NSInteger day = components.day;
    day = MIN(MAX(day, 0), 7);

    NSString* address = [NSString stringWithFormat:
                         @"http://%@.appspot.com/LookupTheaterListings2?country=%@&language=%@&postalcode=%@&day=%d&format=pb&latitude=%d&longitude=%d",
                         [Application host],
                         country,
                         [LocaleUtilities isoLanguage],
                         [StringUtilities stringByAddingPercentEscapes:location.postalCode],
                         day,
                         (int)(location.latitude * 1000000),
                         (int)(location.longitude * 1000000)];

    NSData* data = [NetworkUtilities dataWithContentsOfAddress:address
                                                     important:YES];
    if (data == nil) {
        return nil;
    }

    @try {
        TheaterListingsProto* theaterListings = [TheaterListingsProto parseFromData:data];

        return [self processTheaterListings:theaterListings
                        originatingLocation:location
                               theaterNames:theaterNames];

    }
    @catch (NSException * e) {
    }

    return nil;
}

@end