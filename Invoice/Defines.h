//
//  Defines.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#ifndef Invoice_Defines_h
#define Invoice_Defines_h

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "AppDelegate.h"

#import "InvoiceUserDefaults.h"
#import "QuoteUserDefaults.h"
#import "EstimateUserDefaults.h"
#import "PurchaseUserDefaults.h"
#import "ReceiptUserDefaults.h"
#import "TimesheetUserDefaults.h"
#import "ObjectsUserDefaults.h"
#import "CustomUserDefaults.h"

#define DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define InvoiceDefaults [InvoiceUserDefaults defaultUserDefaults]
#define QuoteDefaults [QuoteUserDefaults defaultUserDefaults]
#define EstimateDefaults [EstimateUserDefaults defaultUserDefaults]
#define PurchaseDefaults [PurchaseUserDefaults defaultUserDefaults]
#define ReceiptDefaults [ReceiptUserDefaults defaultUserDefaults]
#define TimesheetDefaults [TimesheetUserDefaults defaultUserDefaults]
#define ObjectsDefaults [ObjectsUserDefaults defaultUserDefaults]
#define CustomDefaults [CustomUserDefaults defaultUserDefaults]

#define kAppUseCustomDefaults @"custom_default"

#define sys_version [[[UIDevice currentDevice] systemVersion] intValue]
#define iPad [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define dvc_height ([[UIScreen mainScreen] bounds].size.height - 20)
#define dvc_width [[UIScreen mainScreen] bounds].size.width
#define keyboard_height (iPad ? 264 : 216)
#define picker_height 216
#define statusBarHeight (([[[UIDevice currentDevice] systemVersion] intValue] >= 7) ? 20 : 0)

#define DEVICE_ID @"generatedDeviceID"

#define DOCUMENTS_COUNT_KEY @"documentsCount"
#define DOCUMENTS_COUNT [CustomDefaults customIntegerForKey:DOCUMENTS_COUNT_KEY]

#define FULL_VERSION_KEY @"886035796"
#define isFullVersion [CustomDefaults customBoolForKey:FULL_VERSION_KEY]

#define FULL_CSV_KEY @"111"
#define isFullCSVVersion [CustomDefaults customBoolForKey:FULL_CSV_KEY]

#define FULL_DROPBOX_BU_KEY @"full_dropbox_bu_key"
#define isFullDROPBOX_BU [CustomDefaults customBoolForKey:FULL_DROPBOX_BU_KEY]
#define DROPBOX_BACKUP_DID_PURCHASE_NOTIFICATION @"dropbox_backup_did_purchase_notification"
#define DROPBOX_DID_LOGIN_NOTIFICATION @"dropbox_did_login_notification"

#define DO_DROPBOX_BACKUP_KEY @"do_dropbox_backup_key"
#define isDropboxBackupOn [CustomDefaults customBoolForKey:DO_DROPBOX_BACKUP_KEY]

#import "SyncManager.h"
#define sync_manager ((SyncManager*)[SyncManager sharedManager])

#import "DataManager.h"
#define data_manager ((DataManager*)[DataManager sharedManager])
#define date_formatter [DataManager dateFormatter]

#import "ManagerCSV.h"
#define csv_manager ((ManagerCSV*)[ManagerCSV sharedManager])

#define app_tab_normal_color [UIColor colorWithRed:0.29 green:0.37 blue:0.29 alpha:1.0]
#define app_tab_selected_color [UIColor colorWithRed:0.15 green:0.44 blue:1.0 alpha:1.0]
#define app_pressed_selected_color [UIColor colorWithRed:0.06 green:0.24 blue:0.53 alpha:1.0]
#define app_bar_update_color [UIColor colorWithRed:(float)57/255 green:(float)177/255 blue:(float)238/255 alpha:1.0]
#define app_background_color [UIColor colorWithRed:(float)238/255 green:(float)241/255 blue:(float)246/255 alpha:1.0]
//#define app_title_color [UIColor colorWithRed:(float)154/255 green:(float)157/255 blue:(float)163/255 alpha:1.0]
#define app_title_color [UIColor colorWithRed:(float)152/255 green:(float)158/255 blue:(float)166/255 alpha:1.0]

