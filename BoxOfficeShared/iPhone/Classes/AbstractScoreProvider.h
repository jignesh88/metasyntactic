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

#import "ScoreProvider.h"
#import "AbstractMovieCache.h"

@interface AbstractScoreProvider : AbstractMovieCache<ScoreProvider> {
@private
  // <-- Accessed from multiple threads.  needs gate

  // Mapping from score title to score.
  ThreadsafeValue*/*NSDictionary*/ scoresData;
  ThreadsafeValue*/*NSString*/ hashData;
  ThreadsafeValue*/*NSArray*/ moviesData;

  // Mapping from google movie title to score provider title
  ThreadsafeValue*/*NSDictionary*/ movieMapData;

  // -->

  NSString* providerDirectory;
  NSString* reviewsDirectory;
}

@end
