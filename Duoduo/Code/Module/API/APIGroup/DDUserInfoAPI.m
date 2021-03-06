//
//  DDUserInfoAPI.m
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2014年 zuoye. All rights reserved.
//

#import "DDUserInfoAPI.h"
#import "UserEntity.h"
@implementation DDUserInfoAPI
/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval
{
    return 2;
}

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID
{
    return MODULE_ID_FRIENDLIST;
}

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID
{
    return MODULE_ID_FRIENDLIST;
}

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID
{
    return CMD_FRI_USER_INFO_LIST_REQ;
}

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID
{
    return CMD_FRI_USER_INFO_LIST;
}

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSData* data)
    {
        DataInputStream* bodyData = [DataInputStream dataInputStreamWithData:data];
        uint32_t userCnt = [bodyData readInt];
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        
        for (uint32_t i = 0; i < userCnt; i++) {
            UserEntity *user = [[UserEntity alloc] init];
            user.userId = [bodyData readUTF];
            user.name = [bodyData readUTF];
            user.nick = [bodyData readUTF];
            user.avatar = [bodyData readUTF];
            user.department = [bodyData readUTF];
            user.userRole = [bodyData readInt];
            
            [userList addObject:user];
        }
        
        DDLog(@"userListHandler, userCnt=%u", userCnt);
        return userList;
    };
    return analysis;
}

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject
{
    Package package = (id)^(id object,uint32_t seqNo)
    {
        NSArray* userList = (NSArray*)object;
        DataOutputStream *dataout = [[DataOutputStream alloc] init];
        uint32_t totalLen = IM_PDU_HEADER_LEN + 4;
        uint32_t userCnt = (uint32_t)[userList count];
        for (uint32_t i = 0; i < userCnt; i++) {
            totalLen += 4 + strLen((NSString*)[userList objectAtIndex:i]);
        }
        
        [dataout writeInt:totalLen];
        [dataout writeTcpProtocolHeader:MODULE_ID_FRIENDLIST
                                    cId:CMD_FRI_USER_INFO_LIST_REQ
                                  seqNo:seqNo];
        [dataout writeInt:userCnt];
        for (uint32_t i = 0; i < userCnt; i++) {
            NSString *userId = (NSString*)[userList objectAtIndex:i];
            [dataout writeUTF:userId];
        }
        log4CInfo(@"serviceID:%i cmdID:%i --> get user info list",MODULE_ID_FRIENDLIST,CMD_FRI_USER_INFO_LIST_REQ);
        return [dataout toByteArray];
    };
    return package;
}
@end
