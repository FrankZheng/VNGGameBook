//
//  SDKManager.m
//  VNGGameBook
//
//  Created by Frank Zheng on 2019/4/30.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

#import "SDKManager.h"
#import <VungleSDK/VungleSDK.h>

@interface VungleSDK ()
- (void)setPluginName:(NSString *)pluginName version:(NSString *)version;
- (void)setHTTPHeaderPair:(NSDictionary *)header;
- (void)clearAdUnitCreativesForPlacement:(NSString *)placementRefID completionBlock:(nullable void (^)(NSError *))completionBlock;
- (NSArray *)getValidPlacementInfo;
@end

@interface SDKManager() <VungleSDKDelegate, VungleSDKLogger>
@property(nonatomic, strong) VungleSDK *sdk;
@property(nonatomic, strong) NSMutableArray<NSString *> *queue;
@property(nonatomic, strong) NSMutableArray<NSValue *> *delegates;
@property(nonatomic, strong) NSUserDefaults *defaults;
@property(nonatomic, copy) NSString *appId;

@end

@implementation SDKManager
@synthesize sdkVersion = _sdkVersion;
@synthesize serverURL = _serverURL;
@synthesize networkLoggingEnabled = _networkLoggingEnabled;

+ (nonnull instancetype)sharedManager {
    static SDKManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SDKManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sdkVersion = VungleSDKVersion;
        _queue = [NSMutableArray array];
        _delegates = [NSMutableArray array];
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)start:(nonnull NSString *)appId {
    //initialize SDK
    if (!_sdk || !_sdk.isInitialized) {
        self.appId = appId;
        //if sdk not initialized, try to initialize
        //Should set end point before sdk instantiation, and url should not have "/" at the last.
        //It's tricky, but needed for 5.3.2 version
        NSString *url = self.serverURL.absoluteString;
        if([url characterAtIndex:url.length-1] == '/') {
            url = [url substringWithRange:NSMakeRange(0,url.length-1)];
        }
        [_defaults setObject:url forKey:@"vungle.api_endpoint"];
        
        _sdk = [VungleSDK sharedSDK];
        [_sdk setLoggingEnabled:YES];
        [_sdk attachLogger:self];
        _sdk.delegate = self;
        
        [self startSDK];
    }
}

- (void)startSDK {
    NSError *error = nil;
    if(![_sdk startWithAppId:_appId error:&error]) {
        NSLog(@"Failed to initialize SDK, %@", error);
    }
}


- (void)addDelegate:(nonnull id<SDKDelegate>)delegate {
    [_delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
}

- (void)setNetworkLoggingEnabled:(BOOL)networkLoggingEnabled {
    [_defaults setBool:networkLoggingEnabled forKey:@"vungle.network_logging"];
}


- (void)clearCache:(nonnull NSString *)placementId {
    [self clearCache:placementId completionBlock:nil];
}

- (BOOL)isReady:(NSString *)placementId {
    return [_sdk isAdCachedForPlacementID:placementId];
}

- (void)loadAd:(nonnull NSString *)placementId {
    if (!_sdk.isInitialized) {
        //add placementId to queue
        [_queue addObject:placementId];
        
    } else {
        //if sdk already initialized, just load ad directly
        [self loadPlacement:placementId];
    }
}

- (void)playAd:(nonnull NSString *)placementId viewController:(nonnull UIViewController *)viewController {
    NSError *error = nil;
    if(![_sdk playAd:viewController options:nil placementID:placementId error:&error]) {
        NSLog(@"Failed to play ad, %@, %@", placementId, error);
    }
}

- (void)clearCache:(NSString *)pID completionBlock:(nullable void (^)(NSError *))completionBlock;{
    if([_sdk isAdCachedForPlacementID:pID]) {
        //if has cache, remove the cache
        [_sdk clearAdUnitCreativesForPlacement:pID completionBlock:^(NSError *error) {
            if (completionBlock != nil) {
                completionBlock(error);
            }
        }];
    } else {
        if (completionBlock != nil) {
            completionBlock(nil);
        }
    }
}

- (void)loadPlacement:(NSString *)pID {
    
    __weak typeof(self) weakSelf = self;
    [self clearCache:pID completionBlock:^(NSError *error) {
        if(error != nil) {
            NSLog(@"Failed to clear cache, %@, %@", pID, error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err = nil;
            if(![weakSelf.sdk loadPlacementWithID:pID error:&err]) {
                NSLog(@"Failed to load ad, %@, %@", pID, error);
            }
        });
    }];
}

- (void)notifyDelegates:(SEL)selector {
    [self notifyDelegates:selector withParams:@[]];
}

- (void)notifyDelegates:(SEL)selector withParams:(NSArray *)params {
    for(NSValue *value in _delegates) {
        NSObject<SDKDelegate> *delegate = [value nonretainedObjectValue];
        if(delegate != nil) {
            if([delegate respondsToSelector:selector]) {
                if(params.count == 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [delegate performSelector:selector];
                } else if(params.count == 1) {
                    id param = (params[0] == [NSNull null] ? nil : params[0]);
                    [delegate performSelector:selector withObject:param];
                } else if(params.count == 2) {
                    id param0 = (params[0] == [NSNull null] ? nil : params[0]);
                    id param1 = (params[1] == [NSNull null] ? nil : params[1]);
                    [delegate performSelector:selector withObject:param0 withObject:param1];
                }
#pragma clang diagnostic pop
            }
        }
    }
}




#pragma mark - VungleSDKLogger methods
- (void)vungleSDKLog:(nonnull NSString *)message {
    
}

#pragma mark - VungleSDKDelegate methods

- (void)vungleSDKDidInitialize {
    NSLog(@"vungleSDKDidInitialize");
    
    [self notifyDelegates:@selector(sdkDidInitialize)];
    
    if(_queue.count > 0) {
        for(NSString *pID in _queue) {
            [self loadPlacement:pID];
        }
        [_queue removeAllObjects];
    }
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(nullable NSString *)placementID
                            error:(nullable NSError *)error {
    NSLog(@"vungleAdPlayabilityUpdate:%@ placementID:%@  error:%@", @(isAdPlayable), placementID, error);
    if (_sdk.initialized) {
        id pID = placementID ? : [NSNull null];
        if(isAdPlayable) {
            [self notifyDelegates:@selector(onAdLoaded:error:) withParams:@[pID, [NSNull null]]];
        } else {
            if(error != nil) {
                [self notifyDelegates:@selector(onAdLoaded:error:) withParams:@[pID, error]];
            }
        }
    }
}


- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    NSLog(@"vungleSDKFailedToInitializeWithError, %@", error);
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID {
    NSLog(@"vungleWillShowAdForPlacementID, %@", placementID);
    id pID = placementID ? : [NSNull null];
    [self notifyDelegates:@selector(onAdDidPlay:) withParams:@[pID]];
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID {
    NSLog(@"vungleWillCloseAdWithViewInfo, %@, %@", info, placementID);
    //[self notifyDelegates:@selector(onAdDidClose)];
}

- (void)vungleDidCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID {
    NSLog(@"vungleDidCloseAdWithViewInfo, %@, %@", info, placementID);
    [self notifyDelegates:@selector(onAdDidClose:) withParams:@[placementID]];
    
}



@end
