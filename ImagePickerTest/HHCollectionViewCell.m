//
//  HHCollectionViewCell.m
//  ImagePickerTest
//
//  Created by .Mr.SupEr on 16/1/5.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import "HHCollectionViewCell.h"

@implementation HHCollectionViewCell

- (void)awakeFromNib
{
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 0.5;
}

@end
