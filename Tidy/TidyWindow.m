//
//  TidyWindow.m
//  Tidy
//
//  Created by admin on 2015-12-29.
//  Copyright © 2015 Tommy Le. All rights reserved.
//

#import "TidyWindow.h"
#import "Group.h"
#import "Item.h"
#import "AppDelegate.h"

#import <ScriptingBridge/ScriptingBridge.h>
#import "Finder.h"

@implementation TidyWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
    if(self)
    {
        _delegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
        
        _horizontalMargin = 20;
        _verticalMargin = 30;
        _iconSize = [self getDesktopViewSetting:@"iconSize"];
        _gridSpacing = [self getDesktopViewSetting:@"gridSpacing"];
        
        _groups = [_delegate getAllGroups];
        
        Group *g = (Group*)[_groups objectForKey:@"Applications"];
        [self cleanUpGroup: g];
        
        //[self setLevel: -1000];
        
        [self setLevel:kCGDesktopWindowLevel - 1];
        
        [self setCollectionBehavior:
         (NSWindowCollectionBehaviorCanJoinAllSpaces |
          NSWindowCollectionBehaviorStationary |
          NSWindowCollectionBehaviorIgnoresCycle)];
        
        self.alphaValue = 0.5f;
        self.title = @"Folders";
        
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask|NSKeyDownMask|NSLeftMouseDownMask|NSLeftMouseUpMask handler:^(NSEvent *e){
        
            [self handleGlobalEvent:e];
        }];
        
        [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask|NSLeftMouseDownMask|NSLeftMouseUpMask handler:^NSEvent *(NSEvent *e){
            
            [self handleLocalEvent:e];
            
            return e;
        }];
    }
    return self;
}

- (BOOL)canBecomeMainWindow
{
    return false;
}

- (BOOL)canBecomeKeyWindow
{
    return false;
}

- (void)moveWindow{
    NSPoint currentLocation;
    NSPoint newOrigin;
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x;
    newOrigin.y = currentLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [self setFrameOrigin:newOrigin];
}

#pragma applescript
- (void)moveFile:(CGPoint)p gridSpacing:(int)spacing{
    NSMutableString* cmd = [NSMutableString new];
    [cmd appendString:@"tell application \"Finder\"\n"];
    [cmd appendString:[NSString stringWithFormat:@"set xPos to %f\n", p.x]];
    [cmd appendString:[NSString stringWithFormat:@"set yPos to %f\n", p.y]];
    [cmd appendString:@"set theSelection to selection\n"];
    [cmd appendString:@"repeat with oneItem in theSelection\n"];
    [cmd appendString:@"set desktop position of oneItem to {xPos, yPos}\n"];
    [cmd appendString:[NSString stringWithFormat:@"set xPos to xPos + %d\n", spacing]];
    [cmd appendString:@"end repeat\n"];
    [cmd appendString:@"end tell"];
    
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:cmd];
    NSDictionary *err = nil;
    NSAppleEventDescriptor *result = [script executeAndReturnError:&err];
}

