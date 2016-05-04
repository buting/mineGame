//
//  DBManager.h
//  MineGame
//
//  Created by buTing on 16/5/4.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBManager : NSObject

+ (FMDatabase *)CreateDBAtPath:(NSString *)DBPath ;

@end
