//
//   TTNetWorkCacheHandle.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   

#import "TTNetWorkCacheHandle.h"
#import <YYCache/YYCache.h>

@interface TTNetWorkCacheHandle ()
@property (nonatomic, strong) YYCache *cache;
@property (nonatomic, copy) NSString *cacheKey;
@end

@implementation TTNetWorkCacheHandle

- (instancetype)initWithCache:(YYCache *)cache key:(NSString *)key {
    if (self = [super init]) {
        _cache = cache;
        _cacheKey = key;
    }
    return self;
}

#pragma mark - TTNetWorkCacheHandleProtocol

- (id)cacheData {
    if (_cache == nil || _cacheKey == nil) {
        return nil;
    }
    return [_cache objectForKey:_cacheKey];
}

- (void)clearCacheData {
    if (_cache == nil || _cacheKey == nil) {
        return;
    }
    [_cache removeObjectForKey:_cacheKey];
}

@end

@implementation TTNetWorkCacheHandleNilObject

#pragma mark - TTNetWorkCacheHandleProtocol

- (id)cacheData {
    return nil;
}

- (void)clearCacheData {
}

@end
