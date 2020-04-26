//
//   TTNetWorkDomainBeanRequest.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkDomainBeanRequest.h"
#import "TTNetWorkCache.h"
#import "TTNetWorkConfig.h"
#import "TTNetWorkConstants.h"
#import "TTNetEngine.h"

@implementation TTNetWorkDomainBeanRequest

#pragma mark - TTNetWorkDomainRequestProtocol

- (NSString *)baseUrl {
    NSString *url = [TTNetEngine sharedInstance].engineConfigation.baseUrl;
    return url == nil ? @"" : url;
}

- (NSString *)requestUrl {
    return nil;
}

- (id)securityPolicy {
    return [TTNetEngine sharedInstance].engineConfigation.securityPolicy;
}

- (TTNetRequestMethod)requestMethod {
    return TTNetRequestMethodGET;
}

- (TTNetRequestSerializer)requestSerializerType {
    return TTNetRequestSerializerHTTP;
}

- (TTNetResponseSerializer)responseSerializerType {
    return TTNetResponseSerializerJSON;
}

- (TTNetRequestPriority)requestPriority {
    return TTNetRequestPriorityNormal;
}

- (NSArray<NSString *> *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)publicHeaders {
    return [TTNetEngine sharedInstance].engineConfigation.publicHeaders;
}

- (id)requestArgument {
    return nil;
}

- (id)publicArgument {
    return [TTNetEngine sharedInstance].engineConfigation.publicArgument;
}

- (TTNetWorkRequestData*)requestData {
    return nil;
}

- (NSTimeInterval)timeoutInterval {
    return [TTNetEngine sharedInstance].engineConfigation.timeoutInterval;
}

- (BOOL)allowsCellularAccess {
    return [TTNetEngine sharedInstance].engineConfigation.allowsCellularAccess;
}

- (id<TTNetWorkRequestCacheProtocol>)cachePolocy {
    return [[TTNetWorkCache alloc] init];
}

#pragma mark - TTNetWorkDomainRequestHelperProtocol

- (BOOL)statusCodeValidator:(NSURLResponse *)response {
    if (response == nil) {
        return NO;
    }
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    return (statusCode >= 200 && statusCode <= 299);
}

- (NSString*)requestUrlMosaicWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean error:(NSError * __autoreleasing *)error {
    id <TTNetWorkDomainRequestProtocol> bean = requestBean;
    
    NSString *requestUrl = [bean requestUrl];
    if (requestUrl == nil) {
        requestUrl = @"";
    }
    NSURL *temp = [NSURL URLWithString:requestUrl];
    if (temp && temp.host && temp.scheme) {
        return requestUrl;
    }
    
    NSString *baseUrl = [bean baseUrl];
    if (baseUrl == nil || baseUrl.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                         code:TTNetWorkEngineErrorRequestUrlInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ 地址不能为空！",requestBean]}];
        }
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:baseUrl];
    if (baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    return [NSURL URLWithString:requestUrl relativeToURL:url].absoluteString;
}

- (id)requestArgumentMosaicWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean error:(NSError * __autoreleasing *)error {
    id <TTNetWorkDomainRequestProtocol> bean = requestBean;
    
    NSDictionary *publicArgument = [bean publicArgument];
    NSDictionary *requestArgument = [bean requestArgument];
    
    if ((publicArgument != nil && ![publicArgument isKindOfClass:[NSDictionary class]]) ||
        (requestArgument != nil && ![requestArgument isKindOfClass:[NSDictionary class]])) {
        if (error) {
            *error = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                         code:TTNetWorkEngineErrorRequestArgumentInvalid
                                     userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ 请求参数类型错误（不是字典）！",requestBean]}];
        }
    }
    
    NSMutableDictionary *fullArgument = [NSMutableDictionary dictionaryWithCapacity:50];
    if(publicArgument != nil)[fullArgument addEntriesFromDictionary:publicArgument];
    if(requestArgument != nil)[fullArgument addEntriesFromDictionary:requestArgument];
    
    return [fullArgument copy];
}

- (id)requestArgumentMapWithArguments:(id)arguments error:(NSError * __autoreleasing *)error {
    return arguments == nil ? @{} : arguments;
}

@end
