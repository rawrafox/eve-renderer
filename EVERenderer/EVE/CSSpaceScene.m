//
//  CSSpaceScene.m
//  EVERenderer
//
//  Created by Aurora on 27/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSSpaceScene.h"

@implementation CSSpaceScene

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"backgroundEffect"]) {
    _backgroundEffect = [reader readElement];

    if (![[CSEffect class] isEqual: [_backgroundEffect class]]) {
      NSLog(@"%@ is of wrong class, expected CSEffect", _backgroundEffect);
    }
  } else if ([key isEqualToString: @"backgroundRenderingEnabled"]) {
    _backgroundRenderingEnabled = [reader readBoolean];
  } else if ([key isEqualToString: @"envMapResPath"]) {
    _envMapResPath = [reader readString];
  } else if ([key isEqualToString: @"envMap1ResPath"]) {
    _envMap1ResPath = [reader readString];
  } else if ([key isEqualToString: @"envMap2ResPath"]) {
    _envMap2ResPath = [reader readString];
  } else if ([key isEqualToString: @"ambientColor"]) {
    _ambientColor = [reader readFloat4];
  } else if ([key isEqualToString: @"nebulaIntensity"]) {
    _nebulaIntensity = [reader readFloat];
  } else if ([key isEqualToString: @"fogStart"]) {
    _fogStart = [reader readFloat];
  } else if ([key isEqualToString: @"fogEnd"]) {
    _fogEnd = [reader readFloat];
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
