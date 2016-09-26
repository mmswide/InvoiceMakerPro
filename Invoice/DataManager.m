//
//  DataManager.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "DataManager.h"

#import "Defines.h"

@implementation DataManager

+(id)sharedManager
{
	static DataManager * manager;
	
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
		
	}
	
	return self;
}

#pragma mark - DATE FORMATTER

+(NSDateFormatter*)dateFormatter
{
	static NSDateFormatter * dtForm;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		dtForm = [[NSDateFormatter alloc] init];
		
	});
	
	return dtForm;
}

#pragma mark - TEMPLATES

-(kTemplate)selectedTemplate
{
	return [CustomDefaults customIntegerForKey:@"template"];
}

-(void)setTemplate:(kTemplate)sender
{
	[CustomDefaults setCustomInteger:sender forKey:@"template"];
}

-(UIImage*)templateImage
{
	NSString * nameOfImage = @"";
	
	switch ([self selectedTemplate])
	{
		case kTemplateBlackAndWhite:
		{
			nameOfImage = @"";
			break;
		}
			
		case kTemplateLava:
		{
			nameOfImage = @"lava.png";
			break;
		}
			
		case kTemplateNeon:
		{
			nameOfImage = @"neon.png";
			break;
		}
			
		case kTemplateRoyal:
		{
			nameOfImage = @"royal.png";
			break;
		}
			
		case kTemplateSeafoam:
		{
			nameOfImage = @"seafoam.png";
			break;
		}
			
		default:
			break;
	}
	
	return [UIImage imageNamed:nameOfImage];
}

#pragma mark - CUSTOM LOG

void CSLog(NSString *format, ...)
{
	if (DEBUG_MODE == 0)
		return;
	
	va_list argumentList;
	va_start(argumentList, format);
	NSMutableString * message = [[NSMutableString alloc] initWithFormat:format arguments:argumentList];
	NSLogv(message, argumentList);
	va_end(argumentList);
}

#pragma mark - LOG FUNCTIONS

-(void)logGetterErrorFromClass:(Class)theClass forProperty:(NSString*)property containedValue:(id)object withDefautReturnValue:(NSString*)defaultReturn
{
	if (SHOW_GETTERS_AND_SETTERS_ERRORS)
		CSLog(@"%@: getter error: \"%@\". dictionary contains: %@. returning %@.", theClass, property, object, defaultReturn);
}

-(void)logSetterErrorFromClass:(Class)theClass forProperty:(NSString*)property sentValue:(id)object withDefaultSetValue:(NSString*)defaultSet
{
	if (SHOW_GETTERS_AND_SETTERS_ERRORS)
		CSLog(@"%@: setter error: \"%@\". sent value: %@. setting %@.", theClass, property, object, defaultSet);
}

#pragma mark - SHAKE VIEW

-(void)shakeView:(UIView*)sender times:(int)times
{
	if (times % 2 == 1)
		times++;
	
	int x = -8;
	
	[UIView animateWithDuration:0.05 animations:^{
		
		[sender setFrame:CGRectMake(sender.frame.origin.x + x, sender.frame.origin.y, sender.frame.size.width, sender.frame.size.height)];
		
	} completion:^(BOOL finished) {
		
		[self continueShakingView:sender timesRemaining:times - 1];
		
	}];
}

-(void)continueShakingView:(UIView*)sender timesRemaining:(int)times
{
	if (times == 0)
		return;
	
	int x = 8;
	
	if (times % 2 == 0)
		x = -8;
	
	[UIView animateWithDuration:0.05 animations:^{
		
		[sender setFrame:CGRectMake(sender.frame.origin.x + x, sender.frame.origin.y, sender.frame.size.width, sender.frame.size.height)];
		
	} completion:^(BOOL finished) {
		
		[self continueShakingView:sender timesRemaining:times - 1];
		
	}];
}

#pragma mark - IMAGE MANIPULATION

-(UIImage*)scaleAndRotateImage:(UIImage*)image andResolution:(int)kMaxResolution
{
	CGImageRef imgRef = CGImageRetain(image.CGImage);
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	if (width > kMaxResolution || height > kMaxResolution)
	{
		CGFloat ratio = width/height;
		
		if (ratio > 1)
		{
			bounds.size.width = kMaxResolution;
			bounds.size.height = roundf(bounds.size.width / ratio);
		}
		else
		{
			bounds.size.height = kMaxResolution;
			bounds.size.width = roundf(bounds.size.height * ratio);
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	
	UIImageOrientation orient = image.imageOrientation;
	
	switch(orient)
	{
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else
	{
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
		
	UIImage * imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	CGImageRelease(imgRef);
	
	return imageCopy;
}

#pragma mark - SAVE TO USER DEFAULTS

-(void)saveProductsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (NSObject * obj in sender)
	{
		if ([obj isKindOfClass:[ServiceOBJ class]])
		{
			[temp addObject:[(ServiceOBJ*)obj contentsDictionary]];
		}
		else
		{
			[temp addObject:[(ProductOBJ*)obj contentsDictionary]];
		}
	}
	
	[ObjectsDefaults saveProducts:temp];
}

-(void)saveClientsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (ClientOBJ * obj in sender)
	{
		[temp addObject:[obj contentsDictionary]];
	}

	[ObjectsDefaults saveClients:temp];
}

-(void)saveInvoicesArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (InvoiceOBJ * obj in sender)
	{
		[temp addObject:[obj contentsDictionary]];
	}
	
	[InvoiceDefaults saveInvoices:temp];	
}

-(void)saveQuotesArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (QuoteOBJ * obj in sender)
	{
		[temp addObject:[obj contentsDictionary]];
	}

	[QuoteDefaults saveQuotes:temp];
}

-(void)saveEstimatesArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (EstimateOBJ * obj in sender)
	{
		[temp addObject:[obj contentsDictionary]];
	}

	[EstimateDefaults saveEstimates:temp];
}

-(void)savePurchaseOrdersArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	for (PurchaseOrderOBJ * obj in sender)
	{
		[temp addObject:[obj contentsDictionary]];
	}

	[PurchaseDefaults savePurchases:temp];
}

-(void)saveProjectsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	for(ProjectOBJ * obj in sender)
	{
		[temp addObject:[obj contentsDictionary]];
	}

	[ObjectsDefaults saveProjects:temp];
}

-(void)saveReceiptsArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	for(ReceiptOBJ * obj in sender)
	{
		[temp addObject:[obj dictionaryRepresentation]];
	}

	[ReceiptDefaults saveReceipts:temp];
}

-(void)saveTimesheetArrayToUserDefaults:(NSArray*)sender forKey:(NSString*)key
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	for(TimeSheetOBJ * obj in sender)
	{
		[temp addObject:[obj dictionaryRepresentation]];
	}
	
	[TimesheetDefaults saveTimesheets:temp];
}

-(void)saveServiceTimeToUserDefaults:(ServiceTimeOBJ*)sender forKey:(NSString*)key
{
	[CustomDefaults setCustomObjects:[sender dictionaryRepresentation] forKey:key];
}

#pragma mark - LOAD FROM USER DEFAULTS

-(NSArray*)loadProductsArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	NSArray * array = [ObjectsDefaults loadProducts];
	
	for (NSDictionary * dict in array)
	{
		if (![[dict allKeys] containsObject:@"code"])
		{
			[temp addObject:[[ServiceOBJ alloc] initWithContentsDictionary:dict]];
		}
		else
		{
			[temp addObject:[[ProductOBJ alloc] initWithContentsDictionary:dict]];
		}
	}
	
	return temp;
}

-(NSArray*)loadClientsArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	NSArray * array = [ObjectsDefaults loadClients];
	
	for (NSDictionary * dict in array)
	{
		[temp addObject:[[ClientOBJ alloc] initWithContentsDictionary:dict]];
	}
	
	return temp;
}

