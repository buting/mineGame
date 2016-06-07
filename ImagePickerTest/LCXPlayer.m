//
//  LCXPlayer.m
//  MineGame
//
//  Created by buTing on 16/6/4.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import "LCXPlayer.h"
#import "LCXPlayerMaster.h"
#import "LCXPlayerFresh.h"
@implementation LCXPlayer

+ (LCXPlayer*)playerWithLevel:(LCXPlayerLevel)level{
    switch (level) {
        case LCXPlayerLevelMaster:
            return [LCXPlayerMaster new];
            break;
        case LCXPlayerLevelFresh:
            return [LCXPlayerFresh new];
            break;
    }
}
- (void)playGame{
// subclass doing this method .
// 这是抽象基类，不作任何事情，只通过工厂方法对外提供子类。
    
}
@end
