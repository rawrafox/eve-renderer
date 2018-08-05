//
//  GameViewController.m
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "GameViewController.h"
#import "CSContext.h"
#import "CSViewport.h"
#import "CSMatrix.h"

#define CAMERA_ZOOM_MIN 0.1f
#define CAMERA_ZOOM_MAX 1000000.0f
#define CAMERA_ZOOM_SCALE 0.01f
#define CAMERA_DRAG_SCALE 0.005f

@implementation GameViewController {
  MTKView * metalView;
  CSContext * context;
  CSViewport * viewport;

  vector_float2 rotation;
  float distance;
}

- (void) viewDidAppear {
  [metalView.window makeFirstResponder: self];
}

- (void) viewDidLoad {
  [super viewDidLoad];

  id<MTLDevice> device = MTLCreateSystemDefaultDevice();

  metalView = (MTKView *)self.view;
  metalView.device = device;

  if (device) {
    NSLog(@"Rendering on %@", [device name]);
    if (device.readWriteTextureSupport == MTLReadWriteTextureTier1) { NSLog(@" - Read/Write Texture Tier 1"); }
    if (device.readWriteTextureSupport == MTLReadWriteTextureTier2) { NSLog(@" - Read/Write Texture Tier 2"); }
    if (device.argumentBuffersSupport) { NSLog(@"  - Argument Buffers"); }
    if (device.programmableSamplePositionsSupported) { NSLog(@"  - Programmable Sample Positions"); }
    if (device.rasterOrderGroupsSupported) { NSLog(@"  - Raster Order Groups"); }
  } else {
      NSLog(@"Metal is not supported on this device");
      return exit(1);
  }

  distance = 8.0;

  context = [[CSContext alloc] initWithDevice: metalView.device];
  viewport = [[CSViewport alloc] initWithContext: context andView: metalView];
  viewport.delegate = self;

  [viewport mtkView: metalView drawableSizeWillChange: metalView.bounds.size];

  metalView.delegate = viewport;
}

- (void) beforeFrameForViewport: (CSViewport *) viewport {
  rotation.y = simd_clamp(rotation.y, -(float)M_PI_2, (float)M_PI_2);

  matrix_float4x4 view = matrix4x4_translation(0.0f, 0.0f, -distance);

  view = matrix_multiply(view, matrix4x4_rotation(rotation.y, simd_make_float3(1.0f, 0.0f, 0.0f)));
  view = matrix_multiply(view, matrix4x4_rotation(rotation.x, simd_make_float3(0.0f, 1.0f, 0.0f)));

  viewport.view = view;
}

- (void) afterFrameForViewport: (CSViewport *) viewport {
}

- (void) mouseDragged: (NSEvent *)event {
  rotation += simd_make_float2(event.deltaX, event.deltaY) * CAMERA_DRAG_SCALE;
}

- (void) scrollWheel: (NSEvent *)event {
  float value = distance + event.deltaY * distance * CAMERA_ZOOM_SCALE;

  distance = simd_clamp(value, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);
}

@end
