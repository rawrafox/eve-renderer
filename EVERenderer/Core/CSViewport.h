//
//  CSViewport.h
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <simd/simd.h>

#import <MetalKit/MetalKit.h>

#import "CSContext.h"

@class CSViewport;

@protocol CSViewportDelegate <NSObject>

- (void) beforeFrameForViewport: (nonnull CSViewport *)viewport;
- (void) afterFrameForViewport: (nonnull CSViewport *)viewport;

@end


@interface CSViewport : NSObject <MTKViewDelegate>

- (nonnull instancetype) initWithContext: (nonnull CSContext *)context andView: (nonnull MTKView *)view;

@property (weak) id<CSViewportDelegate> delegate;

@property double startTime;
@property double currentTime;
@property double previousTime;
@property double deltaTime;

@property vector_float3 eyePosition;
@property vector_float2 targetResolution;
@property (readonly) float aspectRatio;
@property (readonly) vector_float2 fovXY;
@property (nonatomic) matrix_float4x4 world; // TODO: Part of context?
@property (nonatomic, readonly) matrix_float4x4 worldInverse;
@property (nonatomic) matrix_float4x4 view;
@property (nonatomic, readonly) matrix_float4x4 viewInverse;
@property (nonatomic) matrix_float4x4 projection;
@property (nonatomic, readonly) matrix_float4x4 projectionInverse;
@property (nonatomic, readonly) matrix_float4x4 projectionTranspose;
@property (nonatomic, readonly) matrix_float4x4 viewProjection;
@property (nonatomic, readonly) matrix_float4x4 viewProjectionTranspose;

@end
