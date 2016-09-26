//
//  AppDelegate.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "AppDelegate.h"

#import "Defines.h"
#import "BottomBar.h"
#import "ProfileVC.h"

#import "HomeVC.h"
#import "ProductsVC.h"
#import "ClientsVC.h"
#import "SettingsVC.h"

#import "EstimatesVC_Q.h"
#import "EstimatesVC.h"
#import "PurchaseOrdersVC.h"

#import "ReceiptsVC.h"
#import "TimesheetVC.h"

#import "ProjectsVC.h"

#import "Reachability.h"
#import "MKStoreManager.h"

#import "DropboxManager.h"

#define kLanguageKeysUserDefaultsKey @"kLanguageKeysUserDefaultsKey"
#define LanguageKeysUodatedVersion1 1.f

@interface AppDelegate () <PinViewDelegate, AlertViewDelegate>

@end

@implementation AppDelegate

@synthesize tax_misconfigured;
@synthesize bottomBar;
@synthesize navigationController1;
@synthesize storeManager;

#pragma mark - DATE FORMAT

-(NSString*)userSelectedDateFormat
{
	kDateFormat type = [[CustomDefaults customObjectForKey:@"user_selected_date_format"] intValue];
	//comment here
	NSString * format = @"dd/MMM/yyyy";
	
	switch (type)
	{
		case kDateFormat1:
		{
			format = @"dd/MMM/yyyy";
			break;
		}
			
		case kDateFormat2:
		{
			format = @"dd/MM/yyyy";
			break;
		}
			
		case kDateFormat3:
		{
			format = @"MM/dd/yyyy";
			break;
		}
			
		default:
			break;
	}
	
	return format;
}

-(NSString*)formatForType:(kDateFormat)type
{
	NSString * format = @"dd/MMM/yyyy";
	
	switch (type)
	{
		case kDateFormat1:
		{
			format = @"dd/MMM/yyyy";
			break;
		}
			
		case kDateFormat2:
		{
			format = @"dd/MM/yyyy";
			break;
		}
			
		case kDateFormat3:
		{
			format = @"MM/dd/yyyy";
			break;
		}
			
		default:
			break;
	}
	
	return format;
}

-(void)transferData
{
	if(![CustomDefaults customObjectForKey:repairFiles])
	{
		[ObjectsDefaults createProductsFile];
		[ObjectsDefaults createClientsFile];
		[ObjectsDefaults createProjectsFile];
		
		switch (app_version)
		{
			case 0:
			{
				[InvoiceDefaults createFile];
				[QuoteDefaults createFile];
				[EstimateDefaults createFile];
				[PurchaseDefaults createFile];
				
				[ReceiptDefaults createFile];
				[TimesheetDefaults createFile];
								
				break;
			}
				
			case 1:
			{
				[QuoteDefaults createFile];
				
				break;
			}
				
			case 2:
			{
				[EstimateDefaults createFile];
				
				break;
			}
				
			case 3:
			{
				[PurchaseDefaults createFile];
				
				break;
			}
				
			case 4:
			{
				[ReceiptDefaults createFile];
				
				break;
			}
				
			case 5:
			{
				[TimesheetDefaults createFile];
				
				break;
			}
				
			default:
				break;
		}		
		
		[CustomDefaults setCustomObjects:@"1" forKey:repairFiles];
	}
		
	if(![CustomDefaults customObjectForKey:kAppUseCustomDefaults])
	{
		[CustomDefaults createFile];
		[CustomDefaults setContent:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
		
		[CustomDefaults setCustomObjects:@"1" forKey:kAppUseCustomDefaults];
    [CustomDefaults setCustomObjects:@"1" forKey:repairFiles];
	}
}

#pragma mark - APPLICATION DID FINISH LAUNCHING

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
		
	[self transferData];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	
	_internetReachability = [Reachability reachabilityForInternetConnection];
	[_internetReachability startNotifier];
	[self updateInterfaceWithReachability:_internetReachability];
	
	storeManager = [MKStoreManager sharedManager];
  
  [DropboxManager startSession];
	
	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
	[NSURLCache setSharedURLCache:sharedCache];
	
	revertPaperSize;
	
	tax_misconfigured = NO;
		
	bottomBar = [[BottomBar alloc] initWithFrame:CGRectMake(0, dvc_height - 25, dvc_width, 45)];
		
	[data_manager checkSymbols];
  
	[self checkNSUserDefaults];
						
	[self initializeViewControllers];
		
	if(![CustomDefaults customObjectForKey:@"FIRST_USE"]) {
		[CustomDefaults setCustomObjects:@"DONE" forKey:@"FIRST_USE"];
		
		ProfileVC * vc = [[ProfileVC alloc] init];
		[vc remakeForFirstUse];
		
		UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
		[nvc setNavigationBarHidden:YES];
		[(UINavigationController*)self.window.rootViewController presentViewController:nvc animated:YES completion:nil];
	}
	
	[self checkDocumentsCount];
		
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  return [DropboxManager handleOpenURL:url];
}

#pragma mark - REACHBILITY

-(void)reachabilityChanged:(NSNotification*)note
{
	Reachability * curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

-(void)updateInterfaceWithReachability:(Reachability*)reachability
{
	if (reachability == _internetReachability)
	{
		NetworkStatus netStatus = [reachability currentReachabilityStatus];
		
		_internetIsAvailable = NO;
		
		if (netStatus == ReachableViaWiFi || netStatus == ReachableViaWWAN)
		{
			_internetIsAvailable = YES;
		}
	}
}

#pragma mark - INAPP PURCHASE

-(void)buyPremiumApp
{
	[CustomDefaults setCustomBool:YES forKey:FULL_VERSION_KEY];
}

-(void)buyCSVExport
{
	[CustomDefaults setCustomBool:YES forKey:FULL_CSV_KEY];
}

-(void)buyDropboxBackup {
  [CustomDefaults setCustomBool:YES forKey:FULL_DROPBOX_BU_KEY];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:DROPBOX_BACKUP_DID_PURCHASE_NOTIFICATION object:nil];
}

