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

@implementation WebCanvasView

- (id)init{
    
    self = [super init];
    if(self){
        //connect delegate
        [self setUIDelegate:self];
        [self setResourceLoadDelegate:self];
        [self setEditingDelegate:self];
        [self setFrameLoadDelegate:self];
    }
    
    return self;
    
}

#pragma mark -
#pragma mark mouse operation

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    //make new IU;
    return [super draggingEntered:sender];
}

- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation modifierFlags:(NSUInteger)modifierFlags{
    //whem mouse move, save current element!
    currentNode = [elementInformation objectForKey:WebElementDOMNodeKey];
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
    [((CanvasWindowController *)(self.window.delegate)) updateFrameDictionary:[self convertWebScriptObjectToNSDictionary:scriptObj]];
    IULog(@"reportSharedFrameDict");
}


#pragma mark -
#pragma mark text

//TODO: insert text => iu 에 현재 text information (text) html을 돌려줄것.
- (BOOL)webView:(WebView *)webView shouldInsertText:(NSString *)text replacingDOMRange:(DOMRange *)range givenAction:(WebViewInsertAction)action{
    
    NSLog(@"insert Text : %@", text);
    
    return YES;
}

- (void)webViewDidEndEditing:(NSNotification *)notification{
    
}

- (void)webViewDidChange:(NSNotification *)notification{
    NSLog(@"didChangeNotification");
}

#pragma mark -
#pragma mark manage IU
- (NSString *)IDOfCurrentIU{
    if( [currentNode isKindOfClass:[DOMHTMLElement class]] ){
        return [currentNode idName];
    }
    return nil;
}


#pragma mark -
#pragma mark manage CSS


#pragma mark -
#pragma mark manage HTML

@end
