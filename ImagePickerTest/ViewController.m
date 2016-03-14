//
//  ViewController.m
//  ImagePickerTest
//
//  Created by .Mr.SupEr on 15/12/11.
//  Copyright © 2015年 .Mr.SupEr. All rights reserved.
//

#import "ViewController.h"
#import "HHCollectionViewCell.h"
#import "HHBombItem.h"

#define rowCount 10

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *bombPositionArray;
@property (nonatomic, assign) int bombCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.bombCount = 35;
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self showImagePicker:UIImagePickerControllerSourceTypeCamera allowsEditing:YES];
}

- (IBAction)didTapRestartButton:(id)sender {
    self.bombCount = self.textField.text.intValue;
    self.textField.text = nil;
    self.bombCount = MAX(self.bombCount,20);
    [self.textField resignFirstResponder];
    [self initData];
    [self.collectionView reloadData];
}

- (IBAction)sliderChange:(UISlider *)sender {
    self.textField.text = [NSString stringWithFormat:@"%d",(int)sender.value];
}

- (void)initData
{
    self.bombPositionArray = [NSMutableArray array];
    int bombCount = self.bombCount;
    for (int i = 0; i < rowCount; ++i) {
        
        NSMutableArray *rowArray = [NSMutableArray array];
        
        for (int j = 0; j < rowCount; ++j) {
            
            HHBombItem *item = [[HHBombItem alloc] init];
            [rowArray addObject:item];
            
            if (bombCount) {
                
                BOOL haveBomb = arc4random()%100 > (100 - self.bombCount);
                
                if (haveBomb) {
                    item.haveBomb = YES;
                    bombCount--;
                }
            }
        }
        [self.bombPositionArray addObject:rowArray];
    }
    
    // statistics bomb
    for (int i = 0; i < rowCount; ++i) {
        for (int j = 0; j < rowCount; ++j) {
            HHBombItem *item = self.bombPositionArray[i][j];
            item.bombCount += [self bombAtX:(i-1) Y:(j-1)];
            item.bombCount += [self bombAtX:(i) Y:(j-1)];
            item.bombCount += [self bombAtX:(i+1) Y:(j-1)];
            item.bombCount += [self bombAtX:(i-1) Y:(j)];
            item.bombCount += [self bombAtX:(i+1) Y:(j)];
            item.bombCount += [self bombAtX:(i-1) Y:(j+1)];
            item.bombCount += [self bombAtX:(i) Y:(j+1)];
            item.bombCount += [self bombAtX:(i+1) Y:(j+1)];
        }
    }
}

- (BOOL)bombAtX:(int)x Y:(int)y
{
    if (x < 0 || y < 0 || x >= rowCount || y >= rowCount) {
        return NO;
    }
    HHBombItem * item = self.bombPositionArray[x][y];
    return item.haveBomb;
}

- (void)showZeroZoneX:(int)x Y:(int)y
{
    if (x < 0 || y < 0 || x >= rowCount || y >= rowCount) {
        return;
    }
    HHBombItem * item = self.bombPositionArray[x][y];
    if (item.haveBeenDetect) {
        return;
    }
    item.haveBeenDetect = YES;
    if (item.bombCount) {
        return;
    }
    [self showZeroZoneX:x-1 Y:y-1];
    [self showZeroZoneX:x-1 Y:y];
    [self showZeroZoneX:x-1 Y:y+1];
    [self showZeroZoneX:x Y:y-1];
    [self showZeroZoneX:x Y:y+1];
    [self showZeroZoneX:x+1 Y:y-1];
    [self showZeroZoneX:x+1 Y:y];
    [self showZeroZoneX:x+1 Y:y+1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType allowsEditing:(BOOL)allowsEditing
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.showsCameraControls = NO;
    picker.delegate = self;
    picker.allowsEditing = allowsEditing;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:picker animated:YES completion:nil];
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return rowCount;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return rowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHCollectionViewCell" forIndexPath:indexPath];
    HHBombItem *item = self.bombPositionArray[indexPath.section][indexPath.item];
    if (item.haveBeenDetect) {
        cell.maskView.hidden = YES;
        if (item.haveBomb) {
            cell.imageView.hidden = NO;
            cell.numberLabel.hidden = YES;
        } else {
            cell.numberLabel.text = [NSString stringWithFormat:@"%d",item.bombCount];
            cell.imageView.hidden = YES;
            cell.numberLabel.hidden = item.bombCount ? NO : YES;
        }
    } else {
        cell.maskView.hidden = NO;
        cell.imageView.hidden = YES;
        cell.numberLabel.hidden = YES;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HHBombItem *item = self.bombPositionArray[indexPath.section][indexPath.item];
    if (item.haveBeenDetect) {
        return;
    }
    if (item.haveBomb) {
        item.haveBeenDetect = YES;
        [collectionView reloadData];
        return;
    }
    [self showZeroZoneX:(int)indexPath.section Y:(int)indexPath.item];
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(screenWidth / 10.f, screenWidth / 10.f);
}
@end