-(NSArray*)loadInvoicesArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	NSArray * array = [InvoiceDefaults loadInvoices];
	
	for (NSDictionary * dict in array)
	{
		[temp addObject:[[InvoiceOBJ alloc] initWithContentsDictionary:dict]];
	}
	
	return temp;
}

-(NSArray*)loadQuotesArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	NSArray * array = [QuoteDefaults loadQuotes];
	
	for (NSDictionary * dict in array)
	{
		[temp addObject:[[QuoteOBJ alloc] initWithContentsDictionary:dict]];
	}
	
	return temp;
}

-(NSArray*)loadEstimatesArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	NSArray * array = [EstimateDefaults loadEstimates];
	
	for (NSDictionary * dict in array)
	{
		[temp addObject:[[EstimateOBJ alloc] initWithContentsDictionary:dict]];
	}
	
	return temp;
}

-(NSArray*)loadPurchaseOrdersArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray * temp = [[NSMutableArray alloc] init];
	
	NSArray * array = [PurchaseDefaults loadPurchases];
	
	for (NSDictionary * dict in array)
	{
		[temp addObject:[[PurchaseOrderOBJ alloc] initWithContentsDictionary:dict]];
	}
	
	return temp;
}

-(NSArray*)loadProjectsArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	NSArray *array = [ObjectsDefaults loadProjects];
	
	for(NSDictionary * dict in array)
	{
		[temp addObject:[[ProjectOBJ alloc] initWithContentsDictionary:dict]];
	}
	
	return temp;
}

-(NSArray*)loadReceiptsArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	NSArray *array = [ReceiptDefaults loadReceipts];
	
	for(NSDictionary * dict in array)
	{
		[temp addObject:[[ReceiptOBJ alloc] initWithDictionaryRepresentation:dict]];
	}
	
	return temp;
}

-(NSArray*)loadTimesheetsArrayFromUserDefaultsAtKey:(NSString*)key
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	NSArray *array = [TimesheetDefaults loadTimesheets];
	
	for(NSDictionary * dict in array)
	{
		[temp addObject:[[TimeSheetOBJ alloc] initWithDictionaryRepresentation:dict]];
	}
		
	return temp;
}

#pragma mark - COMPANY METHODS

- (NSArray *)companyProfileSettings {
  return [CustomDefaults profileSettings];
}

- (void)setCompanyProfileSettings:(NSArray *)settings {
  [CustomDefaults setProfileSettings:settings];
}

#pragma mark - INVOICE FOR CLIENT

-(InvoiceOBJ*)nextInvoiceForClient:(ClientOBJ*)client
{
	NSArray * invoicesArray = [self loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults];
	
	NSDate * today = [NSDate date];
	NSDate * nextDate = [NSDate dateWithTimeIntervalSinceNow:8999999999999999999];
	
	InvoiceOBJ * theInvoice = nil;
	
	for (InvoiceOBJ * invoice in invoicesArray)
	{
		if(![[invoice client] isEqual:client])
			continue;
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		NSDate * invDate = [date_formatter dateFromString:[invoice date]];
		
		if ([today compare:invDate] == NSOrderedAscending)
		{
			if ([invDate compare:nextDate] == NSOrderedAscending)
			{
				theInvoice = [[InvoiceOBJ alloc] initWithInvoice:invoice];
				nextDate = [date_formatter dateFromString:[invoice date]];
			}
		}
	}
	
	return theInvoice;
}

-(NSArray*)overdueInvoicesForClient:(ClientOBJ*)client
{
	NSMutableArray * invoicesArray = [[NSMutableArray alloc] init];
	
	NSArray * array = [self allInvoicesForClient:client];
	
	for (InvoiceOBJ * temp in array)
	{
		if ([temp status] == kInvoiceStatusOverdue)
		{
			[invoicesArray addObject:temp];
		}
	}
	
	return invoicesArray;
}

-(NSArray*)overdueInvoicesForProject:(ProjectOBJ*)project;
{
	NSMutableArray *invoicesArray = [[NSMutableArray alloc] init];
	
	NSArray *array = [self allInvoicesForProject:project];
	
	for(InvoiceOBJ * temp in array)
	{
		if([temp status] == kInvoiceStatusOverdue)
		{
			[invoicesArray addObject:temp];
		}
	}
	
	return invoicesArray;
}

-(NSArray*)currentInvoicesForClient:(ClientOBJ*)client
{
	NSMutableArray * invoicesArray = [[NSMutableArray alloc] init];
	
	NSArray * array = [self allInvoicesForClient:client];
	
	for (InvoiceOBJ * temp in array)
	{
		if ([temp status] == kInvoiceStatusCurrent)
		{
			[invoicesArray addObject:temp];
		}
	}
	
	return invoicesArray;
}

-(NSArray*)currentInvoicesForProject:(ProjectOBJ*)project
{
	NSMutableArray *invoicesArray = [[NSMutableArray alloc] init];
	
	NSArray *array = [self allInvoicesForProject:project];
	
	for(InvoiceOBJ *temp in array)
	{
		if([temp status] == kInvoiceStatusCurrent)
		{
			[invoicesArray addObject:temp];
		}
	}
	
	return invoicesArray;
}

-(NSArray*)paidInvoicesForClient:(ClientOBJ*)client
{
	NSMutableArray * invoicesArray = [[NSMutableArray alloc] init];
	
	NSArray * array = [self allInvoicesForClient:client];
	
	for (InvoiceOBJ * temp in array)
	{
		if ([temp status] == kInvoiceStatusPaid)
		{
			[invoicesArray addObject:temp];
		}
	}
	
	return invoicesArray;
}
-(NSArray*)paidInvoicesForProject:(ProjectOBJ*)project
{
	NSMutableArray *invoicesArray = [[NSMutableArray alloc] init];
	
	NSArray *array = [self allInvoicesForProject:project];
	
	for(InvoiceOBJ *temp in array)
	{
		if([temp status] == kInvoiceStatusPaid)
		{
			[invoicesArray addObject:temp];
		}
	}
	
	return invoicesArray;
}

-(NSArray*)allInvoicesForClient:(ClientOBJ*)client
{
	NSArray * invoicesArray = [self loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults];
	
	NSMutableArray * clientsInvoices = [[NSMutableArray alloc] init];
	
	for (InvoiceOBJ * inv in invoicesArray)
	{
		if ([[[inv client] contentsDictionary] isEqualToDictionary:[client contentsDictionary]] || ([[[inv client] ID] isEqual:[client ID]] && ![[[inv client] ID] isEqual:@""] && ![[client ID] isEqual:@""]))
		{
			[clientsInvoices addObject:inv];
		}
	}
	
	return clientsInvoices;
}

-(NSArray*)allInvoicesForProject:(ProjectOBJ *)project
{
	NSArray *invoicesArray = [self loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults];
	
	NSMutableArray *projectInvoices = [[NSMutableArray alloc] init];
	
	for(InvoiceOBJ *inv in invoicesArray)
	{
		if([[[inv project] contentsDictionary] isEqualToDictionary:[project contentsDictionary]] || ([[[inv project] ID] isEqual:[project ID]] && ![[[inv project] ID] isEqual:@""] && ![[project ID] isEqual:@""]))
		{
			[projectInvoices addObject:inv];
		}
	}
	
	return projectInvoices;
}

- (NSArray *)invoiceFigureSettings {
    return [InvoiceDefaults figuresSettings];
}

- (void)setInvoiceFiguresSettings:(NSArray *)settings {
    [InvoiceDefaults setFiguresSettings:settings];
}

- (NSArray *)invoiceDetailsSettings {
    return [InvoiceDefaults detailsSettings];
}

- (void)setInvoiceDetailsSettings:(NSArray *)settings {
    [InvoiceDefaults setDetailsSettings:settings];
}

- (NSArray *)invoiceAddItemDetailsSettings {
    return [InvoiceDefaults addItemDetailsSettings];
}

- (void)setInvoiceAddItemDetailsSettings:(NSArray *)settings {
    [InvoiceDefaults setAddItemDetailsSettings:settings];
}

