//
//   TTNetWorkEngine.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkEngine.h"
#import "TTNetWorkConfig.h"
#import "TTNetWorkEngineHandle.h"
#import "TTNetWorkUtils.h"
#import "TTNetWorkEngineHandle.h"
#import <AFNetworking/AFNetworking.h>

#define kTTNetworkIncompleteDownloadFolderName @"Incomplete"

@interface TTNetWorkEngine()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPResponseSerializer *httpResponseSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) AFXMLParserResponseSerializer *xmlParserResponseSerialzier;
@end

@implementation TTNetWorkEngine{
    dispatch_queue_t _processingQueue;
    NSIndexSet *_allStatusCodes;
    NSSet <NSString *> *_allContentTypes;
}

#pragma mark - <Instancetype>

- (instancetype)init {
    if ((self = [super init])) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        _processingQueue = dispatch_queue_create("com.TT.processing", DISPATCH_QUEUE_CONCURRENT);
        _allStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        _allContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",  @"text/html",nil];
        
        _manager.responseSerializer = self.httpResponseSerializer;
        _manager.completionQueue = _processingQueue;
    }
    return self;
}

#pragma mark - AFHTTPResponseSerializer

- (AFHTTPResponseSerializer *)httpResponseSerializer {
    if (!_httpResponseSerializer) {
        _httpResponseSerializer = [AFHTTPResponseSerializer serializer];
        _httpResponseSerializer.acceptableStatusCodes = _allStatusCodes;
        _httpResponseSerializer.acceptableContentTypes = _allContentTypes;
    }
    return _httpResponseSerializer;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableStatusCodes = _allStatusCodes;
        _jsonResponseSerializer.acceptableContentTypes = _allContentTypes;
    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlParserResponseSerialzier) {
        _xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
        _xmlParserResponseSerialzier.acceptableStatusCodes = _allStatusCodes;
        _xmlParserResponseSerialzier.acceptableContentTypes = _allContentTypes;
    }
    return _xmlParserResponseSerialzier;
}

