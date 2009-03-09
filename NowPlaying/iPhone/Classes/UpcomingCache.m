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

#import "UpcomingCache.h"

#import "Application.h"
#import "DateUtilities.h"
#import "FileUtilities.h"
#import "ImageUtilities.h"
#import "IMDbCache.h"
#import "LargePosterCache.h"
#import "LinkedSet.h"
#import "Movie.h"
#import "NetflixCache.h"
#import "NetworkUtilities.h"
#import "AppDelegate.h"
#import "Model.h"
#import "ThreadingUtilities.h"
#import "Utilities.h"
#import "WikipediaCache.h"
#import "XmlElement.h"

@interface UpcomingCache()
@property (retain) NSString* hashData;
@property (retain) NSDictionary* movieMapData;
@property (retain) NSDictionary* studioKeysData;
@property (retain) NSDictionary* titleKeysData;
@property (retain) NSMutableDictionary* bookmarksData;
@end


@implementation UpcomingCache

@synthesize hashData;
@synthesize movieMapData;
@synthesize studioKeysData;
@synthesize titleKeysData;
@synthesize bookmarksData;

- (void) dealloc {
    self.hashData = nil;
    self.movieMapData = nil;
    self.studioKeysData = nil;
    self.titleKeysData = nil;
    self.bookmarksData = nil;

    [super dealloc];
}


- (id) initWithModel:(Model*) model_ {
    if (self = [super initWithModel:model_]) {
    }

    return self;
}


+ (UpcomingCache*) cacheWithModel:(Model*) model {
    return [[[UpcomingCache alloc] initWithModel:model] autorelease];
}


- (NSString*) hashFile {
    return [[Application upcomingDirectory] stringByAppendingPathComponent:@"Hash.plist"];
}


- (NSString*) studiosFile {
    return [[Application upcomingDirectory] stringByAppendingPathComponent:@"Studios.plist"];
}


- (NSString*) titlesFile {
    return [[Application upcomingDirectory] stringByAppendingPathComponent:@"Titles.plist"];
}


- (NSString*) moviesFile {
    return [[Application upcomingDirectory] stringByAppendingPathComponent:@"Movies.plist"];
}


- (void) writeData:(NSString*) hash
            movies:(NSArray*) movies
        studioKeys:(NSDictionary*) studioKeys
         titleKeys:(NSDictionary*) titleKeys {
    [FileUtilities writeObject:studioKeys toFile:self.studiosFile];
    [FileUtilities writeObject:titleKeys toFile:self.titlesFile];

    [FileUtilities writeObject:[Movie encodeArray:movies] toFile:self.moviesFile];

    // do this last, it signifies that we're done.
    [FileUtilities writeObject:hash toFile:self.hashFile];
}


- (NSArray*) processArray:(XmlElement*) element {
    NSMutableArray* array = [NSMutableArray array];

    for (XmlElement* child in element.children) {
        [array addObject:[child attributeValue:@"value"]];
    }

    return array;
}


- (NSString*) massageTitle:(NSString*) title {
    return [title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}


- (Movie*) processMovieElement:(XmlElement*) movieElement
                    studioKeys:(NSMutableDictionary*) studioKeys
                     titleKeys:(NSMutableDictionary*) titleKeys  {
    NSDate* releaseDate = [DateUtilities dateWithNaturalLanguageString:[movieElement attributeValue:@"date"]];
    NSString* poster = [movieElement attributeValue:@"poster"];
    NSString* rating = [movieElement attributeValue:@"rating"];
    NSString* studio = [movieElement attributeValue:@"studio"];
    NSString* title = [movieElement attributeValue:@"title"];
    title = [self massageTitle:title];
    NSArray* directors = [self processArray:[movieElement element:@"directors"]];
    NSArray* cast = [self processArray:[movieElement element:@"actors"]];
    NSArray* genres = [self processArray:[movieElement element:@"genres"]];

    NSString* studioKey = [movieElement attributeValue:@"studioKey"];
    NSString* titleKey = [movieElement attributeValue:@"titleKey"];

    Movie* movie = [Movie movieWithIdentifier:[NSString stringWithFormat:@"%d", movieElement]
                                        title:title
                                       rating:rating
                                       length:0
                                  releaseDate:releaseDate
                                  imdbAddress:@""
                                       poster:poster
                                     synopsis:@""
                                       studio:studio
                                    directors:directors
                                         cast:cast
                                       genres:genres];

    [studioKeys setObject:studioKey forKey:movie.canonicalTitle];
    [titleKeys setObject:titleKey forKey:movie.canonicalTitle];

    return movie;
}


- (NSMutableArray*) processResultElement:(XmlElement*) resultElement
                              studioKeys:(NSMutableDictionary*) studioKeys
                               titleKeys:(NSMutableDictionary*) titleKeys {
    NSMutableArray* result = [NSMutableArray array];
    NSDate* cutoff = [NSDate dateWithTimeIntervalSinceNow:-2 * ONE_WEEK];

    for (XmlElement* movieElement in resultElement.children) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        {
            Movie* movie = [self processMovieElement:movieElement studioKeys:studioKeys titleKeys:titleKeys];

            if (movie != nil) {
                if([cutoff compare:movie.releaseDate] != NSOrderedDescending) {
                    [result addObject:movie];
                }
            }
        }
        [pool release];
    }

    return result;
}


