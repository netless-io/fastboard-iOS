//
//  ViewController.m
//  OCExample
//
//  Created by xuyunshi on 2021/12/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "ViewController.h"
#import "RoomInfo.h"
#import <Fastboard/Fastboard-Swift.h>
#import <Masonry/Masonry.h>
#import <Whiteboard/Whiteboard.h>
#import "Utility.h"
#import "CustomFastboardOverlay.h"
#import "OCExample-Swift.h"

@interface ViewController() <FastboardDelegate>
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIStackView* stackView;
@property (nonatomic, copy) Theme theme;
@property (nonatomic, assign) BOOL isHide;
@end

@implementation ViewController {
    Fastboard* _fastboard;
    Theme _theme;
}

// MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFastboardWithCustom:nil];
    [self setupTools];
    if (@available(iOS 13.0, *)) {
        _theme = ThemeAuto;
        [self applyTheme:ThemeAuto];
    } else {
        _theme = ThemeLight;
        [self applyTheme:ThemeLight];
    }
}

// MARK: - Action
- (void)onTheme {
    _theme = [self nextThemeFor:_theme];
    [self applyTheme:_theme];
}

- (void)onDirection {
    if (FastboardView.appearance.operationBarDirection == OperationBarDirectionLeft) {
        FastboardView.appearance.operationBarDirection = OperationBarDirectionRight;
        [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).inset(10);
            make.left.equalTo(self.view).inset(88);
            make.width.equalTo(@120);
        }];
    } else {
        FastboardView.appearance.operationBarDirection = OperationBarDirectionLeft;
        [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).inset(10);
            make.right.equalTo(self.view).inset(88);
            make.width.equalTo(@120);
        }];
    }
    [AppearanceManager.shared commitUpdate];
}

- (void)onBarSize {
    if (ControlBar.appearance.itemWidth == 48) {
        ControlBar.appearance.itemWidth = 44;
    } else {
        ControlBar.appearance.itemWidth = 48;
    }
    [AppearanceManager.shared commitUpdate];
}

- (void)onIcons {
    [FastboardThemeManager.shared updateIconsUsing:[NSBundle mainBundle]];
    [self reloadFastboardOverlay:nil];
    self.view.userInteractionEnabled = FALSE;
    dispatch_after(DISPATCH_TIME_NOW + 3, dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = TRUE;
    });
}

- (void)onHideAll {
    self.isHide = !self.isHide;
}

- (void)onHideItem {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableArray* values = [NSMutableArray array];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceClicker shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:AppliancePencil shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceSelector shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceText shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceEllipse shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceRectangle shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceEraser shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceStraight shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceArrow shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceHand shape:nil]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceLaserPointer shape:nil]];
    
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceShape shape:ApplianceShapeTypeTriangle]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceShape shape:ApplianceShapeTypeRhombus]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceShape shape:ApplianceShapeTypePentagram]];
    [values addObject:[DefaultOperationIdentifier appliceWithKey:ApplianceShape shape:ApplianceShapeTypeSpeechBalloon]];
    
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeDeleteSelection]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeStrokeWidth]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeClean]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeRedo]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeUndo]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeNewPage]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypePreviousPage]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypeNextPage]];
    [values addObject:[DefaultOperationIdentifier operationType:DefaultOperationTypePageIndicator]];
    
    for (DefaultOperationIdentifier* item in values) {
        [alert addAction:[UIAlertAction actionWithTitle:item.identifier
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self->_fastboard setPanelItemHideWithItem:item hide:TRUE];
        }]];
    }
    alert.popoverPresentationController.sourceView = self.stackView;
    [self presentViewController:alert animated:TRUE completion:nil];
}

- (void)onWritable {
    BOOL writable = _fastboard.room.isWritable;
    [_fastboard updateWritable:!writable completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"update writable fail");
        } else {
            NSLog(@"update writable successfully");
        }
    }];
}

