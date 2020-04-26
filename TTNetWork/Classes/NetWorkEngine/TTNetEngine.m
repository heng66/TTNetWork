//
//   TTNetEngine.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//

#import "TTNetEngine.h"
#import "TTNetWorkEngine.h"
#import "TTNetWorkConfig.h"
#import "TTNetWorkUtils.h"
#import "TTNetWorkCache.h"
#import "TTNetWorkCacheEngine.h"
#import "TTNetWorkDomainBeanRequest.h"
#import "TTNetWorkDomainBeanResponse.h"
#import "TTNetWorkEngineHandle.h"
#import "TTNetWorkCacheHandle.h"
#import <objc/runtime.h>

@interface TTNetWorkDomainBeanRequest (Extention)
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFirstRequest;
@end

@implementation TTNetWorkDomainBeanRequest (Extention)

- (void)setIsExecuting:(BOOL)isExecuting {
    objc_setAssociatedObject(self, @selector(isExecuting), @(isExecuting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isExecuting {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}
- (void)setIsFirstRequest:(BOOL)isFirstRequested {
    objc_setAssociatedObject(self, @selector(isFirstRequest), @(isFirstRequested), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isFirstRequest {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

@end

@interface TTNetEngine ()<TTNetWorkRequestProtocol>

@property (nonatomic, strong) TTNetWorkEngine *afNetWorkEngine;
@property (nonatomic, strong) TTNetWorkCacheEngine *cacheEngine;
@property (nonatomic, strong) TTNetWorkConfig *networkConfig;

@end

@implementation TTNetEngine

- (instancetype)init {
    if (self = [super init]) {
        self.afNetWorkEngine = [[TTNetWorkEngine alloc] init];
        self.cacheEngine = [[TTNetWorkCacheEngine alloc] init];
        self.networkConfig = [TTNetWorkConfig sharedConfig];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (TTNetWorkConfig *)engineConfigation {
    return self.networkConfig;
}

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean {
    return [self excuteWithRequestBean:requestBean
                          responseBean:responseBean
                             successed:nil
                                failed:nil];
}

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed {
    return [self excuteWithRequestBean:requestBean
                          responseBean:responseBean
                                 begin:nil
                             successed:successed
                                failed:failed
                                   end:nil];
}

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                      begin:(TTNetWorkEngineRequestBeanBeginBlock)begin
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed
                                                        end:(TTNetWorkEngineRequestBeanEndBlock)end {
    return [self excuteWithRequestBean:requestBean
                          responseBean:responseBean
                                 begin:begin
                              progress:nil
                             successed:successed
                                failed:failed
                                   end:end];
}

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                   progress:(TTNetWorkRequestProgressCallback)progress
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed {
    return [self excuteWithRequestBean:requestBean
                          responseBean:responseBean
                                 begin:nil
                              progress:progress
                             successed:successed
                                failed:failed
                                   end:nil];
}

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                      begin:(TTNetWorkEngineRequestBeanBeginBlock)begin
                                                   progress:(TTNetWorkRequestProgressCallback)progress
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed
                                                        end:(TTNetWorkEngineRequestBeanEndBlock)end {
    if (begin != NULL) {
        begin();
    }
    
    NSError *verificationError = nil;
    
    do {
        ///< 入参内容是否有值检测
        if (requestBean == nil || responseBean == nil) {
            verificationError = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                                    code:TTNetWorkEngineErrorNilDomainBean
                                                userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ 请求对象不能为空！",requestBean]}];
            break;
        }
        
        ///< 入参合法性检测
        if (![requestBean isKindOfClass:[TTNetWorkDomainBeanRequest class]] ||
            ![responseBean isKindOfClass:[TTNetWorkDomainBeanResponse class]]) {
            verificationError = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                                    code:TTNetWorkEngineErrorDomainBeanInvalid
                                                userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ 请求对象不合法！",requestBean]}];
            break;
        }
        
        if (requestBean.isExecuting) {
            NSLog(@"%@ -> is Executing!",requestBean);
            return [[TTNetWorkEngineNilObject alloc] init];
        }
        
        ///< 拼接请求链接
        NSString * requestUrlString = nil;
        MESSAGE_SEND(requestBean, requestUrlMosaicWithRequestBean:error:){
            requestUrlString = [requestBean requestUrlMosaicWithRequestBean:requestBean error:&verificationError];
        };
        if (verificationError) break;
        
        NSDictionary *fullParams = nil;
        ///< 拼接请求参数
        MESSAGE_SEND(requestBean, requestArgumentMosaicWithRequestBean:error:){
            fullParams = [requestBean requestArgumentMosaicWithRequestBean:requestBean error:&verificationError];
        };
        if (verificationError) break;
        
        ///< 请求参数过滤
        MESSAGE_SEND(requestBean, requestArgumentMapWithArguments:error:){
            fullParams = [requestBean requestArgumentMapWithArguments:fullParams error:&verificationError];
        };
        if (verificationError) break;
        
        ///< 安全政策
        id securityPolicy = nil;
        MESSAGE_SEND(requestBean, securityPolicy){
            securityPolicy = [requestBean securityPolicy];
        };
        
        ///< 请求方法
        TTNetRequestMethod method = TTNetRequestMethodGET;
        MESSAGE_SEND(requestBean, requestMethod){
            method = [requestBean requestMethod];
        };
        
        ///< 请求序列化
        TTNetRequestSerializer requestSerializer = TTNetRequestSerializerHTTP;
        MESSAGE_SEND(requestBean, requestSerializerType){
            requestSerializer = [requestBean requestSerializerType];
        };
        
        ///< 响应序列化
        TTNetResponseSerializer responseSerializer = TTNetResponseSerializerJSON;
        MESSAGE_SEND(requestBean, responseSerializerType){
            responseSerializer = [requestBean responseSerializerType];
        };
        
        ///< 请求优先级
        TTNetRequestPriority priority = TTNetRequestPriorityNormal;
        MESSAGE_SEND(requestBean, requestPriority){
            priority = [requestBean requestPriority];
        };
        
        ///< 服务器认证信息
        NSArray *authorization = @[];
        MESSAGE_SEND(requestBean, requestAuthorizationHeaderFieldArray){
            authorization = [requestBean requestAuthorizationHeaderFieldArray];
        };
        
        ///< 请求头
        NSDictionary *headers = @{};
        MESSAGE_SEND(requestBean, requestHeaderFieldValueDictionary){
            headers = [requestBean requestHeaderFieldValueDictionary];
        };
        
        ///< 公共请求头
        NSDictionary *publicHeaders = @{};
        MESSAGE_SEND(requestBean, publicHeaders){
            publicHeaders = [requestBean publicHeaders];
        };
        
        ///< 拼接请求头
        NSMutableDictionary *mHeaders = [NSMutableDictionary dictionaryWithCapacity:headers.count + publicHeaders.count];
        [mHeaders addEntriesFromDictionary:headers];
        [mHeaders addEntriesFromDictionary:publicHeaders];
        headers = [mHeaders copy];
        
        ///< POST Data
        TTNetWorkRequestData *data = nil;
        MESSAGE_SEND(requestBean, requestData){
            data = [requestBean requestData];
        };
        if(data != nil && ![data isKindOfClass:[TTNetWorkRequestData class]]){
            verificationError = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                                    code:TTNetWorkEngineErrorPostDataInvalid
                                                userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ POST 数据不合法！",requestBean]}];
            break;
        }
        
        ///< 请求过期时间
        NSTimeInterval timeout = 0;
        MESSAGE_SEND(requestBean, timeoutInterval){
            timeout = [requestBean timeoutInterval];
        };
        if(timeout <= 0) timeout = self.engineConfigation.timeoutInterval;
        if(timeout <= 0) timeout = 60;
        
        ///< 是否允许使用蜂窝数据
        BOOL allowsCellularAccess = YES;
        MESSAGE_SEND(requestBean, allowsCellularAccess){
            allowsCellularAccess = [requestBean allowsCellularAccess];
        };
        
        ///< 数据缓存策略
        id<TTNetWorkRequestCacheProtocol> cachePolocy = nil;
        MESSAGE_SEND(requestBean, cachePolocy){
            cachePolocy = [requestBean cachePolocy];
        }
        if (cachePolocy == nil) cachePolocy = [[TTNetWorkCache alloc] init];
        
        ///< 是否支持缓存
        BOOL cacheEnable = NO;
        MESSAGE_SEND(cachePolocy, shouldCacheWithRequestBean:){
            cacheEnable = [cachePolocy shouldCacheWithRequestBean:requestBean];
        }
        
        ///< 缓存数据读取策略
        TTNetRequestReadCachePolicy readCachePolicy = TTNetRequestReadCacheFirst;
        MESSAGE_SEND(cachePolocy, loadCachePolicyWithRequestBean:){
            readCachePolicy = [cachePolocy loadCachePolicyWithRequestBean:requestBean];
        }
        
        ///< 读取缓存数据
        id cacheData = nil;
        if (cacheEnable && (readCachePolicy == TTNetRequestReadCacheEver || (readCachePolicy == TTNetRequestReadCacheFirst && requestBean.isFirstRequest == NO))) {
            NSError *cacheError;
            id<TTNetWorkCacheHandleProtocol> cacheHandle =
            [self.cacheEngine loadCacheWithRequestBean:requestBean
                                                 error:&cacheError];
            if (cacheError) {
                NSLog(@"TTDevNetWorking -> readCache Error : %@",cacheError.localizedDescription);
            }else{
                cacheData = [cacheHandle cacheData];
                NSLog(@"TTDevNetWorking -> readCache Data %@!",cacheData != nil ? @"Success" : @"Failed");
            }
        }
        
        ///< 读取缓存的策略是只有第一次请求读取缓存，并且是第一次请求，并且读取到了缓存数据，并且支持缓存
        if (readCachePolicy == TTNetRequestReadCacheFirst && cacheData && requestBean.isFirstRequest == NO) {
            responseBean.responseObject = cacheData;
            responseBean.dataFromCache = YES;
            
            ///< 告诉请求完成，进行模型解析等操作
            MESSAGE_SEND(responseBean, complementWithRequestBean:respondBean:isDataFromCache:){
                [responseBean complementWithRequestBean:requestBean respondBean:responseBean isDataFromCache:YES];
            }
            
            if (successed) {
                successed(requestBean,responseBean,YES);
                return [[TTNetWorkEngineNilObject alloc] init];
            }
        }
        
        ///< 读取缓存的策略是每次都读取缓存，并且读取到了缓存数据
        if (readCachePolicy == TTNetRequestReadCacheEver && cacheData) {
            responseBean.responseObject = cacheData;
            responseBean.dataFromCache = YES;
            
            ///< 告诉请求完成，进行模型解析等操作
            MESSAGE_SEND(responseBean, complementWithRequestBean:respondBean:isDataFromCache:){
                [responseBean complementWithRequestBean:requestBean respondBean:responseBean isDataFromCache:YES];
            }
            
            if (successed) {
                successed(requestBean,responseBean,YES);
                return [[TTNetWorkEngineNilObject alloc] init];
            }
        }
                
        __block TTNetWorkDomainBeanRequest *domainBeanRequest = requestBean;
        __block TTNetWorkDomainBeanResponse *domainBeanResponse = responseBean;
        
        TTNetWorkRequestSuccessedCallback requestSuccess = ^(NSURLResponse *response, id responseObject){
            domainBeanResponse.response = response;
            domainBeanResponse.responseObject = responseObject;
            domainBeanResponse.dataFromCache = NO;
            domainBeanRequest.isExecuting = NO;
            domainBeanRequest.isFirstRequest = YES;
            
            NSError *validatError = nil;
            
            do {
                ///< 网络请求状态码校验
                BOOL statusCodeValidator = NO;
                MESSAGE_SEND(domainBeanRequest, statusCodeValidator:){
                    statusCodeValidator = [domainBeanRequest statusCodeValidator:response];
                }
                if (!statusCodeValidator) {
                    validatError = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                                       code:TTNetWorkEngineErrorNetStatusCodeInvalid
                                                   userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ 网络请求状态码校验失败！",requestBean]}];
                    break;
                }
                
                ///< 校验响应数据 json 合法性
                id json = responseObject;
                id validator = nil;
                MESSAGE_SEND(domainBeanResponse, jsonValidator){
                    validator = [domainBeanResponse jsonValidator];
                };
                if (json && validator) {
                    BOOL result = [TTNetWorkUtils validateJSON:json withValidator:validator];
                    if (!result) {
                        validatError = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                                           code:TTNetWorkEngineErrorResponseJSONInvalid
                                                       userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络请求：%@ JSON 结构和值校验失败！",requestBean]}];
                        break;
                    }
                }
                
                ///< 错误码校验
                NSString *codeKey = self.engineConfigation.codeKey;
                NSInteger rightCode = self.engineConfigation.rightCode;
                NSDictionary *errorCodeInfos = self.engineConfigation.errorCodeInfo;
                if (codeKey && codeKey.length > 0 && [responseObject objectForKey:codeKey]) {
                    NSInteger responseCode = [[responseObject objectForKey:codeKey] integerValue];
                    if (responseCode != rightCode) {
                        NSString *errorMessage = @"响应数据状态码校验失败！";
                        if (errorCodeInfos && [errorCodeInfos objectForKey:[NSString stringWithFormat:@"%li",responseCode]]) {
                            errorMessage = [errorCodeInfos objectForKey:[NSString stringWithFormat:@"%li",responseCode]];
                        }
                        validatError = [NSError errorWithDomain:TTNetWorkEngineErrorDomain
                                                           code:responseCode
                                                       userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                        break;
                    }
                }
                
                ///< 数据缓存处理
                id<TTNetWorkRequestCacheProtocol> cachePolocy = nil;
                MESSAGE_SEND(domainBeanRequest, cachePolocy){
                    cachePolocy = [domainBeanRequest cachePolocy];
                }
                if (cachePolocy == nil) cachePolocy = [[TTNetWorkCache alloc] init];
                
                ///< 是否支持缓存
                BOOL cacheEnable = NO;
                MESSAGE_SEND(cachePolocy, shouldCacheWithRequestBean:){
                    cacheEnable = [cachePolocy shouldCacheWithRequestBean:domainBeanRequest];
                }
                
                if (cacheEnable) {
                    NSError *cacheError;
                    id<TTNetWorkCacheHandleProtocol> cacheHandle =
                    [self.cacheEngine writeCacheWithRequestBean:domainBeanRequest
                                                 responseObject:domainBeanResponse.responseObject
                                                          error:&cacheError];
                    if (cacheError) {
                        NSLog(@"TTDevNetWorking -> writeCache Error : %@",cacheError.localizedDescription);
                    }else{
                        [cacheHandle cacheData];
                        NSLog(@"TTDevNetWorking -> writeCache data Success!");
                    }
                }
                
                ///< 告诉请求完成，进行模型解析等操作
                MESSAGE_SEND(domainBeanResponse, complementWithRequestBean:respondBean:isDataFromCache:){
                    [domainBeanResponse complementWithRequestBean:domainBeanRequest respondBean:domainBeanResponse isDataFromCache:NO];
                }
                
                if (successed != NULL) {
                    if ([NSThread currentThread] != [NSThread mainThread]) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            successed(domainBeanRequest,domainBeanResponse,NO);
                        });
                    }
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (end != NULL) {
                        end();
                    }
                });
                
                return ;
                
            } while (NO);
            
            if (failed != NULL) {
                if ([NSThread currentThread] != [NSThread mainThread]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        failed(domainBeanRequest,domainBeanResponse,validatError);
                    });
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (end != NULL) {
                    end();
                }
            });
            
        };
        
        ///< 请求句柄
        requestBean.isExecuting = YES;
        id<TTNetWorkRequestHandleProtocol> requestHandle = [self.afNetWorkEngine requestWithUrlString:requestUrlString
                                                                                       securityPolicy:securityPolicy
                                                                                               method:method
                                                                                    requestSerializer:requestSerializer
                                                                                   responseSerializer:responseSerializer
                                                                                             priority:priority
                                                                                        authorization:authorization
                                                                                              headers:headers
                                                                                             argument:fullParams
                                                                                                 data:data
                                                                                              timeout:timeout
                                                                                 allowsCellularAccess:allowsCellularAccess
                                                                                             progress:progress
                                                                                              success:requestSuccess
                                                                                              failure:^(NSURLResponse *response, id responseObject, NSError *error) {
            
            domainBeanResponse.response = response;
            domainBeanResponse.responseObject = responseObject;
            domainBeanResponse.dataFromCache = NO;
            domainBeanRequest.isExecuting = NO;
            
            if (failed != NULL) {
                if ([NSThread currentThread] != [NSThread mainThread]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        failed(domainBeanRequest,domainBeanResponse,error);
                    });
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (end != NULL) {
                    end();
                }
            });
        }];
        return requestHandle;
    } while (NO);
    
    ///< 出现错误结束请求
    if (failed != NULL) {
        failed(requestBean,responseBean,verificationError);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (end != NULL) {
            end();
        }
    });
    
    return [[TTNetWorkEngineNilObject alloc] init];
}

@end
