//
//  CanvasWindowController.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WebCanvasView.h"

@interface CanvasWindowController : NSWindowController{
    NSMutableArray *selectedIUs;
    NSMutableDictionary *frameDict;
}


//load page
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)URL;

//select IUs
- (void)removeSelectedAllIUs;
- (void)addSelectedIU:(NSString *)IU;

//set css
/*
 cssText: #test2{background-color:green; width:100px; height:100px}
 */
- (void)setIUStyle:(NSString *)cssText withID:(NSString *)iuID;
- (void)setIUStyle:(NSString *)cssText withID:(NSString *)iuID size:(NSInteger)size;

//set html
- (void)setIUInnerHTML:(NSString *)HTML withParentID:(NSString *)parentID tag:(NSString *)tag;
- (void)removeIU:(NSString *)iuID;

- (void)updateFrameDictionary:(NSMutableDictionary *)dict;

@end
