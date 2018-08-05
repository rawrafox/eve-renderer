//
//  CSParticleElementDeclaration.m
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSParticleElementDeclaration.h"

@implementation CSParticleElementDeclaration

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"elementType"]) {
    [reader readU32];
  } else if ([key isEqualToString: @"customName"]) {
    [reader readString];
  } else if ([key isEqualToString: @"usageIndex"]) {
    [reader readU32];
  } else if ([key isEqualToString: @"dimension"]) {
    [reader readU32];
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