-(void)checkNSUserDefaults
{
  NSString *firstPageNote = [[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] objectForKey:@"defaultNote"];
  if(!firstPageNote || [firstPageNote length] == 0) {
    firstPageNote = @"Thanks for your business!";
  }
  
	//INVOICE
	{
		if (![CustomDefaults customObjectForKey:INVOICE_OTHER_COMMENTS_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Other Comments" forKey:INVOICE_OTHER_COMMENTS_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:INVOICE_OTHER_COMMENTS_TEXT_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:INVOICE_OTHER_COMMENTS_TEXT_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:INVOICE_RIGHT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Right)" forKey:INVOICE_RIGHT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:INVOICE_LEFT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Left)" forKey:INVOICE_LEFT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:INVOICE_LEFT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:INVOICE_LEFT_SIGNATURE_PATH_KEY];
		}
		
		if ([[CustomDefaults customObjectForKey:INVOICE_FIRST_PAGE_NOTE_KEY] length] == 0)
		{
			[CustomDefaults setCustomObjects:firstPageNote forKey:INVOICE_FIRST_PAGE_NOTE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:INVOICE_SECOND_PAGE_NOTE_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:INVOICE_SECOND_PAGE_NOTE_KEY];
		}
	}
	
	//QUOTE
	{		
		if (![CustomDefaults customObjectForKey:QUOTE_OTHER_COMMENTS_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Other Comments" forKey:QUOTE_OTHER_COMMENTS_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:QUOTE_OTHER_COMMENTS_TEXT_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:QUOTE_OTHER_COMMENTS_TEXT_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:QUOTE_LEFT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Left)" forKey:QUOTE_LEFT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:QUOTE_LEFT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:QUOTE_LEFT_SIGNATURE_PATH_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:QUOTE_RIGHT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Right)" forKey:QUOTE_RIGHT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:QUOTE_RIGHT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:QUOTE_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		if ([[CustomDefaults customObjectForKey:QUOTE_FIRST_PAGE_NOTE_KEY] length] == 0)
		{
			[CustomDefaults setCustomObjects:firstPageNote forKey:QUOTE_FIRST_PAGE_NOTE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:QUOTE_SECOND_PAGE_NOTE_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:QUOTE_SECOND_PAGE_NOTE_KEY];
		}
	}
	
	//ESTIMATE
	{
		if (![CustomDefaults customObjectForKey:ESTIMATE_OTHER_COMMENTS_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Other Comments" forKey:ESTIMATE_OTHER_COMMENTS_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:ESTIMATE_OTHER_COMMENTS_TEXT_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:ESTIMATE_OTHER_COMMENTS_TEXT_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:ESTIMATE_LEFT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Left)" forKey:ESTIMATE_LEFT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:ESTIMATE_LEFT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:ESTIMATE_LEFT_SIGNATURE_PATH_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:ESTIMATE_RIGHT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Right)" forKey:ESTIMATE_RIGHT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:ESTIMATE_RIGHT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:ESTIMATE_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		if ([[CustomDefaults customObjectForKey:ESTIMATE_FIRST_PAGE_NOTE_KEY] length] == 0)
		{
			[CustomDefaults setCustomObjects:firstPageNote forKey:ESTIMATE_FIRST_PAGE_NOTE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:ESTIMATE_SECOND_PAGE_NOTE_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:ESTIMATE_SECOND_PAGE_NOTE_KEY];
		}
	}
	
	//PURCHASE ORDER
	{
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_OTHER_COMMENTS_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Other Comments" forKey:PURCHASE_ORDER_OTHER_COMMENTS_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_OTHER_COMMENTS_TEXT_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:PURCHASE_ORDER_OTHER_COMMENTS_TEXT_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_LEFT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Left)" forKey:PURCHASE_ORDER_LEFT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_LEFT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:PURCHASE_ORDER_LEFT_SIGNATURE_PATH_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_RIGHT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Right)" forKey:PURCHASE_ORDER_RIGHT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_RIGHT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:PURCHASE_ORDER_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		if ([[CustomDefaults customObjectForKey:PURCHASE_ORDER_FIRST_PAGE_NOTE_KEY] length] == 0)
		{
			[CustomDefaults setCustomObjects:firstPageNote forKey:PURCHASE_ORDER_FIRST_PAGE_NOTE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:PURCHASE_ORDER_SECOND_PAGE_NOTE_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:PURCHASE_ORDER_SECOND_PAGE_NOTE_KEY];
		}
	}
	
	// RECEIPT CATEGORIES
	{
		if(![CustomDefaults customObjectForKey:kDefaultCategories])
		{
			NSMutableArray *tempCategories = [[NSMutableArray alloc] initWithObjects:@"Accomodation",@"Advertisement",@"Airfare",@"Car Expense",@"Clothing",@"Communication",@"Electricity",@"Entertainment",@"Food",@"Fuel",@"Gas",@"General",@"Groceries",@"Hardware",@"Health",@"Insurance",@"Office",@"Rent",@"Repairs",@"Shipping",@"Software",@"Transportation",@"Travel",@"Phone",@"Utilities",@"Loans", nil];
			
			[CustomDefaults setCustomObjects:tempCategories forKey:kDefaultCategories];
		}
	}
		
	//TIMESHEET
	{
		if (![CustomDefaults customObjectForKey:kTimesheetTitleKeyForNSUserDefaults])
		{
			[CustomDefaults setCustomObjects:@"Timesheet" forKey:kTimesheetTitleKeyForNSUserDefaults];
		}
		
		if(![CustomDefaults customObjectForKey:kTimesheetStartTimeKey])
		{
			[date_formatter setDateFormat:@"HH:mm:ss"];
			[CustomDefaults setCustomObjects:[[NSDate alloc] initWithTimeInterval:0 sinceDate:[date_formatter dateFromString:@"07:00:00"]] forKey:kTimesheetStartTimeKey];
		}
		
		if(![CustomDefaults customObjectForKey:kTimesheetFinishTimeKey])
		{
			[date_formatter setDateFormat:@"HH:mm:ss"];
			[CustomDefaults setCustomObjects:[[NSDate alloc] initWithTimeInterval:0 sinceDate:[date_formatter dateFromString:@"15:00:00"]] forKey:kTimesheetFinishTimeKey];
		}
		
		if(![CustomDefaults customObjectForKey:kTimesheetBreakTimeKey])
		{
			[CustomDefaults setCustomObjects:@"0.0" forKey:kTimesheetBreakTimeKey];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_OTHER_COMMENTS_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Other Comments" forKey:TIMESHEET_OTHER_COMMENTS_TITLE_KEY];
		}
				
		if (![CustomDefaults customObjectForKey:TIMESHEET_OTHER_COMMENTS_TEXT_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:TIMESHEET_OTHER_COMMENTS_TEXT_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_RIGHT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Right)" forKey:TIMESHEET_RIGHT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_RIGHT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:TIMESHEET_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_LEFT_SIGNATURE_TITLE_KEY])
		{
			[CustomDefaults setCustomObjects:@"Signature (Left)" forKey:TIMESHEET_LEFT_SIGNATURE_TITLE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_LEFT_SIGNATURE_PATH_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:TIMESHEET_LEFT_SIGNATURE_PATH_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_FIRST_PAGE_NOTE_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:TIMESHEET_FIRST_PAGE_NOTE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:TIMESHEET_SECOND_PAGE_NOTE_KEY])
		{
			[CustomDefaults setCustomObjects:@"" forKey:TIMESHEET_SECOND_PAGE_NOTE_KEY];
		}
		
		if (![CustomDefaults customObjectForKey:kDefaultServiceTime])
		{
			[CustomDefaults setCustomObjects:[[[ServiceTimeOBJ alloc] init] dictionaryRepresentation] forKey:kDefaultServiceTime];
		}
	}
    
        if(![CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] ||
       ([[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] isKindOfClass:[NSDictionary class]] &&
        [[(NSDictionary*)[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] allKeys] count] != 13))
	{
		NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] init];
		[settingsDictionary setObject:[NSNumber numberWithInt:0] forKey:@"terms"];
		[settingsDictionary setObject:@"No Tax" forKey:@"taxType"];
		[settingsDictionary setObject:@"0.0" forKey:@"taxRate1"];
		[settingsDictionary setObject:@"" forKey:@"taxAbreviation1"];
		[settingsDictionary setObject:@"0.0" forKey:@"taxRate2"];
		[settingsDictionary setObject:@"" forKey:@"taxAbreviation2"];
		[settingsDictionary setObject:@"" forKey:@"taxRegNo"];
		[settingsDictionary setObject:@"Thanks for your business!" forKey:@"defaultNote"];
		[settingsDictionary setObject:@"0" forKey:@"passwordLock"];
		[settingsDictionary setObject:@"9.7" forKey:@"version"];
		[settingsDictionary setObject:@"ABN" forKey:@"businessName"];
		[settingsDictionary setObject:@"" forKey:@"businessNumber"];
		
		[CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
	}
    
	NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
    
	if(![settingsDict.allKeys containsObject:@"background_image"])
	{
		[settingsDict setObject:@"" forKey:@"background_image"];
	}
    else
    {
        NSString *imagePath = [settingsDict objectForKey:@"background_image"];
        
        if([[imagePath componentsSeparatedByString:@"/Documents/"] count] > 1)
        {
            NSString *documentsString = [NSString stringWithFormat:@"/Documents/%@",[[imagePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1]];
            [settingsDict setObject:documentsString forKey:@"background_image"];
        }
        
    }
			
	kApplicationVersion version = app_version;
	
	switch (version)
	{
		case kApplicationVersionInvoice:
		{
			[settingsDict setObject:@"9.7" forKey:@"version"];
			break;
		}
			
		case kApplicationVersionEstimate:
		{
			[settingsDict setObject:@"9.7" forKey:@"version"];
			break;
		}
			
		case kApplicationVersionPurchase:
		{
			[settingsDict setObject:@"9.7" forKey:@"version"];
			break;
		}
			
		case kApplicationVersionQuote:
		{
			[settingsDict setObject:@"9.7" forKey:@"version"];
			break;
		}
			
		case kApplicationVersionReceipts:
		{
			[settingsDict setObject:@"9.7" forKey:@"version"];
			break;
		}
			
		case kApplicationVersionTimesheets:
		{
			[settingsDict setObject:@"9.7" forKey:@"version"];
			break;
		}
			
		default:
			break;
	}
	
	[CustomDefaults setCustomObjects:settingsDict forKey:kSettingsKeyForNSUserDefaults];
	
	if ([CustomDefaults customIntegerForKey:kNumberOfInvoicesKeyForNSUserDefaults] < 1)
	{
		[CustomDefaults setCustomInteger:1 forKey:kNumberOfInvoicesKeyForNSUserDefaults];
	}
	
	if ([CustomDefaults customIntegerForKey:kNumberOfQuotesKeyForNSUserDefaults] < 1)
	{
		[CustomDefaults setCustomInteger:1 forKey:kNumberOfQuotesKeyForNSUserDefaults];
	}
	
	if ([CustomDefaults customIntegerForKey:kNumberOfEstimatesKeyForNSUserDefaults] < 1)
	{
		[CustomDefaults setCustomInteger:1 forKey:kNumberOfEstimatesKeyForNSUserDefaults];
	}
	
	if ([CustomDefaults customIntegerForKey:kNumberOfPurchaseOrdersKeyForNSUserDefaults] < 1)
	{
		[CustomDefaults setCustomInteger:1 forKey:kNumberOfPurchaseOrdersKeyForNSUserDefaults];
	}

	if ([CustomDefaults customIntegerForKey:kNumberOfRecipeKeyForNSUserDefaults] < 1)
	{
		[CustomDefaults setCustomInteger:1 forKey:kNumberOfRecipeKeyForNSUserDefaults];
	}
	
	if ([CustomDefaults customIntegerForKey:kNumberOfTimesheetKeyForNSUserDefaults] < 1)
	{
		[CustomDefaults setCustomInteger:1 forKey:kNumberOfTimesheetKeyForNSUserDefaults];
	}
	
	if (![CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Billing address" forKey:kBillingAddressTitleKeyForNSUserDefaults];
	}
  
  if (![CustomDefaults customObjectForKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults])
  {
    [CustomDefaults setCustomObjects:@"Invoice to" forKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults];
  }
	
	if (![CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Shipping address" forKey:kShippingAddressTitleKeyForNSUserDefaults];
	}
  
  if (![CustomDefaults customObjectForKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults])
  {
    [CustomDefaults setCustomObjects:@"Ship to" forKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults];
  }
	
	if (![CustomDefaults customObjectForKey:kInvoiceTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Invoice" forKey:kInvoiceTitleKeyForNSUserDefaults];
	}
	
	if (![CustomDefaults customObjectForKey:kEstimateTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Estimate" forKey:kEstimateTitleKeyForNSUserDefaults];
	}
	
	if (![CustomDefaults customObjectForKey:kQuoteTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Quote" forKey:kQuoteTitleKeyForNSUserDefaults];
	}
	
	if (![CustomDefaults customObjectForKey:kPurchaseOrderTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Purchase Order" forKey:kPurchaseOrderTitleKeyForNSUserDefaults];
	}
	
	if (![CustomDefaults customObjectForKey:kReceiptTitleKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"Receipt" forKey:kReceiptTitleKeyForNSUserDefaults];
	}
			
	if (![CustomDefaults customObjectForKey:kSyncValue])
	{
		[CustomDefaults setCustomObjects:@"0" forKey:kSyncValue];
	}
	
	if(![CustomDefaults customObjectForKey:DEVICE_ID])
	{
		[CustomDefaults setCustomObjects:[data_manager generateDeviceID] forKey:DEVICE_ID];
	}
	
	if(![CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults])
	{
		NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] init];
		
		NSMutableDictionary *invoiceDict = [[NSMutableDictionary alloc] init];
		[invoiceDict setObject:kInvTitle        forKey:@"Invoice"];
		[invoiceDict setObject:@"Invoice No"    forKey:@"Invoice No"];
		[invoiceDict setObject:@"Invoice date"  forKey:@"Invoice date"];
		[invoiceDict setObject:@"Due date"      forKey:@"Due date"];
        [invoiceDict setObject:@"Date"          forKey:@"Date"];
        [invoiceDict setObject:@"Terms"         forKey:@"Terms"];
		[invoiceDict setObject:@"Project Name"  forKey:@"Project Name"];
		[invoiceDict setObject:@"Project No"    forKey:@"Project No"];
		[invoiceDict setObject:@"Invoice to"    forKey:@"Invoice to"];
		[invoiceDict setObject:@"Ship to"       forKey:@"Ship to"];
		[invoiceDict setObject:@"Item"          forKey:@"Item"];
		[invoiceDict setObject:@"Description"   forKey:@"Description"];
		[invoiceDict setObject:@"D(%)"          forKey:@"D(%)"];
		[invoiceDict setObject:@"Qty"           forKey:@"Qty"];
		[invoiceDict setObject:@"Rate"          forKey:@"Rate"];
		[invoiceDict setObject:@"Amount"        forKey:@"Amount"];
        [invoiceDict setObject:@"Code"          forKey:@"Code"];
		[invoiceDict setObject:@"Subtotal"      forKey:@"Subtotal"];
		[invoiceDict setObject:@"Discount"      forKey:@"Discount"];
		[invoiceDict setObject:@"Shipping"      forKey:@"Shipping"];
		[invoiceDict setObject:@"Total"         forKey:@"Total"];
		[invoiceDict setObject:@"Paid"          forKey:@"Paid"];
		[invoiceDict setObject:@"Balance due"   forKey:@"Balance due"];
		[invoiceDict setObject:@"Other Comments" forKey:@"Other Comments"];
		
		[languageDict setObject:invoiceDict forKey:@"invoice"];
		
		NSMutableDictionary *quoteDict = [[NSMutableDictionary alloc] init];
		[quoteDict setObject:kQuoTitle forKey:@"Quote"];
		[quoteDict setObject:@"Quote No" forKey:@"Quote No"];
		[quoteDict setObject:@"Quote date" forKey:@"Quote date"];
		[quoteDict setObject:@"Project Name" forKey:@"Project Name"];
		[quoteDict setObject:@"Project No" forKey:@"Project No"];
		[quoteDict setObject:@"Item" forKey:@"Item"];
		[quoteDict setObject:@"Description" forKey:@"Description"];
		[quoteDict setObject:@"D(%)" forKey:@"D(%)"];
		[quoteDict setObject:@"Qty" forKey:@"Qty"];
		[quoteDict setObject:@"Rate" forKey:@"Rate"];
		[quoteDict setObject:@"Amount" forKey:@"Amount"];
        [quoteDict setObject:@"Code" forKey:@"Code"];
		[quoteDict setObject:@"Subtotal" forKey:@"Subtotal"];
		[quoteDict setObject:@"Discount" forKey:@"Discount"];
		[quoteDict setObject:@"Shipping" forKey:@"Shipping"];
		[quoteDict setObject:@"Total" forKey:@"Total"];
		[quoteDict setObject:@"Billing address" forKey:@"Billing address"];
		[quoteDict setObject:@"Shipping address" forKey:@"Shipping address"];
		
		[languageDict setObject:quoteDict forKey:@"quote"];
		
		NSMutableDictionary *estimateDict = [[NSMutableDictionary alloc] init];
		[estimateDict setObject:kEstTitle forKey:@"Estimate"];
		[estimateDict setObject:@"Estimate No" forKey:@"Estimate No"];
		[estimateDict setObject:@"Estimate date" forKey:@"Estimate date"];
		[estimateDict setObject:@"Project Name" forKey:@"Project Name"];
		[estimateDict setObject:@"Project No" forKey:@"Project No"];
		[estimateDict setObject:@"Item" forKey:@"Item"];
		[estimateDict setObject:@"Description" forKey:@"Description"];
		[estimateDict setObject:@"D(%)" forKey:@"D(%)"];
		[estimateDict setObject:@"Qty" forKey:@"Qty"];
		[estimateDict setObject:@"Rate" forKey:@"Rate"];
		[estimateDict setObject:@"Amount" forKey:@"Amount"];
        [estimateDict setObject:@"Code" forKey:@"Code"];
		[estimateDict setObject:@"Subtotal" forKey:@"Subtotal"];
		[estimateDict setObject:@"Discount" forKey:@"Discount"];
		[estimateDict setObject:@"Shipping" forKey:@"Shipping"];
		[estimateDict setObject:@"Total" forKey:@"Total"];
		[estimateDict setObject:@"Billing address" forKey:@"Billing address"];
		[estimateDict setObject:@"Shipping address" forKey:@"Shipping address"];
		
		[languageDict setObject:estimateDict forKey:@"estimate"];
		
		NSMutableDictionary *purchaseDict = [[NSMutableDictionary alloc] init];
		[purchaseDict setObject:kPurTitle forKey:@"Purchase Order"];
		[purchaseDict setObject:@"P.O. No" forKey:@"P.O. No"];
		[purchaseDict setObject:@"P.O. date" forKey:@"P.O. date"];
		[purchaseDict setObject:@"Project Name" forKey:@"Project Name"];
		[purchaseDict setObject:@"Project No" forKey:@"Project No"];
		[purchaseDict setObject:@"Item" forKey:@"Item"];
		[purchaseDict setObject:@"Description" forKey:@"Description"];
		[purchaseDict setObject:@"D(%)" forKey:@"D(%)"];
		[purchaseDict setObject:@"Qty" forKey:@"Qty"];
		[purchaseDict setObject:@"Rate" forKey:@"Rate"];
		[purchaseDict setObject:@"Amount" forKey:@"Amount"];
        [purchaseDict setObject:@"Code" forKey:@"Code"];
		[purchaseDict setObject:@"Subtotal" forKey:@"Subtotal"];
		[purchaseDict setObject:@"Discount" forKey:@"Discount"];
		[purchaseDict setObject:@"Shipping" forKey:@"Shipping"];
		[purchaseDict setObject:@"Total" forKey:@"Total"];
		[purchaseDict setObject:@"Billing address" forKey:@"Billing address"];
		[purchaseDict setObject:@"Shipping address" forKey:@"Shipping address"];
		
		[languageDict setObject:purchaseDict forKey:@"purchase"];
		
		NSMutableDictionary *receiptDict = [[NSMutableDictionary alloc] init];
		[receiptDict setObject:@"Title" forKey:@"Title"];
		[receiptDict setObject:@"Number" forKey:@"Number"];
		[receiptDict setObject:@"Category" forKey:@"Category"];
		[receiptDict setObject:@"Project No" forKey:@"Project No"];
		[receiptDict setObject:@"Vendor" forKey:@"Vendor"];
		[receiptDict setObject:@"Description" forKey:@"Description"];
		[receiptDict setObject:@"Date" forKey:@"Date"];
		[receiptDict setObject:@"Receipts" forKey:@"Receipts"];
		[receiptDict setObject:@"Total" forKey:@"Total"];
		[receiptDict setObject:[CustomDefaults customObjectForKey:kReceiptTitleKeyForNSUserDefaults] forKey:@"Receipt"];
		
		[languageDict setObject:receiptDict forKey:@"receipt"];
		
		NSMutableDictionary *timesheetDict = [[NSMutableDictionary alloc] init];
		[timesheetDict setObject:@"Timesheet No" forKey:@"Timesheet No"];
		[timesheetDict setObject:@"Timesheet to" forKey:@"Timesheet to"];
		[timesheetDict setObject:@"Timesheet date" forKey:@"Timesheet date"];
		[timesheetDict setObject:@"Date" forKey:@"Date"];
		[timesheetDict setObject:@"Ship to" forKey:@"Ship to"];
		[timesheetDict setObject:@"Day" forKey:@"Day"];
		[timesheetDict setObject:@"Start" forKey:@"Start"];
		[timesheetDict setObject:@"Finish" forKey:@"Finish"];
		[timesheetDict setObject:@"Break" forKey:@"Break"];
		[timesheetDict setObject:@"Overtime" forKey:@"Overtime"];
		[timesheetDict setObject:@"Total" forKey:@"Total"];
		[timesheetDict setObject:@"Total Hours" forKey:@"Total Hours"];
		[timesheetDict setObject:@"Project Name" forKey:@"Project Name"];
		[timesheetDict setObject:@"Project No" forKey:@"Project No"];
		[timesheetDict setObject:[CustomDefaults customObjectForKey:kTimesheetTitleKeyForNSUserDefaults] forKey:@"Timesheet"];
		
		[languageDict setObject:timesheetDict forKey:@"timesheet"];
		
		[CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
	}
    
    [self updateLanguageKyesVersion];
	
	if(![CustomDefaults customObjectForKey:kDefaultTaxable])
	{
		if(![[[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults] objectForKey:@"taxType"] isEqual:@"No Tax"])
		{
			[CustomDefaults setCustomBool:YES forKey:kDefaultTaxable];
		}
		else
		{
			[CustomDefaults setCustomBool:NO forKey:kDefaultTaxable];
		}
	}
	
	if(![CustomDefaults customObjectForKey:repairImages])
	{
		[self repairImagePaths];
			
		[CustomDefaults setCustomObjects:@"1" forKey:repairImages];
	}
	
	if(![CustomDefaults customObjectForKey:kUpdatedApp])
	{
		[sync_manager startSyncWithSelector:@selector(checkObjectsID)];
	}
	else
	{
		[SyncManager sharedManager];
	}
}

- (void)updateLanguageKyesVersion {
    CGFloat version = [[NSUserDefaults standardUserDefaults] floatForKey:kLanguageKeysUserDefaultsKey];
    if(version < LanguageKeysUodatedVersion1) {
        NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
        
        NSMutableDictionary *invoiceDict = [NSMutableDictionary dictionaryWithDictionary:[languageDict objectForKey:@"invoice"]];
        [invoiceDict setObject:@"Date" forKey:@"Date"];
        [invoiceDict setObject:@"Terms" forKey:@"Terms"];
        [invoiceDict setObject:@"Code" forKey:@"Code"];
        [languageDict setObject:invoiceDict forKey:@"invoice"];
        
        NSMutableDictionary *quoteDict = [NSMutableDictionary dictionaryWithDictionary:[languageDict objectForKey:@"quote"]];
        [quoteDict setObject:@"Code" forKey:@"Code"];
        [languageDict setObject:quoteDict forKey:@"quote"];
        
        NSMutableDictionary *estimateDict = [NSMutableDictionary dictionaryWithDictionary:[languageDict objectForKey:@"estimate"]];
        [estimateDict setObject:@"Code" forKey:@"Code"];
        [languageDict setObject:estimateDict forKey:@"estimate"];
        
        NSMutableDictionary *purchaseDict = [NSMutableDictionary dictionaryWithDictionary:[languageDict objectForKey:@"purchase"]];
        [purchaseDict setObject:@"Code"          forKey:@"Code"];
        [languageDict setObject:purchaseDict forKey:@"purchase"];
        
        [CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
    }
    
    [[NSUserDefaults standardUserDefaults] setFloat:LanguageKeysUodatedVersion1 forKey:kLanguageKeysUserDefaultsKey];
}

#pragma mark - DOCUMENTS COUNT

-(void)incrementDocumentsCount
{
	if (!free_version)
		return;
	
	[CustomDefaults setCustomInteger:DOCUMENTS_COUNT + 1 forKey:DOCUMENTS_COUNT_KEY];
	
	[self checkDocumentsCount];
}

-(void)checkDocumentsCount
{	
	if (!free_version)
		return;
	
	BOOL fullVersion = [CustomDefaults customBoolForKey:FULL_VERSION_KEY];
	
	if (DOCUMENTS_COUNT >= 5 && fullVersion == NO)
	{
		NSArray * otherButtons = [NSArray arrayWithObjects:@"Ok", @"Restore", nil];
		
		AlertView * alert = [[AlertView alloc] initWithTitle:@"Upgrading to Premium version" message:@"Would you like to create unlimited documents? Please upgrade to the Premium version" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:otherButtons];
		[alert setTag:11];
		[alert showInWindow];
	}
}

-(BOOL)documentsLimitReached
{
	if (!free_version)
	{
		return NO;
	}
	
	if (isFullVersion)
	{
		return NO;
	}
	
	if (DOCUMENTS_COUNT >= 5)
	{
		NSArray * otherButtons = [NSArray arrayWithObjects:@"Ok", @"Restore", nil];
		
		AlertView * alert = [[AlertView alloc] initWithTitle:@"Upgrading to Premium version" message:@"Would you like to create unlimited documents? Please upgrade to the Premium version" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:otherButtons];
		[alert setTag:11];
		[alert showInWindow];
		
		return YES;
	}
	
	return NO;
}

-(void)checkDropboxBackupEnable {
  if(isFullDROPBOX_BU) return;
  
  NSArray * otherButtons = [NSArray arrayWithObjects:@"Ok", @"Restore", nil];
		
		AlertView * alert = [[AlertView alloc] initWithTitle:@"" message:@"Would you like to automatically save all your documents in PDF in your dropbox?" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:otherButtons];
		[alert setTag:22];
		[alert showInWindow];
}

#pragma mark - NAVIGATION

-(void)initializeViewControllers
{
	switch (app_version)
	{
		case kApplicationVersionInvoice:
		{
			HomeVC * vc1 = [[HomeVC alloc] init];
			navigationController1 = [[UINavigationController alloc] initWithRootViewController:vc1];
			[navigationController1 setNavigationBarHidden:YES];
			break;
		}
			
		case kApplicationVersionQuote:
		{
			EstimatesVC_Q * vc1 = [[EstimatesVC_Q alloc] init];
			navigationController1 = [[UINavigationController alloc] initWithRootViewController:vc1];
			[navigationController1 setNavigationBarHidden:YES];
			break;
		}
			
		case kApplicationVersionEstimate:
		{
			EstimatesVC * vc1 = [[EstimatesVC alloc] init];
			navigationController1 = [[UINavigationController alloc] initWithRootViewController:vc1];
			[navigationController1 setNavigationBarHidden:YES];
			break;
		}
			
		case kApplicationVersionPurchase:
		{
			PurchaseOrdersVC * vc1 = [[PurchaseOrdersVC alloc] init];
			navigationController1 = [[UINavigationController alloc] initWithRootViewController:vc1];
			[navigationController1 setNavigationBarHidden:YES];
			break;
		}
			
		case kApplicationVersionReceipts:
		{
			ReceiptsVC *vc = [[ReceiptsVC alloc] init];
			navigationController1 = [[UINavigationController alloc] initWithRootViewController:vc];
			[navigationController1 setNavigationBarHidden:YES];
			
			break;
		}
			
		case kApplicationVersionTimesheets:
		{
			TimesheetVC *vc = [[TimesheetVC alloc] init];
			navigationController1 = [[UINavigationController alloc] initWithRootViewController:vc];
			[navigationController1 setNavigationBarHidden:YES];
			
			break;
		}
						
		default:
			break;
	}
	
	ProductsVC * vc2 = [[ProductsVC alloc] init];
	navigationController2 = [[UINavigationController alloc] initWithRootViewController:vc2];
	[navigationController2 setNavigationBarHidden:YES];
	
	ClientsVC * vc3 = [[ClientsVC alloc] init];
	navigationController3 = [[UINavigationController alloc] initWithRootViewController:vc3];
	[navigationController3 setNavigationBarHidden:YES];
	
	ProjectsVC *vc5 = [[ProjectsVC alloc] init];
	navigationController5 = [[UINavigationController alloc] initWithRootViewController:vc5];
	[navigationController5 setNavigationBarHidden:YES];
	
	SettingsVC * vc4 = [[SettingsVC alloc] init];
	navigationController4 = [[UINavigationController alloc] initWithRootViewController:vc4];
	[navigationController4 setNavigationBarHidden:YES];
	
	last_index = 1;
	
	[navigationController1.view addSubview:bottomBar];
	[self.window setRootViewController:navigationController1];
	[bottomBar selectButton:1];
}

-(void)goToTab:(UIButton*)sender
{
	if (tax_misconfigured && sender.tag != 5)
	{
		NSString * message = @"The tax type you selected seems to be misconfigured. The taxes must have an abreviation and their value must be greater than 0 (zero).";
		[[[AlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
		return;
	}
	
	[bottomBar selectButton:(int)sender.tag];
	
	switch (sender.tag)
	{
		case 1:
		{
			[navigationController1.view addSubview:bottomBar];
			[self.window setRootViewController:navigationController1];
			
			break;
		}
			
		case 2:
		{
			[navigationController2.view addSubview:bottomBar];
			[self.window setRootViewController:navigationController2];
			
			break;
		}
			
		case 3:
		{
			[navigationController3.view addSubview:bottomBar];
			[self.window setRootViewController:navigationController3];
			
			break;
		}
			
		case 4:
		{
			[navigationController5.view addSubview:bottomBar];
			[self.window setRootViewController:navigationController5];
			break;
		}
			
		case 5:
		{
			[navigationController4.view addSubview:bottomBar];
			[self.window setRootViewController:navigationController4];
			
			break;
		}
			
		default:
			break;
	}
	
	if (last_index == sender.tag)
	{
		[(UINavigationController*)self.window.rootViewController popToRootViewControllerAnimated:YES];
	}
	
	last_index = (int)sender.tag;
}

#pragma mark - LOADING VIEW

-(void)addLoadingView
{
	number_of_loading_views++;
	
	if ([self.window viewWithTag:333] != nil)
		[[self.window viewWithTag:333] removeFromSuperview];
	
	UIView * loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height + 20)];
	[loadingView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	[loadingView setTag:333];
	[self.window addSubview:loadingView];
	
	UIView * activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
	[activityView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.75]];
	[activityView.layer setMasksToBounds:YES];
	[activityView.layer setCornerRadius:6];
	[activityView setCenter:CGPointMake(dvc_width / 2, dvc_height / 2)];
	[loadingView addSubview:activityView];
	
	UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
	[activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
	[activity startAnimating];
	[activityView addSubview:activity];
}

-(void)removeLoadingView
{
	if (number_of_loading_views > 0)
		number_of_loading_views--;
	
	if (number_of_loading_views == 0)
		if ([self.window viewWithTag:333] != nil)
			[[self.window viewWithTag:333] removeFromSuperview];
}

#pragma mark - PIN VIEW DELEGATE

-(void)pinView:(PinView*)view FinishedEnteringPin:(NSString*)pin
{
	if ([[CustomDefaults customObjectForKey:kPinKeyForNSUserDefaults] isEqual:pin])
	{
		[view resignFirstResponder];
		
		[UIView animateWithDuration:0.25 animations:^{
			
			[view setAlpha:0.0];
			
		} completion:^(BOOL finished) {
			
			[view removeFromSuperview];
			pinView = nil;
			
		}];
	}
	else
	{
		[view removeFromSuperview];
		
		pinView = [[PinView alloc] initWithTitle:@"Enter PIN" backButtonType:kBackButtonTypeNone];
		[pinView setDelegate:self];
		pinView.backgroundColor = app_background_color;
		[pinView setFrame:CGRectMake(0, 20, dvc_width, dvc_height)];
		[self.window addSubview:pinView];
		
		[pinView resignFirstResponder];
		
		[[[AlertView alloc] initWithTitle:@"Wrong PIN. Try again." message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
	}
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 11 || alertView.tag == 22) {
		if (buttonIndex == 0) {
			//cancel
		} else if (buttonIndex == 1) {
			//ok
			
			if (_purchase_in_progres) {
				[[[AlertView alloc] initWithTitle:@"" message:@"Another purchase is in progress" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] showInWindow];
			} else {
        if (alertView.tag == 11) {
          [storeManager buyPremiumApp];
        } else if (alertView.tag == 22) {
          [storeManager buyDropboxBackup];
        }
			}
		} else if (buttonIndex == 2) {
			//restore
			
			if (_purchase_in_progres) {
				[[[AlertView alloc] initWithTitle:@"" message:@"Another purchase is in progress" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] showInWindow];
			} else {
				[storeManager restorePurchases];
			}
		}
		
		return;
	}
	
	[pinView becomeFirstResponder];
}

#pragma mark - APPLICATION DID SOMETHING

-(void)applicationDidBecomeActive:(UIApplication*)application
{
	if ([CustomDefaults customObjectForKey:kPinKeyForNSUserDefaults] && !pinView)
	{
		pinView = [[PinView alloc] initWithTitle:@"Enter PIN" backButtonType:kBackButtonTypeNone];
		pinView.backgroundColor = app_background_color;
		[pinView setDelegate:self];
		[pinView setFrame:CGRectMake(0, 20, dvc_width, dvc_height)];
		[self.window addSubview:pinView];
	}
}

-(void)repairImagePaths
{
	// INVOICE
	{
		NSMutableArray *invoiceArray = [[NSMutableArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
		
		for(InvoiceOBJ *invoice in invoiceArray)
		{
			[invoice repairSignatures];
		}
		
		NSString *filePath = [[NSString alloc] initWithString:INVOICE_RIGHT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		filePath = [[NSString alloc] initWithString:INVOICE_LEFT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:INVOICE_LEFT_SIGNATURE_PATH_KEY];
		}
		
		[data_manager saveInvoicesArrayToUserDefaults:invoiceArray forKey:kInvoicesKeyForNSUserDefaults];
	}
	
	// QUOTE
	{
		NSMutableArray *quoteArray = [[NSMutableArray alloc] initWithArray:[data_manager loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults]];
		
		for(QuoteOBJ *quote in quoteArray)
		{
			[quote repairSignatures];
		}
		
		NSString *filePath = [[NSString alloc] initWithString:QUOTE_RIGHT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:QUOTE_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		filePath = [[NSString alloc] initWithString:QUOTE_LEFT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:QUOTE_LEFT_SIGNATURE_PATH_KEY];
		}
		
		[data_manager saveQuotesArrayToUserDefaults:quoteArray forKey:kQuotesKeyForNSUserDefaults];
	}
	
	// Estimate
	{
		NSMutableArray *estimateArray = [[NSMutableArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
		
		for(EstimateOBJ *estimate in estimateArray)
		{
			[estimate repairSignatures];
		}
		
		NSString *filePath = [[NSString alloc] initWithString:ESTIMATE_RIGHT_SIGNATURE_PATH];
				
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:ESTIMATE_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		filePath = [[NSString alloc] initWithString:ESTIMATE_LEFT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:ESTIMATE_LEFT_SIGNATURE_PATH_KEY];
		}
		
		[data_manager saveEstimatesArrayToUserDefaults:estimateArray forKey:kEstimatesKeyForNSUserDefaults];
	}
	
	// Purchase Order
	{
		NSMutableArray *purchaseArray = [[NSMutableArray alloc] initWithArray:[data_manager loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults]];
		
		for(PurchaseOrderOBJ *purchase in purchaseArray)
		{
			[purchase repairSignatures];
		}
		
		NSString *filePath = [[NSString alloc] initWithString:PURCHASE_ORDER_RIGHT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:PURCHASE_ORDER_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		filePath = [[NSString alloc] initWithString:PURCHASE_ORDER_LEFT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:PURCHASE_ORDER_LEFT_SIGNATURE_PATH_KEY];
		}
		
		[data_manager savePurchaseOrdersArrayToUserDefaults:purchaseArray forKey:kPurchaseOrdersKeyForNSUserDefaults];
	}
		
	// Timesheet
	{
		NSString *filePath = [[NSString alloc] initWithString:TIMESHEET_RIGHT_SIGNATURE_PATH];
				
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:TIMESHEET_RIGHT_SIGNATURE_PATH_KEY];
		}
		
		filePath = [[NSString alloc] initWithString:TIMESHEET_LEFT_SIGNATURE_PATH];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[CustomDefaults setCustomObjects:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:TIMESHEET_LEFT_SIGNATURE_PATH_KEY];
		}
	}
		
	NSMutableArray *receiptsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
						
	for(ReceiptOBJ *receipt in receiptsArray)
	{
		[receipt repairImagePath];
	}
		
	[data_manager saveReceiptsArrayToUserDefaults:receiptsArray forKey:kReceiptsKeyForNSUserDefaults];
}

#pragma mark - CHECK TAX

-(void)checkTaxConfiguration
{
  NSDictionary *settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
  BOOL misconfigured = NO;
  
  if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"])
  {
    NSString * abr1 = [settingsDictionary objectForKey:@"taxAbreviation1"];
    NSString * rate1 = [settingsDictionary objectForKey:@"taxRate1"];
    
    if ([abr1 isEqual:@""] || [rate1 floatValue] == 0.0f)
    {
      misconfigured = YES;
    }
  }
  else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Compound Tax"])
  {
    NSString * abr1 = [settingsDictionary objectForKey:@"taxAbreviation1"];
    NSString * rate1 = [settingsDictionary objectForKey:@"taxRate1"];
    
    NSString * abr2 = [settingsDictionary objectForKey:@"taxAbreviation2"];
    NSString * rate2 = [settingsDictionary objectForKey:@"taxRate2"];
    
    if ([abr1 isEqual:@""] || [rate1 floatValue] == 0.0f || [abr2 isEqual:@""] || [rate2 floatValue] == 0.0f)
    {
      misconfigured = YES;
    }
  }
  
  [self setTax_misconfigured:misconfigured];
}


@end