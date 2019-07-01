//
//  SDKManagerProtocol.h
//  VNGGameBook
//
//  Created by Frank Zheng on 2019/4/30.
//  Copyright © 2019 Vungle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDKDelegate <NSObject>
@optional
- (void)sdkDidInitialize;
- (void)onAdLoaded:(NSString*)placementId error:(nullable NSError *)error;
- (void)onAdDidPlay:(NSString*)placementId;
- (void)onAdDidClose:(NSString*)placementId;
- (void)onSDKLog:(NSString *)message;

@end


@protocol SDKManagerProtocol <NSObject>
@property(nonatomic, readonly) NSString *sdkVersion;
@property(nonatomic, copy) NSURL *serverURL; //for mock the backend server
@property(nonatomic, assign) BOOL networkLoggingEnabled;
@property(nonatomic, readonly, getter=isInitialized) BOOL initialized;

- (void)addDelegate:(id<SDKDelegate>) delegate;

- (void)start:(NSString*)appId;

- (BOOL)isReady:(NSString *)placementId;

- (void)loadAd:(NSString*)placementId;

- (void)playAd:(NSString*)placementId viewController:(UIViewController*)viewController;

- (void)clearCache:(NSString*)placementId;

@end


NS_ASSUME_NONNULL_END
