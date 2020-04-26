//
//   TTNetWorkDomainBeanResponse.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   

#import <Foundation/Foundation.h>
#import "TTNetWorkDomainResponseProtocol.h"

@interface TTNetWorkDomainBeanResponse : NSObject<TTNetWorkDomainResponseProtocol>

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, assign, getter=isDataFromCache) BOOL dataFromCache;

@end
