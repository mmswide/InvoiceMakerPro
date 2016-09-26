//
//  SyncManager.m
//  Invoice
//
//  Created by XGRoup on 7/7/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "SyncManager.h"

#import "Defines.h"

@implementation SyncManager

+(id)sharedManager
{
	static SyncManager * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[self alloc] init];
	});
	
	return manager;
}

-(id)init
{
	self = [super init];
	
	if (self)
	{
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
						
		if(![[CustomDefaults customStringForKey:kSyncValue] isEqual:@"0"])
		{
			[[NSNotificationCenter defaultCenter] addObserver:self
									     selector:@selector(cloudNotification:)
										   name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
										 object:store];
		}
	}
	
	return self;
}

/*-(void)resetCloudContent
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudReceipts];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudTimesheets];
	
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudClients];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudDeletedItems];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudEstimates];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudInvoices];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudProducts];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudProjects];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudPurchase];
	[store setObject:[[NSMutableArray alloc] init] forKey:kCloudQuotes];
	
	[store synchronize];
} */

-(void)cloudSwitchChanged
{
	if(![[CustomDefaults customStringForKey:kSyncValue] isEqual:@"0"])
	{
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
								     selector:@selector(cloudNotification:)
									   name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
									 object:store];

		NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(forceSync) object:nil];
		[thread setName:@"FORCE SYNC THREAD"];
		[thread start];
	}
	else
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

-(void)forceSync
{
	@autoreleasepool
	{
		if(app_version == 0)
		{
			[self saveInvoices];
			[self saveQuotes];
			[self saveEstimates];
			[self savePurchaseOrders];
			
			[self saveReceipts];
			[self saveTimesheets];
			
			[self saveProducts];
			[self saveClients];
			[self saveProjects];
		}
		else
		if(app_version == 1)
		{
			[self saveQuotes];

			[self saveProducts];
			[self saveClients];
			[self saveProjects];
		}
		else
		if(app_version == 2)
		{
			[self saveEstimates];
			
			[self saveProducts];
			[self saveClients];
			[self saveProjects];
		}
		else
		if(app_version == 3)
		{
			[self savePurchaseOrders];
			
			[self saveProducts];
			[self saveClients];
			[self saveProjects];
		}
		else
		if(app_version == 4)
		{
			[self saveReceipts];
			
			[self saveProducts];
			[self saveClients];
			[self saveProjects];
		}
		else
		if(app_version == 5)
		{
			[self saveTimesheets];
			
			[self saveProducts];
			[self saveClients];
			[self saveProjects];
		}
	}
}

#pragma mark
#pragma mark Thread Functions
-(void)startSyncWithSelector:(SEL)selector
{
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:selector object:nil];
	[thread setName:@"SYNC THREAD"];
	[thread start];
}

-(void)updateCloud:(NSDictionary*)object andPurposeForDelete:(int)purpose
{
	if([[CustomDefaults customStringForKey:kSyncValue] isEqual:@"0"])
		return;
	
	NSArray *objects = [[NSArray alloc] initWithObjects:object,[NSString stringWithFormat:@"%d",purpose],nil];
	
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateObjectForCloud:) object:objects];
	[thread setName:@"UPDATE THREAD"];
	[thread start];
}

-(void)cloudNotification:(NSNotification *)notification
{
	if([[CustomDefaults customStringForKey:kSyncValue] isEqual:@"0"])
		return;
	
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateCloudItems:) object:notification];
	[thread setName:@"CLOUD THREAD"];
	[thread start];
}

