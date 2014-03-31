//
//  IUFrameDictionary.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 31..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "IUFrameDictionary.h"

@implementation PointLine

+(PointLine *)makePointLine:(NSPoint)startPoint endPoint:(NSPoint)endPoint{
    
    PointLine *line = [[PointLine alloc] init];
    line.start = NSMakePoint(round(startPoint.x), round(startPoint.y));
    line.end = NSMakePoint(round(endPoint.x), round(endPoint.y));
    return line;
}


@end

@implementation IUFrameDictionary

- (id)init{
    self = [super init];
    if(self){
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}


- (NSArray *)lineToDrawSamePositionWithIU:(NSString *)IU{
    NSMutableArray *drawArray = [NSMutableArray array];
    
    //1. find v center of page
    //2. find h center of page
    
    
    //3. top line, 4. hc line, 5. bottom line
    for(int i=IUFrameLineTop; i<=IUFrameLineBottom; i++ ){
        PointLine *line =[self sameHorizontalLine:IU type:(IUFrameLine)i];
        if(line){
            [drawArray addObject:line];
        }
    }
    
    //6. left line, 7. v center line, 8. right line
    for(int i=IUFrameLineLeft; i<=IUFrameLineRight; i++ ){
        PointLine *line =[self sameVerticalLine:IU type:(IUFrameLine)i];
        if(line){
            [drawArray addObject:line];
        }
    }
    
    return drawArray;
}

#pragma mark -
#pragma mark common methods

- (BOOL)isSameFloat:(CGFloat)a b:(CGFloat)b{
    if(abs(a-b) < 0.5){//0.5 pixel 이하면 같은 라인에 있는걸로.
        return YES;
    }
    return NO;
}

- (NSArray *)allKeysExceptKey:(NSString *)key{
    NSMutableArray *allKeys = [[self.dict allKeys] mutableCopy];
    //자기자신 제외
    [allKeys removeObject:key];

    return allKeys;
}



- (CGFloat)floatValue:(NSRect)frame withType:(IUFrameLine)type{
    CGFloat value;
    switch (type) {
        case IUFrameLineTop:
            value = frame.origin.y;
            break;
        case IUFrameLineHorizontalCenter:
            value = frame.origin.y + frame.size.height/2;
            break;
        case IUFrameLineBottom:
            value = frame.origin.y + frame.size.height;
            break;
        case IUFrameLineLeft:
            value = frame.origin.x;
            break;
        case IUFrameLineVerticalCenter:
            value = frame.origin.x + frame.size.width/2;
            break;
        case IUFrameLineRight:
            value = frame.origin.x + frame.size.width;
            break;
        default:
            NSLog(@"warning : there is no type");
            break;
    }
    return value;
}


#pragma mark -
#pragma mark find same location

- (PointLine *)sameHorizontalLine:(NSString *)key type:(IUFrameLine)type {
    NSArray *allKeys = [self allKeysExceptKey:key];
    NSRect keyRect = [[self.dict objectForKey:key] rectValue];
    CGFloat minX = keyRect.origin.x;
    CGFloat maxX = keyRect.origin.x+keyRect.size.height;
    CGFloat typeY = [self floatValue:keyRect withType:type];
    BOOL isFind = NO;
    
    for(NSString *compareKey in allKeys){
        
        NSRect frame = [[self.dict objectForKey:compareKey] rectValue];
        CGFloat compareY = [self floatValue:frame withType:type];
        
        if( [self isSameFloat:typeY b:compareY]) {
            isFind = YES;
            
            if(minX > frame.origin.x){
                minX = frame.origin.x;
            }
            if(maxX < frame.origin.x+frame.size.width){
                maxX = frame.origin.x+frame.size.width;
            }

        }
        
    }
    
    if(isFind){
        NSPoint startPoint = NSMakePoint(minX, typeY);
        NSPoint endPoint = NSMakePoint(maxX, typeY);
        return [PointLine makePointLine:startPoint endPoint:endPoint];
        
    }
    else {
        return nil;
    }
}

- (PointLine *)sameVerticalLine:(NSString *)key type:(IUFrameLine)type {
    NSArray *allKeys = [self allKeysExceptKey:key];
    NSRect keyRect = [[self.dict objectForKey:key] rectValue];
    CGFloat minY = keyRect.origin.y;
    CGFloat maxY = keyRect.origin.y+keyRect.size.height;
    CGFloat typeX = [self floatValue:keyRect withType:type];
    BOOL isFind = NO;

    
    for(NSString *compareKey in allKeys){
        
        NSRect frame = [[self.dict objectForKey:compareKey] rectValue];
        CGFloat compareX = [self floatValue:frame withType:type];
        
        if( [self isSameFloat:typeX b:compareX]) {
            isFind = YES;
            if(minY > frame.origin.y){
                minY = frame.origin.y;
            }
            if(maxY < frame.origin.y+frame.size.height){
                maxY = frame.origin.y+frame.size.height;
            }
        }
        
    }
    
    if(isFind){
        NSPoint startPoint = NSMakePoint(typeX, minY);
        NSPoint endPoint = NSMakePoint(typeX, maxY);
        return [PointLine makePointLine:startPoint endPoint:endPoint];
        
    }
    else {
        return nil;
    }
}

#pragma mark find same size
#if 0
- (NSArray *)sameSize:(NSString *)key type:(IUFrameLine)type{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *allKeys = [self allKeysExceptKey:key];
    NSRect keyRect = [[self.dict objectForKey:key] rectValue];
    CGFloat value = [self floatValue:keyRect withType:type];
    
    for(NSString *compareKey in allKeys){
        
        NSRect frame = [[self.dict objectForKey:compareKey] rectValue];
        CGFloat compareValue = [self floatValue:frame withType:type];
        
        if( [self isSameFloat:value b:compareValue]) {
            NSPoint startPoint = NSMakePoint(frame.origin.x, frame.origin.y);
            NSPoint endPoint;
            if(type == IUFrameLineWidth){
                endPoint = NSMakePoint(frame.origin.x+frame.size.width, frame.origin.y);
            }
            
            else if(type == IUFrameLineHeight){
                endPoint = NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height);
            }
            
            PointLine *line = [PointLine makePointLine:startPoint endPoint:endPoint];
            [array addObject:line];

        }
        
    }
    return array;
}
#endif



@end
