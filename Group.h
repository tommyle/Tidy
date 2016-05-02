//
//  Group.h
//  Tidy
//
//  Created by admin on 2016-01-09.
//  Copyright © 2016 Tommy Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(Item*)getItemWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END

#import "Group+CoreDataProperties.h"
