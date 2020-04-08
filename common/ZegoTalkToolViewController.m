//
//  ZegoTalkToolViewController.m
//  VideoTalk
//
//  Created by summery on 24/10/2017.
//  Copyright © 2017 zego. All rights reserved.
//

#import "ZegoTalkToolViewController.h"
/* faceU */
#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FUManager.h"

@interface ZegoTalkToolViewController ()<FUAPIDemoBarDelegate>

//faceU
@property(nonatomic,strong)FUAPIDemoBar *demoBar;

@end

@implementation ZegoTalkToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.width / 2;
    self.logButton.layer.cornerRadius = self.logButton.frame.size.width / 2;
    self.muteButton.layer.cornerRadius = self.muteButton.frame.size.width / 2;
    self.cameraButton.layer.cornerRadius = self.cameraButton.frame.size.width / 2;
    self.micButton.layer.cornerRadius = self.micButton.frame.size.width / 2;
    self.switchCameraButton.layer.cornerRadius = self.switchCameraButton.frame.size.width / 2;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapView:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    /* faceU */
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event response

- (IBAction)onCameraButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onCameraButton:)]) {
        [self.delegate onCameraButton:sender];
    }
}

- (IBAction)onMicButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onMicButton:)]) {
        [self.delegate onMicButton:sender];
    }
}

- (IBAction)onMuteButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onMuteButton:)]) {
        [self.delegate onMuteButton:sender];
    }
}

- (IBAction)onLogButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onLogButton:)]) {
        [self.delegate onLogButton:sender];
    }
}

- (IBAction)onCloseButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onCloseButton:)]) {
        [self.delegate onCloseButton:sender];
    }
}

- (IBAction)onSwitchCameraButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onSwitchCameraButton:)]) {
        [self.delegate onSwitchCameraButton:sender];
        [FUManager shareManager].flipx = ![FUManager shareManager].flipx;
    }
}

- (void)onTapView:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(onTapViewPoint:)]) {
        [self.delegate onTapViewPoint:[gesture locationInView:nil]];
    }
}

#pragma  mark ----  faceU start  -----
// demobar 初始化
-(FUAPIDemoBar *)demoBar{
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 250,[UIScreen mainScreen].bounds.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
        _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;
        _demoBar.blurShape = [FUManager shareManager].blurShape ;
        _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
        _demoBar.whiteLevel = [FUManager shareManager].whiteLevel ;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        _demoBar.eyelightingLevel = [FUManager shareManager].eyelightingLevel ;
        _demoBar.beautyToothLevel = [FUManager shareManager].beautyToothLevel ;
        _demoBar.faceShape = [FUManager shareManager].faceShape ;
        
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        _demoBar.userInteractionEnabled = YES;
        _demoBar.delegate = self;
    }
    return _demoBar ;
}

/**      FUAPIDemoBarDelegate       **/

// 切换贴纸
- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}


// 更新美颜参数
- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}

-(void)dealloc{
    [[FUManager shareManager] destoryItems];
}


#pragma  mark ----  faceU End  -----


@end
