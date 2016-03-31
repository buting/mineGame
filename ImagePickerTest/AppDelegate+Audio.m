//
//  AppDelegate+Audio.m
//  Undercover
//
//  Created by Xtra Ch/Users/xtra/Desktop/undercover2/Undercover/View/UCPlayViewController.men on 13-10-25.
//  Copyright (c) 2013年 Xtra. All rights reserved.
//

#import "AppDelegate+Audio.h"
#import <AudioToolbox/AudioToolbox.h>
typedef NS_ENUM(int, SoundIndex) {
    SoundIndex_Vibrate = 1101,
    SoundIndex_Background,
    SoundIndex_Fail,
    SoundIndex_PingJu,
    SoundIndex_PK,
    SoundIndex_Victory,
    SoundIndex_Dead,
    SoundIndex_Recv,
    SoundIndex_GuessFaliure,
    SoundIndex_GuessSuccess,
    SoundIndex_ShakeDice,
    SoundIndex_LiarResult,
    SoundIndex_LiarGameover,
    SoundIndex_Dice_F_Open,
    SoundIndex_Dice_M_Open,
    SoundIndex_DixitDispatch,
    SoundIndex_DixitDiscard,
    SoundIndex_DixitShuff,
    SoundIndex_DixitVote,
    SoundIndex_MineBomb,
    SoundIndex_MineMark,
    SoundIndex_MineClick,
    SoundIndex_MineStart,
};

#define CFG_SOUND_ON                        @"CFG_SOUND_ON"

//todo 游戏过程中带着背景音乐
static SystemSoundID soundplay_background = 0;

@implementation AppDelegate (Audio)

- (void)playAudio:(int)index
{
    NSString *isSoundOn = [[NSUserDefaults standardUserDefaults]stringForKey:@"CFG_SOUND_ON"];
    if(![isSoundOn isEqualToString:@"YES"])
        return;

    if (index == SoundIndex_Background) {
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return;
    }
    if((index == SoundIndex_Background) && (soundplay_background > 0)) return;//avoid dup play

    NSString *path = [self pathByDefine:index];
    //soundplay_background = index;
    if (path) {
        //注册声音到系统
        SystemSoundID _soundplay_background = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&_soundplay_background);
        if(index == SoundIndex_Background){
            soundplay_background = _soundplay_background;
            AudioServicesAddSystemSoundCompletion(soundplay_background, NULL, NULL, playBack, (__bridge void *)self);
        }
        AudioServicesPlaySystemSound(_soundplay_background);
        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    }
//    AudioServicesPlaySystemSound(soundplay_background);
}

