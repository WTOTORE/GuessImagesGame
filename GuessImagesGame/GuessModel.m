//
//  GuessModel.m
//  GuessImagesGame
//
//  Created by 王涛 on 15/1/1.
//  Copyright (c) 2015年 王涛. All rights reserved.
//

#import "GuessModel.h"

@implementation GuessModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self.answer=dic[@"answer"];
    self.icon=dic[@"icon"];
    self.title=dic[@"title"];
    self.options=dic[@"options"];
    return self;
}
@end
