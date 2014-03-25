//
//  CanvasWindow.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WebCanvasView.h"
#import "GridView.h"

@interface CanvasWindow : NSWindow{
    BOOL isSelected, isDragged;
    NSPoint startDragPoint, endDragPoint;
}

@property WebCanvasView *webView;
@property GridView *gridView;

@property NSMutableDictionary *frameDict;

@end
