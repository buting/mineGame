//
//  ViewController.m
//  ImagePickerTest
//
//  Created by .Mr.SupEr on 15/12/11.
//  Copyright © 2015年 .Mr.SupEr. All rights reserved.
//
#define SCREEN_WIDTH    ([[UIScreen mainScreen]bounds].size.width)

#import "ViewController.h"
#import "HHCollectionViewCell.h"
#import "HHBombItem.h"

#define rowCount 10

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *bombPositionArray;
@property (nonatomic, assign) int bombCountSetted;
@property (nonatomic, assign) int countOfMarkedFlags; //已经插旗的数量
@property (nonatomic, assign) int X;  //点击数字 的横坐标
@property (nonatomic, assign) int Y;  //点击数字 的Y坐标
@property (nonatomic, assign) int numOfFlagsAroundItem;  //Item附近的旗的数量



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.bombCountSetted = 35;
    [self initData];
    [self addGesture];

}
- (void)addGesture
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.numberOfTouchesRequired = 1;
    lpgr.minimumPressDuration = 0.2;
    [self.collectionView addGestureRecognizer:lpgr];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"handleLongPressaa");
CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        float widthItem = SCREEN_WIDTH/rowCount;
        NSInteger x = point.y / widthItem;
        NSInteger y = point.x / widthItem;
        if (x < 0 || y < 0 || x >= rowCount || y >= rowCount) {
            return;
        }
        NSLog(@"test");
        HHBombItem * item = self.bombPositionArray[x][y];
        NSLog(@"hasBeenMarkedByFlag 00-> %d",item.hasBeenMarkedByFlag);

        if (item.haveBeenDetect) {
            return;
        }
        if (item.hasBeenMarkedByFlag) {
            item.hasBeenMarkedByFlag = NO;
            --self.countOfMarkedFlags;
        } else {
            item.hasBeenMarkedByFlag = YES;
            NSLog(@"hasBeenMarkedByFlag 11-> %d",item.hasBeenMarkedByFlag);

            ++self.countOfMarkedFlags;
        }
        [self.collectionView reloadData];
    }
}

-(int)checkAroundFlagNumsWithPositionX:(int) x Y:(int)y{
    int numOfFlags=0;
    for (int i=x-1; i<=x+1; i++) {
        for (int j=y-1; j<=y+1; j++) {
            HHBombItem * item = self.bombPositionArray[i][j];

            if (item.hasBeenMarkedByFlag) {
                numOfFlags++;
            }
        }
    }
    return numOfFlags;
}

- (void)showAroundZoneX:(int )x Y:(int)y  {
    if (x < 0 || y < 0 || x >= rowCount || y >= rowCount) {
        return;
    }
    HHBombItem * item = self.bombPositionArray[x][y];
    
    //查询附近的插旗数量，如果插旗数量！=数字，return
   int numOfFlagsAroundItem = [self checkAroundFlagNumsWithPositionX:x Y:y];
    if (item.bombCount != numOfFlagsAroundItem){
        return;
    }


    //对相邻九宫格的处理
    if (x >= _X-1 && x <= _X+1 &&y >=_Y-1 && y <=_Y+1) {
        item.haveBeenDetect = YES;
        if (item.hasBeenMarkedByFlag) { //如果有插错的旗，设置为已经掀开，刷新UI。
            --self.countOfMarkedFlags;
        }
        
        [self showZeroZoneX:x-1 Y:y-1];
        [self showZeroZoneX:x-1 Y:y];
        [self showZeroZoneX:x-1 Y:y+1];
        [self showZeroZoneX:x Y:y-1];
        [self showZeroZoneX:x Y:y+1];
        [self showZeroZoneX:x+1 Y:y-1];
        [self showZeroZoneX:x+1 Y:y];
        [self showZeroZoneX:x+1 Y:y+1];
        
    } else {
        if (item.haveBeenDetect) {
            return;
        }
        item.haveBeenDetect = YES;
        if (item.hasBeenMarkedByFlag) {
            --self.countOfMarkedFlags;
        }
        if (item.bombCount) {//检测到数字时已经停止，所以肯定碰不到雷，不再判断是否为雷。
            return;
        }
    }
    item.haveBeenDetect = YES;
    [self showZeroZoneX:x-1 Y:y-1];
    [self showZeroZoneX:x-1 Y:y];
    [self showZeroZoneX:x-1 Y:y+1];
    [self showZeroZoneX:x Y:y-1];
    [self showZeroZoneX:x Y:y+1];
    [self showZeroZoneX:x+1 Y:y-1];
    [self showZeroZoneX:x+1 Y:y];
    [self showZeroZoneX:x+1 Y:y+1];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self showImagePicker:UIImagePickerControllerSourceTypeCamera allowsEditing:YES];
}

- (IBAction)didTapRestartButton:(id)sender {
    self.bombCountSetted = self.textField.text.intValue;
    self.textField.text = nil;
    self.countOfMarkedFlags = 0;
    self.bombCountSetted = MAX(self.bombCountSetted,20);
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
    int bombCountSetted = self.bombCountSetted;
    self.countOfMarkedFlags = 0;
    for (int i = 0; i < rowCount; ++i) {
        
        NSMutableArray *rowArray = [NSMutableArray array];
        
        for (int j = 0; j < rowCount; ++j) {
            
            HHBombItem *item = [[HHBombItem alloc] init];
            [rowArray addObject:item];
            
            if (bombCountSetted) {
                
                BOOL haveBomb = arc4random()%100 > (100 - self.bombCountSetted);
                
                if (haveBomb) {
                    item.haveBomb = YES;
                    bombCountSetted--;
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
        cell.flagView.hidden=!item.hasBeenMarkedByFlag;
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
        if (item.haveBomb) {
            return;
        } else {
            _X = (int)indexPath.section;
            _Y = (int)(indexPath).item;
            [self showAroundZoneX:_X Y:_Y];
        }
    }
    if (item.hasBeenMarkedByFlag) {
        item.hasBeenMarkedByFlag = NO;
        --self.countOfMarkedFlags;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
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
