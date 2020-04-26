//
//   TTNetWorkConstants.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>

#define MESSAGE_SEND(obj, msg) if ((obj) && [(obj) respondsToSelector:@selector(msg)])

typedef NS_ENUM(NSUInteger, TTNetRequestMethod) {
    TTNetRequestMethodGET = 0,
    TTNetRequestMethodPOST = 1,
    TTNetRequestMethodHEAD = 2,
    TTNetRequestMethodPUT = 3,
    TTNetRequestMethodDELETE = 4,
    TTNetRequestMethodPATCH = 5,
};

typedef NS_ENUM(NSUInteger, TTNetRequestSerializer) {
    TTNetRequestSerializerHTTP = 0,
    TTNetRequestSerializerJSON = 1,
    TTNetRequestSerializerPropertyList = 2,
};

typedef NS_ENUM(NSUInteger, TTNetResponseSerializer) {
    TTNetResponseSerializerHTTP = 0,
    TTNetResponseSerializerJSON = 1,
    TTNetResponseSerializerXMLParser = 2,
};

typedef NS_ENUM(NSUInteger, TTNetRequestPriority) {
    TTNetRequestPriorityLow = -4L,
    TTNetRequestPriorityNormal = 0,
    TTNetRequestPriorityHigh = 4,
};

typedef NS_ENUM(NSUInteger, TTNetRequestDataType) {
    TTNetRequestDataTypeFile = 1,
    TTNetRequestDataTypeForm = 2,
    TTNetRequestDataTypeFileUrl = 3,
};

typedef NS_ENUM(NSUInteger, TTNetRequestReadCachePolicy) {
    TTNetRequestReadCacheNever = 1,
    TTNetRequestReadCacheFirst = 0,
    TTNetRequestReadCacheEver = 2,
};

typedef NS_ENUM(NSUInteger, TTNetRequestCachePolicy) {
    TTNetRequestCacheMemory = 1,
    TTNetRequestCacheDisk = 2,
};

#define TTNetWorkCacheErrorDomain @"com.TT.cache"
NS_ENUM(NSInteger) {
    TTNetWorkCacheErrorExpired = -1,
    TTNetWorkCacheErrorVersionMismatch = -2,
    TTNetWorkCacheErrorAppVersionMismatch = -3,
    TTNetWorkCacheErrorInvalidCacheTime = -4,
    TTNetWorkCacheErrorInvalidMetadata = -5,
    TTNetWorkCacheErrorInvalidCacheData = -6,
    TTNetWorkCacheErrorInvalidCacheEnable = -7,
    TTNetWorkCacheErrorInvalidCachePolicy = -8,
    TTNetWorkCacheErrorInvalidCacheType = -9,
    TTNetWorkCacheErrorInvalidCacheKey = -10
};

#define TTNetWorkEngineErrorDomain @"com.TT.engine"
NS_ENUM(NSInteger) {
    TTNetWorkEngineErrorNone = -1024,
    TTNetWorkEngineErrorNilDomainBean = 1001,
    TTNetWorkEngineErrorDomainBeanInvalid = 1002,
    TTNetWorkEngineErrorNullPointer = 1003,
    TTNetWorkEngineErrorRequestUrlInvalid = 1004,
    TTNetWorkEngineErrorNetStatusCodeInvalid = 1005,
    TTNetWorkEngineErrorResponseStatusCodeInvalid = 1006,
    TTNetWorkEngineErrorResponseJSONInvalid = 1007,
    TTNetWorkEngineErrorRequestArgumentInvalid = 1008,
    TTNetWorkEngineErrorPostDataInvalid = 1009,
    TTNetWorkEngineErrorUploadDataInvalid = 1010
};

//请求开始回调
typedef void (^TTNetWorkEngineRequestBeanBeginBlock)(void);
//请求结束回调
typedef void (^TTNetWorkEngineRequestBeanEndBlock)(void);

//请求成功回调
typedef void (^TTNetWorkRequestSuccessedCallback)(NSURLResponse *response,id responseObject);
//请求失败回调
typedef void (^TTNetWorkRequestFailedCallback)(NSURLResponse *response, id responseObject,NSError *error);

//请求成功回调
typedef void (^TTNetWorkEngineRequestBeanSuccessedBlock)(id requestDomainBean,id respondDomainBean,BOOL dataFromCache);
//请求失败回调
typedef void (^TTNetWorkEngineRequestBeanFailedBlock)(id requestDomainBean,id respondDomainBean,NSError *error);

//请求进度回调
typedef void (^TTNetWorkRequestProgressCallback)(NSProgress *uploadProgress);
//下载完成回调
typedef void (^TTNetWorkDownloadCompleteCallback)(NSURLResponse *response, NSURL *filePath, NSError *error);
//下载进度回调
typedef void (^TTNetWorkDownloadProgressCallback)(NSProgress *downloadProgress);
