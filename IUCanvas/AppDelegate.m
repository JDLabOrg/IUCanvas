//
//  AppDelegate.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "AppDelegate.h"
#import "JDUIUtil.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
 
    
    self.canvasWC = [[CanvasWindowController alloc] initWithWindowNibName:@"CanvasWindowController"];
    NSString *htmlPath = @"/Users/choiseungmi/dev/IUCanvas/htdocs/test.html";
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    NSURL *url = [NSURL fileURLWithPath:@"/Users/choiseungmi/dev/IUCanvas/htdocs/"];
    [self.canvasWC loadHTMLString:html baseURL:url];
    
    
    [self.canvasWC addFrame:800];
    [self.canvasWC addFrame:400];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
#pragma mark -
#pragma mark canvas test
#if 0
    self.testController = [[TestController alloc] initWithWindowNibName:@"TestController"];
    self.testController.mainWC = self.canvasWC;
    [self.testController showWindow:nil];
    [self.canvasWC addSelectedIU:@"test"];
#endif
//    [self.canvasWC loadRequest:[NSURLRequest requestWithURL:
//                            [NSURL fileURLWithPath:
//                           [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"]]]];

}

@end
