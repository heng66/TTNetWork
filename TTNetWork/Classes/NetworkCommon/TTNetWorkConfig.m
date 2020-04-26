//
//   TTNetWorkConfig.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   

#import "TTNetWorkConfig.h"

@implementation TTNetWorkConfig

+ (TTNetWorkConfig *)sharedConfig {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseUrl = @"";
        _cachePath = @"TTRequestCache";
        _codeKey = nil;
        _rightCode = 1;
        _errorCodeInfo = @{};
        _debugLogEnabled = YES;
        _securityPolicy = nil;
        _publicArgument = nil;
        _publicHeaders = nil;
        _jsonValidator = nil;
        _timeoutInterval = 60;
        _allowsCellularAccess = YES;
    }
    return self;
}

@end