#define HelveticaNeue(x) [UIFont fontWithName:@"HelveticaNeue" size:x]
#define HelveticaNeueBold(x) [UIFont fontWithName:@"HelveticaNeue-Bold" size:x]
#define HelveticaNeueLight(x) [UIFont fontWithName:@"HelveticaNeue-Light" size:x]
#define HelveticaNeueMedium(x) [UIFont fontWithName:@"HelveticaNeue-Medium" size:x]

#import "AlertView.h"
#import "BackButton.h"
#import "TableWithShadow.h"
#import "ScrollWithShadow.h"
#import "ToolBarView.h"
#import "PinView.h"
#import "PDFCreator.h"
#import "PDFCreator2.h"
#import "TopBar.h"
#import "EditTitleVC.h"

#import "ProductOBJ.h"
#import "ServiceOBJ.h"
#import "InvoiceOBJ.h"
#import "ClientOBJ.h"
#import "CompanyOBJ.h"
#import "EstimateOBJ.h"
#import "PurchaseOrderOBJ.h"
#import "AddressOBJ.h"
#import "TermsManager.h"
#import "QuoteOBJ.h"
#import "ProjectOBJ.h"
#import "TimesheetOBJ.h"
#import "ServiceTimeOBJ.h"

#import "OtherCommentsVC.h"
#import "AddSignatureAndDateVC.h"
#import "NSString+MD5.h"
#import "AddItemVC.h"

#import "ReceiptOBJ.h"

// Type of not chaging
#define kUpdatedApp @"checkIfApplicationIsUpdated"

#define kSyncValue @"sync"

#define kAlignedToRightCompanyInfo @"alignedToRightCompanyInfo"

#define kCloudInvoices @"cloudInvoices"
#define kCloudQuotes @"cloudQuotes"
#define kCloudEstimates @"cloudEstimates"
#define kCloudPurchase @"cloudPurchase"
#define kCloudReceipts @"cloudReceipts"
#define kCloudTimesheets @"cloudTimesheets"

#define kCloudClients @"cloudClients"
#define kCloudProducts @"cloudProducts"
#define kCloudProjects @"cloudProjects"

#define kCloudDeletedItems @"cloudDeletedItems"

//Type of not chaging
#define repairImages @"repair_images"

//Type of not chaging
#define repairFiles @"repair_files"

//INVOICE
#define INVOICE_OTHER_COMMENTS_TITLE_KEY @"INVOICE_otherCommentsTitle"
#define INVOICE_OTHER_COMMENTS_TITLE [CustomDefaults customStringForKey:INVOICE_OTHER_COMMENTS_TITLE_KEY]

#define INVOICE_OTHER_COMMENTS_TEXT_KEY @"INVOICE_otherCommentsText"
#define INVOICE_OTHER_COMMENTS_TEXT [CustomDefaults customStringForKey:INVOICE_OTHER_COMMENTS_TEXT_KEY]

#define INVOICE_RIGHT_SIGNATURE_TITLE_KEY @"INVOICE_RIGHT_signatureTitle"
#define INVOICE_RIGHT_SIGNATURE_TITLE [CustomDefaults customStringForKey:INVOICE_RIGHT_SIGNATURE_TITLE_KEY]

#define INVOICE_RIGHT_SIGNATURE_PATH_KEY @"INVOICE_RIGHT_signaturePath"
#define INVOICE_RIGHT_SIGNATURE_PATH [CustomDefaults customStringForKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY]

#define INVOICE_LEFT_SIGNATURE_TITLE_KEY @"INVOICE_LEFT_signatureTitle"
#define INVOICE_LEFT_SIGNATURE_TITLE [CustomDefaults customStringForKey:INVOICE_LEFT_SIGNATURE_TITLE_KEY]

#define INVOICE_LEFT_SIGNATURE_PATH_KEY @"INVOICE_LEFT_signaturePath"
#define INVOICE_LEFT_SIGNATURE_PATH [CustomDefaults customStringForKey:INVOICE_LEFT_SIGNATURE_PATH_KEY]

