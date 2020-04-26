//
//   TTNetWorkCacheEngine.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNetWorkCacheEngine.h"
#import "TTNetWorkUtils.h"
#import "TTNetWorkConstants.h"
#import "TTNetWorkDomainBeanRequest.h"
#import "TTNetWorkDomainBeanResponse.h"
#import <YYCache/YYCache.h>
#import "TTNetWorkRequestCacheProtocol.h"
#import "TTNetWorkDomainRequestProtocol.h"
#import "TTNetWorkDomainResponseProtocol.h"
#import "TTNetWorkConfig.h"
#import "TTNetEngine.h"
#import "TTNetWorkCacheHandle.h"

@interface TTNetWorkRequestCacheMetaData : NSObject<NSSecureCoding>

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *appVersionString;
@end

@implementation TTNetWorkRequestCacheMetaData

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.version forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.version = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(version))];
        self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
        self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];
    }
    return self;
}

@end


@implementation TTNetWorkCacheEngine

#pragma mark - cache

+ (YYCache *)cacheInstance {
    static dispatch_once_t onceToken;
    static YYCache *instance;
    dispatch_once(&onceToken, ^{
        instance = [YYCache cacheWithName:[self cachePath]];
    });
    
    return instance;
}

#pragma mark - TTNetWorkCacheProtocol

- (id<TTNetWorkCacheHandleProtocol>)writeCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                               responseObject:(id)responseObject
                                                        error:(NSError **)error {
    do {
        ///< 缓存策略
        id<TTNetWorkRequestCacheProtocol>polocy;
        MESSAGE_SEND(requestBean, cachePolocy){
            polocy = [requestBean cachePolocy];
        }
        if (!polocy) {
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCachePolicy
                                         userInfo:@{ NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 缺失缓存策略！",requestBean]}];
            }
            break;
        }
        
        ///< 接口数据是否需要缓存
        BOOL cacheEnable = NO;
        MESSAGE_SEND(polocy, shouldCacheWithRequestBean:){
            cacheEnable = [polocy shouldCacheWithRequestBean:requestBean];
        }
        if(!cacheEnable){
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheEnable
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 不支持缓存！",requestBean]}];
            }
            break;
        }
        
        ///< 缓存时间是否有效
        NSInteger cacheEffectiveTime = -1;
        MESSAGE_SEND(polocy, cacheTimeInSeconds){
            cacheEffectiveTime = [polocy cacheTimeInSeconds];
        }
        
        ///< 缓存存储方式
        TTNetRequestCachePolicy cachePolicy = TTNetRequestCacheMemory;
        MESSAGE_SEND(polocy, cachePolicyWithRequestBean:){
            cachePolicy = [polocy cachePolicyWithRequestBean:requestBean];
        }
        
        ///< 缓存存储方式是否合法
        if (cachePolicy != TTNetRequestCacheMemory && cachePolicy != TTNetRequestCacheDisk){
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheType
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 存储方式无效！",requestBean]}];
            }
            break;
        }
        
        ///< 缓存标识符
        NSString *const cacheName = [polocy cacheIdentificationWithRequestBean:requestBean];
        if (cacheName == nil) {
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheKey
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 缓存标识不能为空！",requestBean]}];
            }
            break;
        }
        NSString *const cacheMetaName = [cacheName stringByAppendingString:@".Metadata"];
        
        YYCache *cache = [TTNetWorkCacheEngine cacheInstance];
        
        if (cacheEffectiveTime > 0) {
            ///< 是否有有效数据
            if (responseObject == nil) {
                if (error) {
                    *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                                 code:TTNetWorkCacheErrorInvalidCacheData
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 数据无效！",requestBean]}];
                }
                break;
            }
            
            TTNetWorkRequestCacheMetaData *metadata = [[TTNetWorkRequestCacheMetaData alloc] init];
            metadata.version = [polocy cacheVersion];
            metadata.creationDate = [NSDate date];
            metadata.appVersionString = [TTNetWorkUtils appVersionString];
            ///< 是否外部拦截缓存事件
            BOOL shouldHoldCacheEvent = NO;
            MESSAGE_SEND(polocy, interceptCacheWithRequestBean:){
                shouldHoldCacheEvent = [polocy interceptCacheWithRequestBean:requestBean];
            }
            
            if (shouldHoldCacheEvent) {
                NSLog(@"TTDevNetWorking -> cacheEvent hold, not should write cache!");
                break;
            }else{
                if (cachePolicy == TTNetRequestCacheMemory) {
                    [cache.memoryCache setObject:responseObject forKey:cacheName];
                    [cache.memoryCache setObject:metadata forKey:cacheMetaName];
                }else{
                    [cache setObject:responseObject forKey:cacheName];
                    [cache setObject:metadata forKey:cacheMetaName];
                }
            }
            
            TTNetWorkCacheHandle *handle = [[TTNetWorkCacheHandle alloc] initWithCache:cache key:cacheName];
            return handle;
        }else{
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheTime
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 时间过期！",requestBean]}];
            }
            [cache removeObjectForKey:cacheName];
            [cache removeObjectForKey:cacheMetaName];
            break;
        }
        
    } while (NO);
    
    return TTNetWorkCacheHandleNilObject.alloc.init;
}

