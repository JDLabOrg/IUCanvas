//
//  CanvasWebView.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 21..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "WebCanvasView.h"
#import "CanvasWindowController.h"
#import "IULog.h"
#import "IUDefinition.h"

@implementation WebCanvasView

- (id)init{
    
    self = [super init];
    if(self){
        //connect delegate
        [self setUIDelegate:self];
        [self setResourceLoadDelegate:self];
        [self setEditingDelegate:self];
        [self setFrameLoadDelegate:self];
        [self setEditable:YES];
        
        //FIXME: IUTYPE
        [self registerForDraggedTypes:@[(id)kUTTypeIUType, NSStringPboardType]];
    }
    
    return self;
    
}

- (BOOL)isFlipped{
    return YES;
}

#pragma mark -
#pragma mark mouse operation

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    return NSDragOperationEvery;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    //make new IU
    NSPasteboard *pBoard = sender.draggingPasteboard;
    NSPoint dragPoint = sender.draggingLocation;
    NSString *iuName = [pBoard stringForType:(id)kUTTypeIUType];
    NSString *parentIUName = [self IUAtPoint:dragPoint];
    if(iuName){
        [((CanvasWindowController *)(self.window.delegate)) makeNewIU:iuName atPoint:dragPoint atIU:parentIUName];
        return YES;
    }
    

    IULog(@"[IU:%@], dragPoint(%.1f, %.1f)", iuName, dragPoint.x, dragPoint.y);

    return NO;
}


- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(NSUInteger)modifierFlags{
    //whem mouse move, save current element!
    currentNode = [elementInformation objectForKey:WebElementDOMNodeKey];
    
    if([currentNode isKindOfClass:[DOMText class]]){
        currentNode = [self textParentIUElement:currentNode];
    }
    
    if(currentNode.idName){
//        IULog(@"%@", currentNode.idName);
    }
}

- (NSString *)IUAtPoint:(NSPoint)point{
    DOMHTMLElement *htmlElement = (DOMHTMLElement *)[self DOMElementAtPoint:point];

    if([htmlElement isKindOfClass:[DOMText class]]){
        htmlElement = [self textParentIUElement:htmlElement];
    }
    
    return [self IUNameOfDomElement:htmlElement];
}

#pragma mark -
#pragma mark Javascript with WebView
- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame{
    [windowObject setValue:self forKey:@"console"];
}


+ (NSString *)webScriptNameForSelector:(SEL)selector{
    if (selector == @selector(doOutputToLog:)){
        return @"log";
    }
    else if(selector == @selector(reportFrameDict:)){
        return @"reportFrameDict";
    }
    else{
        return nil;
    }
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
    if (selector == @selector(reportFrameDict:)
        || selector == @selector(doOutputToLog:)
        ){
        return NO;
    }
    return YES;
}


/* Here is our Objective-C implementation for the JavaScript console.log() method.
 */
- (void)doOutputToLog:(NSString*)theMessage {
    
    NSLog(@"LOG: %@", theMessage);
    
}


#pragma mark -
#pragma mark scriptObject



- (NSArray*) convertWebScriptObjectToNSArray:(WebScriptObject*)webScriptObject
{
    // Assumption: webScriptObject has already been tested using isArray:
    
    NSUInteger count = [[webScriptObject valueForKey:@"length"] integerValue];
    NSMutableArray *a = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        id item = [webScriptObject webScriptValueAtIndex:i];
        if ([item isKindOfClass:[WebScriptObject class]]) {
            [a addObject:[self convertWebScriptObjectToNSDictionary:item]];
        } else {
            [a addObject:item];
        }
    }
    
    return a;
}

- (NSMutableDictionary*) convertWebScriptObjectToNSDictionary:(WebScriptObject*)webScriptObject
{
    WebScriptObject* keysObject = [[self windowScriptObject] callWebScriptMethod:@"getDictionaryKeys" withArguments:[NSArray arrayWithObject:webScriptObject]];
    NSArray* keys = [self convertWebScriptObjectToNSArray:keysObject];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
    
    NSEnumerator* enumerator = [keys objectEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        id value = [webScriptObject valueForKey:key];
        
        if([value isKindOfClass:[WebScriptObject class]]){
            [dict setObject:[self convertWebScriptObjectToNSDictionary:value] forKey:key];
        }
        else{
            [dict setObject:value forKey:key];
        }
    }
    
    return dict;
}



#pragma mark -
#pragma mark IUFrame


