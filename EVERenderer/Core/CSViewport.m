//
//  CSViewport.m
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <ModelIO/ModelIO.h>

#import "CSViewport.h"
#import "CSMatrix.h"
#import "ShaderTypes.h"

static const NSUInteger kMaxBuffersInFlight = 3;

@implementation CSViewport {
  CSContext * context;

  dispatch_semaphore_t semaphore;

  id<MTLDevice> device;

  id <MTLCommandQueue> _commandQueue;

  id <MTLBuffer> perFrameVS[kMaxBuffersInFlight];
  id <MTLBuffer> perFrameFS[kMaxBuffersInFlight];

  id <MTLRenderPipelineState> _pipelineState;
  id <MTLDepthStencilState> _depthState;
  id <MTLTexture> _colorMap;
  MTLVertexDescriptor *_mtlVertexDescriptor;

  uint32_t _uniformBufferOffset;

  uint8_t _uniformBufferIndex;

  void* _uniformBufferAddress;

  matrix_float4x4 _projectionMatrix;

  float _rotation;

  MTKMesh *_mesh;
}

- (nonnull instancetype) initWithContext: (nonnull CSContext *)context andView: (nonnull MTKView *)view {
  if(self = [super init]) {
    context = context;
    semaphore = dispatch_semaphore_create(kMaxBuffersInFlight);
    device = context.device;
    [self _loadMetalWithView: view];
    [self _loadAssets];
  }

  return self;
}

- (matrix_float4x4) viewProjection {
  return matrix_multiply(self.projection, self.view);
}

- (void)_loadMetalWithView:(nonnull MTKView *)view;
{
  /// Load Metal state objects and initalize renderer dependent view properties

  view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
  view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
  view.sampleCount = 1;

  _mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

  _mtlVertexDescriptor.attributes[VertexAttributePosition].format = MTLVertexFormatFloat3;
  _mtlVertexDescriptor.attributes[VertexAttributePosition].offset = 0;
  _mtlVertexDescriptor.attributes[VertexAttributePosition].bufferIndex = BufferIndexMeshPositions;

  _mtlVertexDescriptor.attributes[VertexAttributeTexcoord].format = MTLVertexFormatFloat2;
  _mtlVertexDescriptor.attributes[VertexAttributeTexcoord].offset = 0;
  _mtlVertexDescriptor.attributes[VertexAttributeTexcoord].bufferIndex = BufferIndexMeshGenerics;

  _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride = 12;
  _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepRate = 1;
  _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;

  _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stride = 8;
  _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepRate = 1;
  _mtlVertexDescriptor.layouts[BufferIndexMeshGenerics].stepFunction = MTLVertexStepFunctionPerVertex;

  id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];

  id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName: @"vertexShader"];
  id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName: @"fragmentShader"];

  MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
  pipelineStateDescriptor.label = @"MyPipeline";
  pipelineStateDescriptor.sampleCount = view.sampleCount;
  pipelineStateDescriptor.vertexFunction = vertexFunction;
  pipelineStateDescriptor.fragmentFunction = fragmentFunction;
  pipelineStateDescriptor.vertexDescriptor = _mtlVertexDescriptor;
  pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
  pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
  pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;

  NSError *error = NULL;
  _pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error: &error];
  if (!_pipelineState) {
    NSLog(@"Failed to created pipeline state, error %@", error);
  }

  MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
  depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
  depthStateDesc.depthWriteEnabled = YES;
  _depthState = [device newDepthStencilStateWithDescriptor:depthStateDesc];

  for(NSUInteger i = 0; i < kMaxBuffersInFlight; i++) {
    perFrameVS[i] = [device newBufferWithLength: sizeof(CSPerFrameVS) options: MTLResourceStorageModeShared];
    perFrameFS[i] = [device newBufferWithLength: sizeof(CSPerFrameFS) options: MTLResourceStorageModeShared];
  }

  _commandQueue = [device newCommandQueue];
}

