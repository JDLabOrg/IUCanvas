//
//  CanvasWebView.h
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebCanvasView : WebView {
    DOMHTMLElement *currentNode;
}

- (NSString *)IDOfCurrentIU;
- (void)updateFrameDict;

@end
