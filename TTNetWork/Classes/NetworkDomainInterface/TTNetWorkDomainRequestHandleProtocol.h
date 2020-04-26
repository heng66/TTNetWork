//
//   TTNetWorkDomainRequestHandleProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
@class TTNetWorkDomainBeanRequest;

@protocol TTNetWorkDomainRequestHandleProtocol <NSObject>
@required

- (BOOL)statusCodeValidator:(NSURLResponse *)response;
- (NSString*)requestUrlMosaicWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean error:(NSError **)error;
- (id)requestArgumentMosaicWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean error:(NSError **)error;
- (id)requestArgumentMapWithArguments:(id)arguments error:(NSError **)error;

@end
