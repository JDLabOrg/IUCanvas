//
//  SizeView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 4. 1..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "SizeView.h"
#import "JDUIUtil.h"
#import "CanvasWindow.h"

@implementation SizeTextField : NSTextField
- (id)init{
    self = [super init];
    if (self){
        [self setBezeled:NO];
        [self setDrawsBackground:NO];
        [self setEditable:NO];
        [self setSelectable:NO];
        [self setAlignment:NSCenterTextAlignment];
    }
    return self;
}


- (NSView *)hitTest:(NSPoint)aPoint{
    return nil;
}

@end


@implementation SizeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //textField
        sizeTextField = [[SizeTextField alloc] init];
       
        //sizeBox
        sizeArray = [NSMutableArray array];
        boxManageView = [[NSView alloc] init];
        selectIndex = 0;
        [self addSubviewVeriticalCenterInFrameWithFrame:sizeTextField height:sizeTextField.attributedStringValue.size.height];
        [self addSubviewFullFrame:boxManageView positioned:NSWindowBelow relativeTo:sizeTextField];
        
        //defaultFrame
        [self addFrame:960];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSArray *)sortedArray{
    return [sizeArray sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark -
#pragma mark select
- (void)selectBox:(InnerSizeBox *)selectBox{
    InnerSizeBox *deselectBox = [boxManageView.subviews objectAtIndex:selectIndex];
    [deselectBox deselect];
    selectIndex = [boxManageView.subviews indexOfObject:selectBox];
    
    [sizeTextField setStringValue:[NSString stringWithFormat:@"%.0f", selectBox.frame.size.width]];
    [((CanvasWindow *)[self window]) setWidthOfMainView:selectBox.frame.size.width];
}

#pragma mark -
#pragma mark add, remove width

- (void)addFrame:(NSInteger)width{
    NSNumber *widthNumber = [NSNumber numberWithInteger:width];
    [sizeArray addObject:widthNumber];
    NSRect boxFrame = NSMakeRect(0, 0, width, self.frame.size.height);
    InnerSizeBox *newBox = [[InnerSizeBox alloc] initWithFrame:boxFrame];
    newBox.boxDelegate = self;
    NSInteger index = [[self sortedArray] indexOfObject:widthNumber];
    
    //TODO: make layout, 한가운데 constraint
    if(index > 0){
        NSView *preView = boxManageView.subviews[index-1];
        [boxManageView addSubviewMiddleInFrameWithFrame:newBox positioned:NSWindowBelow relativeTo:preView];
    }
    else if(boxManageView.subviews.count == 0){
        [boxManageView addSubviewMiddleInFrameWithFrame:newBox];
    }
    else{
        NSView *firstView = boxManageView.subviews[0];
        [boxManageView addSubviewMiddleInFrameWithFrame:newBox positioned:NSWindowAbove relativeTo:firstView];
    }

}
- (void)removeFrame:(NSInteger)width{
    NSNumber *widthNumber = [NSNumber numberWithInteger:width];
    NSInteger index = [[self sortedArray] indexOfObject:widthNumber];
    
    NSView *removeView = boxManageView.subviews[index];
    [removeView removeFromSuperview];
}

@end
