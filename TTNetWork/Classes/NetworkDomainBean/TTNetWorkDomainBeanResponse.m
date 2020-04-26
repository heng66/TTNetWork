//
//   TTNetWorkDomainBeanResponse.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkDomainBeanResponse.h"
#import "TTNetWorkCache.h"
#import "TTNetEngine.h"
#import "TTNetWorkConfig.h"

@implementation TTNetWorkDomainBeanResponse

#pragma mark - TTNetWorkDomainResponseProtocol

- (void)complementWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean respondBean:(TTNetWorkDomainBeanResponse *)respondBean isDataFromCache:(BOOL)isDataFromCache {
    
}

#pragma mark - TTNetWorkDomainResponseHelperProtocol

- (id)jsonValidator {
    return [TTNetEngine sharedInstance].engineConfigation.jsonValidator;
}

@end