#define INVOICE_FIRST_PAGE_NOTE_KEY @"INVOICE_firstPageNote"
#define INVOICE_FIRST_PAGE_NOTE [CustomDefaults customStringForKey:INVOICE_FIRST_PAGE_NOTE_KEY]

#define INVOICE_SECOND_PAGE_NOTE_KEY @"INVOICE_secondPageNote"
#define INVOICE_SECOND_PAGE_NOTE [CustomDefaults customStringForKey:INVOICE_SECOND_PAGE_NOTE_KEY]

#define INVOICE_LEFT_FRAME_KEY @"INVOICE_LEFT_frame"
#define INVOICE_LEFT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:INVOICE_LEFT_FRAME_KEY]] CGRectValue]

#define INVOICE_RIGHT_FRAME_KEY @"INVOICE_RIGHT_frame"
#define INVOICE_RIGHT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:INVOICE_RIGHT_FRAME_KEY]] CGRectValue]

#define kInvoiceAlwaysShowOptionalInfoSignatureLeft @"InvoiceAlwaysShowOptionalInfoSignatureLeft"
#define kInvoiceAlwaysShowOptionalInfoSignatureRight @"InvoiceAlwaysShowOptionalInfoSignatureRight"
#define kInvoiceAlwaysShowOptionalInfoNote @"InvoiceAlwaysShowOptionalInfoNote"
#define kInvoiceAlwaysShowOptionalInfoOtherComments @"InvoiceAlwaysShowOptionalInfoOtherComments"

//QUOTE
#define QUOTE_OTHER_COMMENTS_TITLE_KEY @"QUOTE_otherCommentsTitle"
#define QUOTE_OTHER_COMMENTS_TITLE [CustomDefaults customStringForKey:QUOTE_OTHER_COMMENTS_TITLE_KEY]

#define QUOTE_OTHER_COMMENTS_TEXT_KEY @"QUOTE_otherCommentsText"
#define QUOTE_OTHER_COMMENTS_TEXT [CustomDefaults customStringForKey:QUOTE_OTHER_COMMENTS_TEXT_KEY]

#define QUOTE_RIGHT_SIGNATURE_TITLE_KEY @"QUOTE_RIGHT_signatureTitle"
#define QUOTE_RIGHT_SIGNATURE_TITLE [CustomDefaults customStringForKey:QUOTE_RIGHT_SIGNATURE_TITLE_KEY]

#define QUOTE_RIGHT_SIGNATURE_PATH_KEY @"QUOTE_RIGHT_signaturePath"
#define QUOTE_RIGHT_SIGNATURE_PATH [CustomDefaults customStringForKey:QUOTE_RIGHT_SIGNATURE_PATH_KEY]

#define QUOTE_LEFT_SIGNATURE_TITLE_KEY @"QUOTE_LEFT_signatureTitle"
#define QUOTE_LEFT_SIGNATURE_TITLE [CustomDefaults customStringForKey:QUOTE_LEFT_SIGNATURE_TITLE_KEY]

#define QUOTE_LEFT_SIGNATURE_PATH_KEY @"QUOTE_LEFT_signaturePath"
#define QUOTE_LEFT_SIGNATURE_PATH [CustomDefaults customStringForKey:QUOTE_LEFT_SIGNATURE_PATH_KEY]

#define QUOTE_FIRST_PAGE_NOTE_KEY @"QUOTE_firstPageNote"
#define QUOTE_FIRST_PAGE_NOTE [CustomDefaults customStringForKey:QUOTE_FIRST_PAGE_NOTE_KEY]

#define QUOTE_SECOND_PAGE_NOTE_KEY @"QUOTE_secondPageNote"
#define QUOTE_SECOND_PAGE_NOTE [CustomDefaults customStringForKey:QUOTE_SECOND_PAGE_NOTE_KEY]