- (void)onUserTheme {
    WhiteboardAssets* white = [[WhiteboardAssets alloc]
                               initWithWhiteboardBackgroundColor:UIColor.whiteColor
                               containerColor:UIColor.grayColor];
    CustomColor* customColor = [OCBridge getCustomColor];
    ControlBarAssets* control = [[ControlBarAssets alloc]
                                 initWithBackgroundColor:[[UIColor alloc] initWithHexString:customColor.controlBarBg]
                                 borderColor:UIColor.clearColor
                                 effectStyle:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    
    PanelItemAssets* panel = [[PanelItemAssets alloc] initWithNormalIconColor:UIColor.whiteColor
                                   selectedIconColor:[[UIColor alloc] initWithHexString:customColor.selColor]
                                 selectedIconBgColor:[[UIColor alloc] initWithHexString:customColor.iconSelectedBgColor]
                                      highlightColor:[[UIColor alloc] initWithHexString:customColor.highlightColor]
                                    highlightBgColor:UIColor.clearColor
                                        disableColor:[UIColor.grayColor colorWithAlphaComponent:0.7]
                                subOpsIndicatorColor:UIColor.whiteColor
                                  pageTextLabelColor:UIColor.whiteColor];
    ThemeAsset* asset = [[ThemeAsset alloc] initWithWhiteboardAssets:white
                                                    controlBarAssets:control
                                                     panelItemAssets:panel];
    [FastboardThemeManager.shared apply:asset];
}

- (void)onCustom {
    [self reloadFastboardOverlay:[[CustomFastboardOverlay alloc] init]];
    ControlBar.appearance.itemWidth = 66;
    [AppearanceManager.shared commitUpdate];
}

- (void)onPhoneItems {
    CompactFastboardOverlay.defaultCompactAppliance = @[
        AppliancePencil,
        ApplianceSelector,
        ApplianceEraser
    ];
    [self reloadFastboardOverlay:nil];
}

- (void)onPadItems {
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:[[SubOpsItem alloc] initWithSubOps:RegularFastboardOverlay.shapeItems]];
    [items addObject:[DefaultOperationItem selectableApplianceItem:AppliancePencil shape:nil]];
    [items addObject:[DefaultOperationItem clean]];
    FastPanel* panel = [[FastPanel alloc] initWithItems:items];
    RegularFastboardOverlay.customOptionPanel = ^FastPanel * _Nonnull{
        return panel;
    };
    [self reloadFastboardOverlay:nil];
}

- (void)onLayout {
    [_fastboard.view.overlay invalidAllLayout];
    NSObject<FastboardOverlay>* overlay = _fastboard.view.overlay;
    if ([overlay isKindOfClass:[RegularFastboardOverlay class]]) {
        RegularFastboardOverlay* regular = overlay;
        [regular.operationPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(regular.operationPanel.view.superview).inset(20);
            make.centerY.equalTo(regular.operationPanel.view.superview);
        }];
        
        [regular.deleteSelectionPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(regular.operationPanel.view);
            make.bottom.equalTo(regular.operationPanel.view.mas_top).offset(-8);
        }];
        
        [regular.undoRedoPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(regular.undoRedoPanel.view.superview).inset(20);
            make.bottom.equalTo(_fastboard.view.whiteboardView);
        }];
        
        [regular.scenePanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_fastboard.view.whiteboardView);
            make.centerX.equalTo(regular.scenePanel.view.superview);
        }];
    }
    
    if ([overlay isKindOfClass:[CompactFastboardOverlay class]]) {
        CompactFastboardOverlay* compact = overlay;
        [compact.operationPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fastboard.view.whiteboardView);
            make.centerY.equalTo(@0);
        }];
        
        [compact.colorAndStrokePanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fastboard.view.whiteboardView);
            make.bottom.equalTo(compact.operationPanel.view.mas_top).offset(-8);
        }];
        
        [compact.deleteSelectionPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(compact.colorAndStrokePanel.view);
        }];
        
        [compact.undoRedoPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(_fastboard.view.whiteboardView);
        }];
        
        [compact.scenePanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.bottom.equalTo(_fastboard.view.whiteboardView);
        }];
    }
}

- (void)onPencil {
    FastboardManager.followSystemPencilBehavior = !FastboardManager.followSystemPencilBehavior;
}

- (void)onInsertIMAGE {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.fileType == FileTypeImg) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)onInsertMP3 {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.fileType == FileTypeMusic) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)onInsertMP4 {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.fileType == FileTypeVideo) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)onInsertPPT {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.fileType == FileTypePpt && i.taskType == WhiteConvertTypeStatic) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)onInsertPDF {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.fileType == FileTypePdf) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)onInsertDOC {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.fileType == FileTypeWord) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)onInsertPPTX {
    for (StorageItem* i in [StorageItem localStorage]) {
        if (i.taskType == WhiteConvertTypeDynamic) {
            [self insertItem:i];
            return;
        }
    }
}

- (void)insertItem:(StorageItem *)item {
    if (item.fileType == FileTypeImg) {
        [[NSURLSession.sharedSession downloadTaskWithURL:item.fileURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) { return ; }
            NSData* data = [[NSData alloc] initWithContentsOfURL:location];
            UIImage* img = [UIImage imageWithData:data];
            [self->_fastboard insertImg:item.fileURL imageSize:img.size];
        }] resume];
    }
    
    if ((item.fileType == FileTypeVideo) || (item.fileType == FileTypeMusic)) {
        [self->_fastboard insertMedia:item.fileURL title:item.fileName completionHandler:nil];
        return;
    }
    
    [WhiteConverterV5 checkProgressWithTaskUUID:item.taskUUID
                                          token:item.taskToken
                                         region:item.region
                                       taskType:item.taskType result:^(WhiteConversionInfoV5 * _Nullable info, NSError * _Nullable error) {
        if (error) { return; }
        if (!info) { return; }
        
        NSArray* pages = info.progress.convertedFileList;
        if (!pages) { return; }
        switch (item.fileType) {
            case FileTypeImg:
                break;
            case FileTypePdf:
                [self->_fastboard insertStaticDocument:pages
                                                 title:item.fileName completionHandler:nil];
                break;
            case FileTypeVideo:
                break;
            case FileTypeMusic:
                break;
            case FileTypePpt:
                if (item.taskType == WhiteConvertTypeDynamic) {
                    [self->_fastboard insertPptx:pages
                                           title:item.fileName completionHandler:nil];
                } else {
                    [self->_fastboard insertStaticDocument:pages
                                                     title:item.fileName completionHandler:nil];
                }
                break;
            case FileTypeWord:
                [self->_fastboard insertStaticDocument:pages
                                                 title:item.fileName completionHandler:nil];
                break;
            case FileTypeUnknown:
                break;
        }
    }];
}

