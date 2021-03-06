//
//  TestController.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasWindowController.h"

@interface TestView: NSView
@property (weak) IBOutlet NSImageView *imageV;

- (IBAction)clickDragBtn:(id)sender;
@end

@interface TestController : NSWindowController

@property id mainWC;

@property NSString *cssStr, *cssSize;
@property NSString *htmlStr;
@property NSString *removeID;
@property NSString *dragName;

- (IBAction)clickCSSBtn:(id)sender;
- (IBAction)clickHTMLBtn:(id)sender;
- (IBAction)clickRemoveHTMLBtn:(id)sender;


@end
