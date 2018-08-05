//
//  CSContext.m
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#include <mach/mach_time.h>

#include <CoreServices/CoreServices.h>

#import "CSContext.h"

@implementation CSContext {
  double timebase;
}

-(nonnull instancetype) initWithDevice: (nonnull id<MTLDevice>)device {
  if (self = [super init]) {
    _device = device;

    mach_timebase_info_data_t tb;
    mach_timebase_info(&tb);

    timebase = (double)tb.numer / (double)tb.denom;

    _startTime = self.currentTime;

    _resourceManager = [[CSResourceManager alloc] init];

    [self.resourceManager addProtocol: @"res" resourceJSON: @"res.1097993" url: [NSURL URLWithString: @"https://web.ccpgamescdn.com/ccpwgl/res/"]];
    [self.resourceManager addProtocol: @"eve" resourceIndex: @"resfileindex" url: [NSURL URLWithString: @"https://resources.eveonline.com/"]];
    [self.resourceManager loadRedObjectFromURL: [NSURL URLWithString: @"res:/dx9/scene/universe/m10_cube.red"] callback: ^(id data) { NSLog(@"Red: %@", data); }];
    [self.resourceManager loadBlackObjectFromURL: [NSURL URLWithString: @"eve:/dx9/scene/abyssal/ad01_a_cube.black"] callback: ^(id data) {
      NSLog(@"Black: %@", data);
    }];

    [self.resourceManager loadBlackObjectFromURL: [NSURL URLWithString: @"eve:/dx9/scene/starfield/universe.black"] callback: ^(id data) {
      NSLog(@"Black: %@", data);
    }];
  }

  return self;
}

- (double) currentTime {
  return timebase * mach_absolute_time();
}

@end
