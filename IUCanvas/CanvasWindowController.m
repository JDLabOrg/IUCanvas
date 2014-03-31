//
//  CanvasWindowController.m
//  IUCanvas
//
//  Created by ChoiSeungmi on 2014. 3. 24..
//  Copyright (c) 2014년 ChoiSeungmi. All rights reserved.
//

#import "CanvasWindowController.h"
#import "CanvasWindow.h"
#import "IULog.h"

@interface CanvasWindowController (){
}

@end

@implementation CanvasWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        frameDict = [NSMutableDictionary dictionary];
        selectedIUs = [NSMutableArray array];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}


#pragma mark -
#pragma mark webView
- (WebCanvasView *)webView{
    return ((CanvasWindow *)self.window).webView;
}

- (DOMDocument *)DOMDoc{
  return [[[self webView] mainFrame] DOMDocument];
}

- (void)loadRequest:(NSURLRequest *)request{
    [[((CanvasWindow *)self.window).webView mainFrame] loadRequest:request];
}

- (void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)URL{
    [[((CanvasWindow *)self.window).webView mainFrame] loadHTMLString:htmlString baseURL:URL];
}

#pragma mark -
#pragma mark manage IUs
- (BOOL)containsIU:(NSString *)IU{
    if ([selectedIUs containsObject:IU]){
        return YES;
    }
    else {
        return NO;
    }
}
- (void)removeSelectedAllIUs{
    [selectedIUs removeAllObjects];
    [[self gridView] removeAllRedPointLayer];
    [[self gridView] removeAllTextPointLayer];
}
- (void)addSelectedIU:(NSString *)IU{
    [selectedIUs addObject:IU];
    if([frameDict objectForKey:IU]){
        NSRect frame = [[frameDict objectForKey:IU] rectValue];
        [[self gridView] addRedPointLayer:IU withFrame:frame];
        [[self gridView] addTextPointLayer:IU withFrame:frame];
    }
}

- (void)selectIUInRect:(NSRect)frame{
    NSArray *keys = [frameDict allKeys];
    
    [self removeSelectedAllIUs];
    
    for(NSString *key in keys){
        NSRect iuframe = [[frameDict objectForKey:key] rectValue];
        if( NSIntersectsRect(iuframe, frame) ){
            [self addSelectedIU:key];
        }
    }
}

#pragma mark -
#pragma mark HTML

- (DOMHTMLElement *)getHTMLElementbyID:(NSString *)HTMLID{
    DOMHTMLElement *selectNode = (DOMHTMLElement *)[self.DOMDoc getElementById:HTMLID];
    return selectNode;

}

//remake html
- (void)setIUInnerHTML:(NSString *)HTML withParentID:(NSString *)parentID tag:(NSString *)tag{

    DOMHTMLElement *selectHTMLElement = [self getHTMLElementbyID:parentID];
    DOMHTMLElement *newElement = (DOMHTMLElement *)[self.DOMDoc createElement:tag];
    [selectHTMLElement appendChild:newElement];
    selectHTMLElement.innerHTML = HTML;
    
    [self.webView setNeedsDisplay:YES];
}
//remove IU - delete html & css
- (void)removeIU:(NSString *)iuID{
    //remove HTML
    DOMHTMLElement *selectHTMLElement = [self getHTMLElementbyID:iuID];
    DOMElement *parentElement = [selectHTMLElement parentElement];
    [parentElement removeChild:selectHTMLElement];
    
    
    //TODO: remove CSS
    // - 꼭 필요한가??

    
}

#pragma mark -
#pragma mark CSS

- (DOMCSSStyleSheet *)defaultStyleSheet{
    DOMStyleSheetList *list = [[self DOMDoc] styleSheets];
    for(unsigned index =0 ; index < list.length; index++){
        DOMCSSStyleSheet *sheet = (DOMCSSStyleSheet *)[list item:index];
        if(sheet.media.mediaText == nil
           || sheet.media.mediaText.length == 0){
            return sheet;
        }
    }
    return nil;
}

- (DOMCSSStyleSheet *)styleSheetWithSize:(NSInteger)size{
    NSString *sizeStr = [NSString stringWithFormat:@"%ld", size];
    DOMStyleSheetList *list = [[self DOMDoc] styleSheets];
    for(unsigned i =0 ; i < list.length; i++){
        DOMCSSStyleSheet *sheet = (DOMCSSStyleSheet *)[list item:i];
        if([sheet.media.mediaText rangeOfString:sizeStr].length != 0){
            return sheet;
        }
    }

    return nil;
    
}
- (void)makeNewStyleSheet:(NSInteger)size{

    DOMElement *newSheet = [[self DOMDoc] createElement:@"style"];
    NSString *mediaName = [NSString stringWithFormat:@"screen and (max-width:%ldpx)", size];
    [newSheet setAttribute:@"type" value:@"text/css"];
    [newSheet setAttribute:@"media" value:mediaName];
    [newSheet appendChild:[[self DOMDoc] createTextNode:@""]];
    DOMNode *headNode = [[[self DOMDoc] getElementsByTagName:@"head"] item:0];
    [headNode appendChild:newSheet];
}