- (NSArray *)invoiceProfileSettings {
  return [InvoiceDefaults profileSettings];
}

- (void)setInvoiceProfileSettings:(NSArray *)settings {
  [InvoiceDefaults setProfileSettings:settings];
}

- (NSArray *)invoiceDetailsClientSettings {
  return [InvoiceDefaults clientSettings];
}

- (void)setInvoiceClientDetailsSettings:(NSArray *)settings {
  [InvoiceDefaults setClientSettings:settings];
}

#pragma mark - QUOTE FOR CLIENT

-(NSArray*)allQuotesForClient:(ClientOBJ*)client
{
	NSArray * quotesArray = [self loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults];
	
	NSMutableArray * clientsQuotes = [[NSMutableArray alloc] init];
	
	for (QuoteOBJ * quo in quotesArray)
	{
		if ([[[quo client] contentsDictionary] isEqualToDictionary:[client contentsDictionary]] || ([[[quo client] ID] isEqual:[client ID]] && ![[[quo client] ID] isEqual:@""] && ![[client ID] isEqual:@""]))
		{
			[clientsQuotes addObject:quo];
		}
	}
	
	return clientsQuotes;
}
-(NSArray*)allQuotesForProject:(ProjectOBJ*)project
{
	NSArray *quotesArray = [self loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults];
	
	NSMutableArray *projectQuotes = [[NSMutableArray alloc] init];
	
	for(QuoteOBJ *quo in quotesArray)
	{
		if([[[quo project] contentsDictionary] isEqualToDictionary:[project contentsDictionary]] || ([[[quo project] ID] isEqual:[project ID]] && ![[[quo client] ID] isEqual:@""] && ![[project ID] isEqual:@""]))
		{
			[projectQuotes addObject:quo];
		}
	}
	
	return projectQuotes;
}

- (NSArray *)quoteFigureSettings {
    return [QuoteDefaults figuresSettings];
}

- (void)setQuoteFiguresSettings:(NSArray *)settings {
    [QuoteDefaults setFiguresSettings:settings];
}

- (NSArray *)quoteDetailsSettings {
    return [QuoteDefaults detailsSettings];
}

- (void)setQuoteDetailsSettings:(NSArray *)settings {
    [QuoteDefaults setDetailsSettings:settings];
}

- (NSArray *)quoteAddItemDetailsSettings {
    return [QuoteDefaults addItemDetailsSettings];
}

- (void)setQuoteAddItemDetailsSettings:(NSArray *)settings {
    [QuoteDefaults setAddItemDetailsSettings:settings];
}

- (NSArray *)quoteProfileSettings {
  return [QuoteDefaults profileSettings];
}

- (void)setQuoteProfileSettings:(NSArray *)settings {
  [QuoteDefaults setProfileSettings:settings];
}

- (NSArray *)quoteDetailsClientSettings {
  return [QuoteDefaults clientSettings];
}

- (void)setQuoteClientDetailsSettings:(NSArray *)settings {
  [QuoteDefaults setClientSettings:settings];
}

#pragma mark - ESTIMATE FOR CLIENT

-(NSArray*)allEstimatesForClient:(ClientOBJ*)client
{
	NSArray * estimatesArray = [self loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults];
	
	NSMutableArray * clientsEstimates = [[NSMutableArray alloc] init];
	
	for (EstimateOBJ * est in estimatesArray)
	{
		if ([[[est client] contentsDictionary] isEqualToDictionary:[client contentsDictionary]] || ([[[est client] ID] isEqual:[client ID]] && ![[[est client] ID] isEqual:@""] && ![[client ID] isEqual:@""]))
		{
			[clientsEstimates addObject:est];
		}
	}
	
	return clientsEstimates;
}
-(NSArray*)allEstimatesForProject:(ProjectOBJ*)project
{
	NSArray *estimatesArray = [self loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults];
	
	NSMutableArray *projectEstimates = [[NSMutableArray alloc] init];
	
	for(EstimateOBJ *est in estimatesArray)
	{
		if([[[est project] contentsDictionary] isEqualToDictionary:[project contentsDictionary]] || ([[[est project] ID] isEqual:[project ID]] && ![[[est project] ID] isEqual:@""] && ![[project ID] isEqual:@""]))
		{
			[projectEstimates addObject:est];
		}
	}
	
	return projectEstimates;
}

- (NSArray *)estimateFigureSettings {
    return [EstimateDefaults figuresSettings];
}

- (void)setEstimateFiguresSettings:(NSArray *)settings {
    [EstimateDefaults setFiguresSettings:settings];
}

- (NSArray *)estimateDetailsSettings {
    return [EstimateDefaults detailsSettings];
}

- (void)setEstimateDetailsSettings:(NSArray *)settings {
    [EstimateDefaults setDetailsSettings:settings];
}

- (NSArray *)estimateAddItemDetailsSettings {
    return [EstimateDefaults addItemDetailsSettings];
}

- (void)setEstimateAddItemDetailsSettings:(NSArray *)settings {
    [EstimateDefaults setAddItemDetailsSettings:settings];
}

- (NSArray *)estimateProfileSettings {
  return [EstimateDefaults profileSettings];
}

- (void)setEstimateProfileSettings:(NSArray *)settings {
  [EstimateDefaults setProfileSettings:settings];
}

- (NSArray *)estimateDetailsClientSettings {
  return [EstimateDefaults clientSettings];
}

- (void)setEstimateClientDetailsSettings:(NSArray *)settings {
  [EstimateDefaults setClientSettings:settings];
}

#pragma mark - PURCHASE ORDERS FOR CLIENT

-(NSArray*)allPurchaseOrdersForClient:(ClientOBJ*)client
{
	NSArray * purchaseOrdersArray = [self loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults];
	
	NSMutableArray * clientsPurchaseOrders = [[NSMutableArray alloc] init];
	
	for (PurchaseOrderOBJ * po in purchaseOrdersArray)
	{
		if ([[[po client] contentsDictionary] isEqualToDictionary:[client contentsDictionary]] || ([[[po client] ID] isEqual:[client ID]] && ![[[po client] ID] isEqual:@""] && ![[client ID] isEqual:@""]))
		{
			[clientsPurchaseOrders addObject:po];
		}
	}
	
	return clientsPurchaseOrders;
}
-(NSArray*)allPurchaseOrdersForProject:(ProjectOBJ*)project
{
	NSArray *purchaseOrdersArray = [self loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults];
	
	NSMutableArray *projectPurchaseOrders = [[NSMutableArray alloc] init];
	
	for(PurchaseOrderOBJ *po in purchaseOrdersArray)
	{
		if([[[po project] contentsDictionary] isEqualToDictionary:[project contentsDictionary]] || ([[[po project] ID] isEqual:[project ID]] && ![[[po client] ID] isEqual:@""] && ![[project ID] isEqual:@""]))
		{
			[projectPurchaseOrders addObject:po];
		}
	}
	
	return projectPurchaseOrders;
}

- (NSArray *)purchaseFigureSettings {
    return [PurchaseDefaults figuresSettings];
}

- (void)setPurchaseFiguresSettings:(NSArray *)settings {
    [PurchaseDefaults setFiguresSettings:settings];
}

- (NSArray *)purchaseDetailsSettings {
    return [PurchaseDefaults detailsSettings];
}

- (void)setPurchaseDetailsSettings:(NSArray *)settings {
    [PurchaseDefaults setDetailsSettings:settings];
}

- (NSArray *)purchaseAddItemDetailsSettings {
    return [PurchaseDefaults addItemDetailsSettings];
}

- (void)setPurchaseAddItemDetailsSettings:(NSArray *)settings {
    [PurchaseDefaults setAddItemDetailsSettings:settings];
}

- (NSArray *)purchaseProfileSettings {
  return [PurchaseDefaults profileSettings];
}

