//
//   TTNetWorkRequestHandleProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
@protocol TTNetWorkRequestHandleProtocol <NSObject>

//请求是否忙碌
- (BOOL)isBusy;
//取消请求
- (void)cancel;
//请求是否已被取消
- (BOOL)isCanceled;

@end
