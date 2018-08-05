//
//  CSEffect.h
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <simd/simd.h>

#import "CSObject.h"
#import "CSTextureParameter.h"

@interface CSConstantParameter : NSObject

- (nonnull instancetype) initWithKey: (NSString *) key andValue: (vector_float4) value;

@property (readonly) NSString * key;
@property (readonly) vector_float4 value;

@end

@interface CSEffect : CSObject

@property (readonly) NSString * effectFilePath;
@property (readonly) NSArray<CSConstantParameter *> * constParameters;
@property (readonly) NSArray<CSTextureParameter *> * resources;

@end
