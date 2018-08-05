//
//  CSObject.h
//  EVERenderer
//
//  Created by Aurora on 02/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSBlackReader.h"

@interface CSObject : NSObject

- (instancetype) initWithIdentifier: (uint32_t) identifier fromBlackReader: (CSBlackReader *)reader;

@property (readonly) uint32_t identifier;

- (bool) readProperty: (NSString *)key from: (CSBlackReader *)reader;

@end
