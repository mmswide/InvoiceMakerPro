//
//  DataManager.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kTemplate) {
	
	kTemplateBlackAndWhite = 0,
	kTemplateSeafoam,
	kTemplateRoyal,
	kTemplateNeon,
	kTemplateLava
	
};

typedef enum {
	
	kPlacementForCurrencyFront = 0,
	kPlacementForCurrencyBack

} kPlacementForCurrency;

typedef NS_ENUM(NSInteger, kSymbol) {
	
	kSymbolDot = 0,
	kSymbolComma
	
};

typedef enum {
	
	kPlacementForDecimalOneDigit = 0,
	kPlacementForDecimalTwoDigits,
	kPlacementForDecimalThreeDigits,
    kPlacementForDecimalNone,
	
} kPlacementForDecimal;

@class InvoiceOBJ;
@class ClientOBJ;
@class ProjectOBJ;
@class ServiceTimeOBJ;

#define kProductsKeyForNSUserDefaults @"products"
#define kClientsKeyForNSUserDefaults @"clients"
#define kProjectsKeyForNSUserDefaults @"projects"
#define kInvoicesKeyForNSUserDefaults @"invoices"
#define kInvoiceFigureSettingsKey @"InvoiceFigureSettingsKey"
#define kQuotesKeyForNSUserDefaults @"quotes"
#define kEstimatesKeyForNSUserDefaults @"estimates"
#define kPurchaseOrdersKeyForNSUserDefaults @"purchaseOrders"

#define kReceiptsKeyForNSUserDefaults @"receipts"
#define kTimeSheetKeyForNSUserDefaults @"timesheet"

#define kAddressKeyForNSUserDefaults @"address"
#define kPinKeyForNSUserDefaults @"pin"
#define kSettingsKeyForNSUserDefaults @"settings"
#define kLanguageKeyForNSUserDefaults @"language"
#define kCompanyKeyForNSUserDefaults @"company"

#define kNumberOfInvoicesKeyForNSUserDefaults @"numberOfInvoices"
#define kNumberOfQuotesKeyForNSUserDefaults @"numberOfQuotes"
#define kNumberOfEstimatesKeyForNSUserDefaults @"numberOfEstimates"
#define kNumberOfPurchaseOrdersKeyForNSUserDefaults @"numberOfPurchaseOrders"
#define kNumberOfRecipeKeyForNSUserDefaults @"numberOfReceipt"
#define kNumberOfTimesheetKeyForNSUserDefaults @"numberOfTimesheet"

#define kCurrencySymbolKeyForNSUserDefaults @"currency_symbol"
#define kCurrencyPlacementKeyForNSUserDefaults @"currency_placement"

#define kThousandSymbolKeyForNSUserDefaults @"thousand_symbol"
#define kDecimalSymbolKeyForNSUserDefaults @"decimal_symbol"
#define kNewThousandSymbolKeyForNSUserDefaults @"new_thousand_symbol"
#define kNewDecimalSymbolKeyForNSUserDefaults @"new_decimal_symbol"

#define kDecimalPlacementKeyForNSUserDefaults @"decimal_placement"
#define kBillingAddressTitleKeyForNSUserDefaults @"billing_address_title"
#define kShippingAddressTitleKeyForNSUserDefaults @"shipping_address_title"
#define kInvoiceBillingAddressTitleKeyForNSUserDefaults @"invoice_billing_address_title"
#define kInvoiceShippingAddressTitleKeyForNSUserDefaults @"invoice_shipping_address_title"
#define kQuoteBillingAddressTitleKeyForNSUserDefaults @"quote_billing_address_title"
#define kQuoteShippingAddressTitleKeyForNSUserDefaults @"quote_shipping_address_title"
#define kEstimateBillingAddressTitleKeyForNSUserDefaults @"estimate_billing_address_title"
#define kEstimateShippingAddressTitleKeyForNSUserDefaults @"estimate_shipping_address_title"
#define kPurchaseBillingAddressTitleKeyForNSUserDefaults @"purchase_billing_address_title"
#define kPurchaseShippingAddressTitleKeyForNSUserDefaults @"purchase_shipping_address_title"

#define kInvoiceTitleKeyForNSUserDefaults @"invoice_title"
#define kEstimateTitleKeyForNSUserDefaults @"estimate_title"
#define kQuoteTitleKeyForNSUserDefaults @"quote_title"
#define kPurchaseOrderTitleKeyForNSUserDefaults @"purchase_order_title"

#define kReceiptTitleKeyForNSUserDefaults @"receipt_title"
#define kTimesheetTitleKeyForNSUserDefaults @"timesheet_title"

#define kTimesheetStartTimeKey @"timesheet_start_time"
#define kTimesheetFinishTimeKey @"timesheet_finish_time"
#define kTimesheetBreakTimeKey @"timesheet_break_time"

#define kDefaultCategories @"defaultCategories"

#define kDefaultServiceTime @"defaultServiceTime"
#define kDefaultTaxable @"default_taxable"

