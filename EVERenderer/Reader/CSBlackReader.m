//
//  CSBlackReader.m
//  EVERenderer
//
//  Created by Aurora on 02/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSBlackReader.h"
#import "CSSpaceScene.h"
#import "CSEffect.h"
#import "CSParticleElementDeclaration.h"
#import "CSParticleSystem.h"
#import "CSStaticEmitter.h"
#import "CSTextureParameter.h"
#import "CSTransform.h"
#import "CSInstancedMesh.h"

@implementation CSBlackReader {
  NSData * data;
  NSInteger cursor;

  NSArray<NSString *> * strings;
}

- (instancetype) initWithData: (NSData *)black andStrings: (NSArray<NSString *> *)s {
  if (self = [super init]) {
    data = black;
    cursor = 0;
    strings = s;
  }

  return self;
}

- (instancetype) initWithData: (NSData *)black {
  data = black;

  uint32_t a = [self readU32];
  uint32_t b = [self readU32];

  if (a != 0xB1ACF11E || b != 1) {
    NSLog(@"Unexpected content in .black");
    return nil;
  }

  data = [self readData: [self readU32]];
  NSInteger savedCursor = cursor;
  cursor = 0;
  uint16_t count = [self readU16];

  NSMutableArray * s = [NSMutableArray arrayWithCapacity: count];

  for (uint32_t i = 0; i < count; i++) {
    const char * string = [data bytes];
    unsigned long length = strlen(string + cursor);
    [s addObject: [[NSString alloc] initWithData: [self readData: length] encoding: NSUTF8StringEncoding]];
    cursor += 1; // Avoid null byte
  }

  data = black;
  cursor = savedCursor;

  uint16_t c = [self readU16];
  uint16_t d = [self readU16];
  uint16_t e = [self readU16];

  if (c != 2 || d != 0 || e != 0) {
    NSLog(@"Unexpected content in .black");
    return nil;
  }

  NSRange range = NSMakeRange(cursor, [data length] - cursor);

  return [self initWithData: [data subdataWithRange: range] andStrings: s];
}

- (NSData *) readData: (NSInteger) length {
  NSData * subdata = [data subdataWithRange: NSMakeRange(cursor, length)];

  cursor += length;

  return subdata;
}

- (NSData *) readToEnd {
  NSRange range = NSMakeRange(cursor, [data length] - cursor);

  return [data subdataWithRange: range];
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

- (bool) readBoolean {
  return [self readU8] != 0;
}

- (float) readFloat {
  NSData * subdata = [self readData: 4];
  const float * ptr = [subdata bytes];
  return *ptr;
}

- (vector_float4) readFloat4 {
  return vector4([self readFloat], [self readFloat], [self readFloat], [self readFloat]);
}

- (NSString *) readString {
  return [strings objectAtIndex: [self readU16]];
}

- (id) readElement {
  uint32_t identifier = [self readU32];

  CSBlackReader * reader = [[CSBlackReader alloc] initWithData: [self readData: [self readU32]] andStrings: strings];

  NSString * type = [reader readString];

  if ([type isEqualToString: @"EveSpaceScene"]) {
    return [[CSSpaceScene alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"EveTransform"]) {
    return [[CSTransform alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"Tr2Effect"]) {
    return [[CSEffect alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"Tr2ParticleElementDeclaration"]) {
    return [[CSParticleElementDeclaration alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"Tr2ParticleSystem"]) {
    return [[CSParticleSystem alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"Tr2StaticEmitter"]) {
    return [[CSStaticEmitter alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"Tr2InstancedMesh"]) {
    return [[CSInstancedMesh alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else if ([type isEqualToString: @"TriTextureParameter"]) {
    return [[CSTextureParameter alloc] initWithIdentifier: identifier fromBlackReader: reader];
  } else {
    NSLog(@"Root is of type %@", type);
    return nil;
  }
}

- (bool) endOfStream {
  return [data length] <= cursor;
}

- (bool) expectString: (NSString *)key {
  NSString * k = [self readString];

  if (![k isEqualToString: key]) {
    NSLog(@"Unknown key %@, expected %@", k, key);
    return false;
  }

  return true;
}

- (NSString *) peekString {
  const uint8_t * ptr = [data bytes] + cursor;

  return [strings objectAtIndex: *((uint16_t *)ptr)];
}

@end
