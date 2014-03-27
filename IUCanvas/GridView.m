//
//  GridView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "GridView.h"
#import "PointLayer.h"
#import "BorderLayer.h"
#import "IULog.h"
#import "CursorRect.h"
#import "JDUIUtil.h"


@implementation GridView

- (id)init
{
    self = [super init];
    if (self) {
        [self setLayer:[[CALayer alloc] init]];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [self disableLayerAnimation:self.layer];
        
        //iniialize point Manager
        pointManagerLayer = [CALayer layer];
        pointManagerLayer.contentsGravity = kCAGravityTopLeft;
        
        
        [self disableLayerAnimation:pointManagerLayer];
        [self.layer addSubLayerFullFrame:pointManagerLayer];


        //initialize border manager
        borderManagerLayer = [CALayer layer];
        borderManagerLayer.contentsGravity = kCAGravityTopLeft;
        
        [self disableLayerAnimation:borderManagerLayer];
        [self.layer insertSubLayerFullFrame:borderManagerLayer below:pointManagerLayer];
        
        //initialize ghost Layer
        ghostLayer = [CALayer layer];
        ghostLayer.contentsGravity = kCAGravityTopLeft;
        [ghostLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [ghostLayer setOpacity:0.3];
        [self disableLayerAnimation:ghostLayer];
        [self.layer insertSubLayerFullFrame:ghostLayer below:borderManagerLayer];
        
    }
    return self;
}


- (BOOL)isFlipped{
    return YES;
}

- (void)disableLayerAnimation:(CALayer *)layer{
    /*disable animation*/
    /*sublayer disable animation*/
    NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [NSNull null], @"position",
                                       [NSNull null], @"bounds",
                                       [NSNull null], @"sublayers",
                                       [NSNull null], @"contents",
                                       nil];
    layer.actions = newActions;
}

- (void)viewDidChangeBackingProperties{
    [super viewDidChangeBackingProperties];
    [[self layer] setContentsScale:[[self window] backingScaleFactor]];
}

#pragma mark -
#pragma mark mouse operation

- (NSView *)hitTest:(NSPoint)aPoint{
    NSPoint convertedPoint = [self convertPoint:aPoint fromView:self.superview];
    CALayer *hitLayer = [self hitTestInnerPointLayer:convertedPoint];
    if( hitLayer ){
        return self;
    }
    return nil;
}

- (InnerPointLayer *)hitTestInnerPointLayer:(NSPoint)aPoint{
    CALayer *hitLayer = [self.layer hitTest:aPoint];
    if([hitLayer isKindOfClass:[InnerPointLayer class]]){
        return (InnerPointLayer *)hitLayer;
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)theEvent{
    isClicked = YES;
    NSPoint convertedPoint = [self convertPoint:[theEvent locationInWindow] fromView:self.superview];
    InnerPointLayer *hitPointLayer = [self hitTestInnerPointLayer:convertedPoint];
    selectedPointlayer = (PointLayer *)hitPointLayer.superlayer;
    selectedPointType = [hitPointLayer type];

    startPoint = convertedPoint;
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if(isClicked){
        isDragged = YES;
        NSPoint convertedPoint = [self convertPoint:[theEvent locationInWindow] fromView:self.superview];
        NSPoint diffPoint = NSMakePoint(convertedPoint.x-startPoint.x, convertedPoint.y-startPoint.y);
        startPoint = convertedPoint;
        
        NSRect newframe = [selectedPointlayer makeNewFrameWithType:selectedPointType withDiffPoint:diffPoint];
        //FIXME: temporarly 연결되면 updated frame으로 webkit에서 받아서 사용함
        //테스트용도로 우선 업데이트함
        [selectedPointlayer updateFrame:newframe];
        //reset cursor
        [[self window] invalidateCursorRectsForView:self];


        //TODO: send diffPoint to selctedIUs
    }
}

- (void)mouseUp:(NSEvent *)theEvent{
    if(isClicked){
        isClicked = NO;
    }
    if(isDragged){
        isDragged = NO;
    }
}

- (void)resetCursorRects{
    [self discardCursorRects];
    NSMutableArray *cursorArray = [NSMutableArray array];
    
    for(PointLayer *pLayer in pointManagerLayer.sublayers){
        [cursorArray addObjectsFromArray:[pLayer cursorArray]];
    }
    
    for(CursorRect *aCursor in cursorArray){
        [self addCursorRect:aCursor.frame cursor:aCursor.cursor];
    }
    
}

#pragma mark -
#pragma mark selectIU

- (void)removeAllRedPointLayer{
    //delete current layer
    for(CALayer *layer in pointManagerLayer.sublayers){
        [layer removeFromSuperlayer];
    }
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];
    
}

- (void)addRedPointLayer:(NSString *)iuID withFrame:(NSRect)frame{
    PointLayer *pointLayer = [[PointLayer alloc] initWithIUID:iuID withFrame:frame];
    [pointManagerLayer addSubLayerFullFrame:pointLayer];
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];
    
}

//dict[IUID] = frame
- (void)makeRedPointLayer:(NSDictionary *)selectedIUDict{
    
    [self removeAllRedPointLayer];
   
    NSArray *keys = [selectedIUDict allKeys];
    //add new selected layer
    for(NSString *iuID in keys){
        NSRect frame = [[selectedIUDict objectForKey:iuID] rectValue];
        [self addRedPointLayer:iuID withFrame:frame];
    }
    
}


- (void)updateLayerRect:(NSMutableDictionary *)frameDict{
    //framedict가 update될때마다 호출

    //pointLayer
    for(PointLayer *pLayer in pointManagerLayer.sublayers){
        NSRect currentRect = [[frameDict objectForKey:pLayer.iuID] rectValue];
        [pLayer updateFrame:currentRect];
    }
    
    //updated bound layer if already have
    NSMutableDictionary *borderDict = [frameDict mutableCopy];
    for(BorderLayer *bLayer in borderManagerLayer.sublayers){
        NSString *iuID = bLayer.iuID;
        NSRect currentRect =[[borderDict objectForKey:iuID] rectValue];
        [bLayer setFrame:currentRect];
        [borderDict removeObjectForKey:iuID];
    }
    //make new bound layer if doesn't have
    NSArray *remainingBorderKeys = [borderDict allKeys];
    for(NSString *key in remainingBorderKeys){
        NSRect currentRect =[[borderDict objectForKey:key] rectValue];
        BorderLayer *newBLayer = [[BorderLayer alloc] initWithIUID:key withFrame:currentRect];
        [borderManagerLayer addSublayer:newBLayer];
    }
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];

}

#pragma mark -
#pragma mark ghostImage, border
- (void)setBorder:(BOOL)border{
    [borderManagerLayer setHidden:!border];
}
- (void)setGhost:(BOOL)ghost{
    [ghostLayer setHidden:!ghost];
}
- (void)setGhostImage:(NSImage *)image{
    [ghostLayer setContents:image];
}
- (void)setGhostPosition:(NSPoint)position{
    [ghostLayer setPosition:position];
}
@end
