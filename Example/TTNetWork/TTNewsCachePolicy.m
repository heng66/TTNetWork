//
//   TTNewsCachePolicy.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   

#import "TTNewsCachePolicy.h"

@implementation TTNewsCachePolicy

- (BOOL)shouldCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean {
  return YES;
}

- (TTNetRequestCachePolicy)cachePolicyWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean {
  return TTNetRequestCacheDisk;
}

- (NSInteger)cacheTimeInSeconds {
    return 600;
}


@end
