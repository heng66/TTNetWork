//
//   TTNetWorkDomainResponseProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkDomainResponseHandleProtocol.h"
#import "TTNetWorkConstants.h"

@class TTNetWorkDomainBeanRequest;
@class TTNetWorkDomainBeanResponse;

@protocol TTNetWorkDomainResponseProtocol <TTNetWorkDomainResponseHandleProtocol>
@required

- (void)complementWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean respondBean:(TTNetWorkDomainBeanResponse *)respondBean isDataFromCache:(BOOL)isDataFromCache;

@end
