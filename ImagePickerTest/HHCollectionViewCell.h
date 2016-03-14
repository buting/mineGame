//
//  HHCollectionViewCell.h
//  ImagePickerTest
//
//  Created by .Mr.SupEr on 16/1/5.
//  Copyright © 2016年 .Mr.SupEr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end
