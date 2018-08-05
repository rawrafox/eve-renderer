//
//  CSTextureParameter.m
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSTextureParameter.h"

@implementation CSTextureParameter

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  if ([key isEqualToString: @"name"]) {
    _name = [reader readString];
  } else if ([key isEqualToString: @"resourcePath"]) {
    _name = [reader readString];
  } else {
    return [super readProperty: key from: reader];
  }

  return true;
}

@end
