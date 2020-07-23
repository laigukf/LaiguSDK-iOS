//
//  LGAssetUtil.m
//  LGChatViewControllerDemo
//
//  Created by Injoy on 15/11/16.
//  Copyright © 2015年 ijinmao. All rights reserved.
//

#import "LGAssetUtil.h"
#import "LGBundleUtil.h"
#import "LGChatViewController.h"

@implementation LGAssetUtil

+ (UIImage *)imageFromBundleWithName:(NSString *)name
{
    id image = [UIImage imageWithContentsOfFile:[LGAssetUtil resourceWithName:name]];
    if (image) {
        return image;
    } else {
        return [UIImage imageWithContentsOfFile:[[LGAssetUtil resourceWithName:name] stringByAppendingString:@".png"]];
    }
}

+ (UIImage *)templateImageFromBundleWithName:(NSString *)name {
    return [[self.class imageFromBundleWithName:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (NSString*)resourceWithName:(NSString*)fileName
{
//        return [NSString stringWithFormat:@"LGChatViewAsset.bundle/%@",fileName];
    //查看 bundle 是否存在
    NSBundle *laiGuBundle = [NSBundle bundleForClass:[LGChatViewController class]];
    NSString * fileRootPath = [[laiGuBundle bundlePath] stringByAppendingString:@"/LGChatViewAsset.bundle"];
    NSString * filePath = [fileRootPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
    return filePath;
}

+ (UIImage *)incomingDefaultAvatarImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGIcon"];
}

+ (UIImage *)outgoingDefaultAvatarImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGIcon"];
}

+ (UIImage *)messageCameraInputImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageCameraInputImageNormalStyleOne"];
}

+ (UIImage *)messageCameraInputHighlightedImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageCameraInputImageNormalStyleOne"];
}

+ (UIImage *)messageTextInputImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageTextInputImageNormalStyleOne"];
}

+ (UIImage *)messageTextInputHighlightedImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageTextInputImageNormalStyleOne"];
}

+ (UIImage *)messageVoiceInputImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageVoiceInputImageNormalStyleOne"];
}

+ (UIImage *)messageVoiceInputHighlightedImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageVoiceInputImageNormalStyleOne"];
}

+ (UIImage *)messageResignKeyboardImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageKeyboardDownImageNormalStyleOne"];
}

+ (UIImage *)messageResignKeyboardHighlightedImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageKeyboardDownImageNormalStyleOne"];
}

+ (UIImage *)bubbleIncomingImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubbleIncoming"];
}

+ (UIImage *)bubbleOutgoingImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubbleOutgoing"];
}

+ (UIImage *)returnCancelImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGNavReturnCancelImage"];
}

+(UIImage *)imageLoadErrorImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGImageLoadErrorImage"];
}

+(UIImage *)messageWarningImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageWarning"];
}

+ (UIImage *)voiceAnimationGray1
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_voice_animation_gray1"];
}

+ (UIImage *)voiceAnimationGray2
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_voice_animation_gray2"];
}

+ (UIImage *)voiceAnimationGray3
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_voice_animation_gray3"];
}

+ (UIImage *)voiceAnimationGrayError {
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_incoming_voice_error"];
}

+ (UIImage *)voiceAnimationGreen1
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_voice_animation_green1"];
}

+ (UIImage *)voiceAnimationGreen2
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_voice_animation_green2"];
}

+ (UIImage *)voiceAnimationGreen3
{
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_voice_animation_green3"];
}

+ (UIImage *)voiceAnimationGreenError {
    return [LGAssetUtil imageFromBundleWithName:@"LGBubble_outgoing_voice_error"];
}

+ (UIImage *)recordBackImage
{
    return [LGAssetUtil imageFromBundleWithName:@"LGRecord_back"];
}

+ (UIImage *)recordVolume:(NSInteger)volume
{
    NSString *imageName;
    switch (volume) {
        case 0:
            imageName = @"LGRecord0";
            break;
        case 1:
            imageName = @"LGRecord1";
            break;
        case 2:
            imageName = @"LGRecord2";
            break;
        case 3:
            imageName = @"LGRecord3";
            break;
        case 4:
            imageName = @"LGRecord4";
            break;
        case 5:
            imageName = @"LGRecord5";
            break;
        case 6:
            imageName = @"LGRecord6";
            break;
        case 7:
            imageName = @"LGRecord7";
            break;
        case 8:
            imageName = @"LGRecord8";
            break;
        default:
            imageName = @"LGRecord0";
            break;
    }
    return [LGAssetUtil imageFromBundleWithName:imageName];
}

+ (UIImage *)getEvaluationImageWithLevel:(NSInteger)level {
    NSString *imageName = @"LGEvaluationPositiveImage";
    switch (level) {
        case 0:
            imageName = @"LGEvaluationNegativeImage";
            break;
        case 1:
            imageName = @"LGEvaluationModerateImage";
            break;
        case 2:
            imageName = @"LGEvaluationPositiveImage";
            break;
        default:
            break;
    }
    return [LGAssetUtil imageFromBundleWithName:imageName];
}

+ (UIImage *)getNavigationMoreImage {
    return [LGAssetUtil imageFromBundleWithName:@"LGMessageNavMoreImage"];
}

+ (UIImage *)agentOnDutyImage {
    return [LGAssetUtil imageFromBundleWithName:@"LGAgentStatusOnDuty"];
}

+ (UIImage *)agentOffDutyImage {
    return [LGAssetUtil imageFromBundleWithName:@"LGAgentStatusOffDuty"];
}

+ (UIImage *)agentOfflineImage {
    return [LGAssetUtil imageFromBundleWithName:@"LGAgentStatusOffline"];
}

+ (UIImage *)fileIcon {
    return [LGAssetUtil imageFromBundleWithName:@"fileIcon"];
}

+ (UIImage *)fileCancel {
    return [LGAssetUtil imageFromBundleWithName:@"LGFileCancel"];
}

+ (UIImage *)fileDonwload {
    return [LGAssetUtil imageFromBundleWithName:@"LGFileDownload"];
}

+ (UIImage *)backArrow {
    return [[LGAssetUtil imageFromBundleWithName:@"backArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
@end
