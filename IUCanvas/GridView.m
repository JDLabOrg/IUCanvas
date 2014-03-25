//
//  GridView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "GridView.h"

@implementation GridView

- (id)init
{
    self = [super init];
    if (self) {
        [self setLayer:[[CALayer alloc] init]];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}


#pragma mark -
#pragma mark mouse operation

- (NSView *)hitTest:(NSPoint)aPoint{
    
    CALayer *currentLayer =  [self.layer hitTest:aPoint];
    if( [pointManagerLayer.sublayers containsObject:currentLayer] ){
        return self;
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)theEvent{
    isClicked = YES;
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if(isClicked){
        
    }
}

- (void)mouseUp:(NSEvent *)theEvent{
    if(isClicked){
        isClicked = NO;
    }
}

#pragma mark -
#pragma mark selectIU
- (void)selectIU:(NSString *)


@end