- (NSDictionary*) loadMovies {
    NSArray* array = [FileUtilities readObject:self.moviesFile];
    if (array.count == 0) {
        return [NSDictionary dictionary];
    }

    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSDictionary* dictionary in array) {
        Movie* movie = [Movie movieWithDictionary:dictionary];
        [result setObject:movie forKey:movie.canonicalTitle];
    }

    return result;
}


- (NSDictionary*) movieMap {
    if (movieMapData == nil) {
        self.movieMapData = [self loadMovies];
    }

    return movieMapData;
}


- (NSArray*) movies {
    return self.movieMap.allValues;
}


- (NSString*) hash {
    if (hashData == nil) {
        self.hashData = [FileUtilities readObject:self.hashFile];
        if (hashData == nil) {
            self.hashData = @"";
        }
    }

    return hashData;
}


- (NSDictionary*) loadStudioKeys {
    NSDictionary* dictionary = [FileUtilities readObject:self.studiosFile];
    if (dictionary == nil) {
        return [NSDictionary dictionary];
    }

    return dictionary;
}


- (NSDictionary*) studioKeys {
    if (studioKeysData == nil) {
        self.studioKeysData = [self loadStudioKeys];
    }

    return studioKeysData;
}


- (NSDictionary*) loadTitleKeys {
    NSDictionary* dictionary = [FileUtilities readObject:self.titlesFile];
    if (dictionary == nil) {
        return [NSDictionary dictionary];
    }

    return dictionary;
}


- (NSDictionary*) titleKeys {
    if (titleKeysData == nil) {
        self.titleKeysData = [self loadTitleKeys];
    }

    return titleKeysData;
}


- (NSMutableDictionary*) loadBookmarks {
    NSArray* movies = [model bookmarkedUpcoming];
    if (movies.count == 0) {
        return [NSMutableDictionary dictionary];
    }

    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (Movie* movie in movies) {
        [result setObject:movie forKey:movie.canonicalTitle];
    }

    return result;
}


- (NSMutableDictionary*) bookmarks {
    if (bookmarksData == nil) {
        self.bookmarksData = [self loadBookmarks];
    }

    return bookmarksData;
}


- (void) saveBookmarks {
    [model setBookmarkedUpcoming:self.bookmarks.allValues];
}


- (NSString*) castFile:(Movie*) movie {
    return [[[Application upcomingCastDirectory] stringByAppendingPathComponent:[FileUtilities sanitizeFileName:movie.canonicalTitle]] stringByAppendingPathExtension:@"plist"];
}


- (NSString*) synopsisFile:(Movie*) movie {
    return [[[Application upcomingSynopsesDirectory] stringByAppendingPathComponent:[FileUtilities sanitizeFileName:movie.canonicalTitle]] stringByAppendingPathExtension:@"plist"];
}


- (NSString*) trailersFile:(Movie*) movie {
    return [[[Application upcomingTrailersDirectory] stringByAppendingPathComponent:[FileUtilities sanitizeFileName:movie.canonicalTitle]] stringByAppendingPathExtension:@"plist"];
}