- (id<TTNetWorkCacheHandleProtocol>)loadCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                                       error:(NSError **)error {
    do {
        ///< 缓存策略
        id<TTNetWorkRequestCacheProtocol>polocy;
        MESSAGE_SEND(requestBean, cachePolocy){
            polocy = [requestBean cachePolocy];
        }
        if (!polocy) {
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCachePolicy
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 缺失缓存策略！",requestBean]}];
            }
            break;
        }
        
        ///< 接口数据是否需要缓存
        BOOL cacheEnable = NO;
        MESSAGE_SEND(polocy, shouldCacheWithRequestBean:){
            cacheEnable = [polocy shouldCacheWithRequestBean:requestBean];
        }
        if(!cacheEnable){
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheEnable
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 不支持缓存！",requestBean]}];
            }
            break;
        }
        
        ///< 缓存时间是否有效
        NSInteger cacheEffectiveTime = -1;
        MESSAGE_SEND(polocy, cacheTimeInSeconds){
            cacheEffectiveTime = [polocy cacheTimeInSeconds];
        }
        
        ///< 缓存存储方式
        TTNetRequestCachePolicy cachePolicy = TTNetRequestCacheMemory;
        MESSAGE_SEND(polocy, cachePolicyWithRequestBean:){
            cachePolicy = [polocy cachePolicyWithRequestBean:requestBean];
        }
        
        ///< 缓存存储方式是否有效
        if (cachePolicy != TTNetRequestCacheMemory && cachePolicy != TTNetRequestCacheDisk){
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheType
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 存储方式无效！",requestBean]}];
            }
            break;
        }
        
        ///< 缓存标识符
        NSString *const cacheName = [polocy cacheIdentificationWithRequestBean:requestBean];
        if (cacheName == nil) {
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheKey
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 缓存标识不能为空！",requestBean]}];
            }
            break;
        }
        NSString *const cacheMetaName = [cacheName stringByAppendingString:@".Metadata"];
        YYCache *cache = [TTNetWorkCacheEngine cacheInstance];
        
        if (cacheEffectiveTime > 0) {
            ///< 是否有有效数据
            if (requestBean == nil) {
                if (error) {
                    *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                                 code:TTNetWorkCacheErrorInvalidCacheData
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 数据无效！",requestBean]}];
                }
                break;
            }
            
            TTNetWorkRequestCacheMetaData *metadata;
            if (cachePolicy == TTNetRequestCacheMemory) {
                metadata = (TTNetWorkRequestCacheMetaData *)[cache.memoryCache objectForKey:cacheMetaName];
            }else{
                metadata = (TTNetWorkRequestCacheMetaData *)[cache objectForKey:cacheMetaName];
            }
            
            ///< 缓存元数据是否有效
            if (metadata == nil) {
                if (error) {
                    *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                                 code:TTNetWorkCacheErrorInvalidMetadata
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 元数据获取失败！",requestBean]}];
                }
                break;
            }
            
            ///< 缓存是否过期
            NSDate *creationDate = metadata.creationDate;
            NSTimeInterval duration = -[creationDate timeIntervalSinceNow];
            if (duration < 0 || duration > cacheEffectiveTime) {
                if (error) {
                    *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                                 code:TTNetWorkCacheErrorInvalidCacheTime
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 时间过期！",requestBean]}];
                }
                break;
            }
            
            ///< 缓存版本
            NSString *const cacheVersionFileContent = metadata.version;
            if (![cacheVersionFileContent isEqualToString:[polocy cacheVersion]]) {
                if (error) {
                    *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                                 code:TTNetWorkCacheErrorVersionMismatch
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 版本不一致！",requestBean]}];
                }
                break;
            }
            
            id cacheObject = nil;
            ///< 是否外部拦截缓存事件
            BOOL shouldHoldCacheEvent = NO;
            MESSAGE_SEND(polocy, interceptCacheWithRequestBean:){
                shouldHoldCacheEvent = [polocy interceptCacheWithRequestBean:requestBean];
            }
            
            if(shouldHoldCacheEvent){
                NSLog(@"TTDevNetWorking -> cacheEvent hold, not should read cache!");
                break;
            }else{
                if (cachePolicy == TTNetRequestCacheMemory) {
                    cacheObject = [cache.memoryCache objectForKey:cacheName];
                }else{
                    cacheObject = [cache objectForKey:cacheName];
                }
            }
            
            if (cacheObject == nil) {
                if (error) {
                    *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                                 code:TTNetWorkCacheErrorInvalidCacheData
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 没有从缓存中取到有效数据！",requestBean]}];
                }
                break;
            }
            
            TTNetWorkCacheHandle *handle = [[TTNetWorkCacheHandle alloc] initWithCache:cache key:cacheName];
            return handle;
            
        }else{
            if (error) {
                *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                             code:TTNetWorkCacheErrorInvalidCacheTime
                                         userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 时间过期！",requestBean]}];
            }
            break;
        }
        
    } while (NO);
    
    return TTNetWorkCacheHandleNilObject.alloc.init;
}

