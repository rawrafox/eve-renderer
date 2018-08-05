//
//  CSResourceManager.h
//  EVERenderer
//
//  Created by Aurora on 01/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSResourceManager : NSObject

- (void) addProtocol: (NSString *)protocol resourceIndex: (NSString *)name url: (NSURL *)url;
- (void) addProtocol: (NSString *)protocol resourceJSON: (NSString *)name url: (NSURL *)url;

- (void) loadDataFromURL: (NSURL *)url callback: (void(^)(NSData *))callback;
- (void) loadRedObjectFromURL: (NSURL *)url callback: (void(^)(id))callback;
- (void) loadBlackObjectFromURL: (NSURL *)url callback: (void(^)(id))callback;

@end
