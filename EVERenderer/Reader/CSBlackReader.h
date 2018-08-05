//
//  CSBlackReader.h
//  EVERenderer
//
//  Created by Aurora on 02/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <simd/simd.h>

#import <Foundation/Foundation.h>

@interface CSBlackReader : NSObject

- (instancetype) initWithData: (NSData *)black andStrings: (NSArray<NSString *> *)strings;
- (instancetype) initWithData: (NSData *)data;

- (NSData *) readData: (NSInteger) length;
- (NSData *) readToEnd;

- (uint8_t) readU8;
- (uint16_t) readU16;
- (uint32_t) readU32;

- (bool) readBoolean;
- (float) readFloat;
- (vector_float4) readFloat4;
- (NSString *) readString;

- (id) readElement;

- (bool) endOfStream;

- (bool) expectString: (NSString *)key;
- (NSString *) peekString;

@end
