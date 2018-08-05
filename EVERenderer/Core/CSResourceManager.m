//
//  CSResourceManager.m
//  EVERenderer
//
//  Created by Aurora on 01/08/2018.
//  Copyright © 2018 Aventine. All rights reserved.
//

#import "CSResourceManager.h"

#import "CSRedReader.h"
#import "CSBlackReader.h"

@interface CSResourceLoader : NSObject

- (instancetype) initWithResourceIndex: (NSDictionary<NSString *, NSString *> *)index url: (NSURL *)url;

- (NSData *) loadPath: (NSString *)path;

@end

@implementation CSResourceLoader {
  NSDictionary<NSString *, NSString *> * resourceIndex;
  NSURL * cdn;
}

- (instancetype) initWithResourceIndex: (NSDictionary<NSString *, NSString *> *)index url: (NSURL *)url {
  if (self = [super init]) {
    resourceIndex = index;
    cdn = url;

    NSError * error;
    [[NSFileManager defaultManager] createDirectoryAtPath: [cdn host] withIntermediateDirectories: true attributes: nil error: &error];

    if (error) {
      NSLog(@"Error creating resource loader: %@", error);
      return nil;
    }
  }

  return self;
}

- (NSData *) loadPath: (NSString *)path {
  NSString * cdnPath = [resourceIndex objectForKey: [path substringFromIndex: 1]];
  NSString * cachePath = [NSString stringWithFormat: @"%@/%@", [cdn host], cdnPath];
  NSData * data;

  if ([[NSFileManager defaultManager] fileExistsAtPath: cachePath]) {
    data = [NSData dataWithContentsOfFile: cachePath];
  } else {
    data = [NSData dataWithContentsOfURL: [cdn URLByAppendingPathComponent: cdnPath]];

    NSError * error;
    [[NSFileManager defaultManager] createDirectoryAtPath: [cachePath stringByDeletingLastPathComponent] withIntermediateDirectories: true attributes: nil error: &error];

    if (error) {
      NSLog(@"Error caching resource: %@", error);
      return nil;
    }

    [data writeToFile: cachePath atomically: true];
  }

  return data;
}

@end

@implementation CSResourceManager {
  NSMutableDictionary<NSString *, CSResourceLoader *> * loaders;
}

- (instancetype) init {
  if (self = [super init]) {
    loaders = [NSMutableDictionary dictionary];
  }

  return self;
}

- (void) addProtocol: (NSString *)protocol resourceJSON: (NSString *)name url: (NSURL *)url {
  NSURL * indexUrl = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: name ofType: @"json"]];

  NSError * error;
  NSString * string = [NSString stringWithContentsOfURL: indexUrl encoding: NSUTF8StringEncoding error: &error];

  if (error) {
    NSLog(@"Error creating resource manager: %@", error);
    return;
  }

  id jsonObject = [NSJSONSerialization JSONObjectWithData: [string dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingAllowFragments error: &error];

  if (error) {
    NSLog(@"Error creating resource manager: %@", error);
    return;
  }

  [loaders setObject: [[CSResourceLoader alloc] initWithResourceIndex: jsonObject url: url] forKey: protocol];
}


- (void) addProtocol: (NSString *)protocol resourceIndex: (NSString *)name url: (NSURL *)url {
  NSURL * indexUrl = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: name ofType: @"txt"]];

  NSError * error;
  NSString * string = [NSString stringWithContentsOfURL: indexUrl encoding: NSUTF8StringEncoding error: &error];

  if (error) {
    NSLog(@"Error creating resource manager: %@", error);
    return;
  }

  NSArray<NSString *> * lines = [string componentsSeparatedByString: @"\n"];

  NSMutableArray<NSString *> * keys = [NSMutableArray arrayWithCapacity: [lines count]];
  NSMutableArray<NSString *> * vals = [NSMutableArray arrayWithCapacity: [lines count]];

  [lines enumerateObjectsUsingBlock: ^(NSString * object, NSUInteger idx, BOOL * stop) {
    NSArray<NSString *> * components = [object componentsSeparatedByString: @","];

    if (![components isEqualToArray: @[@""]]) {
      NSString * key = [[[components firstObject] componentsSeparatedByString: @":/"] lastObject];
      NSString * val = [components objectAtIndex: 1];

      [keys addObject: key];
      [vals addObject: val];
    }
  }];

  [loaders setObject: [[CSResourceLoader alloc] initWithResourceIndex: [NSDictionary dictionaryWithObjects: vals forKeys: keys] url: url] forKey: protocol];
}

- (void) loadDataFromURL: (NSURL *)url callback: (void(^)(NSData *))callback {
  CSResourceLoader * loader = [loaders objectForKey: url.scheme];

  callback([loader loadPath: [url path]]);
}

- (void) loadRedObjectFromURL: (NSURL *)url callback: (void (^)(id))callback {
  [self loadDataFromURL: url callback: ^(NSData * data) {
    CSRedReader * reader = [[CSRedReader alloc] initWithData: data];

    callback([reader readElement]);
  }];
}

- (void) loadBlackObjectFromURL: (NSURL *)url callback: (void (^)(id))callback {
  [self loadDataFromURL: url callback: ^(NSData * data) {
    CSBlackReader * reader = [[CSBlackReader alloc] initWithData: data];

    callback([reader readElement]);
  }];
}

@end