- (void)setPurchaseProfileSettings:(NSArray *)settings {
  [PurchaseDefaults setProfileSettings:settings];
}

- (NSArray *)purchaseDetailsClientSettings {
  return [PurchaseDefaults clientSettings];
}

- (void)setPurchaseClientDetailsSettings:(NSArray *)settings {
  [PurchaseDefaults setClientSettings:settings];
}

#pragma mark - RECEIPT 

-(void)saveReceiptsCategories:(NSArray*)sender
{
	[CustomDefaults setCustomObjects:sender forKey:kDefaultCategories];
}

-(NSArray*)getReceiptCategories
{
	NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[CustomDefaults customObjectForKey:kDefaultCategories]];
	
	NSComparisonResult (^myComparator)(id, id) = ^NSComparisonResult(NSString * obj1, NSString * obj2) {
		
		return [[obj1 uppercaseString] compare:[obj2 uppercaseString]];
		
	};
	
	[temp sortUsingComparator:myComparator];
	
	return temp;
}

-(NSArray*)allReceiptsForClient:(ClientOBJ*)client
{
	NSArray *receiptsArray = [self loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults];
	
	NSMutableArray *clientsReceipts = [[NSMutableArray alloc] init];
	
	for(ReceiptOBJ *receipt in receiptsArray)
	{
		if([[[receipt client] contentsDictionary] isEqualToDictionary:[client contentsDictionary]] || [[[receipt client] ID] isEqual:[client ID]])
		{
			[clientsReceipts addObject:receipt];
		}
	}
	
	return clientsReceipts;
}

-(NSArray*)allReceiptsForProject:(ProjectOBJ*)project
{
	NSArray *receiptsArray = [self loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults];
	
	NSMutableArray *projectsReceipts = [[NSMutableArray alloc] init];
	
	for(ReceiptOBJ *receipt in receiptsArray)
	{
		if([[[receipt project] contentsDictionary] isEqualToDictionary:[project contentsDictionary]] || [[[receipt project] ID] isEqual:[project ID]])
		{
			[projectsReceipts addObject:receipt];
		}
	}
	
	return projectsReceipts;
}

#pragma mark - TIMESHEET

-(NSString*)getTotalHoursForThisWeek:(NSArray*)timesheetsArray
{
	NSDate *firstDate = [self getFirstDayOfWeek];
	NSDate *lastDate  = [self getLastDayOfWeek];
	NSDate *todayDate = [NSDate date];
		
	float totalTimeInterval = 0.0;
	
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		NSDate *timesheetDate = [timesheet date];

		int firstDay = [self compareDate:firstDate withEndDate:timesheetDate];
		int lastDay = [self compareDate:timesheetDate withEndDate:lastDate];
		int todayDay = [self compareDate:timesheetDate withEndDate:todayDate];
		
		if((firstDay == -1 || firstDay == 0) && (lastDay == -1 || lastDate == 0) && (todayDay == -1 || todayDay == 0))
		{
			for(int i=0;i<timesheet.services.count;i++)
			{
				ServiceTimeOBJ *service = [timesheet serviceTimeAtIndex:i];
				
				totalTimeInterval += [service totalTimeInSeconds];
			}
		}
	}
		
	NSInteger hours = totalTimeInterval / 3600;
	NSInteger remainder = totalTimeInterval - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@ h %@ min", hoursString, minutesString];
}

-(NSString*)getTotalHoursForThisMonth:(NSArray*)timesheetsArray
{
	NSDate *firstDate = [self getFirstDayOfMonth];
	NSDate *lastDate  = [self getLastDayOfMonth];
	NSDate *todayDate = [NSDate date];
		
	float totalTimeInterval = 0.0;
	
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		NSDate *timesheetDate = [timesheet date];
		
		int firstDay = [self compareDate:firstDate withEndDate:timesheetDate];
		int lastDay = [self compareDate:timesheetDate withEndDate:lastDate];
		int todayDay = [self compareDate:timesheetDate withEndDate:todayDate];
		
		if((firstDay == -1 || firstDay == 0) && (lastDay == -1 || lastDate == 0) && (todayDay == -1 || todayDay == 0))
		{
			for(int i=0;i<timesheet.services.count;i++)
			{
				ServiceTimeOBJ *service = [timesheet serviceTimeAtIndex:i];
				
				totalTimeInterval += [service totalTimeInSeconds];
			}
		}
	}
	
	NSInteger hours = totalTimeInterval / 3600;
	NSInteger remainder = totalTimeInterval - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@ h %@ min", hoursString, minutesString];
}

-(NSString*)getTotalHoursForThisYear:(NSArray*)timesheetsArray
{
	NSDate *lastDate  = [self getLastDayOfYear];
	NSDate *todayDate = [NSDate date];
		
	float totalTimeInterval = 0.0;
	
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		NSDate *timesheetDate = [timesheet date];
		
		int lastDay = [self compareDate:timesheetDate withEndDate:lastDate];
		int todayDay = [self compareDate:timesheetDate withEndDate:todayDate];
		
		if((lastDay == -1 || lastDate == 0) && (todayDay == -1 || todayDay == 0))
		{
			for(int i=0;i<timesheet.services.count;i++)
			{
				ServiceTimeOBJ *service = [timesheet serviceTimeAtIndex:i];
				
				totalTimeInterval += [service totalTimeInSeconds];
			}
		}
	}
	
	NSInteger hours = totalTimeInterval / 3600;
	NSInteger remainder = totalTimeInterval - (hours * 3600);
	
	NSInteger minutes = remainder / 60;
	
	NSString * hoursString = [NSString stringWithFormat:@"0%ld", (long)hours];
	NSString * minutesString = [NSString stringWithFormat:@"0%ld", (long)minutes];
	
	if (hours > 9)
	{
		hoursString = [NSString stringWithFormat:@"%ld", (long)hours];
	}
	
	if (minutes > 9)
	{
		minutesString = [NSString stringWithFormat:@"%ld", (long)minutes];
	}
	
	return [NSString stringWithFormat:@"%@ h %@ min", hoursString, minutesString];
}

-(NSArray*)allTimesheetsForClient:(ClientOBJ*)client
{
	NSArray *timesheetsArray = [self loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults];
	
	NSMutableArray *clientsTimesheets = [[NSMutableArray alloc] init];
	
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		if([[[timesheet client] contentsDictionary] isEqualToDictionary:[client contentsDictionary]] || [[[timesheet client] ID] isEqual:[client ID]])
		{
			[clientsTimesheets addObject:timesheet];
		}
	}

	return clientsTimesheets;
}

-(NSArray*)allTimesheetsForProject:(ProjectOBJ*)project
{
	NSArray *timesheetsArray = [self loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults];
	
	NSMutableArray *projectsTimesheets = [[NSMutableArray alloc] init];
		
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		if([[[timesheet project] contentsDictionary] isEqualToDictionary:[project contentsDictionary]] || [[[timesheet project] ID] isEqual:[project ID]])
		{
			[projectsTimesheets addObject:timesheet];
		}
	}
	
	return projectsTimesheets;
}

#pragma mark - CURRENCY

-(NSString*)currency
{
	if (![CustomDefaults customObjectForKey:kCurrencySymbolKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:@"$" forKey:kCurrencySymbolKeyForNSUserDefaults];
	}
	
	return [CustomDefaults customObjectForKey:kCurrencySymbolKeyForNSUserDefaults];
}

-(void)setCurrency:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]] && ![sender isEqual:@""])
	{
		[CustomDefaults setCustomObjects:sender forKey:kCurrencySymbolKeyForNSUserDefaults];
	}
}

-(NSString*)currencyPlacementString
{
	if (![CustomDefaults customObjectForKey:kCurrencyPlacementKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kPlacementForCurrencyFront] forKey:kCurrencyPlacementKeyForNSUserDefaults];
	}
	
	kPlacementForCurrency placement = [[CustomDefaults customObjectForKey:kCurrencyPlacementKeyForNSUserDefaults] intValue];
	
	NSString * string = @"";
	
	switch (placement)
	{
		case kPlacementForCurrencyFront:
		{
			string = @"front";
			
			break;
		}
			
		case kPlacementForCurrencyBack:
		{
			string = @"back";
			
			break;
		}
			
		default:
			break;
	}
	
	return string;
}

