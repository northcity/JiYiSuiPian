//
//  ChuLiImageManager.h
//  shijianjiaonang
//
//  Created by chenxi on 2018/7/6.
//  Copyright © 2018 chenxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChuLiImageManager : NSObject

+ (UIImage *)decodeEchoImageBaseWith:(NSString *)str;

+ (NSData *)gzipData:(NSData *)pUncompressedData;

+ (NSData *)dataSmallerThan:(NSUInteger)dataLength WithImage:(UIImage *)image;

+ (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength WithImage:(UIImage *)image;
@end
