//
//  ViewController.m
//  OCExample
//
//  Created by xuyunshi on 2021/12/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "ViewController.h"
#import <Fastboard/Fastboard-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FastBoardSDK.globalFastboardRatio = 16.0 / 9.0;
    
    FastboardView* fastView = [FastBoardSDK createFastboardWithAppId: nil
                                                             userUID: nil
                                                            roomUUID: nil
                                                           roomToken: nil];
    [self.view addSubview:fastView];
    self.view.autoresizesSubviews = TRUE;
    fastView.autoresizingMask = TRUE;
    fastView.frame = self.view.bounds;
    fastView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    [FastboardThemeManager share]
}


@end
