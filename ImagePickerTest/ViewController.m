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
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "AppDelegate+Audio.h"
#import  "AFNetworking.H"
#import "DBManager.h"
#import "HYBNetworking.h"

//  c 函数
void testAFNetWorking(void){
//afnetworking
    
    NSURL *URL = [NSURL URLWithString:@"http://bookapi.bignerdranch.com/courses.json"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

//static SystemSoundID soundplay_background = 0;

@import AVFoundation;
// TODO :增加当前计数的高亮显示
// TODO :bnr的自己新增的高级联系代码提交到 git ,另外这几天忙着公司工作内容，先停。

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    int rowCount;
}

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (weak,   nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak,   nonatomic) IBOutlet UITextField *textField;
@property (weak,   nonatomic) IBOutlet UITextField *TFSetNumOfPlayers;

@property (nonatomic, assign) int bombCountSetted;
@property (nonatomic, assign) int countOfMarkedFlags;
@property (nonatomic, assign) int numOfFlagsAroundItem;  //Item附近的旗和炸弹的数量
@property (nonatomic, assign) int totalTime;  //计时值
@property (nonatomic, assign) int numOfPlayers;
@property (nonatomic, assign) int stepCNT;
@property (nonatomic, assign) BOOL isFirstBoom; //首雷X2

@property (nonatomic, strong) NSMutableArray *bombPositionArray;
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
//    testAFNetWorking();
//
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"CFG_SOUND_ON"];
    self.bombCountSetted = 40;
    rowCount = 10;
    [self initData];
    [self createDatabase];
    [self addGesture];
    [self setViewsForCountNumberOfPlayers:_numOfPlayers];
    self.textField.userInteractionEnabled=NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //不息屏
    
    [self setBaseURL];
    [self testHYBNetWorking];
}

- (void)testHYBNetWorking
{
    [HYBNetworking getWithUrl:@"courses.json" refreshCache:YES success:^(id response) {
//        UCLog(@" %@",response);
        NSData *data = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        UCLog(@"===response is  %@ ",[response class]);
        UCLog(@"===== %@   class -%@",jsonString,[jsonString class]);
    } fail:^(NSError *error) {
        UCLog(@"%@",error);
    }];

}

- (void)setBaseURL
{
    [HYBNetworking updateBaseUrl:@"http://bookapi.bignerdranch.com"];
}
#pragma mark - Init
- (void)createDatabase{
    FMDatabase *db =  [DBManager CreateDBAtPath:@"/GameRecordDB.sqlite"];
    self.db = db;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_TFSetNumOfPlayers resignFirstResponder];
}

