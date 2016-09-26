//
//  MKStoreManager.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//  mugunthkumar.com
//

#import "MKStoreManager.h"

#import "Defines.h"

@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager
static NSString * premiumAppID = @"invoice_Premium_Unlimited_Docs";
static NSString * csvExportID = csv_export_id;
static NSString * dropBoxBackupID = dropbox_backup_id;

BOOL premiumAppPurchased;
BOOL csvExportPurchased;
BOOL dropboxBackupPurchased;

static MKStoreManager * _sharedStoreManager; // self


+(BOOL)premiumAppPurchased {
	return premiumAppPurchased;
}

+(BOOL)csvExportPurchased {
	return csvExportPurchased;
}

+(BOOL)dropboxBackupPurchased {
  return dropboxBackupPurchased;
}

+(MKStoreManager*)sharedManager
{
	@synchronized(self)
	{
		if (_sharedStoreManager == nil)
		{
			_sharedStoreManager = [[self alloc] init]; // assignment not done here
			
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
		}
	}
	
	return _sharedStoreManager;
}

#pragma mark Singleton Methods

+(id)allocWithZone:(NSZone*)zone
{
	@synchronized(self)
	{
		if (_sharedStoreManager == nil)
		{
			_sharedStoreManager = [super allocWithZone:zone];
			return _sharedStoreManager;  // assignment and return on first allocation
		}
	}
	
	return nil; //on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone*)zone
{
	return self;
}

-(void)requestProductData
{
	SKProductsRequest * request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects: premiumAppID,csvExportID, dropBoxBackupID, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}

-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	
	// populate your UI Controls here	
	for (int i = 0; i < [purchasableObjects count]; i++)
	{
		SKProduct * product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@ Coin: %@", [product localizedTitle], [[product price] doubleValue], [product productIdentifier],[[product priceLocale] localeIdentifier]);
	}
}

-(void)buyPremiumApp
{
	if (DELEGATE.internetIsAvailable)
	{
		DELEGATE.purchase_in_progres = YES;
		
		[DELEGATE addLoadingView];
		
		[self buyFeature:premiumAppID];
	}
	else
	{
		DELEGATE.purchase_in_progres = NO;
		
		[DELEGATE removeLoadingView];
		
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

-(void)buyCSVExport
{
	if(DELEGATE.internetIsAvailable)
	{
		DELEGATE.purchase_in_progres = YES;
		
		[DELEGATE addLoadingView];
		
		[self buyFeature:csvExportID];
	}
	else
	{
		DELEGATE.purchase_in_progres = NO;
		
		[DELEGATE removeLoadingView];
		
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

-(void)buyDropboxBackup {
  if(DELEGATE.internetIsAvailable)
  {
    DELEGATE.purchase_in_progres = YES;
    
    [DELEGATE addLoadingView];
    
    [self buyFeature:dropBoxBackupID];
  }
  else
  {
    DELEGATE.purchase_in_progres = NO;
    
    [DELEGATE removeLoadingView];
    
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
  }
}

-(void)restorePurchases
{
	if (DELEGATE.internetIsAvailable)
	{
		if ([SKPaymentQueue canMakePayments])
		{
			DELEGATE.purchase_in_progres = YES;
			
			[DELEGATE addLoadingView];
		
			[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
		}
		else
		{
			[[[UIAlertView alloc] initWithTitle:@"" message:@"You are not authorized to purchase from AppStore" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		}
	}
	else
	{
		DELEGATE.purchase_in_progres = NO;
		
		[DELEGATE removeLoadingView];
		
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection available." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}

-(void)buyFeature:(NSString*)featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKProduct * product;
		
		for (int i = 0; i < [purchasableObjects count]; i++)
		{
			SKProduct * temp = [purchasableObjects objectAtIndex:i];
      NSLog(@"[temp productIdentifier]: %@", [temp productIdentifier]);
			if ([[temp productIdentifier] isEqual:featureId])
			{
				product = temp;
				break;
			}
		}
		
		if (product)
		{
			SKPayment * payment = [SKPayment paymentWithProduct:product];
			[[SKPaymentQueue defaultQueue] addPayment:payment];
		}
	}
	else
	{
		[[[UIAlertView alloc] initWithTitle:@"" message:@"You are not authorized to purchase from AppStore" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	}
}

-(void)failedTransaction:(SKPaymentTransaction*)transaction
{
	NSString * messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	
	[[[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

-(void)provideContent:(NSString*)productIdentifier {
	if ([productIdentifier isEqualToString:premiumAppID]) {
		premiumAppPurchased = YES;
  }
	
	if([productIdentifier isEqualToString:csvExportID]) {
		csvExportPurchased = YES;
  }
  
  if([productIdentifier isEqualToString:dropBoxBackupID]) {
    dropboxBackupPurchased = YES;
  }
	
	[MKStoreManager updatePurchases];
}

+(void)loadPurchases
{
	premiumAppPurchased = [CustomDefaults customBoolForKey:premiumAppID];
	csvExportPurchased = [CustomDefaults customBoolForKey:csvExportID];
  dropboxBackupPurchased = [CustomDefaults customBoolForKey:dropBoxBackupID];
}

+(void)updatePurchases
{
	[CustomDefaults setCustomBool:premiumAppPurchased forKey:premiumAppID];
  [CustomDefaults setCustomBool:csvExportPurchased forKey:csvExportID];
  [CustomDefaults setCustomBool:dropboxBackupPurchased forKey:dropBoxBackupID];
}

@end
