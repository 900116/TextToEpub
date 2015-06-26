//
//  createEpubHelper.m
//  createEpub
//
//  Created by YongCheHui on 15/6/25.
//  Copyright (c) 2015年 ApesStudio. All rights reserved.
//

#import "createEpubHelper.h"
#import "ZipArchive.h"
#define kDefaultFileManager  [NSFileManager defaultManager]
static inline void createDirIFNotExist(NSString *path)
{
    if (![kDefaultFileManager fileExistsAtPath:path]) {
        [kDefaultFileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

static inline void writeToFile(NSString *str,NSString *path)
{
    NSData *fileData = [str dataUsingEncoding:NSUTF8StringEncoding];
    [fileData writeToFile:path atomically:YES];
}

static inline void copyResFileToRelativePath(NSString *fileName,NSString *basePath)
{
    NSString *releavPath = [basePath stringByAppendingPathComponent:fileName];
    NSString* srcPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:srcPath];
    [data writeToFile:releavPath atomically:YES];
}

static inline void copyResFile(NSString *orginPath,NSString *toPath)
{
    NSData *data = [NSData dataWithContentsOfFile:orginPath];
    [data writeToFile:toPath atomically:YES];
}


@implementation createEpubHelper
{
    __strong Epub *_epub;
    __strong NSMutableString *_contentOPf;
    __strong NSMutableString *_ncxString;
}

-(instancetype)initWithEpub:(Epub *)epub
{
    self = [super init];
    if (self) {
        _epub = epub;
        _contentOPf = [NSMutableString new];
        _ncxString = [NSMutableString new];
    }
    return self;
}

-(void)beginTransmit
{
    [self createTempDir];
    [self OtfInit];
    [self createiTunesMetadata];
    [self createMimetype];
    [self createMETAINF];
    [self createOEBPS];
    [self zipEpub];
}

-(void)createTempDir
{
    NSString *temp = [_epub.savePath stringByAppendingPathComponent:@"temp"];
    createDirIFNotExist(temp);
    _epub.savePath = [temp copy];
}

-(void)createiTunesMetadata
{
    NSMutableDictionary *mutiDict = [NSMutableDictionary new];
    [mutiDict setObject:_epub.autor forKey:@"artistName"];
    [mutiDict setObject:@"武侠" forKey:@"genre"];
    [mutiDict setObject:_epub.title forKey:@"itemName"];
    [mutiDict setObject:_epub.title forKey:@"playlistName"];
    [mutiDict setObject:_epub.publishDate forKey:@"releaseData"];
    
    
    NSMutableDictionary *bookInfo = [NSMutableDictionary new];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyyMMddHHmmsss";
    NSString *unique_id = [formatter stringFromDate:date];
    
    [bookInfo setObject:unique_id forKey:@"cover-image-hash"];
    
    //[bookInfo setObject:@"-5,597,471,024,378,928,277" forKey:@"unique-id"];
    [bookInfo setObject:unique_id forKey:@"unique-id"];
    [bookInfo setObject:@"2" forKey:@"update-level"];
    [bookInfo setObject:@"OEBPS/images/cover.jpeg" forKey:@"cover-image-path"];
    [bookInfo setObject:@"application/epub+zip" forKey:@"mime-type"];
    [bookInfo setObject:unique_id forKey:@"package-file-hash"];
    
    [mutiDict setObject:bookInfo forKey:@"book-info"];
    [mutiDict writeToFile:_epub.itunesPath atomically:YES];
}

-(void)addDir:(NSString *)path za:(ZipArchive *)za
{
    NSArray *subPaths = [kDefaultFileManager subpathsAtPath:path];// 关键是subpathsAtPath方法
    for(NSString *subPath in subPaths){
        NSString *fullPath = [path stringByAppendingPathComponent:subPath];
        BOOL isDir;
        if([kDefaultFileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)// 只处理文件
        {
            [za addFileToZip:fullPath newname:subPath];
        }
    }
}

-(void)zipEpub
{
    NSString *zipFile = [[_epub.savePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub",_epub.title]];
    ZipArchive *za = [[ZipArchive alloc]init];
    [za CreateZipFile2:zipFile];
    [self addDir:_epub.savePath za:za];
    [za CloseZipFile2];
    
    [kDefaultFileManager removeItemAtPath:_epub.savePath error:nil];
}

-(void)createMimetype
{
    copyResFileToRelativePath(_epub.mimetype,_epub.savePath);
}

-(void)createMETAINF
{
    createDirIFNotExist(_epub.metaDir);
    copyResFileToRelativePath(_epub.container,_epub.metaDir);
}


-(void)createOEBPS
{
    createDirIFNotExist(_epub.opesDir);
    [self createCSSFile];
    [self createImages];
    [self createTEXTFile];
}

-(void)createImages
{
    createDirIFNotExist(_epub.imagesDir);
    copyResFile(_epub.coverPath, _epub.saveCoverPath);
}

-(void)createCSSFile
{
    createDirIFNotExist(_epub.stylesDir);
    
    copyResFileToRelativePath(@"page_styles.css",_epub.stylesDir);
    
    copyResFileToRelativePath(@"stylesheet.css",_epub.stylesDir);
}

-(void)createTEXTFile
{
    createDirIFNotExist(_epub.textDir);
    //添加封面
    copyResFileToRelativePath(@"cover.xhtml",_epub.textDir);
    
    //拆分Txt
    NSMutableArray *categorys = [NSMutableArray array];
    [self devideText:_epub.textDir category:categorys];
}
     
-(void)OtfInit
{
    NSString* author = _epub.autor;
    NSString* name = _epub.title;
    NSString *date = _epub.publishDate;
    NSString *price = _epub.price;
    NSString *version = @"1.0.0";
    
    [_contentOPf appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>\n"];
    [_contentOPf appendString:@"<package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"uuid_id\" version=\"2.0\">\n"];
    [_contentOPf appendString:@"\t<metadata xmlns:calibre=\"http://calibre.kovidgoyal.net/2009/metadata\" xmlns:dc=\"http://"
     "purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:opf=\"http://www.idpf.org/2007/opf\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"];
    [_contentOPf appendString:@"\t\t<dc:identifier id=\"uuid_id\" opf:scheme=\"uuid\">f73ae029-7201-4e1c-bc7f-b615c2b2ddd6</dc:identifier>\n"];
    [_contentOPf appendString:@"\t\t<dc:language>zh</dc:language>\n"];
    [_contentOPf appendFormat:@"\t\t<dc:creator opf:file-as=\"%@\" opf:role=\"aut\">卧龙生</dc:creator>\n",author];
    [_contentOPf appendString:@"\t\t<dc:contributor opf:role=\"bkp\">ApesStudio [http://calibre-ebook.com]</dc:contributor>\n"];
    [_contentOPf appendFormat:@"\t\t<dc:title>%@</dc:title>\n",name];
    [_contentOPf appendString:@"\t\t<dc:identifier opf:scheme=\"calibre\">f73ae029-7201-4e1c-bc7f-b615c2b2ddd6</dc:identifier>\n"];
    [_contentOPf appendFormat:@"\t\t<dc:date opf:event=\"modification\">%@</dc:date>\n",date];
    [_contentOPf appendFormat:@"\t\t<meta content=\"%@\" name=\"calibre:rating\" />\n",price];

    [_contentOPf appendString:@"\t\t<meta content=\"2014-08-18T14:11:54.472000+00:00\" name=\"calibre:timestamp\"/>\n"];
    [_contentOPf appendFormat:@"\t\t<meta content=\"%@\" name=\"calibre:title_sort\"/>\n",name];
    [_contentOPf appendFormat:@"\t\t<meta name=\"cover\" content=\"%@\" />\n",_epub.coverName];
    [_contentOPf appendFormat:@"\t\t<meta content=\"%@\" name=\"Sigil version\" />\n",version];
    [_contentOPf appendString:@"\t</metadata>\n\t<manifest>\n"];
    
    
    [_ncxString appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>\n"];
    [_ncxString appendString:@"<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">\n\t<head>\n"];
    [_ncxString appendString:@"\t\t<meta content=\"f73ae029-7201-4e1c-bc7f-b615c2b2ddd6\" name=\"dtb:uid\"/>\n"];
    [_ncxString appendString:@"\t\t<meta content=\"1\" name=\"dtb:depth\"/>\n"];
    [_ncxString appendString:@"\t\t<meta content=\"0\" name=\"dtb:totalPageCount\"/>\n"];
    [_ncxString appendString:@"\t\t<meta content=\"0\" name=\"dtb:maxPageNumber\"/>\n\t</head>\n"];
    [_ncxString appendFormat:@"\t<docTitle>\n\t\t<text>%@</text>\n\t</docTitle>\n\t<navMap>\n",name];
}

-(void)devideText:(NSString *)textDir category:(NSMutableArray *)categorys
{
    NSStringEncoding encode;
    NSString *str = [NSString stringWithContentsOfFile:_epub.txtPath usedEncoding:&encode error:nil];
    NSString *regexStr = _epub.devRegex;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    NSRange range;
    int i = 0;
    for (NSTextCheckingResult* b in array)
    {
        if (i == 0) {
            range.location = b.range.location;
        }
        else
        {
            range.length = b.range.location - range.location;
            NSString *fileStr = [str substringWithRange:range];
            NSString *fileName = [NSString stringWithFormat:@"chapter%d.html",i];
            NSString *relativeName = [NSString stringWithFormat:@"html%d",i];
            [_contentOPf appendFormat:@"\t\t<item href=\"Text/%@\" id=\"%@\" media-type=\"application/xhtml+xml\" />\n",fileName,relativeName];
            
            NSString *filePath = [textDir stringByAppendingPathComponent:fileName];
            NSString *chapterTitle = [self saveFileWithFileString:fileStr filePath:filePath Range:range];
            [categorys addObject:chapterTitle];
            
            [_ncxString appendFormat:@"\t\t<navPoint id=\"navPoint-%d\" playOrder=\"%d\">\n",i,i];
            [_ncxString appendString:@"\t\t\t<navLabel>\n"];
            NSString *titleStr = [NSString stringWithFormat:@"\t\t\t\t<text>%@</text>\n\t\t\t</navLabel>\n",chapterTitle];
            [_ncxString appendString:titleStr];
            [_ncxString appendFormat:@"\t\t\t<content src=\"Text/%@\"/>\n",fileName];
            [_ncxString appendString:@"\t\t</navPoint>\n"];
            range.location = b.range.location;
        }
        i++;
    }
    range.length = str.length - range.location;
    NSString *fileStr = [str substringWithRange:range];
    NSString *fileName = [NSString stringWithFormat:@"chapter%d.html",i];
    NSString *relativeName = [NSString stringWithFormat:@"html%d",i];
    NSString *filePath = [textDir stringByAppendingPathComponent:fileName];
    NSString *chapterTitle = [self saveFileWithFileString:fileStr filePath:filePath Range:range];
    [categorys addObject:chapterTitle];
    
    [_ncxString appendFormat:@"\t\t<navPoint id=\"navPoint-%d\" playOrder=\"%d\">\n",i,i];
    [_ncxString appendString:@"\t\t\t<navLabel>\n"];
    [_ncxString appendFormat:@"\t\t\t\t<text>%@</text>\n\t\t\t</navLabel>\n",chapterTitle];
    [_ncxString appendFormat:@"\t\t\t<content src=\"Text/%@\"/>\n",fileName];
    [_ncxString appendString:@"\t\t</navPoint>\n"];
    [_ncxString appendString:@"\t</navMap>\n"];
    [_ncxString appendString:@"</ncx>\n"];
    
    [_contentOPf appendFormat:@"\t\t<item href=\"Text/%@\" id=\"%@\" media-type=\"application/xhtml+xml\" />\n",fileName,relativeName];
    [_contentOPf appendString:@"\t\t<item href=\"Styles/page_styles.css\" id=\"page_css\" media-type=\"text/css\" />\n"];
    [_contentOPf appendString:@"\t\t<item href=\"Styles/stylesheet.css\" id=\"css\" media-type=\"text/css\" />\n"];
    [_contentOPf appendString:@"\t\t<item href=\"Text/cover.xhtml\" id=\"cover\" media-type=\"application/xhtml+xml\" />\n"];
    [_contentOPf appendFormat:@"\t\t<item href=\"%@\" id=\"ncx\" media-type=\"application/x-dtbncx+xml\" />\n",_epub.ncxName];
    [_contentOPf appendFormat:@"\t\t<item href=\"%@\" id=\"%@\" media-type=\"image/jpeg\" />\n",_epub.coverName,_epub.coverName];
    [_contentOPf appendString:@"\t</manifest>\n\t<spine toc=\"ncx\">\n"];
    [_contentOPf appendString:@"\t\t<itemref idref=\"cover\" properties=\"duokan-page-fullscreen\" />\n"];
    for (int i = 0; i < categorys.count; i++) {
        [_contentOPf appendFormat:@"\t\t<itemref  idref=\"html%d\" />\n",i+1];
    }
    [_contentOPf appendFormat:@"\t</spine>\n\t<guide>\n"];
    [_contentOPf appendString:@"\t\t<reference href=\"Text/cover.xhtml\" title=\"Cover\" type=\"cover\" />\n"];
    [_contentOPf appendFormat:@"\t</guide>\n"];
    [_contentOPf appendFormat:@"</package>\n"];
    writeToFile(_contentOPf, _epub.opfPath);
    writeToFile(_ncxString, _epub.ncxPath);
    str = nil;
}

-(NSString *)saveFileWithFileString:(NSString *)fileStr filePath:(NSString *)filePath Range:(NSRange)range
{
    NSString *cateRegexStr = _epub.devRegex;
    NSRegularExpression *cateRegex = [NSRegularExpression regularExpressionWithPattern:cateRegexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *arrays = [cateRegex matchesInString:fileStr options:0 range:NSMakeRange(0, fileStr.length > 100?100:fileStr.length)];
    if (arrays.count > 0) {
        NSTextCheckingResult* result = arrays[0];
        NSMutableString *fileMulStr = [NSMutableString new];
        NSString *headString = @"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n"
        "<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\">\n"
        "<head>\n"
        "\t<title>未知</title>\n"
        "\t<link href=\"../Styles/stylesheet.css\" rel=\"stylesheet\" type=\"text/css\" />\n"
        "\t<link href=\"../Styles/page_styles.css\" rel=\"stylesheet\" type=\"text/css\" />\n"
        "</head>\n\n"
        "<body class=\"calibre\">\n"
        "\t<div class=\"WordSection\">\n"
        "\t\t<h1 class=\"calibre3\" id=\"calibre_pb_16\"><span class=\"calibre4\">";
        [fileMulStr appendString:headString];
        NSString *title = [fileStr substringWithRange:result.range];
        [fileMulStr appendString:title];
        [fileMulStr appendString:@"</span></h1>\n"];
        
        NSString *subFileStr = [fileStr substringFromIndex:result.range.location+result.range.length];
        NSArray*components = [subFileStr componentsSeparatedByString:@"\n"];
        for (NSString *component in components) {
            [fileMulStr appendString:@"\t\t<p class=\"MsoNormal1\"><span class=\"calibre6\">"];
            [fileMulStr appendString:component];
            [fileMulStr appendString:@"\t\t</span></p>\n"];
        }
        [fileMulStr appendString:@"\t</dir>\n</body>\n</html>"];
        writeToFile(fileMulStr,filePath);
        NSString *chapterTitle = [fileStr substringWithRange:result.range];
        return chapterTitle;
    }
    return nil;
}
@end
