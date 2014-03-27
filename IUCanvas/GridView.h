//
//  GridView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PointLayer.h"

@interface GridView : NSView{
    CALayer *ghostLayer, *borderManagerLayer, *shadowManagerLayer;
    CALayer *textManageLayer, *pointManagerLayer;
    
    //for dragging - change width, height ofIU
    BOOL isClicked, isDragged;
    NSPoint startPoint;
    PointLayer *selectedPointlayer;
    IUPointLayerPosition selectedPointType;
    
    //for managing cursor
    NSMutableDictionary *cursorDict;
}

- (void)addRedPointLayer:(NSString *)iuID withFrame:(NSRect)frame;
- (void)removeAllRedPointLayer;

- (void)updateLayerRect:(NSMutableDictionary *)frameDict;

- (void)setBorder:(BOOL)border;
- (void)setGhost:(BOOL)ghost;
- (void)setGhostImage:(NSImage *)image;
- (void)setGhostPosition:(NSPoint)position;

@end
