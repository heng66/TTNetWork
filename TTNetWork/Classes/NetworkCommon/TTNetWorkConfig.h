//
//   TTNetWorkConfig.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTNetWorkConfig : NSObject

+ (TTNetWorkConfig *)sharedConfig;

@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, copy) NSString *cachePath;
@property (nonatomic, copy) NSString *codeKey;
@property (nonatomic, copy) NSDictionary *errorCodeInfo;
@property (nonatomic, assign) BOOL debugLogEnabled;
@property (nonatomic, assign) NSInteger rightCode;
@property (nonatomic, strong) id securityPolicy;
@property (nonatomic, strong) NSDictionary *publicArgument;
@property (nonatomic, strong) NSDictionary *publicHeaders;
@property (nonatomic, strong) NSDictionary *jsonValidator;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) BOOL allowsCellularAccess;

@end

