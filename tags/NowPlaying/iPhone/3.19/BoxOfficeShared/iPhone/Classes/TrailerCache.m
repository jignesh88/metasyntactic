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

#import "TrailerCache.h"

#import "Application.h"

@interface TrailerCache()
@property (retain) NSDictionary* index;
@property (retain) NSArray* indexKeys;
@end


@implementation TrailerCache

static TrailerCache* cache;

+ (void) initialize {
  if (self == [TrailerCache class]) {
    cache = [[TrailerCache alloc] init];
  }
}


+ (TrailerCache*) cache {
  return cache;
}

@synthesize index;
@synthesize indexKeys;

- (void) dealloc {
  self.index = nil;
  self.indexKeys = nil;

  [super dealloc];
}


- (NSString*) trailerFile:(Movie*) movie {
  NSString* name = [[FileUtilities sanitizeFileName:movie.canonicalTitle] stringByAppendingPathExtension:@"plist"];
  return [[Application trailersDirectory] stringByAppendingPathComponent:name];
}


- (void) updateMovieDetailsWorker:(Movie*) movie force:(BOOL) force {
  NSString* file = [self trailerFile:movie];

  NSDate* downloadDate = [FileUtilities modificationDate:file];
  if (downloadDate != nil) {
    if (ABS(downloadDate.timeIntervalSinceNow) < THREE_DAYS) {
      NSArray* values = [FileUtilities readObject:file];
      if (values.count > 0) {
        return;
      }

      if (!force) {
        return;
      }
    }
  }

  DifferenceEngine* engine = [DifferenceEngine engine];
  NSInteger arrayIndex = [engine findClosestMatchIndex:movie.canonicalTitle.lowercaseString
                                               inArray:indexKeys];
  if (arrayIndex == NSNotFound) {
    // no trailer for this movie.  record that fact.  we'll try again later
    [FileUtilities writeObject:[NSArray array]
                        toFile:[self trailerFile:movie]];
    return;
  }

  NSArray* studioAndLocation = [index objectForKey:[indexKeys objectAtIndex:arrayIndex]];
  NSString* studio = [studioAndLocation objectAtIndex:0];
  NSString* location = [studioAndLocation objectAtIndex:1];

  NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupTrailerListings%@?studio=%@&name=%@",
                   [Application apiHost], [Application apiVersion], studio, location];
  XmlElement* element = [NetworkUtilities xmlWithContentsOfAddress:url pause:NO];
  if (element == nil) {
    // didn't get any data.  ignore this for now.
    return;
  }

  NSMutableArray* final = [NSMutableArray array];
  for (XmlElement* urlElement in element.children) {
    NSString* trailer = [urlElement text];
    if (trailer.length > 0) {
      [final addObject:trailer];
    }
  }

  [FileUtilities writeObject:final toFile:[self trailerFile:movie]];

  if (final.count > 0) {
    [MetasyntacticSharedApplication minorRefresh];
  }
}


- (void) generateIndexWorker:(XmlElement*) element {
  NSMutableDictionary* result = [NSMutableDictionary dictionary];

  for (XmlElement* itemElement in element.children) {
    NSString* fullTitle = [itemElement attributeValue:@"title"];
    NSString* studioKey = [itemElement attributeValue:@"studio_key"];
    NSString* titleKey = [itemElement attributeValue:@"title_key"];

    if (fullTitle.length > 0 && studioKey.length > 0 && titleKey.length > 0) {
      [result setObject:[NSArray arrayWithObjects:studioKey, titleKey, nil]
                 forKey:fullTitle.lowercaseString];
    }
  }

  self.index = result;
  self.indexKeys = index.allKeys;
}


- (BOOL) tryGenerateIndex {
  BOOL result;
  [dataGate lock];
  {
    if (index == nil) {
      NSString* url = [NSString stringWithFormat:@"http://%@.appspot.com/LookupTrailerIndex%@",
                       [Application apiHost], [Application apiVersion]];
      XmlElement* element = [NetworkUtilities xmlWithContentsOfAddress:url pause:NO];
      if (element != nil) {
        [self generateIndexWorker:element];
        [self clearUpdatedMovies];
      }
    }

    result = index != nil;
  }
  [dataGate unlock];
  return result;
}


- (void) updateMovieDetails:(Movie*) movie force:(BOOL) force {
  if ([self tryGenerateIndex]) {
    [self updateMovieDetailsWorker:movie force:force];
  }
}


- (NSArray*) trailersForMovie:(Movie*) movie {
  NSArray* trailers = [FileUtilities readObject:[self trailerFile:movie]];
  if (trailers == nil) {
    return [NSArray array];
  }
  return trailers;
}

@end
