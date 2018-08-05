//
//  CSTransform.m
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSTransform.h"

@implementation CSTransform

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"children"]) {
    uint32_t length = [reader readU32];

    NSMutableArray * children = [NSMutableArray arrayWithCapacity: length];

    for (uint32_t i = 0; i < length; i++) {
      [children addObject: [reader readElement]];
    }

    _children = children;
  } else if ([key isEqualToString: @"particleEmitters"]) {
    uint32_t length = [reader readU32];

    NSMutableArray * particleEmitters = [NSMutableArray arrayWithCapacity: length];

    for (uint32_t i = 0; i < length; i++) {
      [particleEmitters addObject: [reader readElement]];
    }

    _particleEmitters = particleEmitters;
  } else if ([key isEqualToString: @"particleSystems"]) {
    uint32_t length = [reader readU32];
    [reader readToEnd];
  } else if ([key isEqualToString: @"geometryResourcePath"]) {
    _geometryResourcePath = [reader readString];
  } else if ([key isEqualToString: @"mesh"]) {
    _mesh = [reader readElement];
  } else if ([key isEqualToString: @"modifier"]) {
    _modifier = [reader readU32];
  } else if ([key isEqualToString: @"name"]) {
    _name = [reader readString];
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