- (NSInteger)indexOfIDAtStyleSheet:(DOMCSSStyleSheet *)styleSheet withID:(NSString *)iuID{
    DOMCSSRuleList *lists = [styleSheet rules];
    for(unsigned i=0; i<lists.length; i++){
        DOMCSSRule *rule = [lists item:i];

        NSArray *cssArray = [rule.cssText componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#{"]];
        NSString *ruleID = [cssArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([ruleID isEqualToString:iuID]){
            return i;
        }
    }
    return -1;
}

//set default css
- (void)setIUStyle:(NSString *)cssText withID:(NSString *)iuID{
    DOMCSSStyleSheet *currentSheet = [self defaultStyleSheet];
    assert(currentSheet != nil);
    [self setCSSRuleInStyleSheet:currentSheet rule:cssText withID:iuID];
}
//set media query css
- (void)setIUStyle:(NSString *)cssText withID:(NSString *)iuID size:(NSInteger)size{
    DOMCSSStyleSheet *currentSheet = [self styleSheetWithSize:size];
    if(currentSheet == nil){
        [self makeNewStyleSheet:size];
        currentSheet = [self styleSheetWithSize:size];
    }
    
    assert(currentSheet != nil);
    
    [self setCSSRuleInStyleSheet:currentSheet rule:cssText withID:iuID];
    
}

- (void)setCSSRuleInStyleSheet:(DOMCSSStyleSheet *)styleSheet rule:(NSString *)rule withID:(NSString *)iuID{
    NSInteger index = [self indexOfIDAtStyleSheet:styleSheet withID:iuID];
    if(index >= 0){
        //delete rule before change
        [styleSheet deleteRule:(unsigned)index];
    }
    [styleSheet insertRule:rule index:0];
    [[self webView] updateFrameDict];
}

#pragma mark -
#pragma mark GridView
- (GridView *)gridView{
    return ((CanvasWindow *)self.window).gridView;
}


#pragma mark -
#pragma mark border, ghost view
- (void)setBorder:(BOOL)border{
    [[self gridView] setBorder:border];
}
- (void)setGhost:(BOOL)ghost{
    [[self gridView] setGhost:ghost];
}
- (void)setGhostImage:(NSImage *)ghostImage{
    [[self gridView] setGhostImage:ghostImage];
}
- (void)setGhostPosition:(NSPoint)position{
    [[self gridView] setGhostPosition:position];
}

/*
 ******************************************************************************************
 SET IU : View call IU
 ******************************************************************************************
 */
#pragma mark -
#pragma mark setIU

#pragma mark frameDict

- (void)updateIUFrameDictionary:(NSMutableDictionary *)iuFrameDict{
    IULog(@"report updated frame dict");
    
    
    //TODO: updated frame dict to IU
}

- (void)updateGridFrameDictionary:(NSMutableDictionary *)gridFrameDict{
    
    [[self gridView] updateLayerRect:gridFrameDict];
    
    
    NSArray *keys = [gridFrameDict allKeys];
    for(NSString *key in keys){
        if([frameDict objectForKey:key]){
            [frameDict removeObjectForKey:key];
        }
        [frameDict setObject:[gridFrameDict objectForKey:key] forKey:key];
    }
}

#pragma mark updatedText
- (void)updateHTMLText:(NSString *)insertText atIU:(NSString *)iuID{
    
    IULog(@"[IU:%@], %@", iuID, insertText);
}

#pragma mark moveIU
- (void)moveDiffPoint:(NSPoint)point{
    
    IULog(@"Point:(%.1f %.1f)", point.x, point.y);
}
- (void)changeIUFrame:(NSRect)frame IUID:(NSString *)IUID{
    
    IULog(@"[IU:%@]\n origin: (%.1f, %.1f) \n size: (%.1f, %.1f)",
          IUID, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (void)makeNewIU:(NSString *)iuname atPoint:(NSPoint)point{
    IULog(@"[IU:%@] : point(%.1f, %.1f)", iuname, point.x, point.y);
}

@end
