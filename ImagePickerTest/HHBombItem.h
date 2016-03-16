//
//  HHBombItem.h
//  ImagePickerTest
//
//  Created by .Mr.SupEr on 16/1/5.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHBombItem : NSObject

@property (nonatomic, assign) BOOL haveBomb;
@property (nonatomic, assign) BOOL haveBeenDetect;
@property (nonatomic, assign) BOOL hasBeenMarkedByFlag;
@property (nonatomic, assign) int bombCount;
@property (nonatomic, strong) NSString *touchPerson;

@end
