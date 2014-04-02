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
#import "PointTextLayer.h"
#import "CanvasWindowController.h"


@implementation GridView

- (id)init
{
    self = [super init];
    if (self) {
        [self setLayer:[[CALayer alloc] init]];
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [self.layer disableAction];

        
        //iniialize point Manager
        pointManagerLayer = [CALayer layer];
        [pointManagerLayer disableAction];
        [self.layer addSubLayerFullFrame:pointManagerLayer];

        
        //initialize textPoint Manager
        textManageLayer = [CALayer layer];
        [textManageLayer disableAction];
        [self.layer insertSubLayerFullFrame:textManageLayer below:pointManagerLayer];
        
        //initialize border manager
        borderManagerLayer = [CALayer layer];
        [borderManagerLayer disableAction];
        [borderManagerLayer setHidden:YES];
        [self.layer insertSubLayerFullFrame:borderManagerLayer below:textManageLayer];
        
        //initialize ghost Layer
        ghostLayer = [CALayer layer];
        [ghostLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [ghostLayer setOpacity:0.3];
        [ghostLayer disableAction];
        [self.layer insertSubLayerFullFrame:ghostLayer below:borderManagerLayer];
        
        //initialize selection Layer
        selectionLayer = [CALayer layer];
        [selectionLayer setBackgroundColor:[[NSColor clearColor] CGColor]];
        [selectionLayer setBorderColor:[[NSColor gridColor] CGColor]];
        [selectionLayer setBorderWidth:1.0];
        [selectionLayer disableAction];
        [self.layer insertSublayer:selectionLayer below:pointManagerLayer];
        
        //initialize guideline layer;
        guideLayer = [[GuideLineLayer alloc] init];
        [self.layer insertSubLayerFullFrame:guideLayer below:pointManagerLayer];
        
    }
    return self;
}


- (BOOL)isFlipped{
    return YES;
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
    NSPoint convertedPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    InnerPointLayer *hitPointLayer = [self hitTestInnerPointLayer:convertedPoint];
    selectedPointlayer = (PointLayer *)hitPointLayer.superlayer;
    selectedPointType = [hitPointLayer type];

    startPoint = convertedPoint;
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if(isClicked){
        isDragged = YES;
        NSPoint convertedPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSPoint diffPoint = NSMakePoint(convertedPoint.x-startPoint.x, convertedPoint.y-startPoint.y);
        startPoint = convertedPoint;
        
        NSRect newframe = [selectedPointlayer makeNewFrameWithType:selectedPointType withDiffPoint:diffPoint];
        [((CanvasWindowController *)(self.window.delegate)) changeIUFrame:newframe IUID:selectedPointlayer.iuID];

        //FIXME: temporarly 연결되면 updated frame으로 webkit에서 받아서 사용함
        //테스트용도로 우선 업데이트함-나중에 지울것
        //updateFrame은 무조건 dict에서 오는것으로만함!
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

- (void)updateLayerRect:(NSMutableDictionary *)frameDict{
    //framedict가 update될때마다 호출
    
    //pointLayer
    for(PointLayer *pLayer in pointManagerLayer.sublayers){
        NSValue *value = [frameDict objectForKey:pLayer.iuID];
        if(value){
            NSRect currentRect = [value rectValue];
            [pLayer updateFrame:currentRect];
        }
    }
    
    //textLayer update
    for(PointTextLayer *tLayer in textManageLayer.sublayers){
        NSValue *value = [frameDict objectForKey:tLayer.iuID];
        if(value){
            NSRect currentRect = [value rectValue];
            [tLayer updateFrame:currentRect];
        }
    }
    
    //-----------------bound layer---------------------------
    //updated bound layer if already have
    NSMutableDictionary *borderDict = [frameDict mutableCopy];
    for(BorderLayer *bLayer in borderManagerLayer.sublayers){
        NSString *iuID = bLayer.iuID;
        NSValue *value = [borderDict objectForKey:iuID];
        if(value){
            NSRect currentRect =[value rectValue];
            [bLayer setFrame:currentRect];
        }
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

#pragma mark red Point layer

- (void)addRedPointLayer:(NSString *)iuID withFrame:(NSRect)frame{
    PointLayer *pointLayer = [[PointLayer alloc] initWithIUID:iuID withFrame:frame];
    [pointManagerLayer addSubLayerFullFrame:pointLayer];
    
    //reset cursor
    [[self window] invalidateCursorRectsForView:self];
    
}

- (void)removeAllRedPointLayer{
    //delete current layer
    NSArray *pointLayers = [NSArray arrayWithArray:pointManagerLayer.sublayers];

    for(CALayer *layer in pointLayers){
        [layer removeFromSuperlayer];
    }
    
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

#pragma mark text layer

- (void)addTextPointLayer:(NSString *)iuID withFrame:(NSRect)frame{
    PointTextLayer *textOriginLayer = [[PointTextLayer alloc] initWithIUID:iuID withFrame:frame type:PointTextTypeOrigin];
    PointTextLayer *textSizeLayer = [[PointTextLayer alloc] initWithIUID:iuID withFrame:frame type:PointTextTypeSize];
    
    [textManageLayer addSublayer:textOriginLayer];
    [textManageLayer addSublayer:textSizeLayer];

}

- (void)removeAllTextPointLayer{
    //delete current layer
    NSArray *textLayers = [NSArray arrayWithArray:textManageLayer.sublayers];
    for(CALayer *layer in textLayers){
        [layer removeFromSuperlayer];
    }
    
}

#pragma mark selection layer
-(void)drawSelectionLayer:(NSRect)frame{
    [selectionLayer setHidden:NO];
    [selectionLayer setFrame:frame];
}

- (void)resetSelectionLayer{
    [selectionLayer setHidden:YES];
    [selectionLayer setFrame:NSZeroRect];
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

#pragma mark -
#pragma mark guideLine layer

- (void)drawGuideLine:(NSArray *)array{
    [guideLayer drawLine:array];
}

- (void)clearGuideLine{
    [guideLayer clearPath];
}
@end
