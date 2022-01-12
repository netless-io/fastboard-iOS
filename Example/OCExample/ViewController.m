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

@interface ViewController() <FastboardDelegate>
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
        ControlBar.appearance.itemWidth = 40;
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
    [_fastboard.room setWritable:!writable completionHandler:^(BOOL isWritable, NSError * _Nullable error) {
        if (error) {
            NSLog(@"update writable fail");
        } else {
            NSLog(@"update writable successfully");
        }
    }];
}

- (void)onCustom {
    [self reloadFastboardOverlay:[CustomFastboardOverlay new]];
    ControlBar.appearance.itemWidth = 66;
    [AppearanceManager.shared commitUpdate];
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
                                                                         userUID:@"some-unique"];
    config.customOverlay = custom;
    _fastboard = [FastboardManager createFastboardWithConfiguration:config];
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
    [self.view addSubview:self.stackView];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).inset(10);
        make.right.equalTo(self.view).inset(88);
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
                        @"Direction",
                        @"BarSize",
                        @"Icons",
                        @"HideAll",
                        @"HideItem",
                        @"Writable",
                        @"Custom",
                        @"Reload"];
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


// MARK: - Fastboard Delegate
- (void)fastboard:(Fastboard * _Nonnull)fastboard error:(FastError * _Nonnull)error {
    NSLog(@"error %@", error);
}

- (void)fastboardPhaseDidUpdate:(Fastboard * _Nonnull)fastboard phase:(enum FastPhase)phase {
    NSLog(@"phase, %d", (int)phase);
}

- (void)fastboardUserKickedOut:(Fastboard * _Nonnull)fastboard reason:(NSString * _Nonnull)reason {
    NSLog(@"kicked out");
}

@end
