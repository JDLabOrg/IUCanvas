//
//  borderLayer.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 26..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "BorderLayer.h"

@implementation BorderLayer

- (id)initWithIUID:(NSString *)aIUID withFrame:(NSRect)frame{
    self = [super init];
    if(self){
        IUID = aIUID;

        [self setFrame:frame];
        
        [self setBorderColor:[[NSColor gridColor] CGColor]];
        [self setBorderWidth:3.0f];
        
        /*disable animation*/
        /*sublayer disable animation*/
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNull null], @"position",
                                           [NSNull null], @"bounds",
                                           nil];
        self.actions = newActions;
        
    }
    return self;
}

- (NSString *)iuID{
    return IUID;
}

@end
