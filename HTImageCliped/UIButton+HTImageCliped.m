//
//  UIButton+HTImageCliped.m
//  HTImageCliped
//
//  Created by huangyibiao on 16/3/31.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "HTImageCliped.h"

@implementation UIButton (HTImageCliped)

- (void)HT_setImage:(id)image
            forState:(UIControlState)state
        cornerRadius:(CGFloat)cornerRadius
        isEqualScale:(BOOL)isEqualScale {
  [self HT_setImage:image
            forState:state
              toSize:self.frame.size
        cornerRadius:cornerRadius
        isEqualScale:isEqualScale];
}

- (void)HT_setImage:(id)image
            forState:(UIControlState)state
              toSize:(CGSize)targetSize
        cornerRadius:(CGFloat)cornerRadius
        isEqualScale:(BOOL)isEqualScale {
  [self _private_HT_setImage:image
                     forState:state
            isBackgroundImage:NO
                       toSize:targetSize
                 cornerRadius:cornerRadius
                 isEqualScale:isEqualScale];
}

- (void)HT_setBackgroundImage:(id)image
                      forState:(UIControlState)state
                  cornerRadius:(CGFloat)cornerRadius
                  isEqualScale:(BOOL)isEqualScale {
  [self HT_setBackgroundImage:image
                      forState:state
                        toSize:self.frame.size
                  cornerRadius:cornerRadius
                  isEqualScale:isEqualScale];
}

- (void)HT_setBackgroundImage:(id)image
                      forState:(UIControlState)state
                        toSize:(CGSize)targetSize
                  cornerRadius:(CGFloat)cornerRadius
                  isEqualScale:(BOOL)isEqualScale {
  [self _private_HT_setImage:image
                     forState:state
            isBackgroundImage:YES
                       toSize:targetSize
                 cornerRadius:cornerRadius
                 isEqualScale:isEqualScale];
}

#pragma mark - Private
- (void)_private_HT_setImage:(id)image
                     forState:(UIControlState)state
            isBackgroundImage:(BOOL)isBackImage
                       toSize:(CGSize)targetSize
                 cornerRadius:(CGFloat)cornerRadius
                 isEqualScale:(BOOL)isEqualScale {
  if (image == nil || targetSize.width == 0 || targetSize.height == 0) {
    return;
  }
  
  UIImage *willBeClipedImage = image;
  if ([image isKindOfClass:[NSString class]]) {
    willBeClipedImage = [UIImage imageNamed:image];
  } else if ([image isKindOfClass:[UIImage class]]) {
    willBeClipedImage = image;
  } else if ([image isKindOfClass:[NSData class]]) {
    willBeClipedImage = [UIImage imageWithData:image];
  }
  
  if (willBeClipedImage == nil) {
    return;
  }
  
  __block UIImage *clipedImage = nil;
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    @autoreleasepool {
      willBeClipedImage.HT_pathColor = self.HT_pathColor;
      willBeClipedImage.HT_pathWidth = self.HT_pathWidth;
      willBeClipedImage.HT_borderColor = self.HT_borderColor;
      willBeClipedImage.HT_borderWidth = self.HT_borderWidth;
      
      clipedImage = [willBeClipedImage HT_clipToSize:targetSize
                                         cornerRadius:cornerRadius
                                              corners:UIRectCornerAllCorners
                                      backgroundColor:self.backgroundColor
                                         isEqualScale:isEqualScale
                                             isCircle:NO];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        if (clipedImage) {
          if (isBackImage) {
            [self setBackgroundImage:clipedImage forState:state];
          } else {
            [self setImage:clipedImage forState:state];
          }
        }
      });
    }
  });
}

@end