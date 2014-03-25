//
//  GridView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GridView : NSView{
    CALayer *ghostLayer, *borderManagerLayer, *shadowManagerLayer;
    CALayer *textManageLayer, *pointManagerLayer;
    
    BOOL isClicked;
    
}


@end
