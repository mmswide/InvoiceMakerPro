//
//  PurchaseUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "BaseUserDefaults.h"

@interface PurchaseUserDefaults : BaseUserDefaults {
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)savePurchases:(NSArray*)sender;

-(NSArray*)loadPurchases;

- (NSString *)purchasePref;
- (void)setPurchasePref:(NSString *)pref;

@end
