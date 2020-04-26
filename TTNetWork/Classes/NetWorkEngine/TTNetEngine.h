//
//   TTNetEngine.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTNetWorkConstants.h"
#import "TTNetWorkRequestHandleProtocol.h"

@class TTNetWorkDomainBeanRequest;
@class TTNetWorkDomainBeanResponse;
@class TTNetWorkConfig;

@interface TTNetEngine : NSObject

@property (nonatomic, strong, readonly) TTNetWorkConfig *engineConfigation;

+ (instancetype)sharedInstance;

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean;

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed;

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                      begin:(TTNetWorkEngineRequestBeanBeginBlock)begin
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed
                                                        end:(TTNetWorkEngineRequestBeanEndBlock)end;

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                   progress:(TTNetWorkRequestProgressCallback)progress
                                                  successed:( TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed;

- (id<TTNetWorkRequestHandleProtocol>)excuteWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseBean:(TTNetWorkDomainBeanResponse *)responseBean
                                                      begin:(TTNetWorkEngineRequestBeanBeginBlock)begin
                                                   progress:(TTNetWorkRequestProgressCallback)progress
                                                  successed:(TTNetWorkEngineRequestBeanSuccessedBlock)successed
                                                     failed:(TTNetWorkEngineRequestBeanFailedBlock)failed
                                                        end:(TTNetWorkEngineRequestBeanEndBlock)end;
@end