- (void)_loadAssets
{
  /// Load assets into metal objects

  NSError *error;

  MTKMeshBufferAllocator *metalAllocator = [[MTKMeshBufferAllocator alloc]
                                            initWithDevice: device];

  MDLMesh *mdlMesh = [MDLMesh newBoxWithDimensions:(vector_float3){4, 4, 4}
                                          segments:(vector_uint3){2, 2, 2}
                                      geometryType:MDLGeometryTypeTriangles
                                     inwardNormals:NO
                                         allocator:metalAllocator];

  MDLVertexDescriptor *mdlVertexDescriptor =
  MTKModelIOVertexDescriptorFromMetal(_mtlVertexDescriptor);

  mdlVertexDescriptor.attributes[VertexAttributePosition].name  = MDLVertexAttributePosition;
  mdlVertexDescriptor.attributes[VertexAttributeTexcoord].name  = MDLVertexAttributeTextureCoordinate;

  mdlMesh.vertexDescriptor = mdlVertexDescriptor;

  _mesh = [[MTKMesh alloc] initWithMesh:mdlMesh
                                 device:device
                                  error:&error];

  if(!_mesh || error)
  {
    NSLog(@"Error creating MetalKit mesh %@", error.localizedDescription);
  }

  MTKTextureLoader* textureLoader = [[MTKTextureLoader alloc] initWithDevice: device];

  NSDictionary *textureLoaderOptions =
  @{
    MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
    MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate)
    };

  _colorMap = [textureLoader newTextureWithName:@"ColorMap"
                                    scaleFactor:1.0
                                         bundle:nil
                                        options:textureLoaderOptions
                                          error:&error];

  if(!_colorMap || error)
  {
    NSLog(@"Error creating texture %@", error.localizedDescription);
  }
}

- (void)_updateGameState {
  _uniformBufferIndex = (_uniformBufferIndex + 1) % kMaxBuffersInFlight;

  /// Update any game state before encoding renderint commands to our drawable

  CSPerFrameVS * vs = [perFrameVS[_uniformBufferIndex] contents];

  vector_float3 rotationAxis = {1, 1, 0};
  matrix_float4x4 modelMatrix = matrix4x4_rotation(_rotation, rotationAxis);

  vs->projection = self.projection;
  vs->view = self.view;
  vs->viewProjection = self.viewProjection;
  // uniforms->projectionMatrix = _projection;
  // uniforms->modelViewMatrix = matrix_multiply(self.view, modelMatrix);

  // _rotation += .01;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
  /// Per frame updates here

  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

  self->_previousTime = self->_currentTime;
  self->_currentTime = self->context.currentTime;
  self->_deltaTime = self->_currentTime - self->_previousTime;

  [self.delegate beforeFrameForViewport: self];

  id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
  commandBuffer.label = @"MyCommand";

  __block dispatch_semaphore_t block_sema = semaphore;
  [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
    [self.delegate afterFrameForViewport: self];
    dispatch_semaphore_signal(block_sema);
   }];

  [self _updateGameState];

  /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
  ///   holding onto the drawable and blocking the display pipeline any longer than necessary
  MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;

  if(renderPassDescriptor != nil) {

    /// Final pass rendering code here

    id <MTLRenderCommandEncoder> renderEncoder =
    [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    renderEncoder.label = @"MyRenderEncoder";

    [renderEncoder pushDebugGroup:@"DrawBox"];

    [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderEncoder setCullMode:MTLCullModeBack];
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setDepthStencilState:_depthState];

    [renderEncoder setVertexBuffer: perFrameVS[_uniformBufferIndex] offset: 0 atIndex: 2];
    // [renderEncoder setFragmentBuffer: perFrameFS[_uniformBufferIndex] offset: 0 atIndex: 1];

    for (NSUInteger bufferIndex = 0; bufferIndex < _mesh.vertexBuffers.count; bufferIndex++) {
      MTKMeshBuffer *vertexBuffer = _mesh.vertexBuffers[bufferIndex];
      if((NSNull*)vertexBuffer != [NSNull null])
      {
        [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                offset:vertexBuffer.offset
                               atIndex:bufferIndex];
      }
    }

    [renderEncoder setFragmentTexture:_colorMap
                              atIndex:TextureIndexColor];

    for (MTKSubmesh *submesh in _mesh.submeshes) {
      [renderEncoder drawIndexedPrimitives:submesh.primitiveType
                                indexCount:submesh.indexCount
                                 indexType:submesh.indexType
                               indexBuffer:submesh.indexBuffer.buffer
                         indexBufferOffset:submesh.indexBuffer.offset];
    }

    [renderEncoder popDebugGroup];

    [renderEncoder endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];
  }

  [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
  /// Respond to drawable size or orientation changes here

  float aspect = size.width / (float)size.height;
  _projection = matrix_perspective_right_hand(65.0f * (M_PI / 180.0f), aspect, 0.1f, 100.0f);
}

@end