#define kInvTitle [CustomDefaults customObjectForKey:kInvoiceTitleKeyForNSUserDefaults]
#define kEstTitle [CustomDefaults customObjectForKey:kEstimateTitleKeyForNSUserDefaults]
#define kQuoTitle [CustomDefaults customObjectForKey:kQuoteTitleKeyForNSUserDefaults]
#define kPurTitle [CustomDefaults customObjectForKey:kPurchaseOrderTitleKeyForNSUserDefaults]

@interface DataManager : NSObject

+(id)sharedManager;
+(NSDateFormatter*)dateFormatter;

#pragma mark - TEMPLATES

-(kTemplate)selectedTemplate;
-(void)setTemplate:(kTemplate)sender;
-(UIImage*)templateImage;

#pragma mark - CUSTOM LOG

void CSLog(NSString *format, ...);

#pragma mark - LOG FUNCTIONS

-(void)logGetterErrorFromClass:(Class)theClass forProperty:(NSString*)property containedValue:(id)object withDefautReturnValue:(NSString*)defaultReturn;
-(void)logSetterErrorFromClass:(Class)theClass forProperty:(NSString*)property sentValue:(id)object withDefaultSetValue:(NSString*)defaultSet;

#pragma mark - SHAKE VIEW

-(void)shakeView:(UIView*)sender times:(int)times;
-(void)continueShakingView:(UIView*)sender timesRemaining:(int)times;

#pragma mark - IMAGE MANIPULATION

-(UIImage*)scaleAndRotateImage:(UIImage*)image andResolution:(int)kMaxResolution;

#pragma mark - SAVE TO USER DEFAULTS

-(void)saveProductsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveClientsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveQuotesArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveInvoicesArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveEstimatesArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)savePurchaseOrdersArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveProjectsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveReceiptsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveTimesheetArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key;
-(void)saveServiceTimeToUserDefaults:(ServiceTimeOBJ*)sender forKey:(NSString*)key;

#pragma mark - LOAD FROM USER DEFAULTS

-(NSArray*)loadProductsArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadClientsArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadInvoicesArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadQuotesArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadEstimatesArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadPurchaseOrdersArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadProjectsArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadReceiptsArrayFromUserDefaultsAtKey:(NSString*)key;
-(NSArray*)loadTimesheetsArrayFromUserDefaultsAtKey:(NSString*)key;

#pragma mark - COMPANY MATHODS

- (NSArray *)companyProfileSettings;
- (void)setCompanyProfileSettings:(NSArray *)settings;

#pragma mark - INVOICE FOR CLIENT

-(InvoiceOBJ*)nextInvoiceForClient:(ClientOBJ*)client;
-(NSArray*)overdueInvoicesForClient:(ClientOBJ*)client;
-(NSArray*)overdueInvoicesForProject:(ProjectOBJ*)project;

-(NSArray*)currentInvoicesForClient:(ClientOBJ*)client;
-(NSArray*)currentInvoicesForProject:(ProjectOBJ*)project;

-(NSArray*)paidInvoicesForClient:(ClientOBJ*)client;
-(NSArray*)paidInvoicesForProject:(ProjectOBJ*)project;

-(NSArray*)allInvoicesForClient:(ClientOBJ*)client;
-(NSArray*)allInvoicesForProject:(ProjectOBJ*)project;

- (NSArray *)invoiceFigureSettings;
- (void)setInvoiceFiguresSettings:(NSArray *)settings;

- (NSArray *)invoiceDetailsSettings;
- (void)setInvoiceDetailsSettings:(NSArray *)settings;

- (NSArray *)invoiceAddItemDetailsSettings;
- (void)setInvoiceAddItemDetailsSettings:(NSArray *)settings;

- (NSArray *)invoiceProfileSettings;
- (void)setInvoiceProfileSettings:(NSArray *)settings;

- (NSArray *)invoiceDetailsClientSettings;
- (void)setInvoiceClientDetailsSettings:(NSArray *)settings;

#pragma mark - QUOTE FOR CLIENT

-(NSArray*)allQuotesForClient:(ClientOBJ*)client;
-(NSArray*)allQuotesForProject:(ProjectOBJ*)project;

- (NSArray *)quoteFigureSettings;
- (void)setQuoteFiguresSettings:(NSArray *)settings;

- (NSArray *)quoteDetailsSettings;
- (void)setQuoteDetailsSettings:(NSArray *)settings;

- (NSArray *)quoteAddItemDetailsSettings;
- (void)setQuoteAddItemDetailsSettings:(NSArray *)settings;

- (NSArray *)quoteProfileSettings;
- (void)setQuoteProfileSettings:(NSArray *)settings;

- (NSArray *)quoteDetailsClientSettings;
- (void)setQuoteClientDetailsSettings:(NSArray *)settings;

#pragma mark - ESTIMATE FOR CLIENT

-(NSArray*)allEstimatesForClient:(ClientOBJ*)client;
-(NSArray*)allEstimatesForProject:(ProjectOBJ*)project;

- (NSArray *)estimateFigureSettings;
- (void)setEstimateFiguresSettings:(NSArray *)settings;

- (NSArray *)estimateDetailsSettings;
- (void)setEstimateDetailsSettings:(NSArray *)settings;

