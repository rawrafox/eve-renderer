//
//  Shaders.metal
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(constant CSPerFrameVS & perFrame [[buffer(2)]], Vertex in [[stage_in]]) {
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    out.position = perFrame.viewProjection * position;
    out.texCoord = in.texCoord;

    return out;
}

fragment half4 fragmentShader(ColorInOut in [[stage_in]], texture2d<half> colorMap [[texture(TextureIndexColor)]]) {
    constexpr sampler colorSampler(mip_filter::linear, mag_filter::linear, min_filter::linear);

    return colorMap.sample(colorSampler, in.texCoord.xy);
}
