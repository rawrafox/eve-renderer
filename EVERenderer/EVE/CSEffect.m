//
//  CSEffect.m
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSEffect.h"

@implementation CSConstantParameter

- (nonnull instancetype) initWithKey: (NSString *) key andValue: (vector_float4) value {
  if (self = [super init]) {
    _key = key;
    _value = value;
  }

  return self;
}

@end

@implementation CSEffect

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"effectFilePath"]) {
    _effectFilePath = [reader readString];
  } else if ([key isEqualToString: @"constParameters"]) {
    uint32_t length = [reader readU32];

    NSMutableArray * constParameters = [NSMutableArray arrayWithCapacity: length];

    uint16_t a = [reader readU16];
    if (a != 0x0018) {
      NSLog(@"Mysterious number: %u", a);
      return nil;
    }

    for (uint32_t i = 0; i < length; i++) {
      NSString * key = [reader readString];
      uint16_t b = [reader readU16];
      uint16_t c = [reader readU16];
      uint16_t d = [reader readU16];

      if (b != 0 || c != 0 || d != 0) {
        NSLog(@"Mysterious numbers: %u %u %u", b, c, d);
        return nil;
      }

      vector_float4 value = [reader readFloat4];

      [constParameters addObject: [[CSConstantParameter alloc] initWithKey: key andValue: value]];
    }

    _constParameters = constParameters;
  } else if ([key isEqualToString: @"resources"]) {
    uint32_t length = [reader readU32];

    NSMutableArray * resources = [NSMutableArray arrayWithCapacity: length];

    for (uint32_t i = 0; i < length; i++) {
      [resources addObject: [reader readElement]];
    }

    _resources = resources;
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
