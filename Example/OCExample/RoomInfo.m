//
//  RoomInfo.m
//  OCExample
//
//  Created by xuyunshi on 2022/1/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

#import "RoomInfo.h"

RoomInfoKey const RoomInfoAPPID = @"APPID";
RoomInfoKey const RoomInfoRoomID = @"ROOMUUID";
RoomInfoKey const RoomInfoRoomToken = @"ROOMTOKEN";

@implementation RoomInfo


+ (NSString *)getValueFrom:(RoomInfoKey)key {
    NSDictionary* bundleDictionary = [[NSBundle mainBundle] infoDictionary];
    return bundleDictionary[key];
}

@end