-(kPlacementForCurrency)currencyPlacement
{
	if (![CustomDefaults customObjectForKey:kCurrencyPlacementKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kPlacementForCurrencyFront] forKey:kCurrencyPlacementKeyForNSUserDefaults];
	}
	
	return [[CustomDefaults customObjectForKey:kCurrencyPlacementKeyForNSUserDefaults] intValue];
}

-(void)changeCurrencyPlacement
{
	kPlacementForCurrency placement = [[CustomDefaults customObjectForKey:kCurrencyPlacementKeyForNSUserDefaults] intValue];
	
	switch (placement)
	{
		case kPlacementForCurrencyFront:
		{
			[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kPlacementForCurrencyBack] forKey:kCurrencyPlacementKeyForNSUserDefaults];
			
			break;
		}
			
		case kPlacementForCurrencyBack:
		{
			[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kPlacementForCurrencyFront] forKey:kCurrencyPlacementKeyForNSUserDefaults];
			
			break;
		}
			
		default:
			break;
	}
}

-(NSString*)thousandSymbol
{
	return [CustomDefaults customObjectForKey:kNewThousandSymbolKeyForNSUserDefaults];
}

-(NSString*)decimalSymbol
{
	return [CustomDefaults customObjectForKey:kNewDecimalSymbolKeyForNSUserDefaults];
}

-(void)changeThousandSymbol:(NSString*)sender
{
	[CustomDefaults setCustomObjects:sender forKey:kNewThousandSymbolKeyForNSUserDefaults];
}

-(void)changeDecimalSymbol:(NSString*)sender
{
	[CustomDefaults setCustomObjects:sender forKey:kNewDecimalSymbolKeyForNSUserDefaults];
}

-(void)checkSymbols
{
	if (![CustomDefaults customObjectForKey:kThousandSymbolKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kSymbolComma] forKey:kThousandSymbolKeyForNSUserDefaults];
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kSymbolDot] forKey:kDecimalSymbolKeyForNSUserDefaults];
	}
	
	if (![CustomDefaults customObjectForKey:kDecimalSymbolKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kSymbolComma] forKey:kDecimalSymbolKeyForNSUserDefaults];
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kSymbolDot] forKey:kDecimalSymbolKeyForNSUserDefaults];
	}
	
	if([CustomDefaults customObjectForKey:kNewThousandSymbolKeyForNSUserDefaults])
	{
		return;
	}
	
	if([CustomDefaults customObjectForKey:kNewDecimalSymbolKeyForNSUserDefaults])
	{
		return;
	}
	
	kSymbol decimal = [CustomDefaults customIntegerForKey:kDecimalSymbolKeyForNSUserDefaults];
	kSymbol thousand = [CustomDefaults customIntegerForKey:kThousandSymbolKeyForNSUserDefaults];
	
	switch (decimal)
	{
		case kSymbolComma:
		{
			[CustomDefaults setCustomObjects:@"," forKey:kNewDecimalSymbolKeyForNSUserDefaults];
			
			break;
		}
		
		case kSymbolDot:
		{
			[CustomDefaults setCustomObjects:@"." forKey:kNewDecimalSymbolKeyForNSUserDefaults];
			
			break;
		}
	}
	
	switch (thousand)
	{
		case kSymbolComma:
		{
			[CustomDefaults setCustomObjects:@"," forKey:kNewThousandSymbolKeyForNSUserDefaults];
			
			break;
		}
			
		case kSymbolDot:
		{
			[CustomDefaults setCustomObjects:@"." forKey:kNewThousandSymbolKeyForNSUserDefaults];
			
			break;
		}
	}
}

-(NSString*)stringForDecimalPlacement
{
	NSString * string = @"";
	
	switch ([self decimalPlacement])
	{
		case kPlacementForDecimalOneDigit:
		{
			string = @"one digit";
			
			break;
		}
			
		case kPlacementForDecimalTwoDigits:
		{
			string = @"two digits";
			
			break;
		}
			
		case kPlacementForDecimalThreeDigits:
		{
			string = @"three digits";
			
			break;
		}
            
        case kPlacementForDecimalNone:
        {
            string = @"None";
            
            break;
        }
			
		default:
			break;
	}
	
	return string;
}

-(void)changeDecimalPlacement
{
	switch ([self decimalPlacement])
	{
		case kPlacementForDecimalOneDigit:
		{
			[self setDecimalPlacement:kPlacementForDecimalTwoDigits];
			
			break;
		}
			
		case kPlacementForDecimalTwoDigits:
		{
			[self setDecimalPlacement:kPlacementForDecimalThreeDigits];
			
			break;
		}
			
		case kPlacementForDecimalThreeDigits:
		{
			[self setDecimalPlacement:kPlacementForDecimalNone];
			
			break;
		}
            
        case kPlacementForDecimalNone:
        {
            [self setDecimalPlacement:kPlacementForDecimalOneDigit];
            
            break;
        }
			
		default:
			break;
	}
}

-(kPlacementForDecimal)decimalPlacement
{
	if (![CustomDefaults customObjectForKey:kDecimalPlacementKeyForNSUserDefaults])
	{
		[CustomDefaults setCustomObjects:[NSNumber numberWithInt:kPlacementForDecimalTwoDigits] forKey:kDecimalPlacementKeyForNSUserDefaults];
	}
	
	return [[CustomDefaults customObjectForKey:kDecimalPlacementKeyForNSUserDefaults] intValue];
}

-(void)setDecimalPlacement:(kPlacementForDecimal)sender
{
	[CustomDefaults setCustomObjects:[NSNumber numberWithInt:sender] forKey:kDecimalPlacementKeyForNSUserDefaults];
}

-(NSString*)currencyAdjustedValue:(float)sender forSign:(NSString*)sign
{
	kPlacementForDecimal decPlacement = [self decimalPlacement];
	
	NSString * string = @"";
	
	switch (decPlacement)
	{
		case kPlacementForDecimalOneDigit:
		{
			string = [NSString stringWithFormat:@"%.1f", sender];
			
			break;
		}
			
		case kPlacementForDecimalTwoDigits:
		{
			string = [NSString stringWithFormat:@"%.2f", sender];
			
			break;
		}
			
		case kPlacementForDecimalThreeDigits:
		{
			string = [NSString stringWithFormat:@"%.3f", sender];
			
			break;
		}
            
        case kPlacementForDecimalNone:
        {
            string = [NSString stringWithFormat:@"%i", (int)sender];
        }
			
		default:
			break;
	}
	
	NSString * decimal_symbol = [self decimalSymbol];
	NSString * thousand_symbol = [self thousandSymbol];
	
	string = [string stringByReplacingOccurrencesOfString:@"." withString:decimal_symbol];
	
	int integerValue = [[[string componentsSeparatedByString:decimal_symbol] objectAtIndex:0] intValue];
	
	int digit_position = 0;
	NSString * part_string = @"";
	
	if (integerValue == 0)
		part_string = @"0";
	
	while (integerValue > 0)
	{
		digit_position++;
		
		int one_digit = integerValue % 10;
		integerValue = integerValue / 10;
		
		if (digit_position % 3 == 0 && integerValue > 0)
		{
			part_string = [NSString stringWithFormat:@"%@%d%@", thousand_symbol, one_digit, part_string];
		}
		else
		{
			part_string = [NSString stringWithFormat:@"%d%@", one_digit, part_string];
		}
	}
	
    
    NSString * final_form = @"";
    if(decPlacement == kPlacementForDecimalNone) {
        final_form = [NSString stringWithFormat:@"%@", part_string];
    } else {
        final_form = [NSString stringWithFormat:@"%@%@%@", part_string, decimal_symbol, [[string componentsSeparatedByString:decimal_symbol] objectAtIndex:1]];
    }
	
	kPlacementForCurrency placement = [self currencyPlacement];
	
	switch (placement)
	{
		case kPlacementForCurrencyFront:
		{
			final_form = [NSString stringWithFormat:@"%@%@", sign, final_form];
			
			break;
		}
			
		case kPlacementForCurrencyBack:
		{
			final_form = [NSString stringWithFormat:@"%@ %@", final_form, sign];
			
			break;
		}
			
		default:
			break;
	}
	
	return final_form;
}

