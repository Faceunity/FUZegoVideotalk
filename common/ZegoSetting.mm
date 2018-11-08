//
//  ZegoSetting.m
//
//
//  Created by summery on 13/09/2017.
//  Copyright © 2017 ZEGO. All rights reserved.
//

#import "ZegoSetting.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

#ifdef VIDEOLIVE

#import "ZegoVideoFilterDemo.h"
#import "ZegoRenderAudienceViewController.h"
#import <ZegoLiveRoom/ZegoLiveRoomApi-AudioIO.h>

#endif

NSString *kZegoDemoAppTypeKey          = @"apptype";
NSString *kZegoDemoAppIDKey            = @"appid";
NSString *kZegoDemoAppSignKey          = @"appsign";

NSString *kZegoDemoUserIDKey            = @"userid";
NSString *kZegoDemoUserNameKey          = @"username";

NSString *kZegoDemoVideoPresetKey       = @"preset";
NSString *kZegoDemoVideoWitdhKey        = @"resolution-width";
NSString *kZegoDemoVideoHeightKey       = @"resolution-height";
NSString *kZegoDemoVideoFrameRateKey    = @"framerate";
NSString *kZegoDemoVideoBitRateKey      = @"bitrate";
NSString *kZegoDemoBeautifyFeatureKey   = @"beautify_feature";
NSString *kZegoDemoFilterFeatureKey     = @"filter_feature";

NSString *kZegoDemoVideoCodecTypeKey    = @"video_codec_type";
NSString *kZegoDemoHardwareEncode       = @"hardware_encode";
NSString *kZegoDemoHardwareDecode       = @"hardware_decode";

@interface ZegoSetting ()

@property (nonatomic, strong) id<ZegoVideoFilterFactory> filterFactory;
@property (nonatomic, strong) id<ZegoVideoCaptureFactory> captureFactory;

@end

@implementation ZegoSetting

@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize beautifyFeature = _beautifyFeature;
@synthesize filterFeature = _filterFeature;
@synthesize videoCodecType = _videoCodecType;
@synthesize useHardwareEncode = _useHardwareEncode;
@synthesize useHardwareDecode = _useHardwareDecode;

static ZegoSetting *_settingInstance;

#pragma mark - Init

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_settingInstance == nil) {
            _settingInstance = [[self alloc] init];
        }
    });
    
    return _settingInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadAVConfig]; // 从本地文件加载配置
    }
    return self;
}

#pragma mark - Access method

- (void)setUseTestEnv:(BOOL)useTestEnv {
    if (_useTestEnv != useTestEnv) {
        [ZegoManager releaseApi];
    }
    
    _useTestEnv = useTestEnv;
    [ZegoLiveRoomApi setUseTestEnv:useTestEnv];
}

#pragma mark -- UserID / UserName

- (NSString *)userID {
    if (_userID.length == 0) {
        NSUserDefaults *ud = [self myUserDefaults];
        NSString *userID = [ud stringForKey:kZegoDemoUserIDKey];
        if (userID.length > 0) {
            _userID = userID;
        } else {
            srand((unsigned)time(0));
            _userID = [NSString stringWithFormat:@"%u", (unsigned)rand()];
            [ud setObject:_userID forKey:kZegoDemoUserIDKey];
        }
    }
    
    return _userID;
}


- (void)setUserID:(NSString *)userID {
    if ([_userID isEqualToString:userID]) {
        return;
    }
    
    if (userID.length > 0) {
        _userID = userID;
        NSUserDefaults *ud = [self myUserDefaults];
        [ud setObject:_userID forKey:kZegoDemoUserIDKey];
        [ZegoManager releaseApi];
    }
}

- (NSString *)userName {
    if (_userName.length == 0) {
        NSUserDefaults *ud = [self myUserDefaults];
        NSString *userName = [ud stringForKey:kZegoDemoUserNameKey];
        if (userName.length > 0) {
            _userName = userName;
        } else {
            srand((unsigned)time(0));
            
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            
            NSString *systemVerion = nil;
            UIDevice *device = [UIDevice currentDevice];
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString* code = [NSString stringWithCString:systemInfo.machine
                                                encoding:NSUTF8StringEncoding];
            code = [code stringByReplacingOccurrencesOfString:@"," withString:@"."];
            systemVerion = [NSString stringWithFormat:@"%@_%@_%@", device.model, code, device.systemVersion];
            _userName = [NSString stringWithFormat:@"%@-%u", systemVerion, (unsigned)rand()];
#endif
            
            [ud setObject:_userName forKey:kZegoDemoUserNameKey];
        }
    }
    
    return _userName;
}

