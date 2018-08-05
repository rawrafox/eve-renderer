//
//  ShaderTypes.h
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor    = 0,
};

typedef struct {
  matrix_float4x4 viewInverseTranspose;
  matrix_float4x4 viewProjection;
  matrix_float4x4 view;
  matrix_float4x4 projection;
  matrix_float4x4 shadowView;
  matrix_float4x4 shadowViewProjection;
  matrix_float4x4 envMapRotation;
  vector_float4 sunDirection;
  vector_float4 sunDiffuseColor;
  vector_float4 fogFactors;
  vector_float4 targetResolution;
  vector_float4 viewportAdjustment;
  vector_float4 miscSettings;
} CSPerFrameVS;

typedef struct {
  matrix_float4x4 viewInverseTranspose;
  matrix_float4x4 view;
  matrix_float4x4 envMapRotation;
  vector_float4 sunDirection;
  vector_float4 sunDiffuseColor;
  float sceneAmbientColor[3];
  float sceneNebulaIntensity;
  vector_float4 sceneFogColor;
  vector_float2 viewportOffset;
  vector_float2 viewportSize;
  vector_float4 targetResolution;
  vector_float4 shadowMapSettings;
  vector_float4 shadowCameraRange;
  vector_float2 projectionToView;
  vector_float4 miscSettings;
} CSPerFrameFS;

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} Uniforms;

#endif /* ShaderTypes_h */