- (void)moveFileNamed:(NSString*)name toPosition:(CGPoint)p{
    //NSURL *url = [NSURL URLWithString:[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSString *filepath = [url path];
    
    NSURL* url = [NSURL fileURLWithPath:name];
    NSString* hfsPath = (NSString*)CFBridgingRelease(CFURLCopyFileSystemPath((CFURLRef)url, kCFURLHFSPathStyle));

    NSMutableString* cmd = [NSMutableString new];
    
//    [cmd appendString:[NSString stringWithFormat:@"set posixPath to \"%@\"\n", name]];
//    [cmd appendString:@"if kind of (info for (POSIX file posixPath)) is \"folder\" then\n"];
//    [cmd appendString:@"set aliasPath to (((posixPath as text) as POSIX file) as alias)\n"];
//    [cmd appendString:@"tell application \"Finder\"\n"];
//    [cmd appendString:@"set desktopItem to folder aliasPath\n"];
//    [cmd appendString:[NSString stringWithFormat:@"set desktop position of desktopItem to {%f, %f}\n", p.x, p.y]];
//    [cmd appendString:@"end tell\n"];
//    [cmd appendString:@"else\n"];
//    [cmd appendString:@"set aliasPath to (((posixPath as text) as POSIX file) as alias)\n"];
//    [cmd appendString:@"tell application \"Finder\"\n"];
//    [cmd appendString:@"set desktopItem to file aliasPath\n"];
//    [cmd appendString:[NSString stringWithFormat:@"set desktop position of desktopItem to {%f, %f}\n", p.x, p.y]];
//    [cmd appendString:@"end tell\n"];
//    [cmd appendString:@"end if\n"];
    
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:name isDirectory:&isDir] && isDir){
        [cmd appendString:[NSString stringWithFormat:@"set aliasPath to \"%@\"\n", hfsPath]];
        [cmd appendString:@"tell application \"Finder\"\n"];
        [cmd appendString:@"set desktopItem to folder aliasPath\n"];
        [cmd appendString:[NSString stringWithFormat:@"set desktop position of desktopItem to {%f, %f}\n", p.x, p.y]];
        [cmd appendString:@"end tell\n"];
    }
    else {
        [cmd appendString:[NSString stringWithFormat:@"set aliasPath to \"%@\"\n", hfsPath]];
        [cmd appendString:@"tell application \"Finder\"\n"];
        [cmd appendString:@"set desktopItem to file aliasPath\n"];
        [cmd appendString:[NSString stringWithFormat:@"set desktop position of desktopItem to {%f, %f}\n", p.x, p.y]];
        [cmd appendString:@"end tell\n"];
    }

    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:cmd];
    NSDictionary *err = nil;
    NSAppleEventDescriptor *result = [script executeAndReturnError:&err];
}

- (void)cleanUpGroup:(Group*)g{
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    int i = 0;
    
    for (Item* item in g.items) {
        CGPoint p;
        p.x = windowFrame.origin.x + _iconSize/2 + _horizontalMargin;
        p.y = screenFrame.size.height - windowFrame.size.height - windowFrame.origin.y + _iconSize/2 + _verticalMargin;
        
        //need to offset p by the number of items already in the group
        p.x = p.x + (_iconSize + _gridSpacing) * i;
        [self moveFileNamed: item.name toPosition:p];
        i++;
    }
}

#pragma Deskop Settings
- (int)getDesktopViewSetting:(NSString*)settingName {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[ @"-c", [NSString stringWithFormat: @"defaults read com.apple.finder DesktopViewSettings | grep %@", settingName]]];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    
    [task launch];
    
    NSFileHandle * read = [outputPipe fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", stringRead);
    
    NSRange indexOfSemiColon = [stringRead rangeOfString:@";" options:NSBackwardsSearch];
    NSRange indexOfLastSpace = [stringRead rangeOfString:@" " options:NSBackwardsSearch];
    
    NSString *setting = [stringRead substringWithRange:NSMakeRange(indexOfLastSpace.location + 1, indexOfSemiColon.location - indexOfLastSpace.location - 1)];
    
    return [setting intValue];
}

-(BOOL)didClickInFinder:(NSEvent*)e{
    BOOL result = false;
    
    CGWindowID windowID = (CGWindowID)[e windowNumber];
    CFArrayRef a = CFArrayCreate(NULL, (void *)&windowID, 1, NULL);
    NSArray *windowInfos = (NSArray *)CFBridgingRelease(CGWindowListCreateDescriptionFromArray(a));
    CFRelease(a);
    if ([windowInfos count] > 0) {
        NSDictionary *windowInfo = [windowInfos objectAtIndex:0];
        //NSLog(@"Owner: %@", [windowInfo objectForKey:(NSString *)kCGWindowOwnerName]);
        
        int windowLevel = (int)[windowInfo objectForKey:(NSString*)kCGWindowLayer];
        
        //55 is the level of a regular finder window, the desktop one is a large number
        //not sure what the exact windowLevel of the desktop is
        if ([[windowInfo objectForKey:(NSString *)kCGWindowOwnerName] isEqual: @"Finder"] && windowLevel > 1000){
            result = true;
        }
    }
    
    return result;
}

