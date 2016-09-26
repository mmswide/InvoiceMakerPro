//
//  StoreManager.h
//  MKSync
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 MK Inc. All rights reserved.
//  mugunthkumar.com

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@interface MKStoreManager : NSObject <SKProductsRequestDelegate>
{
	NSMutableArray * purchasableObjects;
	MKStoreObserver * storeObserver;
}

@property (nonatomic, retain) NSMutableArray * purchasableObjects;
@property (nonatomic, retain) MKStoreObserver * storeObserver;

-(void)requestProductData;

-(void)buyPremiumApp; // expose product buying functions, do not expose
-(void)buyCSVExport;
-(void)buyDropboxBackup;
-(void)restorePurchases;

// do not call this directly. This is like a private method
-(void)buyFeature:(NSString*)featureId;

-(void)failedTransaction:(SKPaymentTransaction*)transaction;
-(void)provideContent:(NSString*)productIdentifier;

+(MKStoreManager*)sharedManager;

+(BOOL)premiumAppPurchased;
+(BOOL)csvExportPurchased;
+(BOOL)dropboxBackupPurchased;

+(void)loadPurchases;
+(void)updatePurchases;

@end