#define QUOTE_LEFT_FRAME_KEY @"QUOTE_LEFT_frame"
#define QUOTE_LEFT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:QUOTE_LEFT_FRAME_KEY]] CGRectValue]

#define QUOTE_RIGHT_FRAME_KEY @"QUOTE_RIGHT_frame"
#define QUOTE_RIGHT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:QUOTE_RIGHT_FRAME_KEY]] CGRectValue]

#define kQuoteAlwaysShowOptionalInfoSignatureLeft @"QuoteAlwaysShowOptionalInfoSignatureLeft"
#define kQuoteAlwaysShowOptionalInfoSignatureRight @"QuoteAlwaysShowOptionalInfoSignatureRight"
#define kQuoteAlwaysShowOptionalInfoNote @"QuoteAlwaysShowOptionalInfoNote"
#define kQuoteAlwaysShowOptionalInfoOtherComments @"QuoteAlwaysShowOptionalInfoOtherComments"

//ESTIMATE
#define ESTIMATE_OTHER_COMMENTS_TITLE_KEY @"ESTIMATE_otherCommentsTitle"
#define ESTIMATE_OTHER_COMMENTS_TITLE [CustomDefaults customStringForKey:ESTIMATE_OTHER_COMMENTS_TITLE_KEY]

#define ESTIMATE_OTHER_COMMENTS_TEXT_KEY @"ESTIMATE_otherCommentsText"
#define ESTIMATE_OTHER_COMMENTS_TEXT [CustomDefaults customStringForKey:ESTIMATE_OTHER_COMMENTS_TEXT_KEY]

#define ESTIMATE_RIGHT_SIGNATURE_TITLE_KEY @"ESTIMATE_RIGHT_signatureTitle"
#define ESTIMATE_RIGHT_SIGNATURE_TITLE [CustomDefaults customStringForKey:ESTIMATE_RIGHT_SIGNATURE_TITLE_KEY]

#define ESTIMATE_RIGHT_SIGNATURE_PATH_KEY @"ESTIMATE_RIGHT_signaturePath"
#define ESTIMATE_RIGHT_SIGNATURE_PATH [CustomDefaults customStringForKey:ESTIMATE_RIGHT_SIGNATURE_PATH_KEY]

#define ESTIMATE_LEFT_SIGNATURE_TITLE_KEY @"ESTIMATE_LEFT_signatureTitle"
#define ESTIMATE_LEFT_SIGNATURE_TITLE [CustomDefaults customStringForKey:ESTIMATE_LEFT_SIGNATURE_TITLE_KEY]

#define ESTIMATE_LEFT_SIGNATURE_PATH_KEY @"ESTIMATE_LEFT_signaturePath"
#define ESTIMATE_LEFT_SIGNATURE_PATH [CustomDefaults customStringForKey:ESTIMATE_LEFT_SIGNATURE_PATH_KEY]

#define ESTIMATE_FIRST_PAGE_NOTE_KEY @"ESTIMATE_firstPageNote"
#define ESTIMATE_FIRST_PAGE_NOTE [CustomDefaults customStringForKey:ESTIMATE_FIRST_PAGE_NOTE_KEY]

#define ESTIMATE_SECOND_PAGE_NOTE_KEY @"ESTIMATE_secondPageNote"
#define ESTIMATE_SECOND_PAGE_NOTE [CustomDefaults customStringForKey:ESTIMATE_SECOND_PAGE_NOTE_KEY]

#define ESTIMATE_LEFT_FRAME_KEY @"ESTIMATE_LEFT_frame"
#define ESTIMATE_LEFT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:ESTIMATE_LEFT_FRAME_KEY]] CGRectValue]

#define ESTIMATE_RIGHT_FRAME_KEY @"ESTIMATE_RIGHT_frame"
#define ESTIMATE_RIGHT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:ESTIMATE_RIGHT_FRAME_KEY]] CGRectValue]