-(NSString*)currencyAdjustedValue:(float)sender {
  NSString *minus = @"";
  if(sender < 0) {
    sender = ABS(sender);
    minus = @"-";
  }
  
	kPlacementForDecimal decPlacement = [self decimalPlacement];
	
	NSString * string = @"";
	
	switch (decPlacement) {
		case kPlacementForDecimalOneDigit: {
			string = [NSString stringWithFormat:@"%.1f", sender];
			
			break;
		}
			
		case kPlacementForDecimalTwoDigits: {
			string = [NSString stringWithFormat:@"%.2f", sender];
			
			break;
		}
			
		case kPlacementForDecimalThreeDigits: {
			string = [NSString stringWithFormat:@"%.3f", sender];
			
			break;
		}
            
    case kPlacementForDecimalNone: {
        string = [NSString stringWithFormat:@"%i", (int)sender];
    }
			
		default:
			break;
	}
	
	NSString * decimal_symbol = [self decimalSymbol];
	NSString * thousand_symbol = [self thousandSymbol];
	
	string = [string stringByReplacingOccurrencesOfString:@"." withString:decimal_symbol];
	
	int integerValue = [[[string componentsSeparatedByString:decimal_symbol] objectAtIndex:0] intValue];
	
	int digit_position = 0;
	NSString * part_string = @"";
	
	if (integerValue == 0)
		part_string = @"0";
	
	while (integerValue != 0) {
		digit_position++;
		
		int one_digit = integerValue % 10;
		integerValue = integerValue / 10;
		
		if (digit_position % 3 == 0 && integerValue > 0) {
			part_string = [NSString stringWithFormat:@"%@%d%@", thousand_symbol, one_digit, part_string];
		} else {
			part_string = [NSString stringWithFormat:@"%d%@", one_digit, part_string];
		}
	}
	
    NSString * final_form = @"";
    if(decPlacement == kPlacementForDecimalNone) {
        final_form = [NSString stringWithFormat:@"%@", part_string];
    } else {
        final_form = [NSString stringWithFormat:@"%@%@%@", part_string, decimal_symbol, [[string componentsSeparatedByString:decimal_symbol] objectAtIndex:1]];
    }
	
	kPlacementForCurrency placement = [self currencyPlacement];
	
	switch (placement) {
		case kPlacementForCurrencyFront: {
			final_form = [NSString stringWithFormat:@"%@%@%@", [self currency], minus, final_form];
			
			break;
		}
			
		case kPlacementForCurrencyBack: {
			final_form = [NSString stringWithFormat:@"%@%@ %@", minus, final_form, [self currency]];
			
			break;
		}
			
		default:
			break;
	}
	
	return final_form;
}

-(NSString*)valueAdjusted:(float)sender
{
	kPlacementForDecimal decPlacement = [self decimalPlacement];
	
	NSString * string = @"";
	
	switch (decPlacement)
	{
		case kPlacementForDecimalOneDigit:
		{
			string = [NSString stringWithFormat:@"%.1f", sender];
			
			break;
		}
			
		case kPlacementForDecimalTwoDigits:
		{
			string = [NSString stringWithFormat:@"%.2f", sender];
			
			break;
		}
			
		case kPlacementForDecimalThreeDigits:
		{
			string = [NSString stringWithFormat:@"%.3f", sender];
			
			break;
		}
            
        case kPlacementForDecimalNone:
        {
            string = [NSString stringWithFormat:@"%i", (int)sender];
        }
			
		default:
			break;
	}
	
	NSString * decimal_symbol = [self decimalSymbol];
	NSString * thousand_symbol = [self thousandSymbol];
	
	string = [string stringByReplacingOccurrencesOfString:@"." withString:decimal_symbol];
	
	int integerValue = [[[string componentsSeparatedByString:decimal_symbol] objectAtIndex:0] intValue];
	
	int digit_position = 0;
	NSString * part_string = @"";
	
	if (integerValue == 0)
		part_string = @"0";
	
	while (integerValue > 0)
	{
		digit_position++;
		
		int one_digit = integerValue % 10;
		integerValue = integerValue / 10;
		
		if (digit_position % 3 == 0 && integerValue > 0)
		{
			part_string = [NSString stringWithFormat:@"%@%d%@", thousand_symbol, one_digit, part_string];
		}
		else
		{
			part_string = [NSString stringWithFormat:@"%d%@", one_digit, part_string];
		}
	}
	
    NSString * final_form = @"";
    if(decPlacement == kPlacementForDecimalNone) {
        final_form = [NSString stringWithFormat:@"%@", part_string];
    } else {
        final_form = [NSString stringWithFormat:@"%@%@%@", part_string, decimal_symbol, [[string componentsSeparatedByString:decimal_symbol] objectAtIndex:1]];
    }
	
	return final_form;
}

-(NSString*)currencyStrippedString:(NSString*)sender
{
	NSString * string = [sender stringByReplacingOccurrencesOfString:[self thousandSymbol] withString:@""];
	string = [string stringByReplacingOccurrencesOfString:[self decimalSymbol] withString:@"."];
		
	kPlacementForDecimal decPlacement = [self decimalPlacement];
	
	switch (decPlacement)
	{
		case kPlacementForDecimalOneDigit:
		{
			string = [NSString stringWithFormat:@"%.1f", [string floatValue]];
			
			break;
		}
			
		case kPlacementForDecimalTwoDigits:
		{
			string = [NSString stringWithFormat:@"%.2f", [string floatValue]];
			
			break;
		}
			
		case kPlacementForDecimalThreeDigits:
		{
			string = [NSString stringWithFormat:@"%.3f", [string floatValue]];
			
			break;
		}
            
        case kPlacementForDecimalNone:
        {
            string = [NSString stringWithFormat:@"%li", (long)[sender integerValue]];
        }
			
		default:
			break;
	}
	
	return string;
}

#pragma mark - DUE CALCULATIONS

-(int)daysBetweenDate:(NSDate*)date1 andDate:(NSDate*)date2
{
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	date1 = [date_formatter dateFromString:[date_formatter stringFromDate:date1]];
	date2 = [date_formatter dateFromString:[date_formatter stringFromDate:date2]];
	
	NSDateComponents * components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0];
	
	return (int)components.day;
}

-(NSString*)dueStringForDate:(NSDate*)date1 andDate:(NSDate*)date2
{
	int days = [self daysBetweenDate:date1 andDate:date2];
	
	NSString * dueString = [NSString stringWithFormat:@"Due in %d days.", days];
	
	if (days == 0)
	{
		dueString = @"Due today.";
	}
	else if (days < 0)
	{
		if (days == -1)
		{
			dueString = @"Overdue by one day.";
		}
		else
		{
			dueString = [NSString stringWithFormat:@"Overdue by %d days.", -days];
		}
	}
	else if (days == 1)
	{
		dueString = @"Due in one day.";
	}
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	if ([[date_formatter stringFromDate:date2] isEqual:@"01/01/70"])
		dueString = @"Due on receipt";
	
	return dueString;
}

#pragma mark - IMAGE SIZE

