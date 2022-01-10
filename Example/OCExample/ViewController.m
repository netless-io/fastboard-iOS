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

@interface ViewController() <FastboardDelegate>
@end

@implementation ViewController {
    Fastboard* _fastboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    FastBoardSDK.globalFastboardRatio = 16.0 / 9.0;
    _fastboard = [FastBoardSDK createFastboardWithAppId:[RoomInfo getValueFrom:RoomInfoAPPID]
                                  roomUUID:[RoomInfo getValueFrom:RoomInfoRoomID]
                                 roomToken:[RoomInfo getValueFrom:RoomInfoRoomToken]
                                   userUID:@"some-unique"
                       customFastBoardView:nil];
    FastboardView *fastView = _fastboard.view;
    _fastboard.delegate = self;
    [_fastboard joinRoom];
    [self.view addSubview:fastView];
    self.view.autoresizesSubviews = TRUE;
    fastView.autoresizingMask = TRUE;
    fastView.frame = self.view.bounds;
    fastView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)fastboard:(Fastboard * _Nonnull)fastboard error:(FastError * _Nonnull)error {
    NSLog(@"error %@", error);
}

- (void)fastboardPhaseDidUpdate:(Fastboard * _Nonnull)fastboard phase:(enum FastPhase)phase {
    NSLog(@"phase, %d", phase);
}

- (void)fastboardUserKickedOut:(Fastboard * _Nonnull)fastboard reason:(NSString * _Nonnull)reason {
    NSLog(@"kicked out");
}

@end
