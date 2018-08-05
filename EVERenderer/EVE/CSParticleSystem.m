//
//  CSParticleSystem.m
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSParticleSystem.h"

@implementation CSParticleSystem

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"elements"]) {
    uint32_t length = [reader readU32];

    NSMutableArray * elements = [NSMutableArray arrayWithCapacity: length];

    for (uint32_t i = 0; i < length; i++) {
      [elements addObject: [reader readElement]];
    }
  } else if ([key isEqualToString: @"updateSimulation"]) {
    [reader readBoolean];
  } else if ([key isEqualToString: @"applyAging"]) {
    [reader readBoolean];
  } else if ([key isEqualToString: @"maxParticleCount"]) {
    [reader readU32];
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