-(void)checkObjectsID
{
	@autoreleasepool
	{
		// INVOICES
		NSMutableArray *invoicesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
		for(int i=0;i<invoicesArray.count;i++)
		{
			InvoiceOBJ *invoice = [invoicesArray objectAtIndex:i];
			
			if([[invoice ID] isEqual:@""])
			{
				[invoice setID:[data_manager createInvoiceID]];
				[invoicesArray replaceObjectAtIndex:i withObject:invoice];
			}
		}
		
		// QUOTES
		NSMutableArray *quotesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults]];
		for(int i=0;i<quotesArray.count;i++)
		{
			QuoteOBJ *quote = [quotesArray objectAtIndex:i];
			
			if([[quote ID] isEqual:@""])
			{
				[quote setID:[data_manager createQuoteID]];
				[quotesArray replaceObjectAtIndex:i withObject:quote];
			}
		}
		
		// ESTIMATES
		NSMutableArray *estimatesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
		for(int i=0;i<estimatesArray.count;i++)
		{
			EstimateOBJ *estimate = [estimatesArray objectAtIndex:i];
			
			if([[estimate ID] isEqual:@""])
			{
				[estimate setID:[data_manager createEstimateID]];
				[estimatesArray replaceObjectAtIndex:i withObject:estimate];
			}
		}
		
		//PURCHASES
		NSMutableArray *purchasesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults]];
		for(int i=0;i<purchasesArray.count;i++)
		{
			PurchaseOrderOBJ *purchase = [purchasesArray objectAtIndex:i];
			
			if([[purchase ID] isEqual:@""])
			{
				[purchase setID:[data_manager createPurchaseOrderID]];
				[purchasesArray replaceObjectAtIndex:i withObject:purchase];
			}
		}
				
		// PRODUCTS
		NSMutableArray *productsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
		for(int i=0;i<productsArray.count;i++)
		{
			ProductOBJ *product = [productsArray objectAtIndex:i];
			
			if([[product ID] isEqual:@""])
			{
				[product setID:[data_manager createProductID]];
				[productsArray replaceObjectAtIndex:i withObject:product];
			}
		}
		
		[data_manager saveProductsArrayToUserDefaults:productsArray forKey:kProductsKeyForNSUserDefaults];
		
		// CONTACTS
		NSMutableArray *contactsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadClientsArrayFromUserDefaultsAtKey:kClientsKeyForNSUserDefaults]];
		for(int i=0;i<contactsArray.count;i++)
		{
			ClientOBJ *client = [contactsArray objectAtIndex:i];
			
			if([[client ID] isEqual:@""])
			{
				[client setID:[data_manager createContactID]];
				[contactsArray replaceObjectAtIndex:i withObject:client];
			}
		}
		
		[data_manager saveClientsArrayToUserDefaults:contactsArray forKey:kClientsKeyForNSUserDefaults];
		
		// PROJECTS
		NSMutableArray *projectsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
		for(int i=0;i<projectsArray.count;i++)
		{
			ProjectOBJ *project = [projectsArray objectAtIndex:i];
			
			if([[project ID] isEqual:@""])
			{
				[project setID:[data_manager createProjectID]];
				[projectsArray replaceObjectAtIndex:i withObject:project];
			}
		}
		
		[data_manager saveProjectsArrayToUserDefaults:projectsArray forKey:kProjectsKeyForNSUserDefaults];
				
		
		// Checking Projects and Clients for Every Object
		
		// INVOICES
		for(int i=0;i<invoicesArray.count;i++)
		{
			InvoiceOBJ *invoice = [invoicesArray objectAtIndex:i];
			
			for(int j=0;j<contactsArray.count;j++)
			{
				ClientOBJ *client = [contactsArray objectAtIndex:j];
				
				if([[client partiallyContentsDictionary] isEqual:[[invoice client] partiallyContentsDictionary]])
				{
					[invoice setClient:[client contentsDictionary]];
					[invoicesArray replaceObjectAtIndex:i withObject:invoice];
					
					j = (int)contactsArray.count;
				}
			}
			
			for(int j=0;j<projectsArray.count;j++)
			{
				ProjectOBJ *project = [projectsArray objectAtIndex:j];
				
				if([[project partiallyContentsDictionary] isEqual:[[invoice project] partiallyContentsDictionary]])
				{
					[invoice setProject:[project contentsDictionary]];
					[invoicesArray replaceObjectAtIndex:i withObject:invoice];
					
					j = (int)contactsArray.count;
				}
			}
		}
		
		[data_manager saveInvoicesArrayToUserDefaults:invoicesArray forKey:kInvoicesKeyForNSUserDefaults];
		
		// QUOTES
		for(int i=0;i<quotesArray.count;i++)
		{
			QuoteOBJ *quote = [quotesArray objectAtIndex:i];
			
			for(int j=0;j<contactsArray.count;j++)
			{
				ClientOBJ *client = [contactsArray objectAtIndex:j];
				
				if([[client partiallyContentsDictionary] isEqual:[[quote client] partiallyContentsDictionary]])
				{
					[quote setClient:[client contentsDictionary]];
					[quotesArray replaceObjectAtIndex:i withObject:quote];
					
					j = (int)contactsArray.count;
				}
			}
			
			for(int j=0;j<projectsArray.count;j++)
			{
				ProjectOBJ *project = [projectsArray objectAtIndex:j];
				
				if([[project partiallyContentsDictionary] isEqual:[[quote project] partiallyContentsDictionary]])
				{
					[quote setProject:[project contentsDictionary]];
					[quotesArray replaceObjectAtIndex:i withObject:quote];
					
					j = (int)contactsArray.count;
				}
			}
		}
		
		[data_manager saveQuotesArrayToUserDefaults:quotesArray forKey:kQuotesKeyForNSUserDefaults];
		
		// ESTIMATES
		for(int i=0;i<estimatesArray.count;i++)
		{
			EstimateOBJ *estimate = [estimatesArray objectAtIndex:i];
			
			for(int j=0;j<contactsArray.count;j++)
			{
				ClientOBJ *client = [contactsArray objectAtIndex:j];
				
				if([[client partiallyContentsDictionary] isEqual:[[estimate client] partiallyContentsDictionary]])
				{
					[estimate setClient:[client contentsDictionary]];
					[estimatesArray replaceObjectAtIndex:i withObject:estimate];
					
					j = (int)contactsArray.count;
				}
			}
			
			for(int j=0;j<projectsArray.count;j++)
			{
				ProjectOBJ *project = [projectsArray objectAtIndex:j];
				
				if([[project partiallyContentsDictionary] isEqual:[[estimate project] partiallyContentsDictionary]])
				{
					[estimate setProject:[project contentsDictionary]];
					[estimatesArray replaceObjectAtIndex:i withObject:estimate];
					
					j = (int)contactsArray.count;
				}
			}
		}
		
		[data_manager saveEstimatesArrayToUserDefaults:estimatesArray forKey:kEstimatesKeyForNSUserDefaults];
		
		// PURCHASES
		for(int i=0;i<purchasesArray.count;i++)
		{
			PurchaseOrderOBJ *purchase = [purchasesArray objectAtIndex:i];
			
			for(int j=0;j<contactsArray.count;j++)
			{
				ClientOBJ *client = [contactsArray objectAtIndex:j];
				
				if([[client partiallyContentsDictionary] isEqual:[[purchase client] partiallyContentsDictionary]])
				{
					[purchase setClient:[client contentsDictionary]];
					[purchasesArray replaceObjectAtIndex:i withObject:purchase];
					
					j = (int)contactsArray.count;
				}
			}
			
			for(int j=0;j<projectsArray.count;j++)
			{
				ProjectOBJ *project = [projectsArray objectAtIndex:j];
				
				if([[project partiallyContentsDictionary] isEqual:[[purchase project] partiallyContentsDictionary]])
				{
					[purchase setProject:[project contentsDictionary]];
					[purchasesArray replaceObjectAtIndex:i withObject:purchase];
					
					j = (int)contactsArray.count;
				}
			}
		}
		
		[data_manager savePurchaseOrdersArrayToUserDefaults:purchasesArray forKey:kPurchaseOrdersKeyForNSUserDefaults];
				
		[CustomDefaults setCustomBool:YES forKey:kUpdatedApp];
	}
	
}

