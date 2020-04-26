//
//   TTNetWorkDomainRequestProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkConstants.h"
#import "TTNetWorkRequestData.h"
#import "TTNetWorkRequestCacheProtocol.h"
#import "TTNetWorkDomainRequestHandleProtocol.h"

@protocol TTNetWorkDomainRequestProtocol <TTNetWorkDomainRequestHandleProtocol>
@required

- (NSString *)baseUrl;
- (NSString *)requestUrl;
- (id)securityPolicy;
- (TTNetRequestMethod)requestMethod;
- (TTNetRequestSerializer)requestSerializerType;
- (TTNetResponseSerializer)responseSerializerType;
- (TTNetRequestPriority)requestPriority;
- (NSArray<NSString *> *)requestAuthorizationHeaderFieldArray;
- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
- (NSDictionary<NSString *, NSString *> *)publicHeaders;
- (id)requestArgument;
- (id)publicArgument;
- (TTNetWorkRequestData*)requestData;
- (NSTimeInterval)timeoutInterval;
- (BOOL)allowsCellularAccess;

@optional
- (id<TTNetWorkRequestCacheProtocol>)cachePolocy;

@end
