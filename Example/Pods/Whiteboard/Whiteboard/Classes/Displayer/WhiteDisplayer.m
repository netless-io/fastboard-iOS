//
//  WhiteDisplayer.m
//  WhiteSDK
//
//  Created by yleaf on 2019/7/1.
//

#import "WhiteDisplayer.h"
#import "WhiteDisplayer+Private.h"
#import "WhiteScene.h"
#import "WhiteConsts.h"
#import "SyncedStore+Private.h"

@interface WhiteDisplayer ()

@end

@implementation WhiteDisplayer
{
    SyncedStore* _syncedStore;
}

#pragma mark - Class Methods

+ (WhiteScenePathType)scenePathTypeConvertFrom:(NSString *)type {
    if ([type isEqualToString:@"page"]) {
        return WhiteScenePathTypePage;
    } else if ([type isEqualToString:@"dir"]) {
        return WhiteScenePathTypeDir;
    } else {
        return WhiteScenePathTypeEmpty;
    }
}

#pragma mark -
#pragma mark - Instance Methods
#pragma mark -

- (instancetype)initWithUuid:(NSString *)uuid bridge:(WhiteBoardView *)bridge
{
    self = [super init];
    if (self) {
        _bridge = bridge;
        _backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor ? : [UIColor whiteColor];
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
    
    [backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    
    //fix issue: iOS 10/11 rgb css don's support float
    NSUInteger R = floorf(r * 255.0);
    NSUInteger G = floorf(g * 255.0);
    NSUInteger B = floorf(b * 255.0);
    
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"setBackgroundColor"] arguments:@[@(R), @(G), @(B), @(a * 255.0)]];
}

#pragma mark - iframe
- (void)postIframeMessage:(id)payload
{
    NSAssert([NSJSONSerialization isValidJSONObject:payload] || [payload isKindOfClass:[NSString class]], @"pay load should be a valid json object");
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"postMessage"] arguments: @[payload]];
    
}

#pragma mark - 页面（场景）API

- (void)getSceneFromScenePath:(NSString *)scenePath result:(void (^)(WhiteScene * _Nullable))result
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"getScene"] arguments:@[scenePath] completionHandler:^(id  _Nullable value) {
        if (result) {
            WhiteScene* scene = [WhiteScene _white_yy_modelWithJSON:value];
            result(scene);
        }
    }];
}

- (void)getScenePathType:(NSString *)pathOrDir result:(void (^) (WhiteScenePathType pathType))result;
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"scenePathType"] arguments:@[pathOrDir] completionHandler:^(id  _Nullable value) {
        if (result) {
            if ([value isKindOfClass:[NSString class]]) {
                WhiteScenePathType pathType = [[self class] scenePathTypeConvertFrom:value];
                result(pathType);
            }
        }
    }];
}

- (void)getEntireScenes:(void (^) (NSDictionary<NSString *, NSArray<WhiteScene *>*> *dict))result;
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"entireScenes"] completionHandler:^(id  _Nullable value) {
        if (result && [value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)value;
            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithCapacity:dict.allKeys.count];
            [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL * _Nonnull stop) {
                if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSArray class]]) {
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:obj.count];
                    [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        WhiteScene *scene = [WhiteScene _white_yy_modelWithJSON:obj];
                        if (scene) {
                            [mutableArray addObject:scene];
                        }
                    }];
                    mutableDict[key] = mutableArray;
                }
            }];
            result([mutableDict copy]);
        }
    }];
}

#pragma mark - 视野坐标类 API

static NSString * const kDisplayerNamespace = @"displayer.%@";
static NSString * const kAsyncDisplayerNamespace = @"displayerAsync.%@";

- (void)setCameraBound:(WhiteCameraBound *)cameraBound
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"setCameraBound"] arguments:@[cameraBound]];
}

- (void)moveCamera:(WhiteCameraConfig *)camera
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"moveCamera"] arguments:@[camera]];
}

- (void)moveCameraToContainer:(WhiteRectangleConfig *)rectange
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"moveCameraToContain"] arguments:@[rectange]];
}

