//
//  Epub.m
//  createEpub
//
//  Created by YongCheHui on 15/6/26.
//  Copyright (c) 2015年 ApesStudio. All rights reserved.
//

#import "Epub.h"

@implementation Epub
-(NSString *)metaDir
{
    return [_savePath stringByAppendingPathComponent:@"META-INF"];
}

-(NSString *)opesDir
{
    return [_savePath stringByAppendingPathComponent:@"OEBPS"];
}

-(NSString *)opfPath
{
    return [[self opesDir] stringByAppendingPathComponent:self.opfName];
}

-(NSString *)ncxPath
{
    return [[self opesDir] stringByAppendingPathComponent:self.ncxName];
}

-(NSString *)imagesDir
{
    return [[self opesDir] stringByAppendingPathComponent:@"Images"];
}

-(NSString *)saveCoverPath
{
    return [[self imagesDir] stringByAppendingPathComponent:self.coverName];
}

-(NSString *)stylesDir
{
    return [[self opesDir] stringByAppendingPathComponent:@"Styles"];
}

-(NSString *)textDir
{
    return [[self opesDir] stringByAppendingPathComponent:@"Text"];
}

-(NSString *)itunesPath
{
    return [_savePath stringByAppendingPathComponent:@"iTunesMetadata.plist"];
}

-(NSString *)opfName
{
    return @"content.opf";
}

-(NSString *)coverName
{
    return @"cover.jpeg";
}

-(NSString *)ncxName
{
    return @"toc.ncx";
}

-(NSString *)mimetype
{
    return @"mimetype";
}

-(NSString *)container
{
    return @"container.xml";
}
@end
