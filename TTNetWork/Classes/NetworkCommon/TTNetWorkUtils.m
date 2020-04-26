//
//   TTNetWorkUtils.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkUtils.h"
#import "TTNetWorkConfig.h"
#import "TTNetEngine.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TTNetWorkUtils

+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator {
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = json;
        NSDictionary * validator = jsonValidator;
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                result = [self validateJSON:value withValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)jsonValidator;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            for (id item in array) {
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    
    return outputString;
}

+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    
    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}

+ (NSString *)requestMethod:(TTNetRequestMethod)method {
    switch (method) {
        case TTNetRequestMethodGET:
            return @"GET";
            break;
        case TTNetRequestMethodPUT:
            return @"PUT";
            break;
        case TTNetRequestMethodPOST:
            return @"POST";
            break;
        case TTNetRequestMethodDELETE:
            return @"DELETE";
            break;
        case TTNetRequestMethodHEAD:
            return @"HEAD";
            break;
        case TTNetRequestMethodPATCH:
            return @"PATCH";
            break;
            
        default:
            return @"Unknow";
            break;
    }
}

+ (NSString *)requestPriority:(TTNetRequestPriority)priority {
    switch (priority) {
        case TTNetRequestPriorityLow:
            return @"Low";
            break;
        case TTNetRequestPriorityNormal:
            return @"Normal";
            break;
        case TTNetRequestPriorityHigh:
            return @"High";
            break;
            
        default:
            return @"Unknow";
            break;
    }
}

+ (NSString *)readCachePolicy:(TTNetRequestReadCachePolicy)policy {
    switch (policy) {
        case TTNetRequestReadCacheNever:
            return @"TTNetRequestReadCacheNever";
            break;
        case TTNetRequestReadCacheFirst:
            return @"TTNetRequestReadCacheFirst";
            break;
        case TTNetRequestReadCacheEver:
            return @"TTNetRequestReadCacheEver";
            break;
            
        default:
            return @"Nill";
            break;
    }
}

+ (NSString *)cachePolicy:(TTNetRequestCachePolicy)policy {
    switch (policy) {
        case TTNetRequestCacheMemory:
            return @"TTNetRequestCacheMemory";
            break;
        case TTNetRequestCacheDisk:
            return @"TTNetRequestCacheDisk";
            break;
            
        default:
            return @"Nill";
            break;
    }
}

@end
