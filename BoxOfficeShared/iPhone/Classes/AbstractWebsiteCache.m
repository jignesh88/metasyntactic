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

#import "AbstractWebsiteCache.h"

@interface AbstractWebsiteCache()
@end


@implementation AbstractWebsiteCache

- (NSString*) cacheDirectory AbstractMethod;


- (NSString*) serverUrl:(Movie*) movie AbstractMethod;


- (NSString*) addressFile:(Movie*) movie {
  NSString* name = [[FileUtilities sanitizeFileName:movie.canonicalTitle] stringByAppendingPathExtension:@"plist"];
  return [self.cacheDirectory stringByAppendingPathComponent:name];
}


- (void) updateMovieDetails:(Movie*) movie force:(BOOL) force {
  NSString* path = [self addressFile:movie];

  NSDate* lastLookupDate = [FileUtilities modificationDate:path];
  if (lastLookupDate != nil) {
    NSString* value = [FileUtilities readObject:path];
    if (value.length > 0) {
      // we have a real imdb value for this movie
      return;
    }

    if (!force) {
      // we have a sentinel.  only update if it's been long enough
      if (ABS(lastLookupDate.timeIntervalSinceNow) < THREE_DAYS) {
        return;
      }
    }
  }


  NSString* url = [self serverUrl:movie];
  NSData* data = [NetworkUtilities dataWithContentsOfAddress:url pause:NO];
  if (data == nil) {
    return;
  }

  XmlElement* element = [XmlParser parse:data];
  NSString* addressValue = [element text];
  if (addressValue == nil) {
    addressValue = @"";
  }

  // write down the response (even if it is empty).  An empty value will
  // ensure that we don't update this entry too often.
  [FileUtilities writeObject:addressValue toFile:path];
  if (addressValue.length > 0) {
    [MetasyntacticSharedApplication minorRefresh];
  }
}


- (NSString*) addressForMovie:(Movie*) movie {
  return [FileUtilities readObject:[self addressFile:movie]];
}

@end
