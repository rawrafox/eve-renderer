//
//  CSContext.h
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <Metal/Metal.h>

#import "CSResourceManager.h"

@interface CSContext : NSObject

-(nonnull instancetype) initWithDevice: (nonnull id<MTLDevice>)device;

@property (readonly) id<MTLDevice> device;

@property (readonly) CSResourceManager * resourceManager;

@property double startTime;
@property (readonly) double currentTime;

@end
