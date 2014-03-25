//
//  AppDelegate.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasWindowController.h"
#import "TestController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property  CanvasWindowController *canvasWC;
@property TestController *testController;


@end
