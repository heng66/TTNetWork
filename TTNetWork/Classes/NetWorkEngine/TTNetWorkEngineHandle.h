//
//   TTNetWorkEngineHandle.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
#import "TTNetWorkRequestHandleProtocol.h"

@interface TTNetWorkEngineHandle : NSObject<TTNetWorkRequestHandleProtocol>

- (instancetype)initWithTask:(NSURLSessionTask *)task;

@end

@interface TTNetWorkEngineNilObject : NSObject<TTNetWorkRequestHandleProtocol>

@end