-(NSArray*)finderGetSelectedItems{
    FinderApplication * finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    SBElementArray *selection = [[finder selection] get];
    
    //Create a new array without SBObjects (Ex. Volumes Icons) because these have no URLs and cause the program to crash
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    
    for (NSObject *object in selection) {
        //this dones't seem to work
        //if (![object isKindOfClass:[SBObject class]])
        [selectedItems addObject: object];
    }
    
    NSArray * items = [(SBElementArray*)selectedItems arrayByApplyingSelector:@selector(URL)];
    
    return items;
}

-(void)handleGlobalEvent:(NSEvent*)e{
    if(e.type==NSLeftMouseUp && [self didClickInFinder:e]){
        //[self setLevel:kCGDesktopWindowLevel - 1];
        //NSLog(@"Global NSLeftMouseUp");
        
        NSRect  screenFrame = [[NSScreen mainScreen] frame];
        NSPoint mouseLocation = [NSEvent mouseLocation];
        NSRect  windowFrame = [self frame];
        
        NSArray *selectedItems = [self finderGetSelectedItems];
        Group *g = (Group*)[_groups objectForKey:@"Applications"];
        
        if (mouseLocation.x >= windowFrame.origin.x && mouseLocation.x <= windowFrame.origin.x + windowFrame.size.width && mouseLocation.y >= windowFrame.origin.y && mouseLocation.y <= windowFrame.origin.y + windowFrame.size.height) {
            
            CGPoint p;
            p.x = windowFrame.origin.x + _iconSize/2 + _horizontalMargin;
            p.y = screenFrame.size.height - windowFrame.size.height - windowFrame.origin.y + _iconSize/2 + _verticalMargin;
            
            //need to offset p by the number of items already in the group
            p.x = p.x + (_iconSize + _gridSpacing) * (int)[g.items count];
            
            for (NSString * item in selectedItems) {
                NSURL * url = [NSURL URLWithString:item];
                
                if (![g getItemWithName:[url path]]){
                    
                    [_delegate addNewItem:[url path] withPosition:p toGroup:g];
                    
                    [self moveFile: p gridSpacing:_gridSpacing + _iconSize];
                }
            }
        }
        else {
            for (NSString * item in selectedItems) {
                NSURL * url = [NSURL URLWithString:item];
                
                if ([g getItemWithName:[url path]]){
                    [_delegate removeItemWithName:[url path] fromGroup:g];
                    [self cleanUpGroup: g];
                }
            }
        }
    }
    
    if(e.type==NSLeftMouseDragged)
    {
        //NSLog(@"Global");
    }
}

-(void)handleLocalEvent:(NSEvent*)e{
    if(e.type==NSLeftMouseUp){
        //[self setLevel:kCGDesktopWindowLevel - 1];
        
        //NSLog(@"Local NSLeftMouseUp");
        
        NSPoint mouseLocation = [NSEvent mouseLocation];
        NSRect  windowFrame = [self frame];
        
        NSLog(@"Screen: %f, %f", windowFrame.origin.x, windowFrame.origin.y);
        
        if (mouseLocation.x >= windowFrame.origin.x && mouseLocation.x <= windowFrame.origin.x + windowFrame.size.width && mouseLocation.y >= windowFrame.origin.y && mouseLocation.y <= windowFrame.origin.y + windowFrame.size.height) {
            NSLog(@"Clicked inside the window!!!!");
        }
    }
    
    if(e.type==NSLeftMouseDown)
    {
        //[self setLevel: -1000];
        //NSLog(@"Local NSLeftMouseDown");
    }
}

@end
