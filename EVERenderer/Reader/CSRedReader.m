//
//  CSRedReader.m
//  EVERenderer
//
//  Created by Aurora on 02/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSRedReader.h"

#define ID_BIT (1 << 6)
#define REFERENCE_BIT (1 << 7)

#define NONE 0
#define BOOL 1
#define INT 2
#define UINT 3
#define FLOAT 4
#define STRING 5
#define ARRAY 6
#define MAPPING 7
#define OBJECT 8
#define TYPED_ARRAY 9
#define TYPED_MAPPING 10

#define SMALL 0
#define MEDIUM (1 << 4)
#define LARGE (2 << 4)

@implementation CSRedReader {
  NSData * data;
  NSInteger cursor;

  NSArray<NSString *> * strings;
  NSMutableDictionary<NSNumber *, id> * references;
}

- (instancetype) initWithData: (NSData *)red {
  if (self = [super init]) {
    data = red;

    if (![[self readString: 6] isEqualToString: @"binred"]) {
      return nil;
    }

    uint32_t count = [self readU32];

    NSMutableArray * s = [NSMutableArray arrayWithCapacity: count];

    for (uint32_t i = 0; i < count; i++) {
      [s insertObject: [self readString: [self readU16]] atIndex: i];
    }

    strings = s;
    references = [NSMutableDictionary dictionary];
  }

  return self;
}

- (NSData *) readData: (NSInteger) length {
  NSData * subdata = [data subdataWithRange: NSMakeRange(cursor, length)];

  cursor += length;

  return subdata;
}

- (uint8_t) readU8 {
  NSData * subdata = [self readData: 1];
  const uint8_t * ptr = [subdata bytes];
  return *ptr;
}

- (uint16_t) readU16 {
  NSData * subdata = [self readData: 2];
  const uint16_t * ptr = [subdata bytes];
  return *ptr;
}

- (uint32_t) readU32 {
  NSData * subdata = [self readData: 4];
  const uint32_t * ptr = [subdata bytes];
  return *ptr;
}

- (uint32_t) readUint: (uint8_t) type {
  switch (type & 0x30) {
    case SMALL:
      return [self readU8];
    case MEDIUM:
      return [self readU16];
    default:
      return [self readU32];
  }
}

- (float) readF16 {
  uint8_t b1 = [self readU8];
  uint8_t b2 = [self readU8];

  int sign = 1 - (2 * (b1 >> 7));
  int exp = ((b1 >> 2) & 0x1f) - 15;
  int sig = ((b1 & 3) << 8) | b2;

  if (sig == 0 && exp == -15) {
    return 0.0;
  } else {
    NSLog(@"F16: %u %u", b1, b2);
    return sign * (1 + sig * powf(2, -10)) * powf(2, exp);
  }
}

- (float) readF32 {
  NSData * subdata = [self readData: 4];
  NSLog(@"F32: %@", subdata);
  const float * ptr = [subdata bytes];
  return *ptr;
}

- (double) readF64 {
  NSData * subdata = [self readData: 8];
  NSLog(@"F64: %@", subdata);
  const double * ptr = [subdata bytes];
  return *ptr;
}

- (double) readFloat: (uint8_t) type {
  switch (type & 0x30) {
    case SMALL:
      return [self readF16];
    case MEDIUM:
      return [self readF32];
    default:
      return [self readF64];
  }
}

- (NSString *) readString: (NSInteger) length {
  return [[NSString alloc] initWithData: [self readData: length] encoding: NSUTF8StringEncoding];
}

- (id) readElement {
  uint8_t type = [self readU8];

  if (type == REFERENCE_BIT) {
    return nil;
  }

  id result;

  if ((type & ID_BIT) != 0) {
    uint16_t identifier = [self readU16];
    result = [self readElementData: type & 0x3F];
    [references setObject: result forKey: [NSNumber numberWithUnsignedShort: identifier]];
  } else {
    result = [self readElementData: type & 0x3F];
  }

  return result;
}

- (id) readElementData: (uint8_t)type {
  uint8_t t = type & 0x0F;

  if (t == NONE) {
    return nil;
  } else if (t == BOOL) {
    NSLog(@"Unknown type: %u", type & 0x0F);
    return nil;
  } else if (t == INT) {
    NSLog(@"Unknown type: %u", type & 0x0F);
    return nil;
  } else if (t == UINT) {
    return [NSNumber numberWithUnsignedInt: [self readUint: type]];
    return nil;
  }  else if (t == FLOAT) {
    return [NSNumber numberWithDouble: [self readFloat: type]];
  } else if (t == STRING) {
    return [strings objectAtIndex: [self readUint: type]];
  } else if (t == ARRAY) {
    NSLog(@"Unknown type: %u", type & 0x0F);
    return nil;
  } else if (t == MAPPING) {
    uint32_t count = [self readUint: type];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity: count];
    for (uint32_t i = 0; i < count; i++) {
      NSString * key = [strings objectAtIndex: [self readUint: type]];

      [dictionary setObject: [self readElement] forKey: key];
    }

    return dictionary;
  } else if (t == OBJECT) {
    uint32_t count = [self readUint: type];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity: count];
    for (uint32_t i = 0; i < count; i++) {
      NSString * key = [strings objectAtIndex: [self readUint: type]];

      [dictionary setObject: [self readElement] forKey: key];
    }

    return dictionary;
  } else if (t == TYPED_ARRAY) {
    uint32_t count = [self readUint: type];
    uint8_t elementType = [self readU8];

    NSMutableArray * result = [NSMutableArray array];
    for (uint32_t i = 0; i < count; ++i) {
      [result addObject: [self readElementData: elementType]];
    }

    return result;
  } else if (t == TYPED_MAPPING) {
    uint32_t count = [self readUint: type];
    uint8_t elementType = [self readU8];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity: count];
    for (uint32_t i = 0; i < count; i++) {
      NSString * key = [strings objectAtIndex: [self readUint: type]];

      [dictionary setObject: [self readElementData: elementType] forKey: key];
    }

    return dictionary;
  } else {
    NSLog(@"Unknown type: %u", type & 0x0F);
    return nil;
  }
}

@end
