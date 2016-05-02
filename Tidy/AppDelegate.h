//
//  AppDelegate.h
//  Tidy
//
//  Created by admin on 2015-12-29.
//  Copyright © 2015 Tommy Le. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Group.h"
#import "Item.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)createNewGroup:(NSString*)name;
-(Group*)getGroupByName:(NSString*)name;
-(void)addNewItem:(NSString*)name withPosition:(CGPoint)p toGroup:(Group*)g;
-(void)removeItemWithName:(NSString*)name fromGroup:(Group*)g;
-(NSMutableDictionary*)getAllGroups;

@end

