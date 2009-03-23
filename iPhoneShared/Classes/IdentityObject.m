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

#import "IdentityObject.h"

@interface IdentityObject()
@property (retain) id value_;
@end


@implementation IdentityObject

@synthesize value_;

property_wrapper(id, value, Value);

- (void) dealloc {
    self.value = nil;
    [super dealloc];
}


- (id) initWithValue:(id) value__ {
    if (self = [super init]) {
        self.value = value__;
    }

    return self;
}


+ (IdentityObject*) objectWithValue:(id) value {
    return [[[IdentityObject alloc] initWithValue:value] autorelease];
}


- (NSUInteger) hash {
    return (NSUInteger)self.value;
}


- (BOOL) isEqual:(id) other {
    return self.value == [other value];
}


- (NSString*) description {
    return [self.value description];
}

@end