- (void)onReload {
    UIApplication.sharedApplication.keyWindow.rootViewController = [ViewController new];
}

// MARK: - Private
- (void)setupFastboardWithCustom: (id<FastboardOverlay>)custom {
    FastboardManager.globalFastboardRatio = 16.0 / 9.0;
    FastConfiguration* config = [[FastConfiguration alloc] initWithAppIdentifier:[RoomInfo getValueFrom:RoomInfoAPPID]
                                                                        roomUUID:[RoomInfo getValueFrom:RoomInfoRoomID]
                                                                       roomToken:[RoomInfo getValueFrom:RoomInfoRoomToken]
                                                                          region: FastRegionCN
                                                                         userUID:@"some-unique"];
    config.customOverlay = custom;
    _fastboard = [[Fastboard alloc] initWithConfiguration:config];
    FastboardView *fastView = _fastboard.view;
    _fastboard.delegate = self;
    [_fastboard joinRoom];
    [self.view addSubview:fastView];
    self.view.autoresizesSubviews = TRUE;
    fastView.autoresizingMask = TRUE;
    fastView.frame = self.view.bounds;
    fastView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setupTools {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stackView];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(self.view).inset(10);
        make.right.equalTo(self.view).inset(88);
        make.width.equalTo(@120);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(@120);
    }];
}

- (void)reloadFastboardOverlay: (id<FastboardOverlay>)custom {
    [_fastboard.view removeFromSuperview];
    [self setupFastboardWithCustom:custom];
    [self.view bringSubviewToFront:self.stackView];
}

- (Theme)nextThemeFor: (Theme)theme {
    if (@available(iOS 13.0, *)) {
        if ([theme isEqualToString:ThemeAuto]) {
            return ThemeLight;
        } else if ([theme isEqualToString:ThemeLight]) {
            return ThemeDark;
        } else {
            return ThemeAuto;
        }
    } else {
        if ([theme isEqualToString:ThemeAuto]) {
            return ThemeLight;
        } else if ([theme isEqualToString:ThemeLight]) {
            return ThemeDark;
        } else {
            return ThemeLight;
        }
    }
}

- (void)applyTheme: (Theme)theme {
    UIButton* themeBtn = [self.stackView arrangedSubviews][0];
    [themeBtn setTitle:theme forState:UIControlStateNormal];
    if ([theme isEqualToString:ThemeAuto]) {
        [FastboardThemeManager.shared apply:DefaultTheme.defaultAutoTheme];
    } else if ([theme isEqualToString:ThemeLight]) {
        [FastboardThemeManager.shared apply:DefaultTheme.defaultDarkTheme];
    } else if ([theme isEqualToString:ThemeDark]) {
        [FastboardThemeManager.shared apply:DefaultTheme.defaultAutoTheme];
    }
}

- (NSArray<UIButton *> *)setupButtons {
    NSArray* titles = @[@"Theme",
                        @"UserTheme",
                        @"Direction",
                        @"PhoneItems",
                        @"PadItems",
                        @"BarSize",
                        @"Icons",
                        @"HideAll",
                        @"HideItem",
                        @"Writable",
                        @"Custom",
                        @"Layout",
                        @"Reload",
                        @"Pencil",
                        @"InsertPPTX",
                        @"InsertDOC",
                        @"InsertPDF",
                        @"InsertPPT",
                        @"InsertMP4",
                        @"InsertMP3",
                        @"InsertIMAGE",];
    NSMutableArray* btns = [NSMutableArray new];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* title = obj;
        int index = (int)idx;
        UIButton* btn = [Utility buttonWith:title index:index];
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"on%@", title]);
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        [btns addObject:btn];
    }];
    return btns;
}

// MARK: - Setter
- (void)setIsHide:(BOOL)isHide {
    _isHide = isHide;
    [_fastboard setAllPanelWithHide:isHide];
}

// MARK: - Lazy
- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:[self setupButtons]];
    }
    return _stackView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}


// MARK: - Fastboard Delegate
- (void)fastboard:(Fastboard * _Nonnull)fastboard error:(FastError * _Nonnull)error {
    NSLog(@"error %@", error);
}

- (void)fastboardPhaseDidUpdate:(Fastboard * _Nonnull)fastboard phase:(enum FastRoomPhase)phase {
    NSLog(@"phase, %d", (int)phase);
}

- (void)fastboardUserKickedOut:(Fastboard * _Nonnull)fastboard reason:(NSString * _Nonnull)reason {
    NSLog(@"kicked out");
}

@end