- (NSArray*) updateIndexBackgroundEntryPointWorker {
    NSDate* lastLookupDate = [FileUtilities modificationDate:self.hashFile];

    if (lastLookupDate != nil) {
        if (ABS(lastLookupDate.timeIntervalSinceNow) < (3 * ONE_DAY)) {
            return nil;
        }
    }


    NSString* localHash = self.hash;
    NSString* serverHash = [NetworkUtilities stringWithContentsOfAddress:[NSString stringWithFormat:@"http://%@.appspot.com/LookupUpcomingListings?q=index&hash=true", [Application host]]
                                                               important:NO];
    if (serverHash.length == 0) {
        serverHash = @"0";
    }

    if ([localHash isEqual:serverHash]) {
        // save the hash again so we don't check for a few more days.
        [FileUtilities writeObject:serverHash toFile:self.hashFile];
        return nil;
    }

    XmlElement* resultElement = [NetworkUtilities xmlWithContentsOfAddress:[NSString stringWithFormat:@"http://%@.appspot.com/LookupUpcomingListings?q=index", [Application host]]
                                                                 important:NO];

    NSMutableDictionary* studioKeys = [NSMutableDictionary dictionary];
    NSMutableDictionary* titleKeys = [NSMutableDictionary dictionary];
    NSMutableArray* movies = [self processResultElement:resultElement studioKeys:studioKeys titleKeys:titleKeys];
    if (movies.count == 0) {
        return nil;
    }

    [self writeData:serverHash movies:movies studioKeys:studioKeys titleKeys:titleKeys];
    [self clearUpdatedMovies];

    NSArray* arguments = [NSArray arrayWithObjects:serverHash, movies, studioKeys, titleKeys, nil];
    [self performSelectorOnMainThread:@selector(reportIndex:)
                           withObject:arguments
                        waitUntilDone:NO];

    return movies;
}


- (void) updateIndexBackgroundEntryPoint {
    NSArray* movies = [self updateIndexBackgroundEntryPointWorker];
    if (movies.count == 0) {
        movies = [[self loadMovies] allValues];
    }

    [self addPrimaryMovies:movies];
}


- (void) update {
    if (model.userAddress.length == 0) {
        return;
    }

    if (!model.upcomingEnabled) {
        return;
    }

    if (updated) {
        return;
    }
    updated = YES;

    [ThreadingUtilities backgroundSelector:@selector(updateIndexBackgroundEntryPoint)
                                  onTarget:self
                                      gate:nil
                                   visible:YES];
}


- (void) reportIndex:(NSArray*) arguments {
    NSAssert([NSThread isMainThread], nil);

    NSMutableArray* movies = [arguments objectAtIndex:1];

    // add in any previously bookmarked movies that we now no longer know about.
    for (Movie* movie in self.bookmarks.allValues) {
        if (![movies containsObject:movie]) {
            [movies addObject:movie];
        }
    }

    // also determine if any of the data we found match items the user bookmarked
    for (Movie* movie in movies) {
        if ([model isBookmarked:movie]) {
            [self.bookmarks setObject:movie forKey:movie.canonicalTitle];
        }
    }
    [self saveBookmarks];

    NSMutableDictionary* movieMap = [NSMutableDictionary dictionary];
    for (Movie* movie in movies) {
        [movieMap setObject:movie forKey:movie.canonicalTitle];
    }

    self.hashData = [arguments objectAtIndex:0];
    self.movieMapData = movieMap;
    self.studioKeysData = [arguments objectAtIndex:2];
    self.titleKeysData = [arguments objectAtIndex:3];

    [AppDelegate majorRefresh];
}


- (void) updateIMDb:(Movie*) movie {
    [model.imdbCache updateMovie:movie];
}


- (void) updateAmazon:(Movie*) movie {
    [model.amazonCache updateMovie:movie];
}


- (void) updateWikipedia:(Movie*) movie {
    [model.wikipediaCache updateMovie:movie];
}


- (void) updatePoster:(Movie*) movie {
    [model.posterCache updateMovie:movie];
}


