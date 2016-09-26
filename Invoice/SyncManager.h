//
//  SyncManager.h
//  Invoice
//
//  Created by XGRoup on 7/7/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncManager : NSObject
{
	
}

+(id)sharedManager;

-(void)cloudSwitchChanged;

-(void)startSyncWithSelector:(SEL)selector;

-(void)updateCloud:(NSDictionary*)object andPurposeForDelete:(int)purpose;

-(void)updateObjectForCloud:(NSArray*)sender;

-(void)checkObjectsID;

@end
