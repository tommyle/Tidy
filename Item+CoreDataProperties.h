//
//  Item+CoreDataProperties.h
//  Tidy
//
//  Created by admin on 2016-01-09.
//  Copyright © 2016 Tommy Le. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *xPos;
@property (nullable, nonatomic, retain) NSNumber *yPos;
@property (nullable, nonatomic, retain) Group *group;

@end

NS_ASSUME_NONNULL_END
