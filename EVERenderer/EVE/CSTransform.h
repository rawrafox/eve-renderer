//
//  CSTransform.h
//  EVERenderer
//
//  Created by Aurora on 04/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSObject.h"
#import "CSInstancedMesh.h"

@interface CSTransform : CSObject

@property (readonly) NSArray * children;
@property (readonly) NSArray * particleEmitters;
// @property (readonly) NSArray * particleSystems;
@property (readonly) NSString * geometryResourcePath;
@property (readonly) CSInstancedMesh * mesh;
@property (readonly) uint32_t modifier;
@property (readonly) NSString * name;

@end
