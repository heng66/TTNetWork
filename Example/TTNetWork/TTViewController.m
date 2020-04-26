//
//  TTViewController.m
//  TTNetWork
//
//  Created by heng66 on 03/24/2020.
//  Copyright (c) 2020 heng66. All rights reserved.
//

#import "TTViewController.h"
#import "TTNetEngine.h"
#import "TTNewsRequest.h"
#import "TTNewsResponse.h"

@interface TTViewController ()

@end

@implementation TTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTNewsRequest *requestBean = [[TTNewsRequest alloc] init];
    TTNewsResponse *responseBean = [[TTNewsResponse alloc] init];
    [[TTNetEngine sharedInstance] excuteWithRequestBean:requestBean
                                           responseBean:responseBean
                                              successed:^(id requestDomainBean, id respondDomainBean,BOOL dataFromCache) {
        NSLog(@"requestDomainBean -- >%@ \n respondDomainBean -- >%@",requestDomainBean,((TTNewsResponse*)respondDomainBean).responseObject);
        
    }
                                                 failed:^(id requestDomainBean, id respondDomainBean, NSError *error) {
        NSLog(@"error -- > %@ = ",error);
    }];
    
}

@end
