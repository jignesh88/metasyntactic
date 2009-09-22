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

@interface NetworkUtilities : NSObject {
}

+ (XmlElement*) xmlWithContentsOfAddress:(NSString*) address;
+ (XmlElement*) xmlWithContentsOfAddress:(NSString*) address pause:(BOOL) pause;
+ (XmlElement*) xmlWithContentsOfAddress:(NSString*) address response:(NSHTTPURLResponse**) response;
+ (XmlElement*) xmlWithContentsOfAddress:(NSString*) address response:(NSHTTPURLResponse**) response pause:(BOOL) pause;
+ (XmlElement*) xmlWithContentsOfUrl:(NSURL*) url;
+ (XmlElement*) xmlWithContentsOfUrl:(NSURL*) url response:(NSHTTPURLResponse**) response;
+ (XmlElement*) xmlWithContentsOfUrl:(NSURL*) url response:(NSHTTPURLResponse**) response pause:(BOOL) pause;
+ (XmlElement*) xmlWithContentsOfUrlRequest:(NSURLRequest*) url;
+ (XmlElement*) xmlWithContentsOfUrlRequest:(NSURLRequest*) url response:(NSHTTPURLResponse**) response;
+ (XmlElement*) xmlWithContentsOfUrlRequest:(NSURLRequest*) url response:(NSHTTPURLResponse**) response pause:(BOOL) pause;
+ (NSString*) stringWithContentsOfAddress:(NSString*) address;
+ (NSString*) stringWithContentsOfAddress:(NSString*) address pause:(BOOL) pause;
+ (NSString*) stringWithContentsOfUrl:(NSURL*) url;
+ (NSString*) stringWithContentsOfUrl:(NSURL*) url pause:(BOOL) pause;
+ (NSString*) stringWithContentsOfUrlRequest:(NSURLRequest*) url;
+ (NSString*) stringWithContentsOfUrlRequest:(NSURLRequest*) url pause:(BOOL) pause;
+ (NSData*) dataWithContentsOfAddress:(NSString*) address;
+ (NSData*) dataWithContentsOfAddress:(NSString*) address pause:(BOOL) pause;
+ (NSData*) dataWithContentsOfAddress:(NSString*) address response:(NSHTTPURLResponse**) response;
+ (NSData*) dataWithContentsOfAddress:(NSString*) address response:(NSHTTPURLResponse**) response pause:(BOOL) pause;
+ (NSData*) dataWithContentsOfUrl:(NSURL*) url;
+ (NSData*) dataWithContentsOfUrl:(NSURL*) url response:(NSHTTPURLResponse**) response;
+ (NSData*) dataWithContentsOfUrl:(NSURL*) url response:(NSHTTPURLResponse**) response pause:(BOOL) pause;
+ (NSData*) dataWithContentsOfUrlRequest:(NSURLRequest*) url;
+ (NSData*) dataWithContentsOfUrlRequest:(NSURLRequest*) url response:(NSHTTPURLResponse**) response;
+ (NSData*) dataWithContentsOfUrlRequest:(NSURLRequest*) url pause:(BOOL) pause;
+ (NSData*) dataWithContentsOfUrlRequest:(NSURLRequest*) url response:(NSHTTPURLResponse**) response pause:(BOOL) pause;

+ (BOOL) isNetworkAvailable;

+ (NSMutableURLRequest*) createRequest:(NSURL*) url;

@end