- (void)setUserName:(NSString *)userName {
    if ([_userName isEqualToString:userName]) {
        return;
    }
    
    if (userName.length > 0) {
        _userName = userName;
        NSUserDefaults *ud = [self myUserDefaults];
        [ud setObject:_userName forKey:kZegoDemoUserNameKey];
        
        [ZegoManager releaseApi];
    }
}

#pragma mark -- AppType / AppID / AppSign

//- (ZegoAppType)appType {
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSUInteger type = [ud integerForKey:kZegoDemoAppTypeKey];
//    return (ZegoAppType)type;
//}

- (void)setAppType:(ZegoAppType)type {
    if (_appType != type) {
        _appType = type;
        
        // 本地持久化
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setInteger:type forKey:kZegoDemoAppTypeKey];
        
        [ZegoManager releaseApi];
        
        // 临时兼容 SDK 的 Bug，立即初始化 api 对象
        if ([ZegoManager api] == nil) {
            [ZegoManager api];
        }
    }
}

#warning 请开发者联系 ZEGO support 获取各自业务的 AppID 与 signKey
#warning Demo 默认使用 UDP 模式，请填充该模式下的 AppID 与 signKey
#warning AppID 填写样式示例：1234567890
#warning signKey 填写样式示例：{0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x00,0x01}
- (uint32_t)appID {
    switch (self.appType) {
        case ZegoAppTypeCustom:
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            uint32_t appID = [[ud objectForKey:kZegoDemoAppIDKey] unsignedIntValue];
            
            if (appID != 0) {
                return appID;
            } else {
                return 0;
            }
        }
            break;
        case ZegoAppTypeUDP:
            return 1721677906;  // UDP版
        case ZegoAppTypeI18N:
            return 100;  // 国际版
        case ZegoAppTypeRTC:
            return 1000;
    }
}

#warning 请开发者联系 ZEGO support 获取各自业务的 AppID 与 signKey
#warning Demo 默认使用 UDP 模式，请填充该模式下的 AppID 与 signKey
#warning AppID 填写样式示例：1234567890
#warning signKey 填写样式示例：{0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x00,0x01}
- (NSData *)appSign {
    //!! 规范用法：appSign 需要从 server 下发到 App，避免在 App 中存储，防止盗用
    
    switch (self.appType) {
        case ZegoAppTypeUDP:
        {
            Byte signkey[] = {0xad,0xb8,0x22,0x75,0xf4,0x1f,0xb4,0x1b,0xd8,0x59,0x7c,0xc7,0x66,0xdf,0x52,0x7c,0xfb,0x6e,0xd4,0xe4,0xd6,0xd7,0xf3,0x64,0xbd,0xf8,0x15,0x92,0x07,0x61,0x60,0xfa};
            return [NSData dataWithBytes:signkey length:32];
        }
        case ZegoAppTypeI18N:
        {
            Byte signkey[] = {0x00};
            return [NSData dataWithBytes:signkey length:32];
        }
        case ZegoAppTypeRTC:
        {
            Byte signkey[] = {0x00};
            return [NSData dataWithBytes:signkey length:32];
        }
        case ZegoAppTypeCustom:
        {
            // 自定义模式下从本地持久化文件中加载
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *appSign = [ud objectForKey:kZegoDemoAppSignKey];
            if (appSign) {
                return ConvertStringToSign(appSign);
            } else {
                return nil;
            }
            break;
        }
    }
}

- (NSString *)customAppSign {
    ZegoAppType type = [self appType];
    if (type == ZegoAppTypeCustom) {
        // 从本地持久化文件中加载
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *appSign = [ud objectForKey:kZegoDemoAppSignKey];
        return appSign;
    } else {
        return nil;
    }
}

- (NSArray *)appTypeList {
    return @[NSLocalizedString(@"国内版", nil),
             NSLocalizedString(@"国际版", nil),
             NSLocalizedString(@"WebRTC", nil),
             NSLocalizedString(@"自定义", nil)];
}

