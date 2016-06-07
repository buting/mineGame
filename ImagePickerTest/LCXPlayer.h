//
//  LCXPlayer.h
//  MineGame
//
//  Created by buTing on 16/6/4.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LCXPlayerLevel) {
    LCXPlayerLevelMaster,
    LCXPlayerLevelFresh,
};

@interface LCXPlayer : NSObject

+ (LCXPlayer *)playerWithLevel:(LCXPlayerLevel)level;
- (void)playGame;
@end
