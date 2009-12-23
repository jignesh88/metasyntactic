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

@interface LargePosterCache : AbstractMovieCache {
@private
  // Shared amongst multiple threads.
  AutoreleasingMutableDictionary* yearToMovieNames;
  AutoreleasingMutableDictionary* yearToTitleToPosterUrls;

  BOOL updated;
}

+ (LargePosterCache*) cache;

+ (NSDictionary*) processPosterListings:(XmlElement *) posterListingsElement;

- (void) update;

- (UIImage*) posterForMovie:(Movie*) movie loadFromDisk:(BOOL) loadFromDisk;
- (UIImage*) smallPosterForMovie:(Movie*) movie loadFromDisk:(BOOL) loadFromDisk;

- (UIImage*) posterForMovie:(Movie*) movie index:(NSInteger) index loadFromDisk:(BOOL) loadFromDisk;
- (BOOL) posterExistsForMovie:(Movie*) movie index:(NSInteger) index;

- (void) downloadFirstPosterForMovie:(Movie*) movie;
- (void) downloadAllPostersForMovie:(Movie*) movie;
- (BOOL) allPostersDownloadedForMovie:(Movie*) movie;
- (NSInteger) posterCountForMovie:(Movie*) movie;

@end