- (void)reportFrameDict:(WebScriptObject *)scriptObj{
    NSMutableDictionary *scriptDict = [self convertWebScriptObjectToNSDictionary:scriptObj];
    NSMutableDictionary *iuFrameDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *gridFrameDict = [NSMutableDictionary dictionary];
    
    NSArray *keys = [scriptDict allKeys];
    for(NSString *key in keys){
        NSDictionary *innerDict = [scriptDict objectForKey:key];
        
        CGFloat left = [[innerDict objectForKey:@"left"] floatValue];
        CGFloat top = [[innerDict objectForKey:@"top"] floatValue];
        CGFloat x = [[innerDict objectForKey:@"x"] floatValue];
        CGFloat y = [[innerDict objectForKey:@"y"] floatValue];
        CGFloat w = [[innerDict objectForKey:@"width"] floatValue];
        CGFloat h = [[innerDict objectForKey:@"height"] floatValue];
        
        NSRect iuFrame = NSMakeRect(left, top, w, h);
        [iuFrameDict setObject:[NSValue valueWithRect:iuFrame] forKey:key];
        NSRect gridFrame = NSMakeRect(x, y, w, h);
        [gridFrameDict setObject:[NSValue valueWithRect:gridFrame] forKey:key];
    }
    
    
    [((CanvasWindowController *)(self.window.delegate)) updateIUFrameDictionary:iuFrameDict];
    [((CanvasWindowController *)(self.window.delegate)) updateGridFrameDictionary:gridFrameDict];
    IULog(@"reportSharedFrameDict");
}

- (void)updateFrameDict{
    //reportFrameDict(after call setIUCSSStyle)
    [self stringByEvaluatingJavaScriptFromString:@"getIUUpdatedFrameThread()"];
}


#pragma mark -
#pragma mark text

- (DOMHTMLElement *)textParentIUElement:(DOMNode *)node{
    NSString *iuName = [((DOMElement *)node.parentNode) getAttribute:@"iuname"];
    if(iuName && iuName.length != 0){
        return (DOMHTMLElement *)node.parentNode;
    }
    else if ([node.parentNode isKindOfClass:[DOMHTMLHtmlElement class]] ){
        //can't find div node
        //- it can't be in IU model
        //- IU model : text always have to be in Div class
        //reach to html
        assert(1);
        return nil;
    }
    else {
        return [self textParentIUElement:node.parentNode];
    }
}

- (BOOL)webView:(WebView *)webView shouldInsertText:(NSString *)text replacingDOMRange:(DOMRange *)range givenAction:(WebViewInsertAction)action{
    
    DOMNode *node = range.startContainer;
    BOOL isWritable =  NO;
    
    //check to insert Text
    if([node isKindOfClass:[DOMText class] ]){
        isWritable = YES;
    }
    else {
        if([node isNotEqualTo:currentNode]){
            return NO;
        }
        NSString *writableValue = [((DOMElement *)node) getAttribute:@"isWritable"];
        if(writableValue){
            isWritable = [writableValue boolValue];
        }
    }

    //insert Text
    if (isWritable){
        NSLog(@"insert Text : %@", text);
        DOMHTMLElement *insertedTextNode = [self textParentIUElement:node];
        
        if(insertedTextNode != nil){
            [((CanvasWindowController *)(self.window.delegate)) updateHTMLText:insertedTextNode.innerHTML atIU:insertedTextNode.idName];
            return YES;
        }
    }
    return NO;
}
- (BOOL)webView:(WebView *)webView shouldApplyStyle:(DOMCSSStyleDeclaration *)style toElementsInDOMRange:(DOMRange *)range{
    
    
    NSLog(@"insert CSS : %@", style.cssText);
    DOMHTMLElement *insertedTextNode = [self textParentIUElement:range.startContainer];
    
    if(insertedTextNode != nil){
        [((CanvasWindowController *)(self.window.delegate)) updateHTMLText:insertedTextNode.innerHTML atIU:insertedTextNode.idName];
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark -
#pragma mark manage IU

- (NSString *)IUNameOfDomElement:(DOMElement *)element{
    NSString *iuName = [element getAttribute:@"iuname"];
    return iuName;
}
- (NSString *)IDOfCurrentIU{
    if( [currentNode isKindOfClass:[DOMHTMLElement class]] ){
        return [currentNode idName];
    }
    return nil;
}

- (DOMElement *)DOMElementAtPoint:(NSPoint)point{
    NSDictionary *dict  =[self elementAtPoint:point];
    DOMElement *element = [dict objectForKey:WebElementDOMNodeKey];
    return element;
}

- (BOOL)isDOMTextAtPoint:(NSPoint)point{
    DOMElement *element = [self DOMElementAtPoint:point];
    if([element isKindOfClass:[DOMText class]]){
        return YES;
    }
    return NO;
}


@end