-(CGSize)sizeOfAspectScaledSize:(CGSize)im inSize:(CGSize)size
{
	float x, y;
	float a, b;
	
	x = size.width;
	y = size.height;
	
	a = im.width;
	b = im.height;
	
	float imgRatio = a / b;
	float maxRatio = x / y;
	
	
	if ( imgRatio != maxRatio)
	{
		if (imgRatio < maxRatio)
		{
			imgRatio = y / b;
			a = imgRatio * a;
			b = y;
		}
		else
		{
			imgRatio = x / a;
			b = imgRatio * b;
			a = x;
		}
	}
	else
	{
		a = x;
		b = y;
	}
	
	return CGSizeMake(a, b);
}

#pragma mark - TEXT SIZE

-(CGSize)sizeForString:(NSString*)string withFont:(UIFont*)font constrainedToSize:(CGSize)size
{
	if ([[[UIDevice currentDevice] systemVersion] intValue] > 6)
	{
		NSStringDrawingOptions options = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
		NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName, nil];
		CGSize theSize = [string boundingRectWithSize:size options:options attributes:attributes context:nil].size;
		return theSize;
	}
	else
	{
		CGSize theSize = [string sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
		return theSize;
	}
}

#pragma mark - TRIM QUANTITY

-(CGFloat)trimmedQuantity:(CGFloat)quantity
{
	NSString * value = [NSString stringWithFormat:@"%g", quantity];
	
	CGFloat trimm = [value floatValue];
	
	NSArray * components = [value componentsSeparatedByString:@"."];
	
	if (components.count > 1)
	{
		NSString * afterPoint = [components objectAtIndex:1];
		
		switch ([self decimalPlacement])
		{
			case kPlacementForDecimalOneDigit:
			{
				trimm = [[NSString stringWithFormat:@"%.1f", [value floatValue]] floatValue];
				
				break;
			}
				
			case kPlacementForDecimalTwoDigits:
			{
				if (afterPoint.length > 2)
				{
					trimm = [[NSString stringWithFormat:@"%.2f", [value floatValue]] floatValue];
				}
				
				break;
			}
				
			case kPlacementForDecimalThreeDigits:
			{
				if (afterPoint.length > 3)
				{
					trimm = [[NSString stringWithFormat:@"%.3f", [value floatValue]] floatValue];
				}
				
				break;
			}
                
            case kPlacementForDecimalNone:
            {
                if (afterPoint.length > 1)
                {
                    trimm = [[NSString stringWithFormat:@"%i", (int)[value floatValue]] integerValue];
                }
            }
		}
	}
	
	return trimm;
}

-(NSArray*)generateExportCategories
{
	NSMutableArray *categoriesArray;
	
	switch (app_version)
	{
		case kApplicationVersionInvoice:
		{
			categoriesArray = [[NSMutableArray alloc] initWithObjects:@"All Data",@"Invoices",@"Quotes",@"Estimates",@"Purchase Orders",@"Receipts",@"Timesheets",@"Products and Services",@"Contacts",@"Projects", nil];
			break;
		}
			
		case kApplicationVersionEstimate:
		{
			categoriesArray = [[NSMutableArray alloc] initWithObjects:@"All Data",@"Estimates",@"Products and Services",@"Contacts",@"Projects", nil];
			break;
		}
			
		case kApplicationVersionPurchase:
		{
			categoriesArray = [[NSMutableArray alloc] initWithObjects:@"All Data",@"Purchase Orders",@"Products and Services",@"Contacts",@"Projects", nil];
			break;
		}
			
		case kApplicationVersionQuote:
		{
			categoriesArray = [[NSMutableArray alloc] initWithObjects:@"All Data",@"Quotes",@"Products and Services",@"Contacts",@"Projects", nil];
			break;
		}
			
		case kApplicationVersionReceipts:
		{
			categoriesArray = [[NSMutableArray alloc] initWithObjects:@"All Data",@"Receipts",@"Products and Services",@"Contacts",@"Projects", nil];
			break;
		}
			
		case kApplicationVersionTimesheets:
		{
			categoriesArray = [[NSMutableArray alloc] initWithObjects:@"All Data",@"Timesheets",@"Products and Services",@"Contacts",@"Projects", nil];
			break;
		}
			
		default:
			break;
	}
	
	return categoriesArray;
}

#pragma mark - DATE

-(int)compareDate:(NSDate*)startDate withEndDate:(NSDate*)endDate
{
	NSComparisonResult result = [startDate compare:endDate];
	
	switch (result)
	{
		case NSOrderedAscending:
		{
			return -1;
			
			break;
		}
			
		case NSOrderedDescending:
		{
			return 1;
			
			break;
		}
			
		case NSOrderedSame:
		{
			return 0;
			
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - CSV LOAD FUNCTIONS

-(NSArray*)getInvoiceArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSArray *array = [[NSArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
	
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(InvoiceOBJ *invoice in array)
	{
		NSDate *invoiceStart = [date_formatter dateFromString:[invoice date]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:invoiceStart];
		int endResult = [data_manager compareDate:invoiceStart withEndDate:endDate];
				
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:invoice];
	}
	
	return temp;
}

-(NSArray*)getQuotesArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSArray *array = [[NSArray alloc] initWithArray:[data_manager loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults]];
	
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(QuoteOBJ *quote in array)
	{
		NSDate *quoteStart = [date_formatter dateFromString:[quote creationDate]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:quoteStart];
		int endResult = [data_manager compareDate:quoteStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:quote];
	}
	
	return temp;
}

-(NSArray*)getEstimatesArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSArray *array = [[NSArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
	
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(EstimateOBJ *estimate in array)
	{
		NSDate *estimateStart = [date_formatter dateFromString:[estimate creationDate]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:estimateStart];
		int endResult = [data_manager compareDate:estimateStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:estimate];
	}
	
	return temp;
}

-(NSArray*)getPurchaseArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSArray *array = [[NSArray alloc] initWithArray:[data_manager loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults]];
	
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(PurchaseOrderOBJ* purchase in array)
	{
		NSDate *purchaseStart = [date_formatter dateFromString:[purchase creationDate]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:purchaseStart];
		int endResult = [data_manager compareDate:purchaseStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:purchase];
	}
	
	return temp;
}

-(NSArray*)getReceiptsArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSArray *array = [[NSArray alloc] initWithArray:[data_manager loadReceiptsArrayFromUserDefaultsAtKey:kReceiptsKeyForNSUserDefaults]];
	
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(ReceiptOBJ *receipt in array)
	{
		NSDate *receiptStart = [receipt date];
		
		int startResult = [data_manager compareDate:startDate withEndDate:receiptStart];
		int endResult = [data_manager compareDate:receiptStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:receipt];
	}
	
	return temp;
}

-(NSArray*)getTimesheetsArrayFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSArray *array = [[NSArray alloc] initWithArray:[data_manager loadTimesheetsArrayFromUserDefaultsAtKey:kTimeSheetKeyForNSUserDefaults]];
		
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(TimeSheetOBJ *timesheet in array)
	{
		NSDate *timesheetStart = [timesheet date];
				
		int startResult = [data_manager compareDate:startDate withEndDate:timesheetStart];
		int endResult = [data_manager compareDate:timesheetStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:timesheet];
	}
	
	return temp;
}

-(NSArray*)getProductsFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSMutableArray * productsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
	
	return productsArray;
}

-(NSArray*)getContactsFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSMutableArray *contactsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadClientsArrayFromUserDefaultsAtKey:kClientsKeyForNSUserDefaults]];
	
	return contactsArray;
}

