//
//  MKStoreObserver.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//

#import "MKStoreObserver.h"
#import "MKStoreManager.h"
#import "Defines.h"
#import "Base64.h"

@implementation MKStoreObserver

-(void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{	
	for (SKPaymentTransaction * transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
			{
				[self completeTransaction:transaction];
				
				break;
			}
			case SKPaymentTransactionStateFailed:
			{
				[self failedTransaction:transaction];
			
				break;
			}
			case SKPaymentTransactionStateRestored:
			{
				[self restoreTransaction:transaction];

				break;
			}
			default:
				
				break;
		}
	}
}

#pragma mark
#pragma mark STORE ACTIONS

-(void)failedTransaction:(SKPaymentTransaction*)transaction
{
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		
	}
  
//#warning remove it !!!
//  [self completeTransaction:transaction];
//  return;
	
	NSLog(@"failed:\n%@", transaction.error);
	
	if([transaction.error localizedDescription])
	{
		NSString * messageToBeShown = [NSString stringWithFormat:@"Reason: %@",[transaction.error localizedDescription]];
		[[[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	}
	
	DELEGATE.purchase_in_progres = NO;
	
	[DELEGATE removeLoadingView];
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)completeTransaction:(SKPaymentTransaction*)transaction
{
	DELEGATE.purchase_in_progres = NO;
	
	[[MKStoreManager sharedManager] provideContent:transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
	if ([transaction.payment.productIdentifier isEqualToString:@"invoice_Premium_Unlimited_Docs"]) {
		[[[AlertView alloc] initWithTitle:@"" message:@"Purchase Complete!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		
		[DELEGATE buyPremiumApp];
	} else if([transaction.payment.productIdentifier isEqualToString:csv_export_id]) {
			[[[AlertView alloc] initWithTitle:@"" message:@"Purchase Complete!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
			
			[DELEGATE buyCSVExport];
  } else if([transaction.payment.productIdentifier isEqualToString:dropbox_backup_id]) {
    [[[AlertView alloc] initWithTitle:@"" message:@"Purchase Complete!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
    
    [DELEGATE buyDropboxBackup];
  }
	
	[DELEGATE removeLoadingView];
}

-(void)restoreTransaction:(SKPaymentTransaction*)transaction {
	DELEGATE.purchase_in_progres = NO;
	
	[DELEGATE removeLoadingView];
	
	NSLog(@"restored: %@", transaction.payment.productIdentifier);
	
	if ([transaction.payment.productIdentifier isEqualToString:@"invoice_Premium_Unlimited_Docs"]) {
		[DELEGATE buyPremiumApp];
	} else if ([transaction.payment.productIdentifier isEqualToString:csv_export_id]) {
		[DELEGATE buyCSVExport];
  } else if ([transaction.payment.productIdentifier isEqualToString:dropbox_backup_id]) {
    [DELEGATE buyDropboxBackup];
  }
	
	[[MKStoreManager sharedManager] provideContent:transaction.originalTransaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark
#pragma mark DELEGATE

-(void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error
{
	DELEGATE.purchase_in_progres = NO;
	
	[DELEGATE removeLoadingView];
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	if(queue.transactions.count != 0) {
		[[[AlertView alloc] initWithTitle:@"" message:@"Purchases restored!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
	} else {
		[[[AlertView alloc] initWithTitle:@"" message:@"There are no purchases to restore!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
	}

	DELEGATE.purchase_in_progres = NO;
	
	[DELEGATE removeLoadingView];
}


@end