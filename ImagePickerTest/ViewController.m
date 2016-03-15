//
//  ViewController.m
//  ImagePickerTest
//
//  Created by .Mr.SupEr on 15/12/11.
//  Copyright © 2015年 .Mr.SupEr. All rights reserved.
//
/*是否打印日志的配置*/
//#define DEBUG_MODE
#ifdef DEBUG
#define UCLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define UCLog(...)
#endif
#define SCREEN_WIDTH    ([[UIScreen mainScreen]bounds].size.width)

#import "ViewController.h"
#import "HHCollectionViewCell.h"
#import "HHBombItem.h"

#define rowCount 10

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *bombPositionArray;
@property (nonatomic, assign) int bombCountSetted;
@property (nonatomic, assign) int countOfMarkedFlags; //已经插旗的数量
@property (nonatomic, assign) int numOfFlagsAroundItem;  //Item附近的旗的数量
@property (nonatomic, assign) int totalTime;  //计时值


@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.bombCountSetted = 40;
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
//        NSLog(@"hasBeenMarkedByFlag -> %d",item.hasBeenMarkedByFlag);
        if (item.haveBeenDetect) {
            return;
        }
        if (item.hasBeenMarkedByFlag) {
            item.hasBeenMarkedByFlag = NO;
            --self.countOfMarkedFlags;
        } else {
            item.hasBeenMarkedByFlag = YES;
//            NSLog(@"hasBeenMarkedByFlag 11-> %d",item.hasBeenMarkedByFlag);
            ++self.countOfMarkedFlags;
        }
        [self.collectionView reloadData];
    }
}

-(int)checkAroundFlagNumsWithPositionX:(int) x Y:(int)y{
    int numOfFlags = 0;
    for (int i = MAX(x-1,0); i <= MIN(x+1,rowCount-1); i++) {
        for (int j = MAX(y-1,0); j <= MIN(y+1,rowCount-1); j++) {
            HHBombItem * item = self.bombPositionArray[i][j];
            if (item.hasBeenMarkedByFlag) {
                numOfFlags++;
            }
        }
    }
    return numOfFlags;
}

// 检测九宫格内已经爆炸的炸弹
-(int)checkAroundBoomedBombNumsWithPositionX:(int) x Y:(int)y{
    int numOfBombs = 0;
    for (int i = MAX(x-1,0); i <= MIN(x+1,rowCount-1); i++) {
        for (int j = MAX(y-1,0); j <= MIN(y+1,rowCount-1); j++) {
            HHBombItem * item = self.bombPositionArray[i][j];
            if (item.haveBomb&&item.haveBeenDetect) {
                numOfBombs++;
            }
        }
    }
    return numOfBombs;
}

- (void)showAroundZoneX:(int )x Y:(int)y  {
    if (x < 0 || y < 0 || x >= rowCount || y >= rowCount) {
        return;
    }
    HHBombItem * item = self.bombPositionArray[x][y];
    
    //查询附近的插旗数量和已经爆炸的地雷的总数，如果！=数字，return
    int numOfFlagsAroundItem        = [self checkAroundFlagNumsWithPositionX:x Y:y];
    int numOfBoomedBombsAroundItem  = [self checkAroundBoomedBombNumsWithPositionX:x Y:y];

    if (item.bombCount != (numOfFlagsAroundItem + numOfBoomedBombsAroundItem)){
        return;
    }
    //对相邻九宫格的处理
    for (int i = MAX(x-1,0); i <= MIN(x+1,rowCount-1); i++) {
        for (int j = MAX(y-1,0); j <= MIN(y+1,rowCount-1); j++) {
            HHBombItem * item = self.bombPositionArray[i][j];
            if (!item.haveBeenDetect && !item.hasBeenMarkedByFlag) {
                [self showZeroZoneX:x Y:y];
                item.haveBeenDetect = YES;  //翻开

            }
        }
    }

    
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
    if (item.bombCount) { //因为是空白没有数字的砖块，所以附近肯定没有雷，就不需要雷的判断。
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
    _totalTime=60;
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
            [self showAroundZoneX:(int)indexPath.section Y:(int)(indexPath).item];
        }
    }
    if (item.hasBeenMarkedByFlag) {
        item.hasBeenMarkedByFlag = NO;
        --self.countOfMarkedFlags;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        return;
    }
    
    if (item.haveBomb) {
        [_timer invalidate];
        _totalTime=60;
        _timer=nil;
        item.haveBeenDetect = YES;
        [collectionView reloadData];
        return;
    }
    [self showZeroZoneX:(int)indexPath.section Y:(int)indexPath.item];
    [_timer invalidate];
    _totalTime=60;
    _timer=nil;
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(screenWidth / 10.f, screenWidth / 10.f);
}
-(void)changeLable{
    int x=_totalTime-- > 0 ? _totalTime : 0 ;
    _timeLabel.text=[NSString stringWithFormat:@"倒计时%d秒",x];
}
- (IBAction)startCountTime:(id)sender {
    if (_timer) {
        [_timer invalidate];
        _timer=nil;
        _totalTime=60;
    }
    _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeLable) userInfo:nil repeats:YES];
    [_timer fire];
}
@end
