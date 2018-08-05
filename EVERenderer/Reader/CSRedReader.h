//
//  CSRedReader.h
//  EVERenderer
//
//  Created by Aurora on 02/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSRedReader : NSObject

- (instancetype) initWithData: (NSData *)data;

- (id) readElement;

@end
