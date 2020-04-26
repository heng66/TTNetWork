//
//   TTNetWorkCacheProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTNetWorkCacheHandleProtocol;
@protocol TTNetWorkRequestCacheProtocol;
@protocol TTNetWorkDomainRequestProtocol;
@protocol TTNetWorkDomainResponseProtocol;

@class TTNetWorkCache;
@class TTNetWorkDomainBeanRequest;
@class TTNetWorkDomainBeanResponse;

@protocol TTNetWorkCacheProtocol<NSObject>

- (id<TTNetWorkCacheHandleProtocol>)writeCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseObject:(id)responseObject
                                                        error:(NSError **)error;

- (id<TTNetWorkCacheHandleProtocol>)loadCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                                       error:(NSError **)error;

- (id<TTNetWorkCacheHandleProtocol>)clearCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                                        error:(NSError **)error;

- (BOOL)hasCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean;

@end