- (void)disableCameraTransform:(BOOL)disable
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"setDisableCameraTransform"] arguments:@[@(disable)]];
}

- (void)scaleIframeToFit
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"scaleIframeToFit"] arguments:nil];
}

- (void)scalePptToFit:(WhiteAnimationMode)mode
{
    NSDictionary *dict = @{@(0): @"continuous", @(1): @"immediately"};
    NSString *modeString = dict[@(mode)];
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"scalePptToFit"] arguments:@[modeString]];
}

- (void)refreshViewSize
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"refreshViewSize"] completionHandler:nil];
}

- (void)convertToPointInWorld:(WhitePanEvent *)point result:(void (^) (WhitePanEvent *convertPoint))result;
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"convertToPointInWorld"] arguments:@[@(point.x), @(point.y)] completionHandler:^(id  _Nullable value) {
        if (result) {
            WhitePanEvent *convertP = [WhitePanEvent _white_yy_modelWithJSON:value];
            result(convertP);
        }
    }];
}

#pragma mark - SyncedStore
- (SyncedStore *)obtainSyncedStore {
    if (!_syncedStore) {
        _syncedStore = [SyncedStore new];
        _syncedStore.bridge = self.bridge;
    }
    return _syncedStore;
}

#pragma mark - 自定义事件

- (void)addMagixEventListener:(NSString *)eventName
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"addMagixEventListener"] arguments:@[eventName]];
}

- (void)addHighFrequencyEventListener:(NSString *)eventName fireInterval:(NSUInteger)millSeconds
{
    NSAssert(millSeconds >= 500, @"millSecond should not less than 500");
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"addHighFrequencyEventListener"] arguments:@[eventName, @(millSeconds)]];
}

- (void)removeMagixEventListener:(NSString *)eventName
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"removeMagixEventListener"] arguments:@[eventName]];
}

#pragma mark - 截图图片 API
- (void)getScenePreviewImage:(NSString *)scenePath completion:(void (^)(UIImage * _Nullable image))completionHandler
{
    [self.bridge callHandler:[NSString stringWithFormat:kAsyncDisplayerNamespace, @"scenePreview"] arguments:@[scenePath] completionHandler:^(NSString * _Nullable value) {
        NSString *imageData = [value stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
        if (completionHandler) {
            completionHandler(image);
        }
    }];
}

- (void)getSceneSnapshotImage:(NSString *)scenePath completion:(void (^)(UIImage * _Nullable image))completionHandler
{
    [self.bridge callHandler:[NSString stringWithFormat:kAsyncDisplayerNamespace, @"sceneSnapshot"] arguments:@[scenePath] completionHandler:^(NSString * _Nullable value) {
        NSString *imageData = [value stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:imageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
        if (completionHandler) {
            completionHandler(image);
        }
    }];
}

- (void)getLocalSnapShotWithCompletion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completionHandler
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.bridge evaluateJavaScript:@"window.postMessage({type: '@slide/_request_frozen_'}, '*')" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
            if (error) {
                completionHandler(nil, error);
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WhiteBoardView *bridge = weakSelf.bridge;
                CGSize whiteboardSize = bridge.bounds.size;
                UIGraphicsBeginImageContextWithOptions(whiteboardSize, FALSE, UIScreen.mainScreen.scale);
                [bridge drawViewHierarchyInRect:CGRectMake(0, 0, whiteboardSize.width, whiteboardSize.height) afterScreenUpdates:YES];
                UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                completionHandler(snapshot, nil);
                [bridge evaluateJavaScript:@"window.postMessage({type: '@slide/_request_release_'}, '*')" completionHandler:^(id _Nullable  value, NSError * _Nullable error) {
                    return;
                }];
            });
        }];
    });
}

- (void)getWindowManagerAttributesWithResult:(void (^)(NSDictionary * _Nonnull))result
{
    [self.bridge callHandler:[NSString stringWithFormat:kDisplayerNamespace, @"getWindowManagerAttributes"] completionHandler:^(id  _Nullable value) {
        if (result) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                result(value);
            } else {
                result(@{});
            }
        }
    }];
}

@end
