//
//  CanvasWindow.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "CanvasWindow.h"
#import "CanvasWindowController.h"
#import "JDUIUtil.h"
#import "IULog.h"

@implementation CanvasWindow

- (void)awakeFromNib{
    self.webView = [[WebCanvasView alloc] init];
    self.gridView = [[GridView alloc] init];
    
    [self.contentView addSubviewFullFrame:self.webView];
    [self.contentView addSubviewFullFrame:self.gridView];
}



#pragma mark -
#pragma mark mouse

-(void)sendEvent:(NSEvent *)theEvent{

    if ( theEvent.type == NSLeftMouseDown ){
        if(theEvent.clickCount == 1){
//            IULog(@"NSLeftMouseDown");
            [((CanvasWindowController *)self.delegate) removeSelectedAllIUs];
            
            NSString *currentID = [self.webView IDOfCurrentIU];
            if(currentID){
                [((CanvasWindowController *)self.delegate) addSelectedIU:[self.webView IDOfCurrentIU]];
            }
            
            isSelected = YES;
            startDragPoint = theEvent.locationInWindow;
        }
    }
    
    else if (theEvent.type == NSLeftMouseDragged ){
//        IULog(@"NSLeftMouseDragged");
        if(isSelected){
            isDragged = YES;
        }
    }
    
    else if ( theEvent.type == NSLeftMouseUp ){
//        IULog(@"NSLeftMouseUp");
        
        if(isSelected){
            isSelected = NO;
        }
        if(isDragged){
            isDragged = NO;
            endDragPoint = theEvent.locationInWindow;
            NSPoint diffPoint = NSMakePoint(endDragPoint.x - startDragPoint.x, endDragPoint.y - startDragPoint.y);
            
            //TODO: send diff point to selected IUS;
        }
    }
    
    [super sendEvent:theEvent];
}

@end
