//
//   TTNetWorkRequestCacheProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
#import "TTNetWorkConstants.h"

@class TTNetWorkDomainBeanRequest;
@class TTNetWorkDomainBeanResponse;

@protocol TTNetWorkRequestCacheProtocol<NSObject>
@required

- (BOOL)shouldCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean;
- (TTNetRequestCachePolicy)cachePolicyWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean;
- (TTNetRequestReadCachePolicy)loadCachePolicyWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean;
- (NSString *)cacheIdentificationWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean;
- (NSString *)cacheVersion;
- (NSInteger)cacheTimeInSeconds;
- (BOOL)writeCacheAsynchronously;

@optional
- (BOOL)interceptCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean;

@end