- (NSArray *)videoCodecTypeList {
    return @[NSLocalizedString(@"DEFAULT", nil),
             NSLocalizedString(@"MULTILAYER", nil)];
}

- (NSArray *)beautifyList {
    return @[NSLocalizedString(@"无美颜", nil),
             NSLocalizedString(@"磨皮", nil),
             NSLocalizedString(@"全屏美白", nil),
             NSLocalizedString(@"磨皮＋全屏美白", nil),
             NSLocalizedString(@"磨皮+皮肤美白", nil)
             ];
}

- (NSArray *)filterList {
    return @[NSLocalizedString(@"无滤镜", nil),
            NSLocalizedString(@"简洁", nil),
            NSLocalizedString(@"黑白", nil),
            NSLocalizedString(@"老化", nil),
            NSLocalizedString(@"哥特", nil),
            NSLocalizedString(@"锐色", nil),
            NSLocalizedString(@"淡雅", nil),
            NSLocalizedString(@"酒红", nil),
            NSLocalizedString(@"青柠", nil),
            NSLocalizedString(@"浪漫", nil),
            NSLocalizedString(@"光晕", nil),
            NSLocalizedString(@"蓝调", nil),
            NSLocalizedString(@"梦幻", nil),
            NSLocalizedString(@"夜色", nil)
            ];
}

- (NSArray *)presetVideoQualityList {
    return @[NSLocalizedString(@"超低质量", nil),
             NSLocalizedString(@"低质量", nil),
             NSLocalizedString(@"标准质量", nil),
             NSLocalizedString(@"高质量", nil),
             NSLocalizedString(@"超高质量", nil),
             NSLocalizedString(@"极高质量", nil),
             NSLocalizedString(@"自定义", nil)];
}

- (NSInteger)beautifyFeature {
    if (_beautifyFeature == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud objectForKey:kZegoDemoBeautifyFeatureKey]) {
            _beautifyFeature = [ud integerForKey:kZegoDemoBeautifyFeatureKey];
        } else {
            _beautifyFeature = ZEGO_BEAUTIFY_POLISH | ZEGO_BEAUTIFY_WHITEN;
        }
    }
    return _beautifyFeature;
}

- (void)setBeautifyFeature:(NSInteger)beautifyFeature {
    if (_beautifyFeature != beautifyFeature) {
        _beautifyFeature = beautifyFeature;
        [[self myUserDefaults] setInteger:_beautifyFeature forKey:kZegoDemoBeautifyFeatureKey];
    }
}

- (NSInteger)filterFeature {
    if (_filterFeature == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud objectForKey:kZegoDemoFilterFeatureKey]) {
            _filterFeature = [ud integerForKey:kZegoDemoFilterFeatureKey];
        } else {
            _filterFeature = ZEGO_FILTER_NONE;
        }
    }
    return _filterFeature;
}

- (void)setFilterFeature:(NSInteger)filterFeature {
    if (_filterFeature != filterFeature) {
        _filterFeature = filterFeature;
        [[self myUserDefaults] setInteger:_filterFeature forKey:kZegoDemoFilterFeatureKey];
    }
}

