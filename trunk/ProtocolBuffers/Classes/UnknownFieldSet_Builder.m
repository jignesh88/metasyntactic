// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.
// http://code.google.com/p/protobuf/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "UnknownFieldSet_Builder.h"

#import "CodedInputStream.h"
#import "Field.h"
#import "Field_Builder.h"
#import "UnknownFieldSet.h"
#import "WireFormat.h"

@implementation UnknownFieldSet_Builder

@synthesize fields;
@synthesize lastFieldNumber;
@synthesize lastField;


- (void) dealloc {
    self.fields = nil;
    self.lastFieldNumber = 0;
    self.lastField = nil;

    [super dealloc];
}


- (id) init {
    if (self = [super init]) {
        self.fields = [NSMutableDictionary dictionary];
    }
    return self;
}


+ (UnknownFieldSet_Builder*) newBuilder {
    return [[[UnknownFieldSet_Builder alloc] init] autorelease];
}


/**
 * Add a field to the {@code UnknownFieldSet}.  If a field with the same
 * number already exists, it is removed.
 */
- (UnknownFieldSet_Builder*) addField:(Field*) field forNumber:(int32_t) number {
    if (number == 0) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"" userInfo:nil];
    }
    if (lastField != nil && lastFieldNumber == number) {
        // Discard this.
        self.lastField = nil;
        lastFieldNumber = 0;
    }
    [fields setObject:field forKey:[NSNumber numberWithInt:number]];
    return self;
}


/**
 * Get a field builder for the given field number which includes any
 * values that already exist.
 */
- (Field_Builder*) getFieldBuilder:(int32_t) number {
    if (lastField != nil) {
        if (number == lastFieldNumber) {
            return lastField;
        }
        // Note:  addField() will reset lastField and lastFieldNumber.
        [self addField:[lastField build] forNumber:lastFieldNumber];
    }
    if (number == 0) {
        return nil;
    } else {
        Field* existing = [fields objectForKey:[NSNumber numberWithInt:number]];
        lastFieldNumber = number;
        self.lastField = [Field newBuilder];
        if (existing != nil) {
            [lastField mergeFromField:existing];
        }
        return lastField;
    }
}


- (UnknownFieldSet*) build {
    [self getFieldBuilder:0];  // Force lastField to be built.
    UnknownFieldSet* result;
    if (fields.count == 0) {
        result = [UnknownFieldSet getDefaultInstance];
    } else {
        result = [UnknownFieldSet setWithFields:fields];
    }
    self.fields = nil;
    return result;
}


/** Check if the given field number is present in the set. */
- (BOOL) hasField:(int32_t) number {
    if (number == 0) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"" userInfo:nil];
    }

    return number == lastFieldNumber || ([fields objectForKey:[NSNumber numberWithInt:number]] != nil);
}


/**
 * Add a field to the {@code UnknownFieldSet}.  If a field with the same
 * number already exists, the two are merged.
 */
- (UnknownFieldSet_Builder*) mergeField:(Field*) field forNumber:(int32_t) number {
    if (number == 0) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"" userInfo:nil];
    }
    if ([self hasField:number]) {
        [[self getFieldBuilder:number] mergeFromField:field];
    } else {
        // Optimization:  We could call getFieldBuilder(number).mergeFrom(field)
        // in this case, but that would create a copy of the Field object.
        // We'd rather reuse the one passed to us, so call addField() instead.
        [self addField:field forNumber:number];
    }

    return self;
}


- (UnknownFieldSet_Builder*) mergeUnknownFields:(UnknownFieldSet*) other {
    if (other != [UnknownFieldSet getDefaultInstance]) {
        for (NSNumber* number in other.fields) {
            Field* field = [other.fields objectForKey:number];
            [self mergeField:field forNumber:[number intValue]];
        }
    }
    return self;
}


- (UnknownFieldSet_Builder*) mergeFromCodedInputStream:(CodedInputStream*) input {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}


- (UnknownFieldSet_Builder*) mergeFromData:(NSData*) data {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}


- (UnknownFieldSet_Builder*) mergeFromInputStream:(NSInputStream*) input {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}


- (UnknownFieldSet_Builder*) mergeVarintField:(int32_t) number value:(int32_t) value {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}


/**
 * Parse a single field from {@code input} and merge it into this set.
 * @param tag The field's tag number, which was already parsed.
 * @return {@code false} if the tag is an engroup tag.
 */
