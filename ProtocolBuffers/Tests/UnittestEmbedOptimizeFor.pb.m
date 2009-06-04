// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "UnittestEmbedOptimizeFor.pb.h"

@implementation UnittestEmbedOptimizeForRoot
+ (void) initialize {
  if (self == [UnittestEmbedOptimizeForRoot class]) {
  }
}
@end

@interface TestEmbedOptimizedForSize ()
@property (retain) TestOptimizedForSize* optionalMessage;
@property (retain) NSMutableArray* mutableRepeatedMessageList;
@end

@implementation TestEmbedOptimizedForSize

- (BOOL) hasOptionalMessage {
  return hasOptionalMessage;
}
- (void) setHasOptionalMessage:(BOOL) hasOptionalMessage_ {
  hasOptionalMessage = hasOptionalMessage_;
}
@synthesize optionalMessage;
@synthesize mutableRepeatedMessageList;
- (void) dealloc {
  self.optionalMessage = nil;
  self.mutableRepeatedMessageList = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.optionalMessage = [TestOptimizedForSize defaultInstance];
  }
  return self;
}
static TestEmbedOptimizedForSize* defaultTestEmbedOptimizedForSizeInstance = nil;
+ (void) initialize {
  if (self == [TestEmbedOptimizedForSize class]) {
    defaultTestEmbedOptimizedForSizeInstance = [[TestEmbedOptimizedForSize alloc] init];
  }
}
+ (TestEmbedOptimizedForSize*) defaultInstance {
  return defaultTestEmbedOptimizedForSizeInstance;
}
- (TestEmbedOptimizedForSize*) defaultInstance {
  return defaultTestEmbedOptimizedForSizeInstance;
}
- (NSArray*) repeatedMessageList {
  return mutableRepeatedMessageList;
}
- (TestOptimizedForSize*) repeatedMessageAtIndex:(int32_t) index {
  id value = [mutableRepeatedMessageList objectAtIndex:index];
  return value;
}
- (BOOL) isInitialized {
  if (hasOptionalMessage) {
    if (!self.optionalMessage.isInitialized) {
      return NO;
    }
  }
  for (TestOptimizedForSize* element in self.repeatedMessageList) {
    if (!element.isInitialized) {
      return NO;
    }
  }
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (hasOptionalMessage) {
    [output writeMessage:1 value:self.optionalMessage];
  }
  for (TestOptimizedForSize* element in self.repeatedMessageList) {
    [output writeMessage:2 value:element];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size = memoizedSerializedSize;
  if (size != -1) {
    return size;
  }

  size = 0;
  if (hasOptionalMessage) {
    size += computeMessageSize(1, self.optionalMessage);
  }
  for (TestOptimizedForSize* element in self.repeatedMessageList) {
    size += computeMessageSize(2, element);
  }
  size += self.unknownFields.serializedSize;
  memoizedSerializedSize = size;
  return size;
}
+ (TestEmbedOptimizedForSize*) parseFromData:(NSData*) data {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromData:data] build];
}
+ (TestEmbedOptimizedForSize*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (TestEmbedOptimizedForSize*) parseFromInputStream:(NSInputStream*) input {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromInputStream:input] build];
}
+ (TestEmbedOptimizedForSize*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TestEmbedOptimizedForSize*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromCodedInputStream:input] build];
}
+ (TestEmbedOptimizedForSize*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TestEmbedOptimizedForSize*)[[[TestEmbedOptimizedForSize builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TestEmbedOptimizedForSize_Builder*) builder {
  return [[[TestEmbedOptimizedForSize_Builder alloc] init] autorelease];
}
+ (TestEmbedOptimizedForSize_Builder*) builderWithPrototype:(TestEmbedOptimizedForSize*) prototype {
  return [[TestEmbedOptimizedForSize builder] mergeFrom:prototype];
}
- (TestEmbedOptimizedForSize_Builder*) builder {
  return [TestEmbedOptimizedForSize builder];
}
@end

@interface TestEmbedOptimizedForSize_Builder()
@property (retain) TestEmbedOptimizedForSize* result;
@end

@implementation TestEmbedOptimizedForSize_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[TestEmbedOptimizedForSize alloc] init] autorelease];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (TestEmbedOptimizedForSize_Builder*) clear {
  self.result = [[[TestEmbedOptimizedForSize alloc] init] autorelease];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) clone {
  return [TestEmbedOptimizedForSize builderWithPrototype:result];
}
- (TestEmbedOptimizedForSize*) defaultInstance {
  return [TestEmbedOptimizedForSize defaultInstance];
}
- (TestEmbedOptimizedForSize*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (TestEmbedOptimizedForSize*) buildPartial {
  TestEmbedOptimizedForSize* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (TestEmbedOptimizedForSize_Builder*) mergeFrom:(TestEmbedOptimizedForSize*) other {
  if (other == [TestEmbedOptimizedForSize defaultInstance]) {
    return self;
  }
  if (other.hasOptionalMessage) {
    [self mergeOptionalMessage:other.optionalMessage];
  }
  if (other.mutableRepeatedMessageList.count > 0) {
    if (result.mutableRepeatedMessageList == nil) {
      result.mutableRepeatedMessageList = [NSMutableArray array];
    }
    [result.mutableRepeatedMessageList addObjectsFromArray:other.mutableRepeatedMessageList];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (TestEmbedOptimizedForSize_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSet_Builder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    int32_t tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        TestOptimizedForSize_Builder* subBuilder = [TestOptimizedForSize builder];
        if (self.hasOptionalMessage) {
          [subBuilder mergeFrom:self.optionalMessage];
        }
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self setOptionalMessage:[subBuilder buildPartial]];
        break;
      }
      case 18: {
        TestOptimizedForSize_Builder* subBuilder = [TestOptimizedForSize builder];
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self addRepeatedMessage:[subBuilder buildPartial]];
        break;
      }
    }
  }
}
- (BOOL) hasOptionalMessage {
  return result.hasOptionalMessage;
}
- (TestOptimizedForSize*) optionalMessage {
  return result.optionalMessage;
}
- (TestEmbedOptimizedForSize_Builder*) setOptionalMessage:(TestOptimizedForSize*) value {
  result.hasOptionalMessage = YES;
  result.optionalMessage = value;
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) setOptionalMessageBuilder:(TestOptimizedForSize_Builder*) builderForValue {
  return [self setOptionalMessage:[builderForValue build]];
}
- (TestEmbedOptimizedForSize_Builder*) mergeOptionalMessage:(TestOptimizedForSize*) value {
  if (result.hasOptionalMessage &&
      result.optionalMessage != [TestOptimizedForSize defaultInstance]) {
    result.optionalMessage =
      [[[TestOptimizedForSize builderWithPrototype:result.optionalMessage] mergeFrom:value] buildPartial];
  } else {
    result.optionalMessage = value;
  }
  result.hasOptionalMessage = YES;
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) clearOptionalMessage {
  result.hasOptionalMessage = NO;
  result.optionalMessage = [TestOptimizedForSize defaultInstance];
  return self;
}
- (NSArray*) repeatedMessageList {
  if (result.mutableRepeatedMessageList == nil) { return [NSArray array]; }
  return result.mutableRepeatedMessageList;
}
- (TestOptimizedForSize*) repeatedMessageAtIndex:(int32_t) index {
  return [result repeatedMessageAtIndex:index];
}
- (TestEmbedOptimizedForSize_Builder*) replaceRepeatedMessageAtIndex:(int32_t) index with:(TestOptimizedForSize*) value {
  [result.mutableRepeatedMessageList replaceObjectAtIndex:index withObject:value];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) addAllRepeatedMessage:(NSArray*) values {
  if (result.mutableRepeatedMessageList == nil) {
    result.mutableRepeatedMessageList = [NSMutableArray array];
  }
  [result.mutableRepeatedMessageList addObjectsFromArray:values];
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) clearRepeatedMessageList {
  result.mutableRepeatedMessageList = nil;
  return self;
}
- (TestEmbedOptimizedForSize_Builder*) addRepeatedMessage:(TestOptimizedForSize*) value {
  if (result.mutableRepeatedMessageList == nil) {
    result.mutableRepeatedMessageList = [NSMutableArray array];
  }
  [result.mutableRepeatedMessageList addObject:value];
  return self;
}
@end

