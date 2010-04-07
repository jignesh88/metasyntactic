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

@interface Feed : AbstractData<NSCopying, NSCoding> {
@private
    NSString* url;
    NSString* key;
    NSString* name;
}

@property (readonly, copy) NSString* url;
@property (readonly, copy) NSString* key;
@property (readonly, copy) NSString* name;

+ (Feed*) newWithDictionary:(NSDictionary*) dictionary;
+ (Feed*) feedWithUrl:(NSString*) url
                  key:(NSString*) key
                 name:(NSString*) name;

- (NSDictionary*) dictionary;

- (BOOL) isRecommendationsFeed;
- (BOOL) isDVDQueueFeed;
- (BOOL) isInstantQueueFeed;
- (BOOL) isAtHomeFeed;

@end