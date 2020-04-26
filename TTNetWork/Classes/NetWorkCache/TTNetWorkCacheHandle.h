//
//   TTNetWorkCacheHandle.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
#import "TTNetWorkCacheHandleProtocol.h"

@class YYCache;

@interface TTNetWorkCacheHandle : NSObject<TTNetWorkCacheHandleProtocol>

- (instancetype)initWithCache:(YYCache *)cache key:(NSString *)key;

@end

@interface TTNetWorkCacheHandleNilObject : NSObject<TTNetWorkCacheHandleProtocol>

@end