- (NSArray *)estimateAddItemDetailsSettings;
- (void)setEstimateAddItemDetailsSettings:(NSArray *)settings;

- (NSArray *)estimateProfileSettings;
- (void)setEstimateProfileSettings:(NSArray *)settings;

- (NSArray *)estimateDetailsClientSettings;
- (void)setEstimateClientDetailsSettings:(NSArray *)settings;

#pragma mark - PURCHASE ORDERS FOR CLIENT

-(NSArray*)allPurchaseOrdersForClient:(ClientOBJ*)client;
-(NSArray*)allPurchaseOrdersForProject:(ProjectOBJ*)project;

- (NSArray *)purchaseFigureSettings;
- (void)setPurchaseFiguresSettings:(NSArray *)settings;

- (NSArray *)purchaseDetailsSettings;
- (void)setPurchaseDetailsSettings:(NSArray *)settings;

- (NSArray *)purchaseAddItemDetailsSettings;
- (void)setPurchaseAddItemDetailsSettings:(NSArray *)settings;

- (NSArray *)purchaseProfileSettings;
- (void)setPurchaseProfileSettings:(NSArray *)settings;

- (NSArray *)purchaseDetailsClientSettings;
- (void)setPurchaseClientDetailsSettings:(NSArray *)settings;

#pragma mark - RECEIPT

-(void)saveReceiptsCategories:(NSArray*)sender;
-(NSArray*)getReceiptCategories;

-(NSArray*)allReceiptsForClient:(ClientOBJ*)client;
-(NSArray*)allReceiptsForProject:(ProjectOBJ*)project;

#pragma mark - TIMESHEET

-(NSString*)getTotalHoursForThisWeek:(NSArray*)timesheetsArray;
-(NSString*)getTotalHoursForThisMonth:(NSArray*)timesheetsArray;
-(NSString*)getTotalHoursForThisYear:(NSArray*)timesheetsArray;

-(NSArray*)allTimesheetsForClient:(ClientOBJ*)client;
-(NSArray*)allTimesheetsForProject:(ProjectOBJ*)project;

#pragma mark - CURRENCY

-(NSString*)currency;
-(void)setCurrency:(NSString*)sender;
-(NSString*)currencyPlacementString;
-(kPlacementForCurrency)currencyPlacement;
-(void)changeCurrencyPlacement;

-(NSString*)thousandSymbol;
-(NSString*)decimalSymbol;

-(void)changeThousandSymbol:(NSString*)sender;
-(void)changeDecimalSymbol:(NSString*)sender;

-(NSString*)stringForDecimalPlacement;
-(void)changeDecimalPlacement;

-(void)checkSymbols;

-(kPlacementForDecimal)decimalPlacement;
-(void)setDecimalPlacement:(kPlacementForDecimal)sender;

-(NSString*)currencyAdjustedValue:(float)sender;
-(NSString*)currencyAdjustedValue:(float)sender forSign:(NSString*)sign;
-(NSString*)valueAdjusted:(float)sender;
-(NSString*)currencyStrippedString:(NSString*)sender;

#pragma mark - DUE CALCULATIONS

-(int)daysBetweenDate:(NSDate*)date1 andDate:(NSDate*)date2;
-(NSString*)dueStringForDate:(NSDate*)date1 andDate:(NSDate*)date2;

#pragma mark - IMAGE SIZE

-(CGSize)sizeOfAspectScaledSize:(CGSize)im inSize:(CGSize)size;

#pragma mark - TEXT SIZE

-(CGSize)sizeForString:(NSString*)string withFont:(UIFont*)font constrainedToSize:(CGSize)size;

#pragma mark - TRIM QUANTITY

-(CGFloat)trimmedQuantity:(CGFloat)quantity;

-(NSArray*)generateExportCategories;

#pragma mark - DATE

-(int)compareDate:(NSDate*)startDate withEndDate:(NSDate*)endDate;

#pragma mark - CSV LOAD FUNCTIONS

-(NSArray*)getInvoiceArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getQuotesArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getEstimatesArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getPurchaseArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getReceiptsArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getTimesheetsArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getProductsFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getContactsFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

-(NSArray*)getProjectsFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;

#pragma mark - GENERATE ID

-(NSString*)generateDeviceID;

-(NSString*)createInvoiceID;

-(NSString*)createQuoteID;

-(NSString*)createEstimateID;

-(NSString*)createPurchaseOrderID;

-(NSString*)createProductID;

-(NSString*)createServiceID;

-(NSString*)createContactID;

-(NSString*)createProjectID;

-(NSString*)createReceiptID;

-(NSString*)createTimeSheetID;

#pragma mark - DATES

-(NSDate*)getFirstDayOfWeek;

-(NSDate*)getLastDayOfWeek;

-(NSDate*)getFirstDayOfMonth;

-(NSDate*)getLastDayOfMonth;

-(NSDate*)getFirstDayOfYear;

-(NSDate*)getLastDayOfYear;

#pragma mark - STRINGS

-(NSString*)stripString:(NSString*)sender;

-(void)makeProductsAndServicesTaxable;

@end