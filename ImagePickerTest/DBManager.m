//
//  DBManager.m
//  MineGame
//
//  Created by buTing on 16/5/4.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import "DBManager.h"
@implementation DBManager


+ (FMDatabase *)CreateDBAtPath:(NSString *)DBPath 
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
    NSString *docBasePath = docPaths[0];
    NSString *docFullPath = [docBasePath stringByAppendingString:DBPath];
    FMDatabase * db= [FMDatabase databaseWithPath:docFullPath];

    if (![db open]) {
        NSLog(@"could not open gameRecordDB.db ");
    }
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE  IF NOT EXISTS GameRecord(userCount integer , bombCount integer)"];
// lcxNote创建table不给接口，直接写死。 不需要开放接口。数据库对于客户端来说是固定的。
    
    BOOL result = [db executeUpdate:sql];
    
    if (result) {
        NSLog(@"create table success");
    } else {
        NSLog(@"failed create table");
    }
    
    return db;
}




@end
