//
//  AppDelegate.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	kApplicationVersionInvoice = 0,
	kApplicationVersionQuote = 1,
	kApplicationVersionEstimate = 2,
	kApplicationVersionPurchase = 3,
	kApplicationVersionReceipts = 4,
	kApplicationVersionTimesheets = 5
	
} kApplicationVersion;

typedef enum {
	
	kDateFormat1 = 0,
	kDateFormat2,
	kDateFormat3
	
} kDateFormat;

@class BottomBar;
@class PinView;
@class Reachability;
@class MKStoreManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
	BottomBar * bottomBar;
	PinView * pinView;
	UINavigationController * navigationController1;
	UINavigationController * navigationController2;
	UINavigationController * navigationController3;
	UINavigationController * navigationController4;
	UINavigationController *navigationController5;
	int last_index;
	int number_of_loading_views;
}

@property (strong) UINavigationController *navigationController1;
@property (strong, nonatomic) UIWindow * window;
@property BOOL tax_misconfigured;
@property BOOL purchase_in_progres;
@property (nonatomic) Reachability * internetReachability;
@property BOOL internetIsAvailable;
@property (strong) MKStoreManager * storeManager;
@property (strong) BottomBar *bottomBar;

-(void)reachabilityChanged:(NSNotification*)note;
-(void)updateInterfaceWithReachability:(Reachability*)reachability;

-(void)buyPremiumApp;
-(void)buyCSVExport;
-(void)buyDropboxBackup;

-(NSString*)userSelectedDateFormat;
-(NSString*)formatForType:(kDateFormat)type;

-(void)initializeViewControllers;
-(void)goToTab:(UIButton*)sender;

-(void)addLoadingView;
-(void)removeLoadingView;

-(void)incrementDocumentsCount;
-(void)checkDocumentsCount;
-(BOOL)documentsLimitReached;

-(void)checkDropboxBackupEnable;

-(void)checkNSUserDefaults;
-(void)repairImagePaths;

-(void)checkTaxConfiguration;

@end