#define kEstimateAlwaysShowOptionalInfoSignatureLeft @"EstimateAlwaysShowOptionalInfoSignatureLeft"
#define kEstimateAlwaysShowOptionalInfoSignatureRight @"EstimateAlwaysShowOptionalInfoSignatureRight"
#define kEstimateAlwaysShowOptionalInfoNote @"EstimateAlwaysShowOptionalInfoNote"
#define kEstimateAlwaysShowOptionalInfoOtherComments @"EstimateAlwaysShowOptionalInfoOtherComments"

//PURCHASE ORDER
#define PURCHASE_ORDER_OTHER_COMMENTS_TITLE_KEY @"PURCHASE_ORDER_otherCommentsTitle"
#define PURCHASE_ORDER_OTHER_COMMENTS_TITLE [CustomDefaults customStringForKey:PURCHASE_ORDER_OTHER_COMMENTS_TITLE_KEY]

#define PURCHASE_ORDER_OTHER_COMMENTS_TEXT_KEY @"PURCHASE_ORDER_otherCommentsText"
#define PURCHASE_ORDER_OTHER_COMMENTS_TEXT [CustomDefaults customStringForKey:PURCHASE_ORDER_OTHER_COMMENTS_TEXT_KEY]

#define PURCHASE_ORDER_RIGHT_SIGNATURE_TITLE_KEY @"PURCHASE_ORDER_RIGHT_signatureTitle"
#define PURCHASE_ORDER_RIGHT_SIGNATURE_TITLE [CustomDefaults customStringForKey:PURCHASE_ORDER_RIGHT_SIGNATURE_TITLE_KEY]

#define PURCHASE_ORDER_RIGHT_SIGNATURE_PATH_KEY @"PURCHASE_ORDER_RIGHT_signaturePath"
#define PURCHASE_ORDER_RIGHT_SIGNATURE_PATH [CustomDefaults customStringForKey:PURCHASE_ORDER_RIGHT_SIGNATURE_PATH_KEY]

#define PURCHASE_ORDER_LEFT_SIGNATURE_TITLE_KEY @"PURCHASE_ORDER_LEFT_signatureTitle"
#define PURCHASE_ORDER_LEFT_SIGNATURE_TITLE [CustomDefaults customStringForKey:PURCHASE_ORDER_LEFT_SIGNATURE_TITLE_KEY]

#define PURCHASE_ORDER_LEFT_SIGNATURE_PATH_KEY @"PURCHASE_ORDER_LEFT_signaturePath"
#define PURCHASE_ORDER_LEFT_SIGNATURE_PATH [CustomDefaults customStringForKey:PURCHASE_ORDER_LEFT_SIGNATURE_PATH_KEY]

#define PURCHASE_ORDER_FIRST_PAGE_NOTE_KEY @"PURCHASE_ORDER_firstPageNote"
#define PURCHASE_ORDER_FIRST_PAGE_NOTE [CustomDefaults customStringForKey:PURCHASE_ORDER_FIRST_PAGE_NOTE_KEY]

#define PURCHASE_ORDER_SECOND_PAGE_NOTE_KEY @"PURCHASE_ORDER_secondPageNote"
#define PURCHASE_ORDER_SECOND_PAGE_NOTE [CustomDefaults customStringForKey:PURCHASE_ORDER_SECOND_PAGE_NOTE_KEY]

#define PURCHASE_ORDER_LEFT_FRAME_KEY @"PURCHASE_ORDER_LEFT_frame"
#define PURCHASE_ORDER_LEFT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:PURCHASE_ORDER_LEFT_FRAME_KEY]] CGRectValue]

#define PURCHASE_ORDER_RIGHT_FRAME_KEY @"PURCHASE_ORDER_RIGHT_frame"
#define PURCHASE_ORDER_RIGHT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:PURCHASE_ORDER_RIGHT_FRAME_KEY]] CGRectValue]

#define kPurchaseAlwaysShowOptionalInfoSignatureLeft @"PurchaseAlwaysShowOptionalInfoSignatureLeft"
#define kPurchaseAlwaysShowOptionalInfoSignatureRight @"PurchaseAlwaysShowOptionalInfoSignatureRight"
#define kPurchaseAlwaysShowOptionalInfoNote @"PurchaseAlwaysShowOptionalInfoNote"
#define kPurchaseAlwaysShowOptionalInfoOtherComments @"PurchaseAlwaysShowOptionalInfoOtherComments"