- (BOOL)useHeadSet {
#if TARGET_IPHONE_SUMUTOR
    _useHeadSet = NO;
#else
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription *desc in route.outputs) {
        if ([desc.portType isEqualToString:AVAudioSessionPortHeadphones] ||
            [desc.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
            [desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            _useHeadSet = YES;
            return _useHeadSet;
        }
    }
    _useHeadSet = NO;
    return _useHeadSet;

#endif
}

- (void)checkHeadSet {
#if TARGET_IPHONE_SIMULATOR
    self.useHeadSet = NO;
#else
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription *desc in route.outputs)
    {
        if ([desc.portType isEqualToString:AVAudioSessionPortHeadphones] ||
            [desc.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
            [desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
        {
            self.useHeadSet = YES;
            return;
        }
    }
    self.useHeadSet = NO;
#endif
}

#ifdef VIDEOLIVE

- (void)setRecordTime:(BOOL)recordTime {
    if (_recordTime != recordTime) {
        _recordTime = recordTime;
        [self setUseExternalFilter:_recordTime];
    }
}

- (void)setUseExternalFilter:(BOOL)useExternalFilter {
    if (_useExternalFilter != useExternalFilter) {
        [ZegoManager releaseApi];
        
        _useExternalFilter = useExternalFilter;
        if (useExternalFilter) {
            if (_filterFactory == nil) {
                _filterFactory = [[ZegoVideoFilterFactoryDemo alloc] init];
            }
            [ZegoLiveRoomApi setVideoFilterFactory:_filterFactory];
        } else {
            [ZegoLiveRoomApi setVideoFilterFactory:nil];
        }
    }
}

- (void)setUseExternalRender:(BOOL)useExternalRender {
    if (_useExternalRender != useExternalRender) {
        [ZegoManager releaseApi];
        
        _useExternalFilter = useExternalRender;
        [ZegoLiveRoomApi enableExternalRender:useExternalRender];
    }
}


- (void)setUseExternalCapture:(BOOL)useExternalCapture {
    if (_useExternalCapture != useExternalCapture) {
        [ZegoManager releaseApi];
        
        _useExternalCapture = useExternalCapture;
        
        if (useExternalCapture) {
#if TARGET_OS_SIMULATOR
            if (_captureFactory == nil) {
                _captureFactory = [[ZegoVideoCaptureFactory alloc] init];
            }
#else
            if (self.captureFactory == nil) {
                _captureFactory = [[VideoCaptureFactoryDemo alloc] init];
            }
#endif
            [ZegoLiveRoomApi setVideoCaptureFactory:_captureFactory];
        } else {
            [ZegoLiveRoomApi setVideoCaptureFactory:nil];
        }
    }
}

- (void)setEnableAudioPrep:(BOOL)enableAudioPrep {
    if (_enableAudioPrep != enableAudioPrep) {
        _enableAudioPrep = enableAudioPrep;
        
        [ZegoManager releaseApi];
        
        AVE::ExtPrepSet set;
        set.bEncode = false;
        set.nChannel = 0;
        set.nSamples = 0;
        set.nSampleRate = 0;
        
        if (enableAudioPrep) {
            [ZegoLiveRoomApi setAudioPrep2:set dataCallback:prep2_func];
        } else {
            [ZegoLiveRoomApi setAudioPrep2:set dataCallback:nil];
        }
    }
}

void prep2_func(const AVE::AudioFrame& inFrame, AVE::AudioFrame& outFrame) {
    outFrame.frameType = inFrame.frameType;
    outFrame.samples = inFrame.samples;
    outFrame.bytesPerSample = inFrame.bytesPerSample;
    outFrame.channels = inFrame.channels;
    outFrame.sampleRate = inFrame.sampleRate;
    outFrame.timeStamp = inFrame.timeStamp;
    outFrame.configLen = inFrame.configLen;
    outFrame.bufLen = inFrame.bufLen;
    memcpy(outFrame.buffer, inFrame.buffer, inFrame.bufLen);
}

- (void)setEnableRateControl:(BOOL)enableRateControl {
    if (_enableRateControl != enableRateControl) {
        
        if (enableRateControl) {
            if (_useHardwareEncode) {
                _useHardwareEncode = NO;    // 开启码率自适应，要关闭硬件编码
                [ZegoLiveRoomApi requireHardwareEncoder:false];
            }
        }
        
        _enableRateControl = enableRateControl;
        
        [[ZegoManager api] enableRateControl:_enableRateControl];
    }
}

#endif

- (void)setUseHardwareEncode:(BOOL)useHardwareEncode {
    if (_useHardwareEncode != useHardwareEncode) {
        if (useHardwareEncode) {
            if (_enableRateControl) {
                _enableRateControl = NO;    // 开启硬件编码，要关闭码率自适应
                [[ZegoManager api] enableRateControl:false];
            }
        }
        
        _useHardwareEncode = useHardwareEncode;
        [[self myUserDefaults] setInteger:_useHardwareEncode forKey:kZegoDemoHardwareEncode];
        
        [ZegoLiveRoomApi requireHardwareEncoder:_useHardwareEncode];
    }
}

- (BOOL)useHardwareEncode {
    NSUserDefaults *ud = [self myUserDefaults];
    if ([ud integerForKey:kZegoDemoHardwareEncode]) {
        _useHardwareEncode = [ud integerForKey:kZegoDemoHardwareEncode];
    } else {
        _useHardwareEncode = false;
    }
    return _useHardwareEncode;
}

- (void)setUseHardwareDecode:(BOOL)useHardwareDecode {
    if (_useHardwareDecode != useHardwareDecode) {
        _useHardwareDecode = useHardwareDecode;
        
        [[self myUserDefaults] setInteger:_useHardwareDecode forKey:kZegoDemoHardwareDecode];
        [ZegoLiveRoomApi requireHardwareDecoder:_useHardwareDecode];
    }
}

- (BOOL)useHardwareDecode {
    NSUserDefaults *ud = [self myUserDefaults];
    if ([ud integerForKey:kZegoDemoHardwareDecode]) {
        _useHardwareDecode = [ud integerForKey:kZegoDemoHardwareDecode];
    } else {
        _useHardwareDecode = false;
    }
    return _useHardwareDecode;
}

#pragma mark -- streamLayer

- (NSInteger)videoCodecType {
    NSUserDefaults *ud = [self myUserDefaults];
    if ([ud integerForKey:kZegoDemoVideoCodecTypeKey]) {
        _videoCodecType = [ud integerForKey:kZegoDemoVideoCodecTypeKey];
    } else {
        _videoCodecType = 0;
    }
    return _videoCodecType;
}

- (void)setVideoCodecType:(NSInteger)videoCodecType {
    if (_videoCodecType != videoCodecType) {
        _videoCodecType = videoCodecType;
        [[self myUserDefaults] setInteger:_videoCodecType forKey:kZegoDemoVideoCodecTypeKey];
    }
}

#pragma mark - Public

- (void)setCustomAppID:(uint32_t)appid sign:(NSString *)sign {
    NSData *d = ConvertStringToSign(sign);
    
    if (d.length == 32 && appid != 0)
    {
        // 持久化
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@(appid) forKey:kZegoDemoAppIDKey];
        [ud setObject:sign forKey:kZegoDemoAppSignKey];
        
        [ZegoManager releaseApi];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RoomInstanceClear" object:nil userInfo:nil];
    }
    
}

+ (NSString *)getMyRoomID:(ZegoRoomType)roomType
{
    switch (roomType) {
        case SinglePublisherRoom: // * 单主播
            return [NSString stringWithFormat:@"#d-%@", [ZegoSetting sharedInstance].userID];
        case MultiPublisherRoom: // * 连麦
            return [NSString stringWithFormat:@"#m-%@", [ZegoSetting sharedInstance].userID];
        case MixStreamRoom: // * 混流
            return [NSString stringWithFormat:@"#s-%@", [ZegoSetting sharedInstance].userID];
            
        default:
            return nil;
    }
}

+ (NSString *)getPublishStreamID
{
    NSString *userID = [[ZegoSetting sharedInstance] userID];
    unsigned long currentTime = (unsigned long)[[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"s-%@-%lu", userID, currentTime];
}

#ifdef VIDEOLIVE

#if TARGET_OS_SIMULATOR
- (ZegoVideoCaptureFactory *)getVideoCaptureFactory
{
    return self.captureFactory;
}
#else
- (VideoCaptureFactoryDemo *)getVideoCaptureFactory
{
    return self.captureFactory;
}
#endif

#endif

- (BOOL)selectPresetQuality:(NSInteger)presetIndex {
    if (presetIndex >= self.presetVideoQualityList.count) {
        return NO;
    }
    
    _presetAVConfigIndex = presetIndex;
    if (_presetAVConfigIndex < self.presetVideoQualityList.count - 1) {
        _avConfig = [ZegoAVConfig presetConfigOf:(ZegoAVConfigPreset)_presetAVConfigIndex];
    }
    
    [self saveAVConfig];
    return YES;
}

- (UIImage *)getBackgroundImage:(CGSize)viewSize withText:(NSString *)text
{
    NSTimeInterval beginTime = [[NSDate date] timeIntervalSince1970];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background"];
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, [UIScreen mainScreen].scale);
    
    CGFloat height = viewSize.height;
    if (viewSize.height < viewSize.width)
        height = viewSize.width;
    
    [backgroundImage drawInRect:CGRectMake((viewSize.width - height)/2, (viewSize.height - height)/2, height, height)];
    
    if (text.length != 0)
    {
        UIColor *textColor = [UIColor whiteColor];
        UIFont *textFont = [UIFont systemFontOfSize:30];
        NSDictionary *attributes = @{NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor};
        CGRect textRect = [text boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        [text drawAtPoint:CGPointMake((viewSize.width - textRect.size.width)/2, (viewSize.height - textRect.size.height)/2) withAttributes:attributes];
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"cost time is %f", [[NSDate date] timeIntervalSince1970] - beginTime);
    
    return finalImage;
}

#ifdef VIDEOLIVE

- (UIViewController *)getViewControllerFromRoomInfo:(ZegoRoomInfo *)roomInfo
{
    NSString *roomID = roomInfo.roomID;
    NSUInteger liveType = 2; // * 默认play 连麦模式
    if ([roomID hasPrefix:@"#d-"])
    {
        liveType = 1;   // 单主播模式
    }
    else if ([roomID hasPrefix:@"#m-"])
    {
        liveType = 2;   // 多主播模式
    }
    else if ([roomID hasPrefix:@"#s-"])
    {
        liveType = 3;   // 混流模式
    }
    
    if (liveType == 1)
    {

        if (self.useExternalRender)
        {
            ZegoRenderAudienceViewController *audienceViewController = [[ZegoRenderAudienceViewController alloc] init];
            audienceViewController.roomID = roomID;
            return audienceViewController;
            return nil;
        } else {
            ZegoSingleAudienceViewController *audienceViewController = [[ZegoSingleAudienceViewController alloc] initWithNibName:@"ZegoSingleAudienceViewController" bundle:nil];
            audienceViewController.roomID = roomID;
            audienceViewController.streamIdList = [roomInfo.streamInfo copy];
            return audienceViewController;
        }
    }
    else if (liveType == 2)
    {
        ZegoMultiAudienceViewController *audienceViewController = [[ZegoMultiAudienceViewController alloc] initWithNibName:@"ZegoMultiAudienceViewController" bundle:nil];
        audienceViewController.roomID = roomID;
        audienceViewController.streamIdList = [roomInfo.streamInfo copy];
        return audienceViewController;
    }
    else if (liveType == 3)
    {
        ZegoMixStreamAudienceViewController *audienceViewController = [[ZegoMixStreamAudienceViewController alloc] initWithNibName:@"ZegoMixStreamAudienceViewController" bundle:nil];
        audienceViewController.roomID = roomID;
        audienceViewController.streamIdList = [roomInfo.streamInfo copy];
        return audienceViewController;
    }
    else
    {
        return nil;
    }
}

#endif

#pragma mark - Private

#ifdef VIDEOLIVE
- (NSUserDefaults *)myUserDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:@"group.liveDemo5"];
}
#endif

#ifdef VIDEOTALK
- (NSUserDefaults *)myUserDefaults {
    return [NSUserDefaults standardUserDefaults];
}
#endif

// 加载视频配置
- (void)loadAVConfig {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id preset = [ud objectForKey:kZegoDemoVideoPresetKey];
    if (preset) {
        _presetAVConfigIndex = [preset integerValue];
        if (self.presetAVConfigIndex < self.presetVideoQualityList.count - 1) {
            self.avConfig = [ZegoAVConfig presetConfigOf:(ZegoAVConfigPreset)self.presetAVConfigIndex];
            return;
        } else {
            // 如果本地配置文件中保存的值有误，则默认为 high 配置
            _presetAVConfigIndex = ZegoAVConfigPreset_High;
            self.avConfig = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_High];
            return;
        }
    }
    
    // 如果本地配置文件中没有，则创建一个新的配置，默认为 Generic 配置
    self.avConfig = [ZegoAVConfig presetConfigOf:ZegoAVConfigPreset_Generic];
    NSInteger width = [ud integerForKey:kZegoDemoVideoWitdhKey];
    NSInteger height = [ud integerForKey:kZegoDemoVideoHeightKey];
    if (width && height) {
        CGSize r = CGSizeMake(width, height);
        self.avConfig.videoEncodeResolution = r;
        self.avConfig.videoCaptureResolution = r;
    }
    
    id frameRate = [ud objectForKey:kZegoDemoVideoFrameRateKey];
    if (frameRate) {
        self.avConfig.fps = (int)[frameRate integerValue];
    }
    
    id bitRate = [ud objectForKey:kZegoDemoVideoBitRateKey];
    if (bitRate) {
        self.avConfig.bitrate = (int)[bitRate integerValue];
    }
}

