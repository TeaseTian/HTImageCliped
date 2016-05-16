//
//  HTImageClipedManager.m
//  HTImageCliped
//
//  Created by huangyibiao on 16/4/2.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "HTImageClipedManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/message.h>

static inline NSUInteger HTCacheCostForImage(UIImage *image) {
  return image.size.height * image.size.width * image.scale * image.scale;
}

@interface HTImageClipedManager ()

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation HTImageClipedManager

+ (instancetype)shared {
  static  HTImageClipedManager *s_manager = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    s_manager = [[[self class] alloc] init];
  });
  
  return s_manager;
}

- (NSCache *)sharedCache {
  return self.cache;
}

- (instancetype)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HT_private_clearCaches)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    self.shouldCache = YES;
    self.totalCostInMemory = 60 * 1024 * 1024; // 默认60M
    _cache = [[NSCache alloc] init];
    _cache.totalCostLimit = self.totalCostInMemory;
    _serialQueue = dispatch_queue_create("com.huangyibiao.imagecliped_serial_queue",
                                         DISPATCH_QUEUE_SERIAL);
    dispatch_sync(self.serialQueue, ^{
      self.fileManager = [[NSFileManager alloc] init];
    });
  }
  
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                                object:nil];
}

- (void)HT_private_clearCaches {
  [self.cache removeAllObjects];
}

+ (UIImage *)clipedImageFromDiskWithKey:(NSString *)key {
  if (key && key.length) {
    NSString *subpath = [self HT_md5:key];
    
    UIImage *image = nil;
    if ([HTImageClipedManager shared].shouldCache) {
      image = [[HTImageClipedManager shared].cache objectForKey:subpath];
      
      if (image) {
        return image;
      }
    }
    
    NSString *path = [[self HT_cachePath] stringByAppendingPathComponent:subpath];
    image = [UIImage imageWithContentsOfFile:path];
    
    return image;
  }
  
  return nil;
}

+ (void)clipedImageFromDiskWithKey:(NSString *)key completion:(HTCacheImage)completion {
  if (key && key.length) {
    dispatch_async([HTImageClipedManager shared].serialQueue, ^{
      NSString *subpath = [self HT_md5:key];
      
      UIImage *image = nil;
      if ([HTImageClipedManager shared].shouldCache) {
        image = [[HTImageClipedManager shared].cache objectForKey:subpath];
        
        if (image) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
              completion(image);
            }
          });
          return;
        }
      }
      
      NSString *path = [[self HT_cachePath] stringByAppendingPathComponent:subpath];
      image = [UIImage imageWithContentsOfFile:path];
      
      if (image != nil && [HTImageClipedManager shared].shouldCache) {
        NSUInteger cost = HTCacheCostForImage(image);
        [[HTImageClipedManager shared].cache setObject:image forKey:subpath cost:cost];
      }
      
      dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
          completion(image);
        }
      });
    });
  } else {
    if (completion) {
      completion(nil);
    }
  }
}

+ (void)storeClipedImage:(UIImage *)clipedImage toDiskWithKey:(NSString *)key {
  if (clipedImage == nil || key == nil || key.length == 0) {
    return;
  }
  
  NSString *subpath = [self HT_md5:key];
  
  if ([HTImageClipedManager shared].shouldCache) {
    NSUInteger cost = HTCacheCostForImage(clipedImage);
    [[HTImageClipedManager shared].cache setObject:clipedImage forKey:subpath cost:cost];
  }
  
  dispatch_async([HTImageClipedManager shared].serialQueue, ^{
    if (![[HTImageClipedManager shared].fileManager fileExistsAtPath:[self HT_cachePath] isDirectory:nil]) {
      NSError *error = nil;
      BOOL isOK = [[HTImageClipedManager shared].fileManager createDirectoryAtPath:[self HT_cachePath]
                                                        withIntermediateDirectories:YES
                                                                         attributes:nil
                                                                              error:&error];
      if (isOK && error == nil) {
#ifdef kHTImageCliped
        NSLog(@"create folder HTClipedImages ok");
#endif
      } else {
        return;
      }
    }
    
    @autoreleasepool {
      NSString *path = [[self HT_cachePath] stringByAppendingPathComponent:subpath];
      
      NSData *data = UIImageJPEGRepresentation(clipedImage, 1.0);
      BOOL isOk = [[HTImageClipedManager shared].fileManager createFileAtPath:path
                                                                      contents:data
                                                                    attributes:nil];
      if (isOk) {
#ifdef kHTImageCliped
        NSLog(@"save cliped image to disk ok, key path is %@", path);
#endif
      } else {
#ifdef kHTImageCliped
        NSLog(@"save cliped image to disk fail, key path is %@", path);
#endif
      }
    }
  });
}

+ (void)clearClipedImagesCache {
  dispatch_async([HTImageClipedManager shared].serialQueue, ^{
    [[HTImageClipedManager shared].cache removeAllObjects];
    
    NSString *directoryPath = [self HT_cachePath];
    
    if ([[HTImageClipedManager shared].fileManager fileExistsAtPath:directoryPath isDirectory:nil]) {
      NSError *error = nil;
      [[HTImageClipedManager shared].fileManager removeItemAtPath:directoryPath error:&error];
      
      if (error) {
        NSLog(@"clear caches error: %@", error);
      } else {
        NSLog(@"clear caches ok");
      }
    }
  });
}

+ (unsigned long long)imagesCacheSize {
  NSString *directoryPath = [self HT_cachePath];
  BOOL isDir = NO;
  unsigned long long total = 0;
  
  if ([[HTImageClipedManager shared].fileManager fileExistsAtPath:directoryPath isDirectory:&isDir]) {
    if (isDir) {
      NSError *error = nil;
      NSArray *array = [[HTImageClipedManager shared].fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
      
      if (error == nil) {
        for (NSString *subpath in array) {
          NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
          NSDictionary *dict = [[HTImageClipedManager shared].fileManager attributesOfItemAtPath:path
                                                                                            error:&error];
          if (!error) {
            total += [dict[NSFileSize] unsignedIntegerValue];
          }
        }
      }
    }
  }
  
  return total;
}

#pragma mark - Private
+ (NSString *)HT_cachePath {
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HTClipedImages"];
}

+ (NSString *)HT_md5:(NSString *)string {
  if (string == nil || [string length] == 0) {
    return nil;
  }
  
  unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
  CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
  NSMutableString *ms = [NSMutableString string];
  
  for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [ms appendFormat:@"%02x", (int)(digest[i])];
  }
  
  return [ms copy];
}

@end