void playBack ( SystemSoundID  ssID, void *myself ) {
    if (YES) { // Your logic here...
        //在这儿调play background
        AppDelegate *theClass = (__bridge AppDelegate *)myself;
        //CFRelease(myself);
        soundplay_background=0;//indicate not playing
        [theClass playAudio:SoundIndex_Background];
    } else {
        //Unregister, so we don't get called again...
        //        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    }
}

- (void)stopAudio:(int)index
{
    AudioServicesDisposeSystemSoundID(soundplay_background);
    soundplay_background = 0;//indicate not playing
}

//-(void)playDiceWithCount:(NSString*)count andDice:(NSString*)dice isMale:(BOOL)male{
//    NSString *isSoundOn = [[NSUserDefaults standardUserDefaults]stringForKey:CFG_SOUND_ON];
//    if(![isSoundOn isEqualToString:@"YES"])
//        return;
//
//    NSInteger countInt = [count intValue];
//    if (countInt<2 || countInt>25) {
//        return;
//    }
//    NSString *prefix = [NSString stringWithFormat:@"dice_"];
//    if(male){
//        prefix = [prefix stringByAppendingString:@"m_"];
//    }else{
//        prefix = [prefix stringByAppendingString:@"f_"];
//    }
//    self.nextSoundPath = nil;
//    NSString *countPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@",prefix,count] ofType:@"mp3"];
//    if(!countPath){
//        return;
//    }
//    SystemSoundID countSound = 0;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:countPath],&countSound);
//    
//    NSString *dicePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@ge%@",prefix,dice] ofType:@"mp3"];
//    if (!dicePath) {
//        return;
//    }
//    self.nextSoundPath = dicePath;
//    
//    AudioServicesAddSystemSoundCompletion(countSound, NULL, NULL, playNext, (__bridge void *)self);
//    AudioServicesPlaySystemSound(countSound);
//}

//void playNext ( SystemSoundID  ssID,void *myself ) {
//    if (YES) {
//        AppDelegate *theClass = (__bridge AppDelegate *)myself;
//        if(theClass.nextSoundPath){
//            SystemSoundID diceSound = 0;
//            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:theClass.nextSoundPath],&diceSound);
//            AudioServicesPlaySystemSound(diceSound);
//            //todo empty next sound
//            theClass.nextSoundPath = nil;
//        }
//    } else {
//        //Unregister, so we don't get called again...
//        //        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
//    }
//}

- (NSString *)pathByDefine:(int)index
{
    
    return [[NSBundle mainBundle] pathForResource:@"mineClicked" ofType:@"wav"];
//
//    switch (index) {
//        case SoundIndex_Background:
//            return [[NSBundle mainBundle] pathForResource:@"bk" ofType:@"wav"];
//            break;
//        case SoundIndex_Fail:
//            return [[NSBundle mainBundle] pathForResource:@"fail" ofType:@"mp3"];
//            break;
//        case SoundIndex_PingJu:
//            return [[NSBundle mainBundle] pathForResource:@"pingju" ofType:@"mp3"];
//            break;
//        case SoundIndex_PK:
//            return [[NSBundle mainBundle] pathForResource:@"pk" ofType:@"mp3"];
//            break;
//        case SoundIndex_Victory:
//            return [[NSBundle mainBundle] pathForResource:@"victory_low" ofType:@"mp3"];
//            break;
//        case SoundIndex_Dead:
//            return [[NSBundle mainBundle] pathForResource:@"yuansi" ofType:@"mp3"];
//            break;
//        case SoundIndex_Recv:
//            return [[NSBundle mainBundle] pathForResource:@"messageReceived" ofType:@"mp3"];
//            break;
//        case SoundIndex_GuessFaliure:
//            return [[NSBundle mainBundle] pathForResource:@"paintGuessFaliure" ofType:@"mp3"];
//            break;
//        case SoundIndex_GuessSuccess:
//            return [[NSBundle mainBundle] pathForResource:@"paintGuessSuccess" ofType:@"mp3"];
//            break;
//        case SoundIndex_ShakeDice:
//            return [[NSBundle mainBundle] pathForResource:@"shakeDices" ofType:@"mp3"];
//            break;
//        case SoundIndex_LiarResult:
//            return [[NSBundle mainBundle] pathForResource:@"liar_result" ofType:@"mp3"];
//            break;
//        case SoundIndex_LiarGameover:
//            return [[NSBundle mainBundle] pathForResource:@"liar_gameover" ofType:@"mp3"];
//            break;
//        case SoundIndex_Dice_F_Open:
//            return [[NSBundle mainBundle] pathForResource:@"dice_f_open" ofType:@"mp3"];
//            break;
//        case SoundIndex_Dice_M_Open:
//            return [[NSBundle mainBundle] pathForResource:@"dice_m_open" ofType:@"mp3"];
//            break;
//        case SoundIndex_DixitDispatch:
//            return [[NSBundle mainBundle] pathForResource:@"dixit_card_dispatch" ofType:@"mp3"];
//            break;
//        case SoundIndex_DixitDiscard:
//            return [[NSBundle mainBundle] pathForResource:@"dixit_discard" ofType:@"mp3"];
//            break;
//        case SoundIndex_DixitShuff:
//            return [[NSBundle mainBundle] pathForResource:@"dixit_shuff_card" ofType:@"mp3"];
//            break;
//        case SoundIndex_DixitVote:
//            return [[NSBundle mainBundle] pathForResource:@"dixit_vote" ofType:@"wav"];
//            break;
//        case SoundIndex_MineBomb:
//            return [[NSBundle mainBundle] pathForResource:@"bomb" ofType:@"wav"];
//            break;
//        case SoundIndex_MineMark:
//            return [[NSBundle mainBundle] pathForResource:@"marking" ofType:@"mp3"];
//            break;
//        case SoundIndex_MineClick:
//            return [[NSBundle mainBundle] pathForResource:@"check" ofType:@"mp3"];
//            break;
//        case SoundIndex_MineStart:
//            return [[NSBundle mainBundle] pathForResource:@"mode" ofType:@"mp3"];
//            break;
//        default:
//            return nil;
//            break;
//    }
}
@end

//- (void)addVolumeView
//{
//    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    [self addSubview:self.volumeView];
//}
//
//- (void)setSystemVolume:(float)volume
//{
//    UISlider* volumeViewSlider = nil;
//    for (UIView *view in [self.volumeView subviews]){
//        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
//            volumeViewSlider = (UISlider*)view;
//            break;
//        }
//    }
//    
//    // change system volume, the value is between 0.0f and 1.0f
//    [volumeViewSlider setValue:volume animated:NO];
//    
//    NSLog(@"%f",volume);
//}
//
//- (float)getSystemVolume
//{
//    UISlider* volumeViewSlider = nil;
//    for (UIView *view in [self.volumeView subviews]){
//        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
//            volumeViewSlider = (UISlider*)view;
//            break;
//        }
//    }
//    return volumeViewSlider.value;
//}