#pragma mark - TTNetWorkRequestProtocol

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
                                                   failure:(TTNetWorkRequestFailedCallback)failure {
    
    if (securityPolicy != nil && [securityPolicy isKindOfClass:[AFSecurityPolicy class]]) {
        _manager.securityPolicy = securityPolicy;
    }
    
    NSError * __autoreleasing requestSerializationError = nil;
    NSURLSessionDataTask *task = [self sessionTaskForUrlString:urlString
                                                        method:method
                                             requestSerializer:requestSerializer
                                            responseSerializer:responseSerializer
                                                 authorization:authorization
                                                       headers:headers
                                                      argument:argument
                                                          data:data
                                                       timeout:timeout
                                          allowsCellularAccess:allowsCellularAccess
                                                      progress:progress
                                                       success:success
                                                       failure:failure
                                                         error:&requestSerializationError];
    if (requestSerializationError) {
        if (failure) {
            failure(nil,nil,requestSerializationError);
        }
        return [[TTNetWorkEngineNilObject alloc] init];
    }
    
    NSAssert(task != nil, @"requestTask should not be nil");
    
    if ([task respondsToSelector:@selector(priority)]) {
        switch (priority) {
            case TTNetRequestPriorityHigh:
                task.priority = NSURLSessionTaskPriorityHigh;
                break;
            case TTNetRequestPriorityLow:
                task.priority = NSURLSessionTaskPriorityLow;
                break;
            case TTNetRequestPriorityNormal:
            default:
                task.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    
    [task resume];
    
    TTNetWorkEngineHandle *requestHandle = [[TTNetWorkEngineHandle alloc] initWithTask:task];
    
    return requestHandle;
}

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
                                                    failure:(TTNetWorkRequestFailedCallback)failure
{
    if (securityPolicy != nil && [securityPolicy isKindOfClass:[AFSecurityPolicy class]]) {
        _manager.securityPolicy = securityPolicy;
    }
    
    NSError * __autoreleasing requestSerializationError = nil;
    NSURLSessionDataTask *task = [self sessionTaskForUrlString:urlString
                                             requestSerializer:requestSerializer
                                                 authorization:authorization
                                                       headers:headers
                                                      argument:argument
                                                       timeout:timeout
                                         resumableDownloadPath:resumableDownloadPath
                                          allowsCellularAccess:allowsCellularAccess
                                                      progress:progress
                                                      complete:complete
                                                       failure:failure
                                                         error:&requestSerializationError];
    if (requestSerializationError) {
        if (failure) {
            failure(nil,nil,requestSerializationError);
        }
        return [[TTNetWorkEngineNilObject alloc] init];
    }
    
    NSAssert(task != nil, @"requestTask should not be nil");
    
    if ([task respondsToSelector:@selector(priority)]) {
        switch (priority) {
            case TTNetRequestPriorityHigh:
                task.priority = NSURLSessionTaskPriorityHigh;
                break;
            case TTNetRequestPriorityLow:
                task.priority = NSURLSessionTaskPriorityLow;
                break;
            case TTNetRequestPriorityNormal:
            default:
                task.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    
    [task resume];
    
    TTNetWorkEngineHandle *requestHandle = [[TTNetWorkEngineHandle alloc] initWithTask:task];
    
    return requestHandle;
}

#pragma mark - sessionTask

- (NSURLSessionDataTask *)sessionTaskForUrlString:(NSString *)urlString
                                           method:(TTNetRequestMethod)method
                                requestSerializer:(TTNetRequestSerializer)requestSerializer
                               responseSerializer:(TTNetResponseSerializer)responseSerializer
                                    authorization:(NSArray *)authorization
                                          headers:(NSDictionary *)headers
                                         argument:(id)argument
                                             data:(TTNetWorkRequestData *)data
                                          timeout:(NSTimeInterval)timeout
                             allowsCellularAccess:(BOOL)allowsCellularAccess
                                         progress:(TTNetWorkRequestProgressCallback)progress
                                          success:(TTNetWorkRequestSuccessedCallback)success
                                          failure:(TTNetWorkRequestFailedCallback)failure
                                            error:(NSError * __autoreleasing *)error{
    
    AFHTTPRequestSerializer *AFRequestSerializer = [self requestSerializer:requestSerializer
                                                           timeoutInterval:timeout
                                                      allowsCellularAccess:allowsCellularAccess
                                                       authorizationHeader:authorization
                                                                   headers:headers];
    
    AFHTTPResponseSerializer *AFResponseSerializer = [self responseSerializer:responseSerializer];
    
    switch (method) {
        case TTNetRequestMethodGET:
            return [self dataTaskWithHTTPMethod:@"GET"
                              requestSerializer:AFRequestSerializer
                             responseSerializer:AFResponseSerializer
                                      URLString:urlString
                                       argument:argument
                                           data:data
                                       progress:progress
                                        success:success
                                        failure:failure
                                          error:error];
        case TTNetRequestMethodPOST:
            return [self dataTaskWithHTTPMethod:@"POST"
                              requestSerializer:AFRequestSerializer
                             responseSerializer:AFResponseSerializer
                                      URLString:urlString
                                       argument:argument
                                           data:data
                                       progress:progress
                                        success:success
                                        failure:failure
                                          error:error];
        case TTNetRequestMethodHEAD:
            return [self dataTaskWithHTTPMethod:@"HEAD"
                              requestSerializer:AFRequestSerializer
                             responseSerializer:AFResponseSerializer
                                      URLString:urlString
                                       argument:argument
                                           data:data
                                       progress:progress
                                        success:success
                                        failure:failure
                                          error:error];
        case TTNetRequestMethodPUT:
            return [self dataTaskWithHTTPMethod:@"PUT"
                              requestSerializer:AFRequestSerializer
                             responseSerializer:AFResponseSerializer
                                      URLString:urlString
                                       argument:argument
                                           data:data
                                       progress:progress
                                        success:success
                                        failure:failure
                                          error:error];
        case TTNetRequestMethodDELETE:
            return [self dataTaskWithHTTPMethod:@"DELETE"
                              requestSerializer:AFRequestSerializer
                             responseSerializer:AFResponseSerializer
                                      URLString:urlString
                                       argument:argument
                                           data:data
                                       progress:progress
                                        success:success
                                        failure:failure
                                          error:error];
        case TTNetRequestMethodPATCH:
            return [self dataTaskWithHTTPMethod:@"PATCH"
                              requestSerializer:AFRequestSerializer
                             responseSerializer:AFResponseSerializer
                                      URLString:urlString
                                       argument:argument
                                           data:data
                                       progress:progress
                                        success:success
                                        failure:failure
                                          error:error];
        default:
            return nil;
    }
}

- (NSURLSessionDataTask *)sessionTaskForUrlString:(NSString *)urlString
                                requestSerializer:(TTNetRequestSerializer)requestSerializer
                                    authorization:(NSArray *)authorization
                                          headers:(NSDictionary *)headers
                                         argument:(id)argument
                                          timeout:(NSTimeInterval)timeout
                            resumableDownloadPath:(NSString*)resumableDownloadPath
                             allowsCellularAccess:(BOOL)allowsCellularAccess
                                         progress:(TTNetWorkDownloadProgressCallback)progress
                                         complete:(TTNetWorkDownloadCompleteCallback)complete
                                          failure:(TTNetWorkRequestFailedCallback)failure
                                            error:(NSError * __autoreleasing *)error {
    AFHTTPRequestSerializer *AFRequestSerializer = [self requestSerializer:requestSerializer
                                                           timeoutInterval:timeout
                                                      allowsCellularAccess:allowsCellularAccess
                                                       authorizationHeader:authorization
                                                                   headers:headers];
    
    return (NSURLSessionDataTask *)[self dataTaskWithDownloadPath:resumableDownloadPath
                                                requestSerializer:AFRequestSerializer
                                                        URLString:urlString
                                                       parameters:argument
                                                         progress:progress
                                                         complete:complete
                                                            error:error];
}

#pragma mark - data task

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                              responseSerializer:(AFHTTPResponseSerializer *)responseSerializer
                                       URLString:(NSString *)URLString
                                        argument:(id)argument
                                            data:(TTNetWorkRequestData *)data
                                        progress:(TTNetWorkRequestProgressCallback)progress
                                         success:(TTNetWorkRequestSuccessedCallback)success
                                         failure:(TTNetWorkRequestFailedCallback)failure
                                           error:(NSError * __autoreleasing *)error {
    
    NSMutableURLRequest *request = nil;
    id parameters = argument;
    if (data) {
        __block TTNetWorkRequestData *requestData = data;
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:URLString
                                                         parameters:parameters
                                          constructingBodyWithBlock:^(id<AFMultipartFormData>formData) {
            if (requestData.type == TTNetRequestDataTypeFile && requestData.data != nil) {
                [formData appendPartWithFileData:requestData.data
                                            name:requestData.name
                                        fileName:requestData.fileName
                                        mimeType:requestData.mimeType];
            }
            if (requestData.type == TTNetRequestDataTypeForm && requestData.data != nil) {
                [formData appendPartWithFormData:requestData.data
                                            name:requestData.name];
            }
            if (requestData.type == TTNetRequestDataTypeFileUrl && requestData.fileUrl != nil) {
                [formData appendPartWithFileURL:requestData.fileUrl
                                           name:requestData.name
                                       fileName:requestData.fileName
                                       mimeType:requestData.mimeType
                                          error:nil];
            }
        }
                                                              error:error];
    } else {
        request = [requestSerializer requestWithMethod:method
                                             URLString:URLString
                                            parameters:parameters
                                                 error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request
                              uploadProgress:progress
                            downloadProgress:nil
                           completionHandler:^(NSURLResponse *response, id responseObject, NSError * _error) {
        
        if (_error && failure) {
            failure(response,responseObject,_error);
        }
        if (!_error && success) {
            
            NSError * __autoreleasing serializationError = nil;
            
            if ([responseObject isKindOfClass:[NSData class]]) {
                if ([responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
                    responseObject = [(AFJSONResponseSerializer *)responseSerializer responseObjectForResponse:response
                                                                                                          data:responseObject
                                                                                                         error:&serializationError];
                }
                if ([responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]]) {
                    responseObject = [(AFXMLParserResponseSerializer *)responseSerializer responseObjectForResponse:response
                                                                                                               data:responseObject
                                                                                                              error:&serializationError];
                }
            }
            
            if (serializationError) {
                if (failure) {
                    failure(response,responseObject,serializationError);
                }
            }else{
                success(response,responseObject);
            }
            
        }
    }];
    
    return dataTask;
}

- (NSURLSessionDownloadTask *)dataTaskWithDownloadPath:(NSString *)downloadPath
                                     requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                             URLString:(NSString *)URLString
                                            parameters:(id)parameters
                                              progress:(TTNetWorkDownloadProgressCallback)progress
                                              complete:(TTNetWorkDownloadCompleteCallback)complete
                                                 error:(NSError * __autoreleasing *)error {
    
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:@"GET"
                                                                 URLString:URLString
                                                                parameters:parameters
                                                                     error:error];
    
    NSString *downloadTargetPath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTargetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTargetPath error:nil];
    }
    
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self incompleteDownloadTempPathForDownloadPath:downloadPath].path];
    NSData *data = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPathForDownloadPath:downloadPath]];
    BOOL resumeDataIsValid = [TTNetWorkUtils validateResumeData:data];
    
    BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    
    if (canBeResumed) {
        @try {
            downloadTask = [_manager downloadTaskWithResumeData:data
                                                       progress:progress
                                                    destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (complete) {
                    complete(response,filePath,error);
                }
            }];
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            NSLog(@"Resume download failed, reason = %@", exception.reason);
            resumeSucceeded = NO;
        }
    }
    
    if (!resumeSucceeded) {
        downloadTask = [_manager downloadTaskWithRequest:urlRequest
                                                progress:progress
                                             destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (complete) {
                complete(response,filePath,error);
            }
        }];
    }
    return downloadTask;
}

