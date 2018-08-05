//
//  CSStaticEmitter.m
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSStaticEmitter.h"

@implementation CSStaticEmitter

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"geometryResourcePath"]) {
    _geometryResourcePath = [reader readString];
  } else if ([key isEqualToString: @"particleSystem"]) {
    id particleSystem = [reader readElement];
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
