//
//   TTNetWorkEngineHandle.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkEngineHandle.h"

@interface TTNetWorkEngineHandle ()
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end

@implementation TTNetWorkEngineHandle

- (instancetype)initWithTask:(NSURLSessionDataTask *)task {
    if (self = [super init]) {
        _task = task;
    }
    return self;
}

#pragma mark - TTNetWorkRequestHandleProtocol

- (BOOL)isBusy {
    return (_task.state != NSURLSessionTaskStateCompleted && _task.state != NSURLSessionTaskStateCanceling);
}

- (void)cancel {
    [_task cancel];
}

- (BOOL)isCanceled {
    return (_task.state == NSURLSessionTaskStateCanceling);
}

@end

@implementation TTNetWorkEngineNilObject

- (BOOL)isCanceled {return YES;}
- (BOOL)isBusy {return NO;}
- (void)cancel {}

@end