#pragma mark - Resumable Download

- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kTTNetworkIncompleteDownloadFolderName];
    }
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [TTNetWorkUtils md5StringFromString:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

#pragma mark - AFHTTPRequestSerializer

- (AFHTTPRequestSerializer *)requestSerializer:(TTNetRequestSerializer)serializer
                               timeoutInterval:(NSTimeInterval)timeoutInterval
                          allowsCellularAccess:(BOOL)allowsCellularAccess
                           authorizationHeader:(NSArray *)authorizationHeader
                                       headers:(NSDictionary *)headers {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (serializer == TTNetRequestSerializerHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if (serializer == TTNetRequestSerializerJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }else if (serializer == TTNetRequestSerializerPropertyList) {
        requestSerializer = [AFPropertyListRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = timeoutInterval;
    requestSerializer.allowsCellularAccess = allowsCellularAccess;
    
    NSArray<NSString *> *authorizationHeaderFieldArray = authorizationHeader;
    if (authorizationHeaderFieldArray != nil && authorizationHeaderFieldArray.count == 2) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
                                                          password:authorizationHeaderFieldArray.lastObject];
    }
    
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = headers;
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

#pragma mark - responseSerializer

- (AFHTTPResponseSerializer *)responseSerializer:(TTNetResponseSerializer)serializer {
    if (serializer == TTNetResponseSerializerJSON) {
        return self.jsonResponseSerializer;
    }else if (serializer == TTNetResponseSerializerXMLParser){
        return self.xmlParserResponseSerialzier;
    }else{
        return self.httpResponseSerializer;
    }
}

@end
