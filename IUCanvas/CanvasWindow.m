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
#import "IUDefinition.h"

@implementation CanvasWindow

- (void)awakeFromNib{
    self.webView = [[WebCanvasView alloc] init];
    self.gridView = [[GridView alloc] init];
    
    
    [self.mainView addSubviewFullFrame:self.webView];
    [self.mainView addSubviewFullFrame:self.gridView];
    
    [self setWidthOfMainView:defaultFrameWidth];
}

- (void)setWidthOfMainView:(CGFloat)width{
    [self.mainView setWidth:width];
    CGFloat x = ([[self contentView] frame].size.width - width)/2;
    [self.mainView setX:x];
}


#pragma mark -
#pragma mark mouse

- (BOOL)canAddIU:(NSString *)IUID{
    if(IUID != nil){
        if( [((CanvasWindowController *)self.delegate) containsIU:IUID] == NO ){
            return YES;
        }
    }
    return NO;
}

- (BOOL)canRemoveIU:(NSEvent *)theEvent IUID:(NSString *)IUID{
    
    if( ( [theEvent modifierFlags] & NSCommandKeyMask )){
        return NO;
    }
    
    if( [((CanvasWindowController *)self.delegate) containsIU:IUID] == YES ){
        return NO;
    }
    return YES;
}

-  (BOOL)pointInMainView:(NSPoint)point{
    if (point.x <0 || point.y < 0){
        return NO;
    }
    
    return YES;
}

-(void)sendEvent:(NSEvent *)theEvent{
    
    NSPoint originalPoint = [theEvent locationInWindow];
    NSView *hitView = [self.gridView hitTest:originalPoint];
    NSPoint convertedPoint = [self.gridView convertPoint:originalPoint fromView:nil];
    
    if([hitView isKindOfClass:[GridView class]] == NO){
        
        if( [self pointInMainView:convertedPoint]){
            
            if ( theEvent.type == NSLeftMouseDown){
                IULog(@"mouse down");
                NSString *currentIUID = [self.webView IDOfCurrentIU];
                
                if (theEvent.clickCount == 1){
                    
                    
                    if( [self canRemoveIU:theEvent IUID:currentIUID] ){
                        [((CanvasWindowController *)self.delegate) removeSelectedAllIUs];
                        
                    }
                    
                    if([self canAddIU:currentIUID]){
                        [((CanvasWindowController *)self.delegate) addSelectedIU:currentIUID];
                    }
                    
                    if([self.webView isDOMTextAtPoint:convertedPoint] == NO){
                        isSelected = YES;
                    }
                    startDragPoint = convertedPoint;
                    middleDragPoint = startDragPoint;
                }
            }
            else if (theEvent.type == NSLeftMouseDragged ){
                IULog(@"mouse dragged");
                endDragPoint = convertedPoint;
                
                //draw select rect
                if([theEvent modifierFlags] & NSCommandKeyMask ){
                    isSelectDragged = YES;
                    isSelected = NO;
                    
                    NSSize size = NSMakeSize(endDragPoint.x-startDragPoint.x, endDragPoint.y-startDragPoint.y);
                    NSRect selectFrame = NSMakeRect(startDragPoint.x, startDragPoint.y, size.width, size.height);
                    
                    [self.gridView drawSelectionLayer:selectFrame];
                    [((CanvasWindowController *)self.delegate) selectIUInRect:selectFrame];
                    
                }
                if(isSelected){
                    isDragged = YES;
                    NSPoint diffPoint = NSMakePoint(endDragPoint.x - middleDragPoint.x, endDragPoint.y - middleDragPoint.y);
                    [((CanvasWindowController *)self.delegate) moveDiffPoint:diffPoint];
                }
                
                
                middleDragPoint = endDragPoint;
            }
        }
        
        
        if ( theEvent.type == NSLeftMouseUp ){
            //        IULog(@"NSLeftMouseUp");
            
            if(isSelected){
                isSelected = NO;
                [self.gridView clearGuideLine];
            }
            if(isDragged){
                isDragged = NO;
                [self.gridView clearGuideLine];
            }
            if(isSelectDragged){
                isSelectDragged = NO;
                [NSCursor pop];
                [self.gridView resetSelectionLayer];
            }
        }
    }
    else {
        IULog(@"gridview select");
    }
    
    [super sendEvent:theEvent];

    
    if(isSelectDragged){
        [[NSCursor crosshairCursor] push];
    }
}

@end
