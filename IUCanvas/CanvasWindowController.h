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

#pragma mark -
#pragma mark be set by IU

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

//border, ghost view
- (void)setBorder:(BOOL)border;
- (void)setGhost:(BOOL)ghost;
- (void)setGhostImage:(NSImage *)ghostImage;
- (void)setGhostPosition:(NSPoint)position;

#pragma mark -
#pragma mark setIU
//TODO: connect to IU - set value to IU
- (void)updateFrameDictionary:(NSMutableDictionary *)updateDict;
- (void)updateHTMLText:(NSString *)insertText atIU:(NSString *)iuID;



@end