- (id<TTNetWorkCacheHandleProtocol>)clearCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean
                                                        error:(NSError **)error {
    ///< 缓存策略
    id<TTNetWorkRequestCacheProtocol>polocy;
    MESSAGE_SEND(requestBean, cachePolocy){
        polocy = [requestBean cachePolocy];
    }
    if (!polocy) {
        if (error) {
            *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                         code:TTNetWorkCacheErrorInvalidCachePolicy
                                     userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 缺失缓存策略！",requestBean]}];
        }
        return TTNetWorkCacheHandleNilObject.alloc.init;
    }
    
    ///< 缓存标识符
    NSString *const cacheName = [polocy cacheIdentificationWithRequestBean:requestBean];
    if (cacheName == nil) {
        if (error) {
            *error = [NSError errorWithDomain:TTNetWorkCacheErrorDomain
                                         code:TTNetWorkCacheErrorInvalidCacheKey
                                     userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"网络缓存：%@ 缓存标识不能为空！",requestBean]}];
        }
        return TTNetWorkCacheHandleNilObject.alloc.init;
    }
    NSString *const cacheMetaName = [cacheName stringByAppendingString:@".Metadata"];
    
    YYCache *cache = [TTNetWorkCacheEngine cacheInstance];
    [cache removeObjectForKey:cacheName];
    [cache removeObjectForKey:cacheMetaName];
    
    TTNetWorkCacheHandle *handle = [[TTNetWorkCacheHandle alloc] initWithCache:cache key:cacheName];
    return handle;
}

- (BOOL)hasCacheWithRequestBean:(TTNetWorkDomainBeanRequest *)requestBean {
    NSError *error;
    id<TTNetWorkCacheHandleProtocol> handle = [self loadCacheWithRequestBean:requestBean
                                                                       error:&error];
    if (error != nil) {
        return NO;
    }
    id data = [handle cacheData];
    return data != nil;
}

#pragma mark - cache path

+ (NSString *)cachePath {
    if ([TTNetEngine sharedInstance].engineConfigation.cachePath == nil ||
        [TTNetEngine sharedInstance].engineConfigation.cachePath.length == 0) {
        [TTNetEngine sharedInstance].engineConfigation.cachePath = @"TTRequestCache";
    }
    return [TTNetWorkUtils md5StringFromString:[TTNetEngine sharedInstance].engineConfigation.cachePath];
}

@end
