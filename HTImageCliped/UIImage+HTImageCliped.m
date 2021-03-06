//
//  UIImage+HTCliped.m
//  HTImageCliped
//
//  Created by huangyibiao on 16/3/31.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "UIImage+HTmageCliped.h"
#import <objc/runtime.h>

static const char *s_HT_image_borderColorKey = "s_HT_image_borderColorKey";
static const char *s_HT_image_borderWidthKey = "s_HT_image_borderWidthKey";
static const char *s_HT_image_pathColorKey = "s_HT_image_pathColorKey";
static const char *s_HT_image_pathWidthKey = "s_HT_image_pathWidthKey";

@implementation UIImage (HTImageCliped)

#pragma mark - Border
- (CGFloat)HT_borderWidth {
  NSNumber *borderWidth = objc_getAssociatedObject(self, s_HT_image_borderWidthKey);
  
  if ([borderWidth respondsToSelector:@selector(doubleValue)]) {
    return borderWidth.doubleValue;
  }
  
  return 0;
}

- (void)setHT_borderWidth:(CGFloat)HT_borderWidth {
  objc_setAssociatedObject(self,
                           s_HT_image_borderWidthKey,
                           @(HT_borderWidth),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)HT_pathWidth {
  NSNumber *width = objc_getAssociatedObject(self, s_HT_image_pathWidthKey);
  
  if ([width respondsToSelector:@selector(doubleValue)]) {
    return width.doubleValue;
  }
  
  return 0;
}

- (void)setHT_pathWidth:(CGFloat)HT_pathWidth {
  objc_setAssociatedObject(self,
                           s_HT_image_pathWidthKey,
                           @(HT_pathWidth),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)HT_pathColor {
  UIColor *color = objc_getAssociatedObject(self, s_HT_image_pathColorKey);
  
  if (color) {
    return color;
  }
  
  return [UIColor whiteColor];
}

- (void)setHT_pathColor:(UIColor *)HT_pathColor {
  objc_setAssociatedObject(self,
                           s_HT_image_pathColorKey,
                           HT_pathColor,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  
}

- (UIColor *)HT_borderColor {
  UIColor *color = objc_getAssociatedObject(self, s_HT_image_borderColorKey);
  
  if (color) {
    return color;
  }
  
  return [UIColor lightGrayColor];
}

- (void)setHT_borderColor:(UIColor *)HT_borderColor {
  objc_setAssociatedObject(self,
                           s_HT_image_borderColorKey,
                           HT_borderColor,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Clip
- (UIImage *)HT_clipToSize:(CGSize)targetSize {
  return [self HT_clipToSize:targetSize isEqualScale:YES];
}

- (UIImage *)HT_clipToSize:(CGSize)targetSize isEqualScale:(BOOL)isEqualScale {
  return [self HT_private_clipImageToSize:targetSize
                              cornerRadius:0
                                   corners:UIRectCornerAllCorners
                           backgroundColor:[UIColor whiteColor]
                              isEqualScale:isEqualScale
                                  isCircle:NO];
}

- (UIImage *)HT_clipToSize:(CGSize)targetSize
               cornerRadius:(CGFloat)cornerRadius
            backgroundColor:(UIColor *)backgroundColor
               isEqualScale:(BOOL)isEqualScale {
  return [self HT_private_clipImageToSize:targetSize
                              cornerRadius:cornerRadius
                                   corners:UIRectCornerAllCorners
                           backgroundColor:backgroundColor
                              isEqualScale:isEqualScale
                                  isCircle:NO];
}

- (UIImage *)HT_clipToSize:(CGSize)targetSize
               cornerRadius:(CGFloat)cornerRadius {
  return [self HT_clipToSize:targetSize
                 cornerRadius:cornerRadius
              backgroundColor:[UIColor whiteColor]
                 isEqualScale:YES];
}

- (UIImage *)HT_clipToSize:(CGSize)targetSize
               cornerRadius:(CGFloat)cornerRadius
                    corners:(UIRectCorner)corners
            backgroundColor:(UIColor *)backgroundColor
               isEqualScale:(BOOL)isEqualScale {
  return [self HT_private_clipImageToSize:targetSize
                              cornerRadius:cornerRadius
                                   corners:corners
                           backgroundColor:backgroundColor
                              isEqualScale:isEqualScale
                                  isCircle:NO];
}

- (UIImage *)HT_clipToSize:(CGSize)targetSize
               cornerRadius:(CGFloat)cornerRadius
                    corners:(UIRectCorner)corners {
  return [self HT_clipToSize:targetSize
                 cornerRadius:cornerRadius
                      corners:corners
              backgroundColor:[UIColor whiteColor]
                 isEqualScale:YES];
}

- (UIImage *)HT_clipCircleToSize:(CGSize)targetSize
                  backgroundColor:(UIColor *)backgroundColor
                     isEqualScale:(BOOL)isEqualScale {
  return [self HT_private_clipImageToSize:targetSize
                              cornerRadius:0
                                   corners:UIRectCornerAllCorners
                           backgroundColor:backgroundColor
                              isEqualScale:isEqualScale
                                  isCircle:YES];
}

- (UIImage *)HT_clipCircleToSize:(CGSize)targetSize {
  return [self HT_clipCircleToSize:targetSize backgroundColor:[UIColor whiteColor] isEqualScale:YES];
}

- (UIImage *)HT_clipToSize:(CGSize)targetSize
               cornerRadius:(CGFloat)cornerRadius
                    corners:(UIRectCorner)corners
            backgroundColor:(UIColor *)backgroundColor
               isEqualScale:(BOOL)isEqualScale
                   isCircle:(BOOL)isCircle {
  return [self HT_private_clipImageToSize:targetSize
                              cornerRadius:cornerRadius
                                   corners:corners
                           backgroundColor:backgroundColor
                              isEqualScale:isEqualScale
                                  isCircle:isCircle];
}

+ (UIImage *)HT_imageWithColor:(UIColor *)color toSize:(CGSize)targetSize cornerRadius:(CGFloat)cornerRadius {
  return [self HT_imageWithColor:color
                           toSize:targetSize
                     cornerRadius:cornerRadius
                  backgroundColor:[UIColor whiteColor]];
}

+ (UIImage *)HT_imageWithColor:(UIColor *)color
                         toSize:(CGSize)targetSize
                   cornerRadius:(CGFloat)cornerRadius
                backgroundColor:(UIColor *)backgroundColor {
  return [self HT_imageWithColor:color
                           toSize:targetSize
                     cornerRadius:cornerRadius
                  backgroundColor:backgroundColor
                      borderColor:nil
                      borderWidth:0];
}

+ (UIImage *)HT_imageWithColor:(UIColor *)color toSize:(CGSize)targetSize cornerRadius:(CGFloat)cornerRadius backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
  UIGraphicsBeginImageContextWithOptions(targetSize, cornerRadius == 0, [UIScreen mainScreen].scale);
  
  CGRect targetRect = (CGRect){0, 0, targetSize.width, targetSize.height};
  UIImage *finalImage = nil;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [color CGColor]);
  if (cornerRadius == 0) {
    if (borderWidth > 0) {
      CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
      CGContextSetLineWidth(context, borderWidth);
      CGContextFillRect(context, targetRect);
      
      targetRect = CGRectMake(borderWidth / 2, borderWidth / 2, targetSize.width - borderWidth, targetSize.height - borderWidth);
      CGContextStrokeRect(context, targetRect);
    } else {
      CGContextFillRect(context, targetRect);
    }
  } else {
    targetRect = CGRectMake(borderWidth / 2, borderWidth / 2, targetSize.width - borderWidth, targetSize.height - borderWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CGContextAddPath(UIGraphicsGetCurrentContext(), path.CGPath);
    
    if (borderWidth > 0) {
      CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
      CGContextSetLineWidth(context, borderWidth);
      CGContextDrawPath(context, kCGPathFillStroke);
    } else {
      CGContextDrawPath(context, kCGPathFill);
    }
  }
  
  finalImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return finalImage;
}

+ (UIImage *)HT_imageWithColor:(UIColor *)color toSize:(CGSize)targetSize {
  return [self HT_imageWithColor:color toSize:targetSize cornerRadius:0];
}

#pragma mark - Private
- (UIImage *)HT_private_clipImageToSize:(CGSize)targetSize
                            cornerRadius:(CGFloat)cornerRadius
                                 corners:(UIRectCorner)corners
                         backgroundColor:(UIColor *)backgroundColor
                            isEqualScale:(BOOL)isEqualScale
                                isCircle:(BOOL)isCircle {
  if (targetSize.width <= 0 || targetSize.height <= 0) {
    return self;
  }
  //  NSTimeInterval timerval = CFAbsoluteTimeGetCurrent();
  
  CGSize imgSize = self.size;
  
  CGSize resultSize = targetSize;
  if (isEqualScale) {
    CGFloat x = MAX(targetSize.width / imgSize.width, targetSize.height / imgSize.height);
    resultSize = CGSizeMake(x * imgSize.width, x * imgSize.height);
  }
  
  CGRect targetRect = (CGRect){0, 0, resultSize.width, resultSize.height};
  
  if (isCircle) {
    CGFloat width = MIN(resultSize.width, resultSize.height);
    targetRect = (CGRect){0, 0, width, width};
  }
  
  CGFloat pathWidth = self.HT_pathWidth;
  CGFloat borderWidth = self.HT_borderWidth;
  
  if (pathWidth > 0 && borderWidth > 0 && (isCircle || cornerRadius == 0)) {
    UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                           backgroundColor != nil,
                                           [UIScreen mainScreen].scale);
    if (backgroundColor) {
      [backgroundColor setFill];
      CGContextFillRect(UIGraphicsGetCurrentContext(), targetRect);
    }
    
    UIColor *borderColor = self.HT_borderColor;
    UIColor *pathColor = self.HT_pathColor;
    
    CGRect rect = targetRect;
    CGRect rectImage = rect;
    rectImage.origin.x += pathWidth;
    rectImage.origin.y += pathWidth;
    rectImage.size.width -= pathWidth * 2.0;
    rectImage.size.height -= pathWidth * 2.0;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (isCircle) {
      CGContextAddEllipseInRect(ctx, rect);
    } else {
      CGContextAddRect(ctx, rect);
    }
    
    CGContextClip(ctx);
    [self drawInRect:rectImage];
    
    // 添加内线和外线
    rectImage.origin.x -= borderWidth / 2.0;
    rectImage.origin.y -= borderWidth / 2.0;
    rectImage.size.width += borderWidth;
    rectImage.size.height += borderWidth;
    
    rect.origin.x += borderWidth / 2.0;
    rect.origin.y += borderWidth / 2.0;
    rect.size.width -= borderWidth;
    rect.size.height -= borderWidth;
    
    CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
    CGContextSetLineWidth(ctx, borderWidth);
    
    if (isCircle) {
      CGContextStrokeEllipseInRect(ctx, rectImage);
      CGContextStrokeEllipseInRect(ctx, rect);
    } else if (cornerRadius == 0) {
      CGContextStrokeRect(ctx, rectImage);
      CGContextStrokeRect(ctx, rect);
    }
    
    float centerPathWidth = pathWidth - borderWidth * 2.0;
    if (centerPathWidth > 0) {
      CGContextSetLineWidth(ctx, centerPathWidth);
      CGContextSetStrokeColorWithColor(ctx, [pathColor CGColor]);
      
      rectImage.origin.x -= borderWidth / 2.0 + centerPathWidth / 2.0;
      rectImage.origin.y -= borderWidth / 2.0 + centerPathWidth / 2.0;
      rectImage.size.width += borderWidth + centerPathWidth;
      rectImage.size.height += borderWidth + centerPathWidth;
      
      if (isCircle) {
        CGContextStrokeEllipseInRect(ctx, rectImage);
      } else if (cornerRadius == 0) {
        CGContextStrokeRect(ctx, rectImage);
      }
    }
  } else if (pathWidth > 0 && borderWidth > 0 && cornerRadius > 0 && !isCircle) {
    UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                           backgroundColor != nil,
                                           [UIScreen mainScreen].scale);
    if (backgroundColor) {
      [backgroundColor setFill];
      CGContextFillRect(UIGraphicsGetCurrentContext(), targetRect);
    }
    
    UIColor *borderColor = self.HT_borderColor;
    UIColor *pathColor = self.HT_pathColor;
    
    CGRect rect = targetRect;
    CGRect rectImage = rect;
    rectImage.origin.x += pathWidth;
    rectImage.origin.y += pathWidth;
    rectImage.size.width -= pathWidth * 2.0;
    rectImage.size.height -= pathWidth * 2.0;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawInRect:rectImage];
    
    // 添加内线和外线
    rectImage.origin.x -= borderWidth / 2.0;
    rectImage.origin.y -= borderWidth / 2.0;
    rectImage.size.width += borderWidth;
    rectImage.size.height += borderWidth;
    
    rect.origin.x += borderWidth / 2.0;
    rect.origin.y += borderWidth / 2.0;
    rect.size.width -= borderWidth;
    rect.size.height -= borderWidth;
    
    CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
    CGContextSetLineWidth(ctx, borderWidth);
    
    CGFloat minusPath1 = pathWidth / 2;
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:rectImage byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius - minusPath1, cornerRadius - minusPath1)];
    CGContextAddPath(ctx, path1.CGPath);
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:rect
                                                byRoundingCorners:corners
                                                      cornerRadii:CGSizeMake(cornerRadius + minusPath1 ,cornerRadius + minusPath1)];
    CGContextAddPath(ctx, path2.CGPath);
    CGContextStrokePath(ctx);
    
    float centerPathWidth = pathWidth - borderWidth * 2.0;
    if (centerPathWidth > 0) {
      CGContextSetLineWidth(ctx, centerPathWidth);
      CGContextSetStrokeColorWithColor(ctx, [pathColor CGColor]);
      
      rectImage.origin.x -= borderWidth / 2.0 + centerPathWidth / 2.0;
      rectImage.origin.y -= borderWidth / 2.0 + centerPathWidth / 2.0;
      rectImage.size.width += borderWidth + centerPathWidth;
      rectImage.size.height += borderWidth + centerPathWidth;
      
      UIBezierPath *path3 = [UIBezierPath bezierPathWithRoundedRect:rectImage
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
      CGContextAddPath(ctx, path3.CGPath);
      CGContextStrokePath(ctx);
    }
  } else if (pathWidth <= 0 && borderWidth > 0 && (cornerRadius > 0 || isCircle)) {
    UIColor *borderColor = self.HT_borderColor;
    
    CGRect rect = targetRect;
    CGRect rectImage = rect;
    rectImage.origin.x += borderWidth / 2;
    rectImage.origin.y += borderWidth / 2;
    rectImage.size.width -= borderWidth;
    rectImage.size.height -= borderWidth;
    
    UIImage *image = [self _HT_scaleToSize:rectImage.size backgroundColor:backgroundColor];
    UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                           NO,
                                           [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithPatternImage:image].CGColor);
    
    UIBezierPath *path1 = nil;
    if (!isCircle) {
      CGFloat minusPath1 = borderWidth / 2;
      path1 = [UIBezierPath bezierPathWithRoundedRect:rectImage
                                    byRoundingCorners:corners
                                          cornerRadii:CGSizeMake(cornerRadius - minusPath1, cornerRadius - minusPath1)];
    } else {
      path1 = [UIBezierPath bezierPathWithRoundedRect:rectImage
                                    byRoundingCorners:corners
                                          cornerRadii:CGSizeMake(rectImage.size.width / 2, rectImage.size.width / 2)];
    }
    
    CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
    CGContextSetLineWidth(ctx, borderWidth);
    CGContextAddPath(ctx, path1.CGPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
  } else {
    UIGraphicsBeginImageContextWithOptions(targetRect.size,
                                           backgroundColor != nil,
                                           [UIScreen mainScreen].scale);
    if (backgroundColor) {
      [backgroundColor setFill];
      CGContextFillRect(UIGraphicsGetCurrentContext(), targetRect);
    }
 
    if (isCircle) {
      CGContextAddPath(UIGraphicsGetCurrentContext(),
                       [UIBezierPath bezierPathWithRoundedRect:targetRect
                                                  cornerRadius:targetRect.size.width / 2].CGPath);
      CGContextClip(UIGraphicsGetCurrentContext());
    } else if (cornerRadius > 0) {
      UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:targetRect
                                                 byRoundingCorners:corners
                                                       cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
      CGContextAddPath(UIGraphicsGetCurrentContext(), path.CGPath);
      CGContextClip(UIGraphicsGetCurrentContext());
    }
    
    [self drawInRect:targetRect];
  }
  
  UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  //  NSLog(@"time:%f  originalImageSize: %@, targetSize: %@",
  //        CFAbsoluteTimeGetCurrent() - timerval,
  //        NSStringFromCGSize(imgSize),
  //        NSStringFromCGSize(targetSize));
  
  return finalImage;
}

- (UIImage *)_HT_scaleToSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor {
  CGRect rect = CGRectMake(0, 0, size.width, size.height);
  UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
  
  if (backgroundColor) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
  }
  
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return scaledImage;
}

@end