- (BOOL) mergeFieldFrom:(int32_t) tag input:(CodedInputStream*) input {
    int number = WireFormatGetTagFieldNumber(tag);
    switch (WireFormatGetTagWireType(tag)) {
        case WireFormatVarint:
            [[self getFieldBuilder:number] addVarint:[input readInt64]];
            return true;
        case WireFormatFixed64:
            [[self getFieldBuilder:number] addFixed64:[input readFixed64]];
            return true;
        case WireFormatLengthDelimited:
            [[self getFieldBuilder:number] addLengthDelimited:[input readData]];
            return true;
        case WireFormatStartGroup: {
            UnknownFieldSet_Builder* subBuilder = [UnknownFieldSet newBuilder];
            [input readUnknownGroup:number builder:subBuilder];
            [[self getFieldBuilder:number] addGroup:[subBuilder build]];
            return true;
        }
        case WireFormatEndGroup:
            return false;
        case WireFormatFixed32:
            [[self getFieldBuilder:number] addFixed32:[input readFixed32]];
            return true;
        default:
            @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"" userInfo:nil];
    }
}



#if 0


/**
 * Builder for {@link UnknownFieldSet}s.
 *
 * <p>Note that this class maintains {@link Field.Builder}s for all fields
 * in the set.  Thus, adding one element to an existing {@link Field} does not
 * require making a copy.  This is important for efficient parsing of
 * unknown repeated fields.  However, it implies that {@link Field}s cannot
 * be constructed independently, nor can two {@link UnknownFieldSet}s share
 * the same {@code Field} object.
 *
 * <p>Use {@link UnknownFieldSet#newBuilder()} to construct a {@code Builder}.
 */
public static final class Builder {
    private Builder() {}






    /** Reset the builder to an empty set. */
    public Builder clear() {
        fields = new TreeMap<Integer, Field>();
        lastFieldNumber = 0;
        lastField = null;
        return this;
    }

    /**
     * Merge the fields from {@code other} into this set.  If a field number
     * exists in both sets, {@code other}'s values for that field will be
     * appended to the values in this set.
     */
    public Builder mergeFrom(UnknownFieldSet other) {
        if (other != getDefaultInstance()) {
            for (Map.Entry<Integer, Field> entry : other.fields.entrySet()) {
                mergeField(entry.getKey(), entry.getValue());
            }
        }
        return this;
    }

    /**
     * Convenience method for merging a new field containing a single varint
     * value.  This is used in particular when an unknown enum value is
     * encountered.
     */
    public Builder mergeVarintField(int number, int value) {
        if (number == 0) {
            throw new IllegalArgumentException("Zero is not a valid field number.");
        }
        getFieldBuilder(number).addVarint(value);
        return this;
    }



    /**
     * Get all present {@code Field}s as an immutable {@code Map}.  If more
     * fields are added, the changes may or may not be reflected in this map.
     */
    public Map<Integer, Field> asMap() {
        getFieldBuilder(0);  // Force lastField to be built.
        return Collections.unmodifiableMap(fields);
    }

    /**
     * Parse an entire message from {@code input} and merge its fields into
     * this set.
     */
    public Builder mergeFrom(CodedInputStream input) throws IOException {
        while (true) {
            int tag = input.readTag();
            if (tag == 0 || !mergeFieldFrom(tag, input)) {
                break;
            }
        }
        return this;
    }


    /**
     * Parse {@code data} as an {@code UnknownFieldSet} and merge it with the
     * set being built.  This is just a small wrapper around
     * {@link #mergeFrom(CodedInputStream)}.
     */
    public Builder mergeFrom(ByteString data)
    throws InvalidProtocolBufferException {
        try {
            CodedInputStream input = data.newCodedInput();
            mergeFrom(input);
            input.checkLastTagWas(0);
            return this;
        } catch (InvalidProtocolBufferException e) {
            throw e;
        } catch (IOException e) {
            throw new RuntimeException(
                                       "Reading from a ByteString threw an IOException (should " +
                                       "never happen).", e);
        }
    }

    /**
     * Parse {@code data} as an {@code UnknownFieldSet} and merge it with the
     * set being built.  This is just a small wrapper around
     * {@link #mergeFrom(CodedInputStream)}.
     */
    public Builder mergeFrom(byte[] data)
    throws InvalidProtocolBufferException {
        try {
            CodedInputStream input = CodedInputStream.newInstance(data);
            mergeFrom(input);
            input.checkLastTagWas(0);
            return this;
        } catch (InvalidProtocolBufferException e) {
            throw e;
        } catch (IOException e) {
            throw new RuntimeException(
                                       "Reading from a byte array threw an IOException (should " +
                                       "never happen).", e);
        }
    }

    /**
     * Parse an {@code UnknownFieldSet} from {@code input} and merge it with the
     * set being built.  This is just a small wrapper around
     * {@link #mergeFrom(CodedInputStream)}.
     */
    public Builder mergeFrom(InputStream input) throws IOException {
        CodedInputStream codedInput = CodedInputStream.newInstance(input);
        mergeFrom(codedInput);
        codedInput.checkLastTagWas(0);
        return this;
    }
}
#endif

@end
