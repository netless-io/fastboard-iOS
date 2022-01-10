//
//  Utility.m
//  OCExample
//
//  Created by xuyunshi on 2022/1/10.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

#import "Utility.h"
#import <UIKit/UIKit.h>

Theme const ThemeAuto = @"auto";
Theme const ThemeDark = @"dark";
Theme const ThemeLight = @"light";

@implementation Utility

+ (UIButton *)buttonWith: (NSString *)title index: (int)index {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [Utility randomColor];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.tag = index;
    btn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    return btn;
}

+ (UIColor *)randomColor {
    NSArray* colors = @[UIColor.systemRedColor,
                        UIColor.blackColor,
                        UIColor.systemOrangeColor,
                        UIColor.systemBlueColor,
                        UIColor.systemGreenColor,
                        UIColor.systemPinkColor,
                        UIColor.systemYellowColor,
                        UIColor.systemGrayColor,
                        UIColor.systemPurpleColor,
                        UIColor.systemTealColor];
    int i = random() % 10;
    return colors[i];
}

@end
