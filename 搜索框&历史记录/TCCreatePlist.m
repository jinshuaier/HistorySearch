//
//  TCCreatePlist.m
//  搜索框&历史记录
//
//  Created by 胡高广 on 2017/7/31.
//  Copyright © 2017年 胡高广. All rights reserved.
//

#import "TCCreatePlist.h"

@implementation TCCreatePlist
+(NSString *)createPlistFile:(NSString *)name{
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[name stringByAppendingFormat:@"%@", @".plist"]];
    return filepath;
}

@end
