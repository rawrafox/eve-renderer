//
//  CSObject.m
//  EVERenderer
//
//  Created by Aurora on 02/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSObject.h"

@implementation CSObject

- (nonnull instancetype) initWithIdentifier: (uint32_t) identifier fromBlackReader: (CSBlackReader *)reader {
  if (self = [super init]) {
    _identifier = identifier;

    while(![reader endOfStream]) {
      NSString * key = [reader readString];

      if (![self readProperty: key from: reader]) {
        return nil;
      }
    }
  }

  return self;
}

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader {
  NSLog(@"Unknown property: %@ in %@: %@", key, self, [reader readToEnd]);

  return false;
}

@end
