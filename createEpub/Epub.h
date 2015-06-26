//
//  Epub.h
//  createEpub
//
//  Created by YongCheHui on 15/6/26.
//  Copyright (c) 2015年 ApesStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Epub : NSObject
@property(nonatomic,copy) NSString *coverPath;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *autor;
@property(nonatomic,copy) NSString *price;
@property(nonatomic,copy) NSString *publishDate;
@property(nonatomic,copy) NSString *savePath;
@property(nonatomic,copy) NSString *txtPath;
@property(nonatomic,copy) NSString *devRegex;

@property(nonatomic,readonly) NSString *metaDir;
@property(nonatomic,readonly) NSString *opesDir;
@property(nonatomic,readonly) NSString *opfPath;
@property(nonatomic,readonly) NSString *ncxPath;
@property(nonatomic,readonly) NSString *stylesDir;
@property(nonatomic,readonly) NSString *imagesDir;
@property(nonatomic,readonly) NSString *saveCoverPath;
@property(nonatomic,readonly) NSString *textDir;
@property(nonatomic,readonly) NSString *itunesPath;

@property(nonatomic,readonly) NSString *mimetype;
@property(nonatomic,readonly) NSString *container;
@property(nonatomic,readonly) NSString *coverName;
@property(nonatomic,readonly) NSString *ncxName;
@property(nonatomic,readonly) NSString *opfName;
@end
