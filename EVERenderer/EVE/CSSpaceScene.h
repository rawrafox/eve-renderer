//
//  CSSpaceScene.h
//  EVERenderer
//
//  Created by Aurora on 27/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <simd/simd.h>

#import "CSObject.h"
#import "CSBlackReader.h"
#import "CSEffect.h"

@interface CSSpaceScene : CSObject

@property (readonly) CSEffect * backgroundEffect;
@property (readonly) bool backgroundRenderingEnabled;
@property (readonly) NSString * envMapResPath;
@property (readonly) NSString * envMap1ResPath;
@property (readonly) NSString * envMap2ResPath;
@property (readonly) vector_float4 ambientColor;
@property (readonly) float nebulaIntensity;
@property (readonly) float fogStart;
@property (readonly) float fogEnd;

@end
