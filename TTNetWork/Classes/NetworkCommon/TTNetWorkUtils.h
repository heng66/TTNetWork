//
//   TTNetWorkUtils.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
#import "TTNetWorkConstants.h"

@interface TTNetWorkUtils : NSObject

+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator;
+ (NSString *)md5StringFromString:(NSString *)string;
+ (NSString *)appVersionString;
+ (BOOL)validateResumeData:(NSData *)data;
+ (NSString *)requestMethod:(TTNetRequestMethod)method;
+ (NSString *)requestPriority:(TTNetRequestPriority)priority;
+ (NSString *)cachePolicy:(TTNetRequestCachePolicy)policy;
+ (NSString *)readCachePolicy:(TTNetRequestReadCachePolicy)policy;

@end