-(NSArray*)getProjectsFromDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	
	NSArray *invoiceArray = [[NSArray alloc] initWithArray:[data_manager loadInvoicesArrayFromUserDefaultsAtKey:kInvoicesKeyForNSUserDefaults]];
	NSArray *quotesArray = [[NSArray alloc] initWithArray:[data_manager loadQuotesArrayFromUserDefaultsAtKey:kQuotesKeyForNSUserDefaults]];
	NSArray *estimateArray = [[NSArray alloc] initWithArray:[data_manager loadEstimatesArrayFromUserDefaultsAtKey:kEstimatesKeyForNSUserDefaults]];
	NSArray *purchaseArray = [[NSArray alloc] initWithArray:[data_manager loadPurchaseOrdersArrayFromUserDefaultsAtKey:kPurchaseOrdersKeyForNSUserDefaults]];
		
	NSMutableArray *projectsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProjectsArrayFromUserDefaultsAtKey:kProjectsKeyForNSUserDefaults]];
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];

	for(InvoiceOBJ *invoice in invoiceArray)
	{
		NSDate *invoiceStart = [date_formatter dateFromString:[invoice date]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:invoiceStart];
		int endResult = [data_manager compareDate:invoiceStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:[invoice project]];
	}
	
	for(QuoteOBJ *quote in quotesArray)
	{
		NSDate *quoteStart = [date_formatter dateFromString:[quote creationDate]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:quoteStart];
		int endResult = [data_manager compareDate:quoteStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:[quote project]];
	}
	
	for(EstimateOBJ *estimate in estimateArray)
	{
		NSDate *estimateStart = [date_formatter dateFromString:[estimate creationDate]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:estimateStart];
		int endResult = [data_manager compareDate:estimateStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:[estimate project]];
	}
	
	for(PurchaseOrderOBJ *purchase in purchaseArray)
	{
		NSDate *purchaseStart = [date_formatter dateFromString:[purchase creationDate]];
		
		int startResult = [data_manager compareDate:startDate withEndDate:purchaseStart];
		int endResult = [data_manager compareDate:purchaseStart withEndDate:endDate];
		
		if(startResult == 1)
			continue;
		
		if(endResult == 1)
			continue;
		
		[temp addObject:[purchase project]];
	}
		
	for(int i=0;i<projectsArray.count;i++)
	{
		ProjectOBJ *project = (ProjectOBJ*)[projectsArray objectAtIndex:i];
		
		BOOL projectToRemove = YES;
		
		for(NSInteger j=0;j<temp.count;j++)
		{
			ProjectOBJ *project2 = [[ProjectOBJ alloc] initWithProject:[temp objectAtIndex:j]];
			
			if([project isEqual:project2])
				projectToRemove = NO;
			
			if(projectToRemove == NO)
				j = temp.count + 1;
		}
		
		if(projectToRemove == YES)
		{
			[projectsArray removeObjectAtIndex:i];
		}
	}
	
	return projectsArray;
}

#pragma mark - GENERATE ID

-(NSString*)generateDeviceID
{
	NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
	
	NSMutableString *s = [NSMutableString stringWithCapacity:20];
	
	for (NSUInteger i = 0U; i < 20; i++)
	{
		u_int32_t r = arc4random() % [alphabet length];
		unichar c = [alphabet characterAtIndex:r];
		[s appendFormat:@"%C", c];
	}
	
	return s;
	
	/*
	 unsigned char result[16];
	 const char *cStr = [[[NSProcessInfo processInfo] globallyUniqueString] UTF8String];
	 CC_MD5( cStr, strlen(cStr), result );
	 _openUDID = [NSString stringWithFormat:
	 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08x",
	 result[0], result[1], result[2], result[3],
	 result[4], result[5], result[6], result[7],
	 result[8], result[9], result[10], result[11],
	 result[12], result[13], result[14], result[15],
	 arc4random() % 4294967295];
	 */
}

-(NSString*)createInvoiceID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_invoice_%f",deviceID,timeInterval];
}

-(NSString*)createQuoteID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_quote_%f",deviceID,timeInterval];
}

-(NSString*)createEstimateID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_estimate_%f",deviceID,timeInterval];
}

-(NSString*)createPurchaseOrderID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_purchase_order_%f",deviceID,timeInterval];
}

-(NSString*)createProductID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_product_%f",deviceID,timeInterval];
}

-(NSString*)createServiceID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_service_%f",deviceID,timeInterval];
}

-(NSString*)createContactID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_contact_%f",deviceID,timeInterval];
}

-(NSString*)createProjectID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_project_%f",deviceID,timeInterval];
}

-(NSString*)createReceiptID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_receipt_%f",deviceID,timeInterval];
}

-(NSString*)createTimeSheetID
{
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
	
	NSString *deviceID = [[NSString alloc] initWithString:[CustomDefaults customStringForKey:DEVICE_ID]];
	
	return [NSString stringWithFormat:@"%@_timesheet_%f",deviceID,timeInterval];
}

#pragma mark - DATES

-(NSDate*)getFirstDayOfWeek
{
	NSDate *weekDate = [NSDate date];
	NSCalendar *myCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *currentComps = [myCalendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:weekDate];
	
	[currentComps setWeekday:1]; // 1: sunday
	NSDate *firstDayOfTheWeek = [myCalendar dateFromComponents:currentComps];

	return firstDayOfTheWeek;
}

-(NSDate*)getLastDayOfWeek
{
	NSDate *weekDate = [NSDate date];
	NSCalendar *myCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *currentComps = [myCalendar components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:weekDate];
	
	[currentComps setWeekday:7]; // 7: saturday
	NSDate *lastDayOfTheWeek = [myCalendar dateFromComponents:currentComps];

	return lastDayOfTheWeek;
}

-(NSDate*)getFirstDayOfMonth
{
	NSDate *today = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *components = [gregorian components:(NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
	components.day = 1;
	
	NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
	
	return dayOneInCurrentMonth;
}

-(NSDate*)getLastDayOfMonth
{
	NSDate *curDate = [NSDate date];
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:curDate]; // Get necessary date components
	
	[comps setMonth:[comps month]+1];
	[comps setDay:0];
	NSDate *tDateMonth = [calendar dateFromComponents:comps];
	
	return tDateMonth;
}

-(NSDate*)getFirstDayOfYear
{
	[date_formatter setDateFormat:@"yyyy"];
	
	NSString *dateString = [NSString stringWithFormat:@"01/01/%@",[date_formatter stringFromDate:[NSDate date]]];
	
	[date_formatter setDateFormat:@"dd/MM/yyyy"];
	
	NSDate *firstDay = [date_formatter dateFromString:dateString];
	
	return firstDay;
}

-(NSDate*)getLastDayOfYear
{
	[date_formatter setDateFormat:@"yyyy"];
	
	NSString *dateString = [NSString stringWithFormat:@"31/12/%@",[date_formatter stringFromDate:[NSDate date]]];
	
	[date_formatter setDateFormat:@"dd/MM/yyyy"];
	
	NSDate *lastDay = [date_formatter dateFromString:dateString];
	
	return lastDay;
}

#pragma mark - STRINGS

-(NSString*)stripString:(NSString*)sender
{
	NSString *stripString = [[NSString alloc] initWithString:[sender stringByReplacingOccurrencesOfString:@" " withString:@""]];
	
	if([stripString isEqual:@""])
	{
		return @"";
	}
	
	return sender;
}

-(void)makeProductsAndServicesTaxable
{
	NSMutableArray *productsArray = [[NSMutableArray alloc] initWithArray:[data_manager loadProductsArrayFromUserDefaultsAtKey:kProductsKeyForNSUserDefaults]];
	
	for(int i=0;i<productsArray.count;i++)
	{
		if([[productsArray objectAtIndex:i] isKindOfClass:[ProductOBJ class]])
		{
			ProductOBJ *product = [[ProductOBJ alloc] initWithProduct:[productsArray objectAtIndex:i]];
			
			[product setTaxable:YES];
			
			[productsArray replaceObjectAtIndex:i withObject:product];
		}
		else
		{
			ServiceOBJ *product = [[ServiceOBJ alloc] initWithService:[productsArray objectAtIndex:i]];
			
			[product setTaxable:YES];
			
			[productsArray replaceObjectAtIndex:i withObject:product];
		}
	}
	
	[CustomDefaults setCustomBool:YES forKey:kDefaultTaxable];
	
	[data_manager saveProductsArrayToUserDefaults:productsArray forKey:kProductsKeyForNSUserDefaults];
}

@end