#pragma mark
#pragma mark NSNotificationCenter 
-(void)updateCloudItems:(NSNotification*)notification
{
	@autoreleasepool
	{
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		
		NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
		NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
		
		NSDictionary *userInfo = [notification userInfo];
		NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
		
		if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
		{
			[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
		}
		
		for(NSString *key in changedKeys)
		{
			if([key isEqual:kCloudInvoices])
			{
				[self saveInvoices];
			}
			else
			if([key isEqual:kCloudQuotes])
			{
				[self saveQuotes];
			}
			else
			if([key isEqual:kCloudEstimates])
			{
				[self saveEstimates];
			}
			else
			if([key isEqual:kCloudPurchase])
			{
				[self savePurchaseOrders];
			}
			else
			if([key isEqual:kCloudReceipts])
			{
				[self saveReceipts];
			}
			else
			if([key isEqual:kCloudTimesheets])
			{
				[self saveTimesheets];
			}
			else
			if([key isEqual:kCloudProducts])
			{
				[self saveProducts];
			}
			else
			if([key isEqual:kCloudClients])
			{
				[self saveClients];
			}
			else
			if([key isEqual:kCloudProjects])
			{
				[self saveProjects];
			}
			else
			if([key isEqual:kCloudDeletedItems])
			{
				[self saveInvoices];
				[self saveQuotes];
				[self saveEstimates];
				[self savePurchaseOrders];
				
				[self saveReceipts];
				[self saveTimesheets];
				
				[self saveProducts];
				[self saveClients];
				[self saveProjects];
			}
		}
	}
}

-(void)updateObjectForCloud:(NSArray*)sender
{
	@autoreleasepool
	{
		NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
		
		NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
		NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
		
		if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
		{
			[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
		}
		
		NSDictionary *object = [sender objectAtIndex:0];
		
		// Sync Purpose  = -1 delete
		//		     =  0 edit
		//		     =  1 add new
		int syncPurpose = [[sender objectAtIndex:1] intValue];
		
		if(syncPurpose == -1)
		{
			[deletedItems addObject:[object objectForKey:@"id"]];
			
			[store setObject:deletedItems forKey:kCloudDeletedItems];
			[store synchronize];
		}
		else
		if(syncPurpose == 0)
		{
			NSString *key = [self returnKeyforClassString:[object objectForKey:@"class"]];
			
			NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
			
			if([storeDictionary.allKeys containsObject:key])
			{
				[objectsArray addObjectsFromArray:[storeDictionary objectForKey:key]];
			}
			
			for(int i=0;i<objectsArray.count;i++)
			{
				if([[[objectsArray objectAtIndex:i] objectForKey:@"id"] isEqual:[object objectForKey:@"id"]])
				{
					[objectsArray replaceObjectAtIndex:i withObject:object];
					break;
				}
			}
			
			[store setObject:objectsArray forKey:key];
			[store synchronize];
			
		}
		else
		{
			NSString *key = [self returnKeyforClassString:[object objectForKey:@"class"]];
			
			NSMutableArray *objectsArray = [[NSMutableArray alloc] init];
			
			if([storeDictionary.allKeys containsObject:key])
			{
				[objectsArray addObjectsFromArray:[storeDictionary objectForKey:key]];
			}
			
			[objectsArray addObject:object];
			
			[store setObject:objectsArray forKey:key];
			[store synchronize];
		}
	}
}

-(NSString*)returnKeyforClassString:(NSString*)sender
{
	if([sender isEqual:@"InvoiceOBJ"])
		return kCloudInvoices;
	
	if([sender isEqual:@"QuoteOBJ"])
		return kCloudQuotes;
	
	if([sender isEqual:@"EstimateOBJ"])
		return kCloudEstimates;
	
	if([sender isEqual:@"PurchaseOrderOBJ"])
		return kCloudPurchase;
	
	if([sender isEqual:@"ReceiptOBJ"])
		return kCloudReceipts;
	
	if([sender isEqual:@"TimeSheetOBJ"])
		return kCloudTimesheets;
	
	if([sender isEqual:@"ProductOBJ"] || [sender isEqual:@"ServiceOBJ"])
		return kCloudProducts;
	
	if([sender isEqual:@"ClientOBJ"])
		return kCloudClients;
  
  if([sender isEqual:@"ProjectOBJ"])
    return kCloudProjects;
  
	return nil;
}

#pragma mark 
#pragma mark OBJECTS SYNC
-(void)saveInvoices
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
		
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}
	
	NSMutableArray *invoicesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
	
	for(int i=0;i<invoicesArray.count;i++)
	{
		InvoiceOBJ *invoice = [invoicesArray objectAtIndex:i];
		
		if([deletedItems containsObject:[invoice ID]])
		{
			[invoicesArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudInvoices])
	{
		NSMutableArray *cloudInvoices = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudInvoices]];
		
		for(int i=0;i<cloudInvoices.count;i++)
		{
			if([deletedItems containsObject:[[cloudInvoices objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudInvoices removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudInvoices.count;i++)
		{
			InvoiceOBJ *cloudInvoice = [[InvoiceOBJ alloc] initWithContentsDictionary:[cloudInvoices objectAtIndex:i]];
			
			for(int j=0;j<invoicesArray.count;j++)
			{
				InvoiceOBJ *invoice = [invoicesArray objectAtIndex:j];
				
				if([[cloudInvoice ID] isEqual:[invoice ID]])
				{
					[invoicesArray replaceObjectAtIndex:j withObject:cloudInvoice];
					
					[cloudInvoices removeObjectAtIndex:i];
					
					j = (int)invoicesArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudInvoices.count;i++)
		{
			InvoiceOBJ *cloudInvoice = [[InvoiceOBJ alloc] initWithContentsDictionary:[cloudInvoices objectAtIndex:i]];
			[invoicesArray addObject:cloudInvoice];
		}
	}
	
	[data_manager saveInvoicesArrayToUserDefaults:invoicesArray forKey:kInvoicesKeyForNSUserDefaults];
	
	for(int i=0;i<invoicesArray.count;i++)
	{
		InvoiceOBJ *invoice = [invoicesArray objectAtIndex:i];
		[invoicesArray replaceObjectAtIndex:i withObject:[invoice contentsDictionary]];
	}
	
	[store setObject:invoicesArray forKey:kCloudInvoices];
	[store synchronize];
}

-(void)saveQuotes
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}

	
	NSMutableArray *quotesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults]];
	
	for(int i=0;i<quotesArray.count;i++)
	{
		QuoteOBJ *quote = [quotesArray objectAtIndex:i];
		
		if([deletedItems containsObject:[quote ID]])
		{
			[quotesArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudQuotes])
	{
		NSMutableArray *cloudQuotes = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudQuotes]];
		
		for(int i=0;i<cloudQuotes.count;i++)
		{
			if([deletedItems containsObject:[[cloudQuotes objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudQuotes removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudQuotes.count;i++)
		{
			QuoteOBJ *cloudQuote = [[QuoteOBJ alloc] initWithContentsDictionary:[cloudQuotes objectAtIndex:i]];
			
			for(int j=0;j<quotesArray.count;j++)
			{
				QuoteOBJ *quote = [quotesArray objectAtIndex:j];
				
				if([[cloudQuote ID] isEqual:[quote ID]])
				{
					[quotesArray replaceObjectAtIndex:j withObject:cloudQuote];
					
					[cloudQuotes removeObjectAtIndex:i];
					
					j = (int)quotesArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudQuotes.count;i++)
		{
			QuoteOBJ *cloudQuote = [[QuoteOBJ alloc] initWithContentsDictionary:[cloudQuotes objectAtIndex:i]];
			[quotesArray addObject:cloudQuote];
		}
	}
	
	[data_manager saveQuotesArrayToUserDefaults:quotesArray forKey:kQuotesKeyForNSUserDefaults];
	
	for(int i=0;i<quotesArray.count;i++)
	{
		QuoteOBJ *quote = [quotesArray objectAtIndex:i];
		[quotesArray replaceObjectAtIndex:i withObject:[quote contentsDictionary]];
	}
	
	[store setObject:quotesArray forKey:kCloudQuotes];
	[store synchronize];
}

-(void)saveEstimates
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}

	
	NSMutableArray *estimatesArray = [[NSMutableArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
	
	for(int i=0;i<estimatesArray.count;i++)
	{
		EstimateOBJ *estimate = [estimatesArray objectAtIndex:i];
		
		if([deletedItems containsObject:[estimate ID]])
		{
			[estimatesArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudEstimates])
	{
		NSMutableArray *cloudEstimates = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudEstimates]];
		
		for(int i=0;i<cloudEstimates.count;i++)
		{
			if([deletedItems containsObject:[[cloudEstimates objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudEstimates removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudEstimates.count;i++)
		{
			EstimateOBJ *cloudEstimate = [[EstimateOBJ alloc] initWithContentsDictionary:[cloudEstimates objectAtIndex:i]];
			
			for(int j=0;j<estimatesArray.count;j++)
			{
				EstimateOBJ *estimate = [estimatesArray objectAtIndex:j];
				
				if([[cloudEstimate ID] isEqual:[estimate ID]])
				{
					[estimatesArray replaceObjectAtIndex:j withObject:cloudEstimate];
					
					[cloudEstimates removeObjectAtIndex:i];
					
					j = (int)estimatesArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudEstimates.count;i++)
		{
			EstimateOBJ *cloudEstimate = [[EstimateOBJ alloc] initWithContentsDictionary:[cloudEstimates objectAtIndex:i]];
			[estimatesArray addObject:cloudEstimate];
		}
	}
	
	[data_manager saveEstimatesArrayToUserDefaults:estimatesArray forKey:kEstimatesKeyForNSUserDefaults];
	
	for(int i=0;i<estimatesArray.count;i++)
	{
		EstimateOBJ *estimate = [estimatesArray objectAtIndex:i];
		[estimatesArray replaceObjectAtIndex:i withObject:[estimate contentsDictionary]];
	}
	
	[store setObject:estimatesArray forKey:kCloudEstimates];
	[store synchronize];
}

-(void)savePurchaseOrders
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}

	NSMutableArray *purchaseArray = [[NSMutableArray alloc] initWithArray:[data_manager loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults]];
	
	for(int i=0;i<purchaseArray.count;i++)
	{
		PurchaseOrderOBJ *purchase = [purchaseArray objectAtIndex:i];
		
		if([deletedItems containsObject:[purchase ID]])
		{
			[purchaseArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudPurchase])
	{
		NSMutableArray *cloudPurchases = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudPurchase]];
		
		for(int i=0;i<cloudPurchases.count;i++)
		{
			if([deletedItems containsObject:[[cloudPurchases objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudPurchases removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudPurchases.count;i++)
		{
			PurchaseOrderOBJ *cloudPurchase = [[PurchaseOrderOBJ alloc] initWithContentsDictionary:[cloudPurchases objectAtIndex:i]];
			
			for(int j=0;j<purchaseArray.count;j++)
			{
				PurchaseOrderOBJ *purchase = [purchaseArray objectAtIndex:j];
				
				if([[cloudPurchase ID] isEqual:[purchase ID]])
				{
					[purchaseArray replaceObjectAtIndex:j withObject:cloudPurchase];
					
					[cloudPurchases removeObjectAtIndex:i];
					
					j = (int)purchaseArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudPurchases.count;i++)
		{
			PurchaseOrderOBJ *cloudPurchase = [[PurchaseOrderOBJ alloc] initWithContentsDictionary:[cloudPurchases objectAtIndex:i]];
			[purchaseArray addObject:cloudPurchase];
		}
	}
	
	[data_manager savePurchaseOrdersArrayToUserDefaults:purchaseArray forKey:kPurchaseOrdersKeyForNSUserDefaults];
	
	for(int i=0;i<purchaseArray.count;i++)
	{
		PurchaseOrderOBJ *purchase = [purchaseArray objectAtIndex:i];
		[purchaseArray replaceObjectAtIndex:i withObject:[purchase contentsDictionary]];
	}
	
	[store setObject:purchaseArray forKey:kCloudPurchase];
	[store synchronize];
}

-(void)saveReceipts
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
		
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}
	
	NSMutableArray *receiptsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
	
	for(int i=0;i<receiptsArray.count;i++)
	{
		ReceiptOBJ *receipt = [receiptsArray objectAtIndex:i];
		
		if([deletedItems containsObject:[receipt ID]])
		{
			[receiptsArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudReceipts])
	{
		NSMutableArray *cloudReceipts = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudReceipts]];
		
		for(int i=0;i<cloudReceipts.count;i++)
		{
			if([deletedItems containsObject:[[cloudReceipts objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudReceipts removeObjectAtIndex:i];
				i--;
			}
		}
				
		for(int i=0;i<cloudReceipts.count;i++)
		{
			ReceiptOBJ *cloudReceipt = [[ReceiptOBJ alloc] initWithDictionaryRepresentation:[cloudReceipts objectAtIndex:i]];
			
			for(int j=0;j<receiptsArray.count;j++)
			{
				ReceiptOBJ *receipt = [receiptsArray objectAtIndex:j];
				
				if([[cloudReceipt ID] isEqual:[receipt ID]])
				{
					[receiptsArray replaceObjectAtIndex:j withObject:cloudReceipt];
					
					[cloudReceipts removeObjectAtIndex:i];
					
					j = (int)receiptsArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudReceipts.count;i++)
		{
			ReceiptOBJ *cloudReceipt = [[ReceiptOBJ alloc] initWithDictionaryRepresentation:[cloudReceipts objectAtIndex:i]];
			[receiptsArray addObject:cloudReceipt];
		}
	}
	
	[data_manager saveReceiptsArrayToUserDefaults:receiptsArray forKey:kReceiptsKeyForNSUserDefaults];
		
	for(int i=0;i<receiptsArray.count;i++)
	{
		ReceiptOBJ *receipt = [receiptsArray objectAtIndex:i];
		[receiptsArray replaceObjectAtIndex:i withObject:[receipt dictionaryRepresentationForCloud]];
	}
	
	[store setObject:receiptsArray forKey:kCloudReceipts];
	[store synchronize];
}

-(void)saveTimesheets
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}
	
	NSMutableArray *timesheetsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults]];
	
	for(int i=0;i<timesheetsArray.count;i++)
	{
		TimeSheetOBJ *timesheet = [timesheetsArray objectAtIndex:i];
		
		if([deletedItems containsObject:[timesheet ID]])
		{
			[timesheetsArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudTimesheets])
	{
		NSMutableArray *cloudTimesheets = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudTimesheets]];
		
		for(int i=0;i<cloudTimesheets.count;i++)
		{
			if([deletedItems containsObject:[[cloudTimesheets objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudTimesheets removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudTimesheets.count;i++)
		{
			TimeSheetOBJ *cloudTimesheet = [[TimeSheetOBJ alloc] initWithDictionaryRepresentation:[cloudTimesheets objectAtIndex:i]];
			
			for(int j=0;j<timesheetsArray.count;j++)
			{
				TimeSheetOBJ *timesheet = [timesheetsArray objectAtIndex:j];
				
				if([[cloudTimesheet ID] isEqual:[timesheet ID]])
				{
					[timesheetsArray replaceObjectAtIndex:j withObject:cloudTimesheet];
					
					[cloudTimesheets removeObjectAtIndex:i];
					
					j = (int)timesheetsArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudTimesheets.count;i++)
		{
			TimeSheetOBJ *cloudTimesheet = [[TimeSheetOBJ alloc] initWithDictionaryRepresentation:[cloudTimesheets objectAtIndex:i]];
			[timesheetsArray addObject:cloudTimesheet];
		}
	}
	
	[data_manager saveTimesheetArrayToUserDefaults:timesheetsArray forKey:kTimeSheetKeyForNSUserDefaults];
	
	for(int i=0;i<timesheetsArray.count;i++)
	{
		TimeSheetOBJ *timesheet = [timesheetsArray objectAtIndex:i];
		[timesheetsArray replaceObjectAtIndex:i withObject:[timesheet dictionaryRepresentation]];
	}
	
	[store setObject:timesheetsArray forKey:kCloudTimesheets];
	[store synchronize];
}

-(void)saveProducts
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}

	
	NSMutableArray *productsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
	
	for(int i=0;i<productsArray.count;i++)
	{
		ProductOBJ *product = [productsArray objectAtIndex:i];
		
		if([deletedItems containsObject:[product ID]])
		{
			[productsArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudProducts])
	{
		NSMutableArray *cloudProducts = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudProducts]];
		
		for(int i=0;i<cloudProducts.count;i++)
		{
			if([deletedItems containsObject:[[cloudProducts objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudProducts removeObjectAtIndex:i];
				i--;
			}
		}
		
		
		for(int i=0;i<cloudProducts.count;i++)
		{
			ProductOBJ *cloudProduct = [[ProductOBJ alloc] initWithContentsDictionary:[cloudProducts objectAtIndex:i]];
			
			for(int j=0;j<productsArray.count;j++)
			{
				ProductOBJ *product = [productsArray objectAtIndex:j];
				
				if([[cloudProduct ID] isEqual:[product ID]])
				{
					[productsArray replaceObjectAtIndex:j withObject:cloudProduct];
					
					[cloudProducts removeObjectAtIndex:i];
					
					j = (int)productsArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudProducts.count;i++)
		{
			ProductOBJ *cloudProduct = [[ProductOBJ alloc] initWithContentsDictionary:[cloudProducts objectAtIndex:i]];
			[productsArray addObject:cloudProduct];
		}
	}
	
	[data_manager saveProductsArrayToUserDefaults:productsArray forKey:kProductsKeyForNSUserDefaults];
	
	for(int i=0;i<productsArray.count;i++)
	{
		ProductOBJ *product = [productsArray objectAtIndex:i];
		[productsArray replaceObjectAtIndex:i withObject:[product contentsDictionary]];
	}
	
	[store setObject:productsArray forKey:kCloudProducts];
	[store synchronize];
}

-(void)saveClients
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}

	
	NSMutableArray *contactsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadClientsArrayFromUserDefaultsAtKey:kClientsKeyForNSUserDefaults]];
	
	for(int i=0;i<contactsArray.count;i++)
	{
		ClientOBJ *contact = [contactsArray objectAtIndex:i];
		
		if([deletedItems containsObject:[contact ID]])
		{
			[contactsArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudClients])
	{
		NSMutableArray *cloudContacts = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudClients]];
		
		for(int i=0;i<cloudContacts.count;i++)
		{
			if([deletedItems containsObject:[[cloudContacts objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudContacts removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudContacts.count;i++)
		{
			ClientOBJ *cloudContact = [[ClientOBJ alloc] initWithContentsDictionary:[cloudContacts objectAtIndex:i]];
			
			for(int j=0;j<contactsArray.count;j++)
			{
				ClientOBJ *contact = [contactsArray objectAtIndex:j];
				
				if([[cloudContact ID] isEqual:[contact ID]])
				{
					[contactsArray replaceObjectAtIndex:j withObject:cloudContact];
					
					[cloudContacts removeObjectAtIndex:i];
					
					j = (int)contactsArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudContacts.count;i++)
		{
			ClientOBJ *cloudContact = [[ClientOBJ alloc] initWithContentsDictionary:[cloudContacts objectAtIndex:i]];
			[contactsArray addObject:cloudContact];
		}
	}
	
	[data_manager saveClientsArrayToUserDefaults:contactsArray forKey:kClientsKeyForNSUserDefaults];
	
	for(int i=0;i<contactsArray.count;i++)
	{
		ClientOBJ *contact = [contactsArray objectAtIndex:i];
		[contactsArray replaceObjectAtIndex:i withObject:[contact contentsDictionary]];
	}
	
	[store setObject:contactsArray forKey:kCloudClients];
	[store synchronize];
}

-(void)saveProjects
{
	NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
	
	NSMutableDictionary *storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:[store dictionaryRepresentation]];
	NSMutableArray *deletedItems = [[NSMutableArray alloc] init];
	
	if([storeDictionary.allKeys containsObject:kCloudDeletedItems])
	{
		[deletedItems addObjectsFromArray:[storeDictionary objectForKey:kCloudDeletedItems]];
	}
	
	
	NSMutableArray *projectsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
	
	for(int i=0;i<projectsArray.count;i++)
	{
		ProjectOBJ *project = [projectsArray objectAtIndex:i];
		
		if([deletedItems containsObject:[project ID]])
		{
			[projectsArray removeObjectAtIndex:i];
			i--;
		}
	}
	
	if([storeDictionary.allKeys containsObject:kCloudProjects])
	{
		NSMutableArray *cloudProjects = [[NSMutableArray alloc] initWithArray:[storeDictionary objectForKey:kCloudProjects]];
		
		for(int i=0;i<cloudProjects.count;i++)
		{
			if([deletedItems containsObject:[[cloudProjects objectAtIndex:i] objectForKey:@"id"]])
			{
				[cloudProjects removeObjectAtIndex:i];
				i--;
			}
		}
		
		for(int i=0;i<cloudProjects.count;i++)
		{
			ProjectOBJ *cloudProject = [[ProjectOBJ alloc] initWithContentsDictionary:[cloudProjects objectAtIndex:i]];
			
			for(int j=0;j<projectsArray.count;j++)
			{
				ProjectOBJ *project = [projectsArray objectAtIndex:j];
				
				if([[cloudProject ID] isEqual:[project ID]])
				{
					[projectsArray replaceObjectAtIndex:j withObject:cloudProject];
					
					[cloudProjects removeObjectAtIndex:i];
					
					j = (int)projectsArray.count;
					i--;
				}
			}
		}
		
		for(int i=0;i<cloudProjects.count;i++)
		{
			ProjectOBJ *cloudProject = [[ProjectOBJ alloc] initWithContentsDictionary:[cloudProjects objectAtIndex:i]];
			[projectsArray addObject:cloudProject];
		}
	}
	
	[data_manager saveProjectsArrayToUserDefaults:projectsArray forKey:kProjectsKeyForNSUserDefaults];
	
	for(int i=0;i<projectsArray.count;i++)
	{
		ProjectOBJ *project = [projectsArray objectAtIndex:i];
		[projectsArray replaceObjectAtIndex:i withObject:[project contentsDictionary]];
	}
	
	[store setObject:projectsArray forKey:kCloudProjects];
	[store synchronize];
}

@end
