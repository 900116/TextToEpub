//
//  ViewController.m
//  createEpub
//
//  Created by YongCheHui on 15/6/25.
//  Copyright (c) 2015年 ApesStudio. All rights reserved.
//

#import "ViewController.h"
#import "createEpubHelper.h"

@implementation ViewController
{
    __strong NSString *_txtPath;
    __strong NSString *_epubSavePath;
    __strong NSString *_imagePath;
}

-(void)openFileManagerWithISFile:(BOOL)isFile block:(void(^)(NSString * path))cplBlk
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:isFile];
    [openDlg setCanChooseDirectories:!isFile];
    [openDlg setAllowsMultipleSelection:NO];
    NSString *_path = nil;
    if([openDlg runModal] == NSModalResponseOK)
    {
        NSArray* files = [openDlg URLs];
        _path = [files[0] path];
    }
    cplBlk(_path);
}

-(void)showAlertMessage:(NSString *)msg infomative:(NSString *)inf
{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = msg;
    alert.informativeText = inf;
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

-(IBAction)selectTextFile:(id)sender
{
    __block ViewController *wSelf = self;
    [self openFileManagerWithISFile:YES block:^(NSString *path) {
        wSelf->_txtPath = [path copy];
    }];
}

-(IBAction)selectSaveEpubPath:(id)sender
{
    __block ViewController *wSelf = self;
    [self openFileManagerWithISFile:NO block:^(NSString *path) {
        wSelf->_epubSavePath = [path copy];
    }];
}

-(IBAction)transmit:(id)sender
{
    if (!_txtPath) {
        [self showAlertMessage:@"错误" infomative:@"TXT文件未选择!!!"];
        return;
    }
    if (!_epubSavePath) {
        _epubSavePath = [_txtPath stringByDeletingLastPathComponent];
    }
    Epub *epub = [[Epub alloc]init];
    epub.title = _name.stringValue;
    epub.autor = _author.stringValue;
    epub.publishDate = @"2014-05-06";
    epub.price = @"10.0";
    epub.savePath = _epubSavePath;
    epub.txtPath = _txtPath;
    epub.coverPath = _imagePath;
    epub.devRegex = _regex.stringValue;
    createEpubHelper *helper = [[createEpubHelper alloc]initWithEpub:epub];
    [helper beginTransmit];

}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(IBAction)selectImage:(id)sender
{
    __block ViewController *wSelf = self;
    [self openFileManagerWithISFile:YES block:^(NSString *path) {
        wSelf->_imagePath = path;
        NSImage *image = [[NSImage alloc]initWithContentsOfFile:path];
        wSelf.imageView.image = image;
    }];
}
@end
