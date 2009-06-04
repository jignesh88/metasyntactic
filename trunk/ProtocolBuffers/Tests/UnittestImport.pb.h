// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class PBExtendableMessage_Builder;
@class PBGeneratedMessage_Builder;
@class ImportMessage;
@class ImportMessage_Builder;
typedef enum {
  ImportEnumImportFoo = 7,
  ImportEnumImportBar = 8,
  ImportEnumImportBaz = 9,
} ImportEnum;

BOOL ImportEnumIsValidValue(ImportEnum value);


@interface UnittestImportRoot : NSObject {
}
@end

@interface ImportMessage : PBGeneratedMessage {
@private
  BOOL hasD_:1;
  int32_t d;
}
- (BOOL) hasD;
@property (readonly) int32_t d;

+ (ImportMessage*) defaultInstance;
- (ImportMessage*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ImportMessage_Builder*) builder;
+ (ImportMessage_Builder*) builder;
+ (ImportMessage_Builder*) builderWithPrototype:(ImportMessage*) prototype;

+ (ImportMessage*) parseFromData:(NSData*) data;
+ (ImportMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ImportMessage*) parseFromInputStream:(NSInputStream*) input;
+ (ImportMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ImportMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ImportMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ImportMessage_Builder : PBGeneratedMessage_Builder {
@private
  ImportMessage* result;
}

- (ImportMessage*) defaultInstance;

- (ImportMessage_Builder*) clear;
- (ImportMessage_Builder*) clone;

- (ImportMessage*) build;
- (ImportMessage*) buildPartial;

- (ImportMessage_Builder*) mergeFrom:(ImportMessage*) other;
- (ImportMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ImportMessage_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasD;
- (int32_t) d;
- (ImportMessage_Builder*) setD:(int32_t) value;
- (ImportMessage_Builder*) clearD;
@end

