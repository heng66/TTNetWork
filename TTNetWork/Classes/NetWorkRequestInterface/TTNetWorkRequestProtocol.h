//
//   TTNetWorkRequestProtocol.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
#import "TTNetWorkRequestData.h"
#import "TTNetWorkRequestHandleProtocol.h"

@protocol TTNetWorkRequestProtocol<NSObject>
@optional
/**
 urlString 请求的完整链接
 securityPolicy 安全策略
 method 请求方式
 requestSerializer 请求序列化方式
 responseSerializer 响应数据序列化方式
 priority 请求优先级
 authorization 认证信息
 headers 请求头
 argument 请求参数
 data 请求数据
 timeout 超时时间
 allowsCellularAccess 是否允许蜂窝网络
 success 成功回调
 failure 失败回调
 */
- (id<TTNetWorkRequestHandleProtocol>)requestWithUrlString:(NSString *)urlString
                                        securityPolicy:(id)securityPolicy
                                                method:(TTNetRequestMethod)method
                                     requestSerializer:(TTNetRequestSerializer)requestSerializer
                                    responseSerializer:(TTNetResponseSerializer)responseSerializer
                                              priority:(TTNetRequestPriority)priority
                                         authorization:(NSArray *)authorization
                                               headers:(NSDictionary *)headers
                                              argument:(id)argument
                                                  data:(TTNetWorkRequestData *)data
                                               timeout:(NSTimeInterval)timeout
                                  allowsCellularAccess:(BOOL)allowsCellularAccess
                                              progress:(TTNetWorkRequestProgressCallback)progress
                                               success:(TTNetWorkRequestSuccessedCallback)success
                                               failure:(TTNetWorkRequestFailedCallback)failure;

/**
 urlString 请求的完整链接
 securityPolicy 安全策略
 requestSerializer 请求序列化方式
 priority 请求优先级
 authorization 认证信息
 headers 请求头
 argument 请求参数
 resumableDownloadPath 下载路径
 timeout 超时时间
 allowsCellularAccess 是否允许蜂窝网络
 progress 下载进度
 complete 下载完成回调
 failure 失败回调
 */
- (id<TTNetWorkRequestHandleProtocol>)downloadWithUrlString:(NSString *)urlString
                                         securityPolicy:(id)securityPolicy
                                      requestSerializer:(TTNetRequestSerializer)requestSerializer
                                               priority:(TTNetRequestPriority)priority
                                          authorization:(NSArray *)authorization
                                                headers:(NSDictionary *)headers
                                               argument:(id)argument
                                  resumableDownloadPath:(NSString*)resumableDownloadPath
                                                timeout:(NSTimeInterval)timeout
                                   allowsCellularAccess:(BOOL)allowsCellularAccess
                                               progress:(TTNetWorkDownloadProgressCallback)progress
                                               complete:(TTNetWorkDownloadCompleteCallback)complete
                                                failure:(TTNetWorkRequestFailedCallback)failure;
@end
