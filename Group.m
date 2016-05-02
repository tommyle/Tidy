//
//  Group.m
//  Tidy
//
//  Created by admin on 2016-01-09.
//  Copyright © 2016 Tommy Le. All rights reserved.
//

#import "Group.h"
#import "Item.h"

@implementation Group

// Insert code here to add functionality to your managed object subclass

-(Item*)getItemWithName:(NSString*)name {
    Item *item;
    
    for (Item* i in self.items) {
        if ([i.name isEqualToString:name]) {
            item = i;
            break;
        }
    }
    
    return item;
}

@end