- (void)setViewsForCountNumberOfPlayers:(int) numbers{
    if (numbers) {
        self.labelArray=[[NSMutableArray alloc] init];
        for (int i=0; i<numbers; i++) {
            UILabel *numLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/numbers*i+10, SCREEN_HEIGHT-80, SCREEN_WIDTH/numbers -20,40 )];
            numLabel.text=@"0";
            numLabel.textColor=[UIColor blackColor];
            numLabel.textAlignment=NSTextAlignmentCenter;
            numLabel.layer.borderWidth=2.0;
            numLabel.opaque=0.4;
            [self.view addSubview:numLabel];
            [self.labelArray addObject:numLabel];
        }
    }
    
    NSLog(@"%lu",(unsigned long)[self.view.subviews count]);
    NSLog(@"%lu",(unsigned long)[self.labelArray count]);


}
- (void)letViewsCntPlus{
    
    int num=_stepCNT%_numOfPlayers;
    UILabel  *  lable  =[self.labelArray objectAtIndex:num];
    int x=        [lable.text intValue];
    if (_isFirstBoom) {
        x++;
        _isFirstBoom=NO;
    }
    x++;
    lable.text=[NSString stringWithFormat:@"%d",x];
    lable.textColor=[UIColor blackColor];

}
- (void)letViewsHilighted{
    int num;
    if (_numOfPlayers) {
     num  = _stepCNT%_numOfPlayers;
    } else{
        num = 0;

    }
    for ( int i =0 ; i<self.labelArray.count; i++) {
        
        if (i==num) {
            UILabel  *  lable  =[self.labelArray objectAtIndex:i];
            lable.textColor=[UIColor redColor];
        } else {
            UILabel  *  lable  =[self.labelArray objectAtIndex:i];
            lable.textColor=[UIColor blackColor];
        
        }
        
    }
    
}
- (void)initData
{
    self.isFirstBoom=YES;
    self.itemWidth = SCREEN_WIDTH / rowCount;
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

- (void)addGesture
{
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.numberOfTouchesRequired = 1;
    lpgr.minimumPressDuration = 1.0;
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
        if (item.haveBeenDetect) {
            return;
        }
        if (item.hasBeenMarkedByFlag) {
            item.hasBeenMarkedByFlag = NO;
            --self.countOfMarkedFlags;
        } else {
            item.hasBeenMarkedByFlag = YES;
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
}

#pragma mark - Action
- (IBAction)didTapRestartButton:(id)sender {
    [_TFSetNumOfPlayers resignFirstResponder];
    _stepCNT=0;
    _numOfPlayers=[self.TFSetNumOfPlayers.text intValue];
    if (self.labelArray.count!=_numOfPlayers) {
        for (UILabel *lable in self.labelArray) {
            [lable removeFromSuperview];
        }
        [self.labelArray removeAllObjects];
        //        [self sev]
        
        [self setViewsForCountNumberOfPlayers:_numOfPlayers];
        
    }else{
        for (UILabel *lable in self.labelArray) {
            lable.text=@"0";
        }
    }
    self.textField.text = [NSString stringWithFormat:@"%d",(int)self.slider.value];
    
    //    }
    self.bombCountSetted = self.textField.text.intValue;
    UCLog(@"%d",self.textField.text.intValue);
    self.countOfMarkedFlags = 0;
    self.bombCountSetted = MAX(self.bombCountSetted,20);
    [self.textField resignFirstResponder];
    [self initData];
    [self.timer invalidate];
    
    [self addToDB];
    
    
    self.timer=nil;
    _totalTime=60;
    _timeLabel.text=[NSString stringWithFormat:@"倒计时60秒"];
    [self startCountTime:nil];
 
    [self.collectionView reloadData];
}

- (void)addToDB{
    // 放入数据库 @"INSERT INTO PersonList (Name, Age, Sex, Phone, Address, Photo) VALUES (?,?,?,?,?,?)"

    [_db executeUpdate:@"INSERT INTO GameRecord (userCount, bombCount) VALUES (?,?)",[NSNumber numberWithInt:_numOfPlayers],[NSNumber numberWithInt:self.bombCountSetted]];
    
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM GameRecord"];
    
    while ([rs next]) {
        int   count = [rs intForColumn:@"userCount"];
        NSLog(@"%d",count);
    }


}
- (IBAction)passBtnDown:(id)sender {
    [self letViewsCntPlus];
    [self letViewsHilighted];
    self.stepCNT++;
}

- (IBAction)sliderChange:(UISlider *)sender {
    self.textField.text = [NSString stringWithFormat:@"%d",(int)sender.value];
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
    [self letViewsHilighted];
    
    HHBombItem *item = self.bombPositionArray[indexPath.section][indexPath.item];
    if (item.haveBeenDetect) {
        if (item.haveBomb) {
            return;
        } else {
            [self showAroundZoneX:(int)indexPath.section Y:(int)(indexPath).item];
            return;
        }
    }
    if (item.hasBeenMarkedByFlag) {
        item.hasBeenMarkedByFlag = NO;
        --self.countOfMarkedFlags;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        return;
    }
    if (item.haveBomb) {
        if (_numOfPlayers>0) {
            [self letViewsCntPlus];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] playAudio:0];
            _stepCNT++;
            
        }

        [_timer invalidate];
        _totalTime=60;
        _timer=nil;
        [self startCountTime:nil];

        item.haveBeenDetect = YES;
        [self letViewsHilighted];
        [collectionView reloadData];
        return;
    }
    if (_numOfPlayers>0) {
        _stepCNT++;

    }
    [self letViewsHilighted];

    [self showZeroZoneX:(int)indexPath.section Y:(int)indexPath.item];
    [_timer invalidate];
    _totalTime=60;
    _timer=nil;
    [self startCountTime:nil];
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(screenWidth / 10.f, screenWidth / 10.f);
}
-(void)changeLable{
    int x=_totalTime > 0 ? _totalTime : 0 ;
    _timeLabel.text=[NSString stringWithFormat:@"%d秒",x];
    _totalTime--;
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

-(void) playSound

{
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mineClicked" ofType:@"wav"]] error:nil];//
    player.volume =0.8;//0.0-1.0之间
    [player prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
    [player play];
}


@end
