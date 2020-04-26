//
//   TTNetWorkCache.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkCache.h"
#import "TTNetWorkDomainRequestProtocol.h"

@implementation TTNetWorkCache

#pragma mark - TTNetWorkRequestCacheProtocol

- (BOOL)shouldCacheWithRequestBean:(id<TTNetWorkDomainRequestProtocol>)requestBean {
    return NO;
}

- (TTNetRequestCachePolicy)cachePolicyWithRequestBean:(id<TTNetWorkDomainRequestProtocol>)requestBean {
    return -1;
}

- (TTNetRequestReadCachePolicy)loadCachePolicyWithRequestBean:(id<TTNetWorkDomainRequestProtocol>)requestBean {
    return TTNetRequestReadCacheFirst;
}

- (NSString *)cacheIdentificationWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean {
    return [NSString stringWithFormat:@"%s",object_getClassName(requestBean)];
}

- (NSString *)cacheVersion {
    return @"0.0.1";
}

- (NSInteger)cacheTimeInSeconds {
    return NSIntegerMax;
}

- (BOOL)writeCacheAsynchronously {
    return YES;
}

- (BOOL)interceptCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean {
    return NO;
}

@end
