//
//   TTNewsRequest.m
//   TTNetWork_Example
//
//   Created  by chenqg on 2020/4/26
//   Copyright © 2020 chenqg. All rights reserved.
//
   
#import "TTNewsRequest.h"
#import "TTNewsCachePolicy.h"

@implementation TTNewsRequest

- (NSString *)requestUrl {
//    return @"https://api.qctt.cn/qctt-api/8.3.2/Users/getUserInfo";
    return @"https://ios.baertt.com/v3/article/lists.json?&access=WIFI&app_version=1.7.8&catid=0&channel=80000000&channel_code=80000000&cid=80000000&client_version=1.7.8&device_brand=iphone&device_id=&device_model=iPhone&device_platform=iphone&device_type=iphone&fuck=1&isnew=1&mobile_type=2&net_type=1&openudid=181ef1997e1f8a518703162f75a98290&os_version=12.3.1&phone_code=181ef1997e1f8a518703162f75a98290&phone_network=WIFI&platform=3&request_time=1587914096&resolution=750x1334&sign=0efa323d18325d7a9dcad09c0fc21d37&sm_device_id=20191211085342e2bde2c264546a4b2b1a40082a78ea4601feb1e6ad2e2440&step=0&szlm_ddid=D2SqsCg5iN8Icti/tGa%2BQTeghbbb27wxYpt6UZzFTN47wXfe&time=1587914096&uid=44308075&uuid=181ef1997e1f8a518703162f75a98290";
}

- (id)requestArgument {
//    NSDictionary *params = @{@"dataVersion":@"8.3.2",@"deviceid":@"4201A4F1-0E12-4EDE-8CED-082F619A1940",@"platform":@"iOS",@"region":@"%E5%8C%97%E4%BA%AC",@"time":@"2020-04-26%2021%3A35%3A10",@"token":@"f89567225174643582ef2f7be1df3db1",@"userId":@"1524615"};
    return @{};
}

- (id<TTNetWorkRequestCacheProtocol>)cachePolocy {
    return [[TTNewsCachePolicy alloc] init];
}

- (TTNetRequestMethod)requestMethod {
    return TTNetRequestMethodGET;
}

@end
