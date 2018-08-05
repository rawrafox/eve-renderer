//
//  GameViewController.h
//  EVERenderer
//
//  Created by Aurora on 26/07/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#import "CSViewport.h"

// Our macOS view controller.
@interface GameViewController : NSViewController <CSViewportDelegate>

@end
