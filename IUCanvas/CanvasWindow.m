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

-  (BOOL)pointInContentView:(NSPoint)point{
    NSRect originalFrame = [self.contentView frame];
    NSRect contentFrame = NSMakeRect(originalFrame.origin.x+12,
                                     originalFrame.origin.y+12,
                                     originalFrame.size.width-24,
                                     originalFrame.size.height-24);
    
    if(NSPointInRect(point, contentFrame)){
        return YES;
    }
    
    return NO;
}

-(void)sendEvent:(NSEvent *)theEvent{
    
    NSPoint originalPoint = [theEvent locationInWindow];
    NSView *hitView = [self.gridView hitTest:originalPoint];
    NSPoint convertedPoint = [self.gridView convertPoint:originalPoint fromView:nil];
    
    if([hitView isKindOfClass:[GridView class]] == NO){
        
        if( [self pointInContentView:originalPoint]){
            
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
