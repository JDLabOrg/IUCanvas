//
//  TestController.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "TestController.h"

@interface TestController ()

@end

@implementation TestController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)clickCSSBtn:(id)sender {
    if(self.cssSize != nil){
        NSInteger size =[self.cssSize integerValue];
        [((CanvasWindowController *)self.mainWC) setIUStyle:self.cssStr withID:@"test2" size:size];
    }else{
        [((CanvasWindowController *)self.mainWC) setIUStyle:self.cssStr withID:@"test2"];
    }
}

- (IBAction)clickHTMLBtn:(id)sender {
    [((CanvasWindowController *)self.mainWC) setIUInnerHTML:self.htmlStr withParentID:@"test2" tag:@"div"];
}

- (IBAction)clickRemoveHTMLBtn:(id)sender {
    if(self.removeID){
        [((CanvasWindowController *)self.mainWC)  removeIU:self.removeID];
    }
}
@end
