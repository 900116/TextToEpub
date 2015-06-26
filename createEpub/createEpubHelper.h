//
//  createEpubHelper.h
//  createEpub
//
//  Created by YongCheHui on 15/6/25.
//  Copyright (c) 2015年 ApesStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Epub.h"

@interface createEpubHelper : NSObject
-(instancetype)initWithEpub:(Epub *)epub;
-(void)beginTransmit;
@end
