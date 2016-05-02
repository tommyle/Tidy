//
//  TidyWindow.h
//  Tidy
//
//  Created by admin on 2015-12-29.
//  Copyright © 2015 Tommy Le. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface TidyWindow : NSWindow

@property (strong, nonatomic) AppDelegate *delegate;
@property int iconSize;
@property int gridSpacing;
@property int horizontalMargin;
@property int verticalMargin;
@property (strong, nonatomic) NSMutableDictionary *groups;

@end