// 保存视频配置
- (void)saveAVConfig {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(self.presetAVConfigIndex) forKey:kZegoDemoVideoPresetKey];
    
    if (self.presetAVConfigIndex >= self.presetVideoQualityList.count - 1) {
        [ud setInteger:self.avConfig.videoEncodeResolution.width forKey:kZegoDemoVideoWitdhKey];
        [ud setInteger:self.avConfig.videoEncodeResolution.height forKey:kZegoDemoVideoHeightKey];
        [ud setObject:@([self.avConfig fps]) forKey:kZegoDemoVideoFrameRateKey];
        [ud setObject:@([self.avConfig bitrate]) forKey:kZegoDemoVideoBitRateKey];
    } else {
        [ud removeObjectForKey:kZegoDemoVideoWitdhKey];
        [ud removeObjectForKey:kZegoDemoVideoHeightKey];
        [ud removeObjectForKey:kZegoDemoVideoFrameRateKey];
        [ud removeObjectForKey:kZegoDemoVideoBitRateKey];
    }
}

Byte toByte(NSString* c)
{
    NSString *str = @"0123456789abcdef";
    Byte b = [str rangeOfString:c].location;
    return b;
}

NSData* ConvertStringToSign(NSString* strSign)
{
    if(strSign == nil || strSign.length == 0)
        return nil;
    strSign = [strSign lowercaseString];
    strSign = [strSign stringByReplacingOccurrencesOfString:@" " withString:@""];
    strSign = [strSign stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSArray* szStr = [strSign componentsSeparatedByString:@","];
    int nLen = (int)[szStr count];
    Byte szSign[32];
    for(int i = 0; i < nLen; i++)
    {
        NSString *strTmp = [szStr objectAtIndex:i];
        if(strTmp.length == 1)
            szSign[i] = toByte(strTmp);
        else
        {
            szSign[i] = toByte([strTmp substringWithRange:NSMakeRange(0, 1)]) << 4 | toByte([strTmp substringWithRange:NSMakeRange(1, 1)]);
        }
        NSLog(@"%x,", szSign[i]);
    }
    
    NSData *sign = [NSData dataWithBytes:szSign length:32];
    return sign;
}

#ifdef VIDEOLIVE

- (void)setupVideoCaptureDevice
{
    
#if TARGET_OS_SIMULATOR
    self.useExternalCapture = YES;
    
    if (self.captureFactory == nullptr) {
        self.captureFactory = [[ZegoVideoCaptureFactory alloc] init];
    }
    
    [ZegoLiveRoomApi setVideoCaptureFactory:self.captureFactory];
#else
    
//    self.useExternalCapture = YES;
// 
//    if (self.captureFactory == nullptr) {
//        self.captureFactory = [[VideoCaptureFactoryDemo alloc] init];
//    }
//    
//    [ZegoLiveRoomApi setVideoCaptureFactory:self.captureFactory];

#endif
}

- (void)setupVideoFilter
{
    if (![ZegoSetting sharedInstance].useExternalFilter) {
        return;
    }
    
    if (self.filterFactory == nullptr) {
        self.filterFactory = [[ZegoVideoFilterFactoryDemo alloc] init];
    }

    [ZegoLiveRoomApi setVideoFilterFactory:self.filterFactory];
}

#endif

/**
 @"iPad6,7"   : @"iPad Pro (12.9\")",
 @"iPad6,8"   : @"iPad Pro (12.9\")",
 @"iPad7,1"   : @"iPad Pro (12.9\")", 2nd generation
 @"iPad7,2"   : @"iPad Pro (12.9\")", 2nd generation
 @"iPad7,3"   : @"iPad Pro (10.5\")",
 @"iPad7,4"   : @"iPad Pro (10.5\")",
 @"iPad6,3"   : @"iPad Pro (9.7\")",
 @"iPad6,4"   : @"iPad Pro (9.7\")"
 **/
+ (NSString *)iOSDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceModel isEqualToString:@"iPad7,1"] || [deviceModel isEqualToString:@"iPad7,2"]) {
        return IPAD_PRO_129_2ND;
    }
    
    return deviceModel;
}


@end
