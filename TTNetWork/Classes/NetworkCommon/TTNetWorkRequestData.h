//
//   TTNetWorkRequestData.h
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import <Foundation/Foundation.h>
#import "TTNetWorkConstants.h"

@interface TTNetWorkRequestData : NSObject

@property (nonatomic, assign) TTNetRequestDataType type;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;

@end