- (void) updateSynopsisAndCast:(Movie*) movie
                        studio:(NSString*) studio
                         title:(NSString*) title {
    if (studio.length == 0 || title.length == 0) {
        return;
    }

    NSString* synopsisFile = [self synopsisFile:movie];
    NSDate* lastLookupDate = [FileUtilities modificationDate:synopsisFile];

    if (lastLookupDate != nil) {
        if (ABS(lastLookupDate.timeIntervalSinceNow) < ONE_WEEK) {
            return;
        }
    }

    NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupUpcomingListings?studio=%@&name=%@&format=2", [Application host], studio, title];
    NSString* result = [NetworkUtilities stringWithContentsOfAddress:url important:NO];

    if (result == nil) {
        return;
    }

    if ([result rangeOfString:@"403 Over Quota"].length > 0) {
        return;
    }

    NSString* synopsis = @"";
    NSMutableArray* cast = [NSMutableArray array];

    NSArray* components = [result componentsSeparatedByString:@"\n"];
    if (components.count > 0) {
        synopsis = [components objectAtIndex:0];
        cast = [NSMutableArray arrayWithArray:components];
        [cast removeObjectAtIndex:0];
    }

    [FileUtilities writeObject:synopsis toFile:synopsisFile];
    [FileUtilities writeObject:cast toFile:[self castFile:movie]];

    [AppDelegate minorRefresh];
}


- (void) updateTrailers:(Movie*) movie
                 studio:(NSString*) studio
                  title:(NSString*) title {
    if (studio.length == 0 || title.length == 0) {
        return;
    }

    NSString* trailersFile = [self trailersFile:movie];
    NSDate* lastLookupDate = [FileUtilities modificationDate:trailersFile];

    if (lastLookupDate != nil) {
        if (ABS(lastLookupDate.timeIntervalSinceNow) < (3 * ONE_DAY)) {
            return;
        }
    }

    NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupTrailerListings?studio=%@&name=%@", [Application host], studio, title];
    NSString* trailersString = [NetworkUtilities stringWithContentsOfAddress:url important:NO];
    if (trailersString == nil) {
        return;
    }

    NSArray* trailers = [trailersString componentsSeparatedByString:@"\n"];
    NSMutableArray* final = [NSMutableArray array];
    for (NSString* trailer in trailers) {
        if (trailer.length > 0) {
            [final addObject:trailer];
        }
    }

    [FileUtilities writeObject:final toFile:trailersFile];
    [AppDelegate minorRefresh];
}


- (void) updateNetflix:(Movie*) movie {
    [model.netflixCache lookupNetflixMovieForLocalMovieBackgroundEntryPoint:movie];
}


- (void) updateMovieDetails:(Movie*) movie
                studio:(NSString*) studio
                 title:(NSString*) title {
    [self updatePoster:movie];
    [self updateSynopsisAndCast:movie studio:studio title:title];
    [self updateTrailers:movie studio:studio title:title];
    [self updateNetflix:movie];
    [self updateIMDb:movie];
    [self updateWikipedia:movie];
    [self updateAmazon:movie];
}


- (void) updateMovieDetails:(Movie*) movie {
    NSString* studio = [self.studioKeys objectForKey:movie.canonicalTitle];
    NSString* title = [self.titleKeys objectForKey:movie.canonicalTitle];

    [self updateMovieDetails:movie
                 studio:studio
                  title:title];
}


- (NSDate*) releaseDateForMovie:(Movie*) movie {
    return [[self.movieMap objectForKey:movie.canonicalTitle] releaseDate];
}


- (NSArray*) directorsForMovie:(Movie*) movie {
    return [[self.movieMap objectForKey:movie.canonicalTitle] directors];
}


- (NSArray*) castForMovie:(Movie*) movie {
    NSArray* result = [[self.movieMap objectForKey:movie.canonicalTitle] cast];
    if (result.count > 0) {
        return result;
    }

    result = [FileUtilities readObject:[self castFile:movie]];
    if (result.count > 0) {
        return result;
    }

    return [NSArray array];
}


- (NSArray*) genresForMovie:(Movie*) movie {
    return [[self.movieMap objectForKey:movie.canonicalTitle] genres];
}


- (NSString*) synopsisForMovie:(Movie*) movie {
    return [FileUtilities readObject:[self synopsisFile:movie]];
}


- (NSArray*) trailersForMovie:(Movie*) movie {
    NSArray* array = [FileUtilities readObject:[self trailersFile:movie]];
    if (array == nil) {
        return [NSArray array];
    }

    return array;
}


- (void) addBookmark:(NSString*) canonicalTitle {
    for (Movie* movie in self.movies) {
        if ([movie.canonicalTitle isEqual:canonicalTitle]) {
            [self.bookmarks setObject:movie forKey:canonicalTitle];
            [self saveBookmarks];
            return;
        }
    }
}


- (void) removeBookmark:(NSString*) canonicalTitle {
    [self.bookmarks removeObjectForKey:canonicalTitle];
    [self saveBookmarks];
}

@end