//TIMESHEET
#define TIMESHEET_OTHER_COMMENTS_TITLE_KEY @"TIMESHEET_otherCommentsTitle"
#define TIMESHEET_OTHER_COMMENTS_TITLE [CustomDefaults customStringForKey:TIMESHEET_OTHER_COMMENTS_TITLE_KEY]

#define TIMESHEET_OTHER_COMMENTS_TEXT_KEY @"TIMESHEET_otherCommentsText"
#define TIMESHEET_OTHER_COMMENTS_TEXT [CustomDefaults customStringForKey:TIMESHEET_OTHER_COMMENTS_TEXT_KEY]

#define TIMESHEET_RIGHT_SIGNATURE_TITLE_KEY @"TIMESHEET_RIGHT_signatureTitle"
#define TIMESHEET_RIGHT_SIGNATURE_TITLE [CustomDefaults customStringForKey:TIMESHEET_RIGHT_SIGNATURE_TITLE_KEY]

#define TIMESHEET_RIGHT_SIGNATURE_PATH_KEY @"TIMESHEET_RIGHT_signaturePath"
#define TIMESHEET_RIGHT_SIGNATURE_PATH [CustomDefaults customStringForKey:TIMESHEET_RIGHT_SIGNATURE_PATH_KEY]

#define TIMESHEET_LEFT_SIGNATURE_TITLE_KEY @"TIMESHEET_LEFT_signatureTitle"
#define TIMESHEET_LEFT_SIGNATURE_TITLE [CustomDefaults customStringForKey:TIMESHEET_LEFT_SIGNATURE_TITLE_KEY]

#define TIMESHEET_LEFT_SIGNATURE_PATH_KEY @"TIMESHEET_LEFT_signaturePath"
#define TIMESHEET_LEFT_SIGNATURE_PATH [CustomDefaults customStringForKey:TIMESHEET_LEFT_SIGNATURE_PATH_KEY]

#define TIMESHEET_FIRST_PAGE_NOTE_KEY @"TIMESHEET_firstPageNote"
#define TIMESHEET_FIRST_PAGE_NOTE [CustomDefaults customStringForKey:TIMESHEET_FIRST_PAGE_NOTE_KEY]

#define TIMESHEET_SECOND_PAGE_NOTE_KEY @"TIMESHEET_secondPageNote"
#define TIMESHEET_SECOND_PAGE_NOTE [CustomDefaults customStringForKey:TIMESHEET_SECOND_PAGE_NOTE_KEY]

#define TIMESHEET_LEFT_FRAME_KEY @"TIMESHEET_LEFT_frame"
#define TIMESHEET_LEFT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:TIMESHEET_LEFT_FRAME_KEY]] CGRectValue]

#define TIMESHEET_RIGHT_FRAME_KEY @"TIMESHEET_RIGHT_frame"
#define TIMESHEET_RIGHT_FRAME [[NSKeyedUnarchiver unarchiveObjectWithData:[CustomDefaults customObjectForKey:TIMESHEET_RIGHT_FRAME_KEY]] CGRectValue]

#define changePaperSize(width, height)\
[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:width] forKey:@"paper_width"];\
[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:height] forKey:@"paper_height"];\
[[NSUserDefaults standardUserDefaults] synchronize];

#define revertPaperSize changePaperSize(default_paper_size.width, default_paper_size.height)

#define default_paper_size CGSizeMake(2480, 3508)

#define paper_size CGSizeMake([[[NSUserDefaults standardUserDefaults] objectForKey:@"paper_width"] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"paper_height"] floatValue])

#define paperWidthPercent(x) ((paper_size.width * x) / 100)
#define paperHeightPercent(x) ((paper_size.height * x) / 100)

#define SHOW_GETTERS_AND_SETTERS_ERRORS 0

#if TARGET_IPHONE_SIMULATOR
#define DEBUG_MODE 0
#else
#define DEBUG_MODE 1
#endif

#endif