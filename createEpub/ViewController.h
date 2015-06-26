//
//  ViewController.h
//  createEpub
//
//  Created by YongCheHui on 15/6/25.
//  Copyright (c) 2015年 ApesStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property(nonatomic,weak) IBOutlet NSImageView *imageView;
@property(nonatomic,weak) IBOutlet NSTextField *author;
@property(nonatomic,weak) IBOutlet NSTextField *name;
@property(nonatomic,weak) IBOutlet NSTextField *regex;
-(IBAction)selectTextFile:(id)sender;
-(IBAction)selectSaveEpubPath:(id)sender;
-(IBAction)transmit:(id)sender;
-(IBAction)selectImage:(id)sender;
@end

