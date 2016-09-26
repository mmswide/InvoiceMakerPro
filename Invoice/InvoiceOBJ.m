//
//  InvoiceOBJ.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "InvoiceOBJ.h"

#import "Defines.h"

@implementation InvoiceOBJ

-(id)init
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setID:[data_manager createInvoiceID]];
		[contents setObject:kInvTitle forKey:@"title"];
		[self setName:@""];
		[self setClient:[[[ClientOBJ alloc] init] contentsDictionary]];
    [self setClientBillingTitleforKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults
                          shippingKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults];
		[self setProject:[[[ProjectOBJ alloc] init] contentsDictionary]];
		[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setProducts:[NSArray array]];
		[self setDiscount:0.0f];
		
		[self setTax1Name:[settingsDictionary objectForKey:@"taxAbreviation1"]];
		[self setTax1Percentage:[[settingsDictionary objectForKey:@"taxRate1"] floatValue]];
		
		[self setTax2Name:[settingsDictionary objectForKey:@"taxAbreviation2"]];
		[self setTax2Percentage:[[settingsDictionary objectForKey:@"taxRate2"] floatValue]];
		
		[self setPaid:0.0f];
		[self setShippingValue:0.0];
		[self setNote:INVOICE_FIRST_PAGE_NOTE];
		[self setBigNote:INVOICE_SECOND_PAGE_NOTE];
    
		[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
    
    [self setRightSignatureTitle:INVOICE_RIGHT_SIGNATURE_TITLE];
    [self setRightSignatureDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setRightSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]]];
		[self setRightSignatureFrame:INVOICE_RIGHT_FRAME];
    
    [self setLeftSignatureTitle:INVOICE_LEFT_SIGNATURE_TITLE];
    [self setLeftSignatureDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setLeftSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]]];
		[self setLeftSignatureFrame:INVOICE_LEFT_FRAME];
    
    [self setFiguresSettings:[self savedFigureSettings]];
    [self setDetailsSettings:[self savedDetailsSettingsWithCustomFields:YES]];
    [self setAddItemDetailsSettings:[self savedAddItemDetailsSettings]];
    NSArray *addItemSettings = [self localAddItemDetailsSettings];
    if(!addItemSettings || [addItemSettings count] == 0) {
      [self saveAddItemDetailsSettings];
    }
    
    CompanyOBJ *newCompany = [CompanyOBJ savedCompany];
    [self setProfileSettings:[[self savedProfileSettingsWithCustomFields:NO] arrayByAddingObjectsFromArray:[newCompany customProfileFieldsVisibleOnly:NO]]];
    [self setCompanyAlignLeft:[newCompany companyAlignLeft]];
    [self setClientSettings:[self savedClientSettings]];
	}
	
	return self;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		if (sender && [sender isKindOfClass:[InvoiceOBJ class]])
		{
			[self setID:[sender ID]];
			[contents setObject:[sender title] forKey:@"title"];
			[self setName:[sender name]];
			[self setClient:[[sender client] contentsDictionary]];
      [self setClientBillingTitleforKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults
                            shippingKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults];
			[self setProject:[[sender project] contentsDictionary]];
			[self setDate:[date_formatter dateFromString:[sender date]]];
			[self setDueDate:[date_formatter dateFromString:[sender dueDate]]];
			[self setTerms:[sender terms]];
			[self setProducts:[sender products]];
			[self setDiscount:[sender discount]];
      
			[self setTax1Name:[sender tax1Name]];
			[self setTax1Percentage:[sender tax1Percentage]];
			[self setTax2Name:[sender tax2Name]];
			[self setTax2Percentage:[sender tax2Percentage]];
      
			[self setPaid:[sender paid]];
			[self setShippingValue:[sender shippingValue]];
			[self setNote:[sender note]];
			[self setBigNote:[sender bigNote]];
			[self setStringNumber:[sender number]];
      
			[self setOtherCommentsTitle:[sender otherCommentsTitle]];
			[self setOtherCommentsText:[sender otherCommentsText]];
      
			[self setRightSignatureTitle:[sender rightSignatureTitle]];
			[self setRightSignatureDate:[date_formatter dateFromString:[sender rightSignatureDate]]];
			[self setRightSignature:[sender rightSignature]];
			[self setRightSignatureFrame:[sender rightSignatureFrame]];
      
			[self setLeftSignatureTitle:[sender leftSignatureTitle]];
			[self setLeftSignatureDate:[date_formatter dateFromString:[sender leftSignatureDate]]];
			[self setLeftSignature:[sender leftSignature]];
			[self setLeftSignatureFrame:[sender leftSignatureFrame]];
      
      [self setAlwaysShowNote:[sender alwaysShowNote]];
      [self setAlwaysShowOtherComments:[sender alwaysShowOtherComments]];
      [self setAlwaysShowSignatureLeft:[sender alwaysShowSignatureLeft]];
      [self setAlwaysShowSignatureRight:[sender alwaysShowSignatureRight]];
      
      [self setFiguresSettings:[sender figuresSettings]];
      [self setDetailsSettings:[sender detailsSettings]];
      [self setAddItemDetailsSettings:[sender addItemDetailsSettings]];
      [self setProfileSettings:[sender profileSettings]];
      [self setCompanyAlignLeft:[sender companyAlignLeft]];
      [self setClientSettings:[sender clientSettings]];
		}
		else
		{
			NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
			
			[self setID:[data_manager createInvoiceID]];
			[contents setObject:kInvTitle forKey:@"title"];
			[self setName:@""];
			[self setClient:[[[ClientOBJ alloc] init] contentsDictionary]];
      [self setClientBillingTitleforKey:kInvoiceBillingAddressTitleKeyForNSUserDefaults
                            shippingKey:kInvoiceShippingAddressTitleKeyForNSUserDefaults];
			[self setProject:[[[ProjectOBJ alloc] init] contentsDictionary]];
			[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
			[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
			[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
			[self setProducts:[NSArray array]];
			[self setDiscount:0.0f];
			
			[self setTax1Name:[settingsDictionary objectForKey:@"taxAbreviation1"]];
			[self setTax1Percentage:[[settingsDictionary objectForKey:@"taxRate1"] floatValue]];
			
			[self setTax2Name:[settingsDictionary objectForKey:@"taxAbreviation2"]];
			[self setTax2Percentage:[[settingsDictionary objectForKey:@"taxRate2"] floatValue]];
			
			[self setPaid:0.0f];
			[self setShippingValue:0.0];
			[self setNote:INVOICE_FIRST_PAGE_NOTE];
			[self setBigNote:INVOICE_SECOND_PAGE_NOTE];
      
			[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
			[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
      
			[self setRightSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]]];
			[self setRightSignatureFrame:INVOICE_RIGHT_FRAME];
      
			[self setLeftSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]]];
			[self setLeftSignatureFrame:INVOICE_LEFT_FRAME];
      
      [self setFiguresSettings:[self savedFigureSettings]];
      [self setDetailsSettings:[self savedDetailsSettingsWithCustomFields:YES]];
      [self setAddItemDetailsSettings:[self savedAddItemDetailsSettings]];
      CompanyOBJ *newCompany = [CompanyOBJ savedCompany];
      [self setProfileSettings:[[self savedProfileSettingsWithCustomFields:NO] arrayByAddingObjectsFromArray:[newCompany customProfileFieldsVisibleOnly:NO]]];
      [self setCompanyAlignLeft:[newCompany companyAlignLeft]];
      [self setClientSettings:[self savedClientSettings]];
		}
	}
	
	return self;
}

-(id)initWithContentsDictionary:(NSDictionary*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		[contents addEntriesFromDictionary:sender];
	}
	
	return self;
}

-(id)initWithQuote:(QuoteOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setID:[data_manager createInvoiceID]];
		[contents setObject:kInvTitle forKey:@"title"];
		[self setName:[sender name]];
		[self setClient:[[sender client] contentsDictionary]];
		[self setProject:[[sender project] contentsDictionary]];
		[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setProducts:[sender products]];
		[self setDiscount:[sender discount]];
		
		[self setTax1Name:[sender tax1Name]];
		[self setTax1Percentage:[sender tax1Percentage]];
		
		[self setTax2Name:[sender tax2Name]];
		[self setTax2Percentage:[sender tax2Percentage]];
		
		[self setPaid:0.0f];
		[self setShippingValue:[sender shippingValue]];
		[self setNote:[sender note]];
		[self setBigNote:[sender bigNote]];
		[self setStringNumber:[sender number]];
		[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
		[self setRightSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]]];
		[self setRightSignatureFrame:INVOICE_RIGHT_FRAME];
		[self setLeftSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]]];
		[self setLeftSignatureFrame:INVOICE_LEFT_FRAME];
	}
	
	return self;
}

-(id)initWithEstimate:(EstimateOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setID:[data_manager createInvoiceID]];
		[contents setObject:kInvTitle forKey:@"title"];
		[self setName:[sender name]];
		[self setClient:[[sender client] contentsDictionary]];
		[self setProject:[[sender project] contentsDictionary]];
		[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setProducts:[sender products]];
		[self setDiscount:[sender discount]];
		
		[self setTax1Name:[sender tax1Name]];
		[self setTax1Percentage:[sender tax1Percentage]];
		
		[self setTax2Name:[sender tax2Name]];
		[self setTax2Percentage:[sender tax2Percentage]];
		
		[self setPaid:0.0f];
		[self setShippingValue:[sender shippingValue]];
		[self setNote:[sender note]];
		[self setBigNote:[sender bigNote]];
		[self setStringNumber:[sender number]];
		[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
		[self setRightSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]]];
		[self setRightSignatureFrame:INVOICE_RIGHT_FRAME];
		[self setLeftSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]]];
		[self setLeftSignatureFrame:INVOICE_LEFT_FRAME];
	}
	
	return self;
}

-(id)initWithPurchaseOrder:(PurchaseOrderOBJ*)sender
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];

		[self setID:[data_manager createInvoiceID]];
		[contents setObject:kInvTitle forKey:@"title"];
		[self setName:[sender name]];
		[self setClient:[[sender client] contentsDictionary]];
		[self setProject:[[sender project] contentsDictionary]];
		[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setProducts:[sender products]];
		[self setDiscount:[sender discount]];
		
		[self setTax1Name:[sender tax1Name]];
		[self setTax1Percentage:[sender tax1Percentage]];
		
		[self setTax2Name:[sender tax2Name]];
		[self setTax2Percentage:[sender tax2Percentage]];
		
		[self setPaid:0.0f];
		[self setShippingValue:[sender shippingValue]];
		[self setNote:[sender note]];
		[self setBigNote:[sender bigNote]];
		[self setStringNumber:[sender number]];
		[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
		[self setRightSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]]];
		[self setRightSignatureFrame:INVOICE_RIGHT_FRAME];
		[self setLeftSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]]];
		[self setLeftSignatureFrame:INVOICE_LEFT_FRAME];
	}
	
	return self;
}

-(id)initWithTimesheet:(TimeSheetOBJ*)sender
{
	self = [super init];
	
	if(self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		NSDictionary *settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[self setID:[data_manager createInvoiceID]];
		[contents setObject:kInvTitle forKey:@"title"];
		[self setName:[sender title]];
		[self setClient:[[sender client] contentsDictionary]];
		[self setProject:[[sender project] contentsDictionary]];
		[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		
		NSMutableArray *productsArray = [[NSMutableArray alloc] init];
		
		for(int i=0;i<[sender services].count;i++)
		{
			ServiceTimeOBJ *time = [sender serviceTimeAtIndex:i];
			
			ProductOBJ *product = [time product];
			[product setPrice:[time getTotal]];
			
			[productsArray addObject:[product contentsDictionary]];
		}
		
		[self setProducts:productsArray];
		
		[self setDiscount:[sender discount]];

		[self setTax1Name:@""];
		[self setTax1Percentage:0.0];
		[self setTax2Name:@""];
		[self setTax2Percentage:0.0];
		
		[self setPaid:0.0];
		[self setShippingValue:0.0];
		
		[self setNote:[sender note]];
		[self setBigNote:[sender bigNote]];
		
		[self setStringNumber:[sender number]];
		
		[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
		[self setRightSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]]];
		[self setRightSignatureFrame:INVOICE_RIGHT_FRAME];
		[self setLeftSignature:[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]]];
		[self setLeftSignatureFrame:INVOICE_LEFT_FRAME];
	}
	
	return self;
}

-(id)initForTemplate
{
	self = [super init];
	
	if (self)
	{
		contents = [[NSMutableDictionary alloc] init];
		[contents setObject:NSStringFromClass([self class]) forKey:@"class"];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		NSDictionary * settingsDictionary = [[NSDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
		
		[contents setObject:kInvTitle forKey:@"title"];
		[self setName:@"Template"];
		[self setClient:[[[ClientOBJ alloc] initForTemplate] contentsDictionary]];
		[self setProject:[[[ProjectOBJ alloc] init] contentsDictionary]];
		[self setDate:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]];
		[self setDueDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
		[self setTerms:[[settingsDictionary objectForKey:@"terms"] intValue]];
		[self setProducts:[NSArray arrayWithObject:[[[ProductOBJ alloc] initForTemplate] contentsDictionary]]];
		[self setDiscount:10.0f];
		
		[self setTax1Name:[settingsDictionary objectForKey:@"taxAbreviation1"]];
		[self setTax1Percentage:[[settingsDictionary objectForKey:@"taxRate1"] floatValue]];
		
		[self setTax2Name:[settingsDictionary objectForKey:@"taxAbreviation2"]];
		[self setTax2Percentage:[[settingsDictionary objectForKey:@"taxRate2"] floatValue]];
		
		[self setPaid:0.0f];
		[self setShippingValue:20.0];
		[self setNote:@"Note"];
		[self setBigNote:@"Big Note"];
		[self setOtherCommentsTitle:INVOICE_OTHER_COMMENTS_TITLE];
		[self setOtherCommentsText:INVOICE_OTHER_COMMENTS_TEXT];
	}
	
	return self;
}

- (NSString *)objLanguageKey {
    return @"invoice";
}

- (NSString *)objTitle {
    return @"Invoice";
}

- (NSString *)alwaysShowLeftSignatureKey {
  return kInvoiceAlwaysShowOptionalInfoSignatureLeft;
}

- (NSString *)alwaysShowRightSignatureKey {
  return kInvoiceAlwaysShowOptionalInfoSignatureRight;
}

- (NSString *)alwaysShowNoteKey {
  return kInvoiceAlwaysShowOptionalInfoNote;
}

- (NSString *)alwaysShowOptionalInfoKey {
  return kInvoiceAlwaysShowOptionalInfoOtherComments;
}

#pragma mark - Figure settings methods

- (NSArray *)newFigureSettings {
    NSMutableArray *settings = [NSMutableArray arrayWithArray:[super newFigureSettings]];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:FigurePaid]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:FigureBalanceDue]}];
    
    return settings;
}

- (NSArray *)localFigureSettings {
    return [data_manager invoiceFigureSettings];
}

- (void)saveFigureSettings {
    [data_manager setInvoiceFiguresSettings:[self figuresSettings]];
}

#pragma mark - Details settings methods

- (NSArray *)newDetailsSettings {
  NSMutableArray *settings = [NSMutableArray arrayWithArray:[super newDetailsSettings]];
  [settings insertObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                           TYPE: [NSNumber numberWithInteger:DetailDate]}
                 atIndex:1];
  [settings insertObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                           TYPE: [NSNumber numberWithInteger:DetailDueDate]}
                 atIndex:2];
  
    return settings;
}

- (NSArray *)localDetailsSettings {
    return [data_manager invoiceDetailsSettings];
}

- (void)saveDetailsSettings {
    [data_manager setInvoiceDetailsSettings:[self detailsSettings]];
}

- (void)setAndSaveDetailsSettings:(NSArray *)details {
  [data_manager setInvoiceDetailsSettings:details];
}

#pragma mark - AddItem Details settings methods

- (NSArray *)localAddItemDetailsSettings {
  return [data_manager invoiceAddItemDetailsSettings];
}

- (void)saveAddItemDetailsSettings {
  [data_manager setInvoiceAddItemDetailsSettings:[self addItemDetailsSettings]];
}

- (void)setAndSaveAddItemDetailsSettings:(NSArray *)settings {
  [data_manager setInvoiceAddItemDetailsSettings:settings];
}

#pragma mark - Profile settings methods

- (NSArray *)localProfileSettings {
  return [data_manager invoiceProfileSettings];
}

- (void)saveProfileSettings {
  [data_manager setInvoiceProfileSettings:[self profileSettings]];
}

#pragma mark - Client settings methods
- (NSArray *)localClientSettings {
  return [data_manager invoiceDetailsClientSettings];
}

- (void)saveClientSettings {
  [data_manager setInvoiceClientDetailsSettings:[self clientSettings]];
}

#pragma mark - GETTERS

+(NSString*)statusTextFor:(kInvoiceStatus)status
{
	switch (status)
	{
		case kInvoiceStatusCurrent:
		{
			return @"Current";
			break;
		}
			
		case kInvoiceStatusOverdue:
		{
			return @"Overdue";
			break;
		}
			
		case kInvoiceStatusPaid:
		{
			return @"Paid";
			break;
		}
			
		default:
			break;
	}
}

-(NSDictionary*)contentsDictionary
{
	return contents;
}

-(NSString*)ID
{
	if([[contents allKeys] containsObject:@"id"] && [[contents objectForKey:@"id"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"id"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"id" containedValue:[contents objectForKey:@"id"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)title
{
	if ([[contents allKeys] containsObject:@"title"] && [[contents objectForKey:@"title"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"title"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"title" containedValue:[contents objectForKey:@"title"] withDefautReturnValue:kInvTitle];
		return kInvTitle;
	}
}

-(NSString*)name
{
	if ([[contents allKeys] containsObject:@"name"] && [[contents objectForKey:@"name"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"name"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"name" containedValue:[contents objectForKey:@"name"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(kInvoiceStatus)status
{
	if ([self paid] == [self total])
	{
		return kInvoiceStatusPaid;
	}
	
	if ([[self dueDate] isEqual:@"01/01/70"])
	{
		return kInvoiceStatusCurrent;
	}
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	NSDate * dueDate = [date_formatter dateFromString:[self dueDate]];
	
	if ([dueDate compare:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]]] == NSOrderedAscending)
	{
		return kInvoiceStatusOverdue;
	}
	
	return kInvoiceStatusCurrent;
}

-(ClientOBJ*)client
{
	if ([[contents allKeys] containsObject:@"client"] && [[contents objectForKey:@"client"] isKindOfClass:[NSDictionary class]])
	{
		return [[ClientOBJ alloc] initWithContentsDictionary:[contents objectForKey:@"client"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"client" containedValue:[contents objectForKey:@"client"] withDefautReturnValue:@"empty client"];
		return [[ClientOBJ alloc] init];
	}
}

-(ProjectOBJ*)project
{
	if([[contents allKeys] containsObject:@"project"] && [[contents objectForKey:@"project"] isKindOfClass:[NSDictionary class]])
	{
		return [[ProjectOBJ alloc] initWithContentsDictionary:[contents objectForKey:@"project"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"project" containedValue:[contents objectForKey:@"project"] withDefautReturnValue:@"empty project"];
		return [[ProjectOBJ alloc] init];
	}
}

-(NSString*)date
{
	if ([[contents allKeys] containsObject:@"date"] && [[contents objectForKey:@"date"] isKindOfClass:[NSDate class]])
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[contents objectForKey:@"date"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"date" containedValue:[contents objectForKey:@"date"] withDefautReturnValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[NSDate date]];
	}
}

-(NSString*)dueDate
{
	if ([[contents allKeys] containsObject:@"dueDate"] && [[contents objectForKey:@"dueDate"] isKindOfClass:[NSDate class]])
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[contents objectForKey:@"dueDate"]];
	}
	else
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[TermsManager dueDateFromThisDate:[date_formatter dateFromString:[self date]] withTerms:[self terms]]];
	}
}

-(kTerms)terms
{
	if ([[contents allKeys] containsObject:@"terms"] && [[contents objectForKey:@"terms"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"terms"] intValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"terms" containedValue:[contents objectForKey:@"terms"] withDefautReturnValue:@"7 days"];
		return kTerms7Days;
	}
}

-(CGFloat)balanceDue
{
	CGFloat value = [self total] - [self paid];
	
	return value;
}

-(CGFloat)balanceDuePaid
{
	CGFloat value = [self total] - [self paid];
	
	if(value == 0)
	{
		value = [self total];
	}
	
	return value;
}

-(CGFloat)subtotal
{
	NSArray * array = [self products];
	
	CGFloat value = 0.0f;
	
	for (NSDictionary * dict in array)
	{
		ProductOBJ * obj = [[ProductOBJ alloc] initWithContentsDictionary:dict];
		
		value += [obj total];
	}
    
    return [[NSString stringWithFormat:@"%.3f",value] floatValue];
}

-(CGFloat)discount
{
	if ([[contents allKeys] containsObject:@"discount"] && [[contents objectForKey:@"discount"] isKindOfClass:[NSNumber class]])
	{
		return [[NSString stringWithFormat:@"%.3f",[[contents objectForKey:@"discount"] floatValue]] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"discount" containedValue:[contents objectForKey:@"discount"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(CGFloat)discountPercentage
{
	if ([self subtotal] == 0)
    {
		return 0.0f;
    }
	
	CGFloat value = ([self discount] * 100) / [self subtotal];
    
	return [[NSString stringWithFormat:@"%.3f",value] floatValue];
}

-(CGFloat)tax1Value
{
	CGFloat value = 0.0f;
	
	NSArray * products = [self products];
	
	for (NSDictionary * objDict in products)
	{
		if ([[objDict objectForKey:@"class"] isEqual:NSStringFromClass([ProductOBJ class])])
		{
			ProductOBJ * prodOBJ = [[ProductOBJ alloc] initWithContentsDictionary:objDict];
			
			if ([prodOBJ taxable])
				value += ([self tax1Percentage] / 100) * ([prodOBJ total] - [self discount]);
		}
		else if ([[objDict objectForKey:@"class"] isEqual:NSStringFromClass([ServiceOBJ class])])
		{
			ServiceOBJ * servOBJ = [[ServiceOBJ alloc] initWithContentsDictionary:objDict];
			
			if ([servOBJ taxable])
				value += ([self tax1Percentage] / 100) * ([servOBJ total] - [self discount]);
		}
	}
	
    return [[NSString stringWithFormat:@"%.3f",value] floatValue];
}

-(CGFloat)tax1Percentage
{
	if ([[contents allKeys] containsObject:@"tax1Percentage"] && [[contents objectForKey:@"tax1Percentage"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"tax1Percentage"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"tax1Percentage" containedValue:[contents objectForKey:@"tax1Percentage"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(NSString*)tax1Name
{
	if ([[contents allKeys] containsObject:@"tax1Name"] && [[contents objectForKey:@"tax1Name"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"tax1Name"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"tax1Name" containedValue:[contents objectForKey:@"tax1Name"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(CGFloat)tax2Value
{
	CGFloat value = 0.0f;
	
	NSArray * products = [self products];
	
	for (NSDictionary * objDict in products)
	{
		if ([[objDict objectForKey:@"class"] isEqual:NSStringFromClass([ProductOBJ class])])
		{
			ProductOBJ * prodOBJ = [[ProductOBJ alloc] initWithContentsDictionary:objDict];
			
			if ([prodOBJ taxable])
				value += ([self tax2Percentage] / 100) * ([prodOBJ total] - [self discount]);
		}
		else if ([[objDict objectForKey:@"class"] isEqual:NSStringFromClass([ServiceOBJ class])])
		{
			ServiceOBJ * servOBJ = [[ServiceOBJ alloc] initWithContentsDictionary:objDict];
			
			if ([servOBJ taxable])
				value += ([self tax2Percentage] / 100) * ([servOBJ total] - [self discount]);
		}
	}
	
	return [[NSString stringWithFormat:@"%.3f",value] floatValue];
}

-(CGFloat)tax2Percentage
{
	if ([[contents allKeys] containsObject:@"tax2Percentage"] && [[contents objectForKey:@"tax2Percentage"] isKindOfClass:[NSNumber class]])
	{
		return [[contents objectForKey:@"tax2Percentage"] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"tax2Percentage" containedValue:[contents objectForKey:@"tax2Percentage"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(NSString*)tax2Name
{
	if ([[contents allKeys] containsObject:@"tax2Name"] && [[contents objectForKey:@"tax2Name"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"tax2Name"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"tax2Name" containedValue:[contents objectForKey:@"tax2Name"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(CGFloat)shippingValue
{
	if ([[contents allKeys] containsObject:@"shippingValue"] && [[contents objectForKey:@"shippingValue"] isKindOfClass:[NSNumber class]])
	{
		return [[NSString stringWithFormat:@"%.3f",[[contents objectForKey:@"shippingValue"] floatValue]] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"shippingValue" containedValue:[contents objectForKey:@"shippingValue"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(CGFloat)total
{
	CGFloat value = [self subtotal] + [self tax1Value] + [self tax2Value] + [self shippingValue] - [self discount];
    return [[NSString stringWithFormat:@"%.3f",value] floatValue];
}

-(CGFloat)paid
{
	if ([[contents allKeys] containsObject:@"paid"] && [[contents objectForKey:@"paid"] isKindOfClass:[NSNumber class]])
	{
		return [[NSString stringWithFormat:@"%.3f",[[contents objectForKey:@"paid"] floatValue]] floatValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"paid" containedValue:[contents objectForKey:@"paid"] withDefautReturnValue:@"0.0"];
		return 0.0f;
	}
}

-(NSString*)note
{
	if ([[contents allKeys] containsObject:@"note"] && [[contents objectForKey:@"note"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"note"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"note" containedValue:[contents objectForKey:@"note"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)bigNote
{
	if ([[contents allKeys] containsObject:@"bigNote"] && [[contents objectForKey:@"bigNote"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"bigNote"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"bigNote" containedValue:[contents objectForKey:@"bigNote"] withDefautReturnValue:@"empty string"];
		return @"";
	}
}

-(NSString*)number {
    NSString *pref = [InvoiceDefaults invoicePref];
	if ([[contents allKeys] containsObject:@"number"] && [[contents objectForKey:@"number"] isKindOfClass:[NSNumber class]])
	{
		int temp = [[contents objectForKey:@"number"] intValue];
		
		NSString * value = @"";
		
		if (temp < 10)
		{
			value = [NSString stringWithFormat:@"%@0000%d", pref, temp];
		}
		else if (temp < 100)
		{
			value = [NSString stringWithFormat:@"%@000%d", pref, temp];
		}
		else if (temp < 1000)
		{
			value = [NSString stringWithFormat:@"%@00%d", pref, temp];
		}
		else if (temp < 10000)
		{
			value = [NSString stringWithFormat:@"%@0%d", pref, temp];
		}
		else
		{
			value = [NSString stringWithFormat:@"%@%d", pref, temp];
		}
		
		return value;
	}
	else if ([[contents allKeys] containsObject:@"number"] && [[contents objectForKey:@"number"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"number"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"number" containedValue:[contents objectForKey:@"number"] withDefautReturnValue:[NSString stringWithFormat:@"%@00001", pref]];
        return [NSString stringWithFormat:@"%@00001", pref];
	}
}

-(NSString*)otherCommentsTitle
{
	if ([[contents allKeys] containsObject:@"otherCommentsTitle"] && [[contents objectForKey:@"otherCommentsTitle"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"otherCommentsTitle"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"otherCommentsTitle" containedValue:[contents objectForKey:@"otherCommentsTitle"] withDefautReturnValue:@"empty string"];
		return INVOICE_OTHER_COMMENTS_TITLE;
	}
}

-(NSString*)otherCommentsText
{
	if ([[contents allKeys] containsObject:@"otherCommentsText"] && [[contents objectForKey:@"otherCommentsText"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"otherCommentsText"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"otherCommentsText" containedValue:[contents objectForKey:@"otherCommentsText"] withDefautReturnValue:@"empty string"];
		return INVOICE_OTHER_COMMENTS_TEXT;
	}
}

-(NSString*)rightSignatureTitle
{
	if ([[contents allKeys] containsObject:@"rightSignatureTitle"] && [[contents objectForKey:@"rightSignatureTitle"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"rightSignatureTitle"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"rightSignatureTitle" containedValue:[contents objectForKey:@"rightSignatureTitle"] withDefautReturnValue:@"empty string"];
		return INVOICE_RIGHT_SIGNATURE_TITLE;
	}
}

-(UIImage*)rightSignature
{
	if ([[contents allKeys] containsObject:@"rightSignatureFilePath"] && [[contents objectForKey:@"rightSignatureFilePath"] isKindOfClass:[NSString class]])
	{
		NSString * path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[contents objectForKey:@"rightSignatureFilePath"]];
		
		NSData * data = [NSData dataWithContentsOfFile:path];
		
		if (data)
		{
			return [UIImage imageWithData:data];
		}
		else
		{
			return nil;
		}
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"rightSignatureFilePath" containedValue:[contents objectForKey:@"rightSignatureFilePath"] withDefautReturnValue:@"nil"];
		return [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_RIGHT_SIGNATURE_PATH]];
	}
}

-(NSString*)rightSignatureDate
{
	if ([[contents allKeys] containsObject:@"rightSignatureDate"] && [[contents objectForKey:@"rightSignatureDate"] isKindOfClass:[NSDate class]])
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[contents objectForKey:@"rightSignatureDate"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"rightSignatureDate" containedValue:[contents objectForKey:@"rightSignatureDate"] withDefautReturnValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[NSDate date]];
	}
}

-(CGRect)rightSignatureFrame
{
	if ([[contents allKeys] containsObject:@"rightSignatureFrame"] && [[contents objectForKey:@"rightSignatureFrame"] isKindOfClass:[NSData class]])
	{
		return [[NSKeyedUnarchiver unarchiveObjectWithData:[contents objectForKey:@"rightSignatureFrame"]] CGRectValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"rightSignatureFrame" containedValue:[contents objectForKey:@"rightSignatureFrame"] withDefautReturnValue:@"CGRectZero"];
		return INVOICE_RIGHT_FRAME;
	}
}

-(NSString*)leftSignatureTitle
{
	if ([[contents allKeys] containsObject:@"leftSignatureTitle"] && [[contents objectForKey:@"leftSignatureTitle"] isKindOfClass:[NSString class]])
	{
		return [contents objectForKey:@"leftSignatureTitle"];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"leftSignatureTitle" containedValue:[contents objectForKey:@"leftSignatureTitle"] withDefautReturnValue:@"empty string"];
		return INVOICE_LEFT_SIGNATURE_TITLE;
	}
}

-(UIImage*)leftSignature
{
	if ([[contents allKeys] containsObject:@"leftSignatureFilePath"] && [[contents objectForKey:@"leftSignatureFilePath"] isKindOfClass:[NSString class]])
	{
		NSString * path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",[contents objectForKey:@"leftSignatureFilePath"]];
		
		NSData * data = [NSData dataWithContentsOfFile:path];
		
		if (data)
		{
			return [UIImage imageWithData:data];
		}
		else
		{
			return nil;
		}
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"leftSignatureFilePath" containedValue:[contents objectForKey:@"leftSignatureFilePath"] withDefautReturnValue:@"nil"];
		return [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",INVOICE_LEFT_SIGNATURE_PATH]];
	}
}

-(NSString*)leftSignatureDate
{
	if ([[contents allKeys] containsObject:@"leftSignatureDate"] && [[contents objectForKey:@"leftSignatureDate"] isKindOfClass:[NSDate class]])
	{
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[contents objectForKey:@"leftSignatureDate"]];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"leftSignatureDate" containedValue:[contents objectForKey:@"leftSignatureDate"] withDefautReturnValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		return [date_formatter stringFromDate:[NSDate date]];
	}
}

-(CGRect)leftSignatureFrame
{
	if ([[contents allKeys] containsObject:@"leftSignatureFrame"] && [[contents objectForKey:@"leftSignatureFrame"] isKindOfClass:[NSData class]])
	{
		return [[NSKeyedUnarchiver unarchiveObjectWithData:[contents objectForKey:@"leftSignatureFrame"]] CGRectValue];
	}
	else
	{
		[data_manager logGetterErrorFromClass:[self class] forProperty:@"leftSignatureFrame" containedValue:[contents objectForKey:@"leftSignatureFrame"] withDefautReturnValue:@"CGRectZero"];
		return INVOICE_LEFT_FRAME;
	}
}

#pragma mark - SETTERS

-(void)setID:(NSString *)sender
{
	if(sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"id"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"id" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"id"];
	}
}

-(void)setTitle:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[CustomDefaults setCustomObjects:sender forKey:kInvoiceTitleKeyForNSUserDefaults];

		[contents setObject:sender forKey:@"title"];
		
		NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
		
		NSMutableDictionary *invoiceDict = [[NSMutableDictionary alloc] initWithDictionary:[languageDict objectForKey:@"invoice"]];
		[invoiceDict setObject:sender forKey:@"Invoice"];
		
		[languageDict setObject:invoiceDict forKey:@"invoice"];
		
		[CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"title" sentValue:sender withDefaultSetValue:kInvTitle];
		[contents setObject:kInvTitle forKey:@"title"];
	}
}

-(void)setName:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"name"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"name" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"name"];
	}
}

-(void)setClient:(NSDictionary*)sender
{
	if (sender && [sender isKindOfClass:[NSDictionary class]])
	{
		if ([[sender allKeys] containsObject:@"class"] && [[sender objectForKey:@"class"] isEqual:NSStringFromClass([ClientOBJ class])])
			[self setTerms:[[[ClientOBJ alloc] initWithContentsDictionary:sender] terms]];
		
		[contents setObject:sender forKey:@"client"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"client" sentValue:sender withDefaultSetValue:@"empty dictionary"];
		[contents setObject:[[[ClientOBJ alloc] init] contentsDictionary] forKey:@"client"];
	}
}

-(void)setProject:(NSDictionary *)sender
{
	if(sender && [sender isKindOfClass:[NSDictionary class]])
	{
		[contents setObject:sender forKey:@"project"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"project" sentValue:sender withDefaultSetValue:@"empty dictionary"];
		[contents setObject:[[[ProjectOBJ alloc] init] contentsDictionary] forKey:@"project"];
	}
}

-(void)setDate:(NSDate*)sender
{
	if (sender && [sender isKindOfClass:[NSDate class]])
	{
		[contents setObject:sender forKey:@"date"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"date" sentValue:sender withDefaultSetValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		[contents setObject:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]] forKey:@"date"];
	}
}

-(void)setDueDate:(NSDate*)sender
{
	if (sender && [sender isKindOfClass:[NSDate class]])
	{
		[contents setObject:sender forKey:@"dueDate"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"dueDate" sentValue:sender withDefaultSetValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		[contents setObject:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]] forKey:@"dueDate"];
	}
}

-(void)clearDueDate
{
	[contents removeObjectForKey:@"dueDate"];
}

-(void)setTerms:(kTerms)sender
{
	[contents setObject:[NSNumber numberWithInt:sender] forKey:@"terms"];
}

-(void)setDiscount:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"discount"];
}

-(void)setTax1Percentage:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"tax1Percentage"];
}

-(void)setTax1Name:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"tax1Name"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"tax1Name" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"tax1Name"];
	}
}

-(void)setTax2Percentage:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"tax2Percentage"];
}

-(void)setTax2Name:(NSString *)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"tax2Name"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"tax2Name" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"tax2Name"];
	}
}

-(void)setShippingValue:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"shippingValue"];
}

-(void)setPaid:(CGFloat)sender
{
	[contents setObject:[NSNumber numberWithFloat:sender] forKey:@"paid"];
}

-(void)setNote:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
    [contents setObject:sender forKey:@"note"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"note" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"note"];
	}
}

- (void)saveNote:(NSString *)sender {
  if (sender && [sender isKindOfClass:[NSString class]]) {
    [CustomDefaults setCustomString:sender forKey:INVOICE_FIRST_PAGE_NOTE_KEY];
  }
}

-(void)setBigNote:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"bigNote"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"bigNote" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"bigNote"];
	}
}

- (void)saveBigNote:(NSString *)sender {
  if (sender && [sender isKindOfClass:[NSString class]]) {
    if (![[sender uppercaseString] isEqual:@"BIG NOTE"]) {
      [CustomDefaults setCustomString:sender forKey:INVOICE_SECOND_PAGE_NOTE_KEY];
    }
  }
}

-(void)setNumber:(int)sender
{
	[contents setObject:[NSNumber numberWithInt:sender] forKey:@"number"];
}

-(void)setStringNumber:(NSString*)sender
{
	if (sender && [sender isKindOfClass:[NSString class]])
	{
		[contents setObject:sender forKey:@"number"];
	}
	else
	{
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"number" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"number"];
	}
}

-(void)setOtherCommentsTitle:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"otherCommentsTitle"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"otherCommentsTitle" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"otherCommentsTitle"];
	}
}

- (void)saveOtherCommentsTitle:(NSString *)sender {
  if (sender && [sender isKindOfClass:[NSString class]]) {
    [CustomDefaults setCustomString:sender forKey:INVOICE_OTHER_COMMENTS_TITLE_KEY];
  }
}

-(void)setOtherCommentsText:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"otherCommentsText"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"otherCommentsText" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"otherCommentsText"];
	}
}

- (void)saveOtherCommentsText:(NSString *)sender {
  if (sender && [sender isKindOfClass:[NSString class]]) {
    [CustomDefaults setCustomString:sender forKey:INVOICE_OTHER_COMMENTS_TEXT_KEY];
  }
}

#pragma mark - Signature

#pragma mark - Right
-(void)setRightSignatureTitle:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"rightSignatureTitle"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"rightSignatureTitle" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"rightSignatureTitle"];
	}
}

- (void)saveRightSignatureTitle:(NSString *)sender {
  if (sender && [sender isKindOfClass:[NSString class]]) {
    [CustomDefaults setCustomString:sender forKey:INVOICE_RIGHT_SIGNATURE_TITLE_KEY];
  }
}

-(void)setRightSignature:(UIImage*)sender {
  [self setRightSignature:sender andSave:NO];
}

- (void)saveRightSignature:(UIImage *)sender {
  [self setRightSignature:sender andSave:YES];
}

- (void)setRightSignature:(UIImage *)sender andSave:(BOOL)save {
  [self removeRightSignatureImageAndSave:save];
  
  if (!sender) {
    return;
  }
  
  NSMutableString * filePath = [[NSMutableString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
  NSData * imageData = UIImagePNGRepresentation(sender);
  NSString * MD5 = [[NSString stringWithFormat:@"%@", imageData] MD5];
  [filePath appendFormat:@"%@", MD5];
  
  if(save) {
    [CustomDefaults setCustomString:MD5 forKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY];
  } else {
    [contents setObject:MD5 forKey:@"rightSignatureFilePath"];
  }
  
  [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:[[NSDictionary alloc] init]];
  [imageData writeToFile:filePath atomically:YES];
}

-(void)removeRightSignatureImageAndSave:(BOOL)save {
  NSString *signFilePath = [contents objectForKey:@"rightSignatureFilePath"];
  
  if((![signFilePath isEqualToString:INVOICE_RIGHT_SIGNATURE_PATH] && !save) || save) {
    NSString *imagePath = save?INVOICE_RIGHT_SIGNATURE_PATH:signFilePath;
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",imagePath];
    
    if ((![filePath isEqual:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"]]) && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
  }
	
  if(save) {
    [CustomDefaults setCustomString:@"" forKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY];
  } else {
    [contents setObject:@"" forKey:@"rightSignatureFilePath"];
  }
}

- (void)removeRightCommonSignatureKey {
  [CustomDefaults setCustomString:@"" forKey:INVOICE_RIGHT_SIGNATURE_PATH_KEY];
}

-(void)setRightSignatureDate:(NSDate*)sender {
	if (sender && [sender isKindOfClass:[NSDate class]]) {
		[contents setObject:sender forKey:@"rightSignatureDate"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"rightSignatureDate" sentValue:sender withDefaultSetValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		[contents setObject:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]] forKey:@"rightSignatureDate"];
	}
}

-(void)setRightSignatureFrame:(CGRect)sender {
	[contents setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:sender]] forKey:@"rightSignatureFrame"];
}

- (void)saveRightSignatureFrame:(CGRect)sender {
  [CustomDefaults setCustomObjects:[NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:sender]] forKey:INVOICE_RIGHT_FRAME_KEY];
}

#pragma mark - Left

-(void)setLeftSignatureTitle:(NSString*)sender {
	if (sender && [sender isKindOfClass:[NSString class]]) {
		[contents setObject:sender forKey:@"leftSignatureTitle"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"leftSignatureTitle" sentValue:sender withDefaultSetValue:@"empty string"];
		[contents setObject:@"" forKey:@"leftSignatureTitle"];
	}
}

- (void)saveLeftSignatureTitle:(NSString *)sender {
  if (sender && [sender isKindOfClass:[NSString class]]) {
    [CustomDefaults setCustomString:sender forKey:INVOICE_LEFT_SIGNATURE_TITLE_KEY];
  }
}

-(void)setLeftSignature:(UIImage*)sender {
  [self setLeftSignature:sender andSave:NO];
}

- (void)saveLeftSignature:(UIImage *)sender {
  [self setLeftSignature:sender andSave:YES];
}

- (void)setLeftSignature:(UIImage *)sender andSave:(BOOL)save {
  [self removeLeftSignatureImageAndSave:save];
  
  if (!sender) {
    return;
  }
  
  NSMutableString * filePath = [[NSMutableString alloc] initWithFormat:@"%@/Documents/", NSHomeDirectory()];
  NSData * imageData = UIImagePNGRepresentation(sender);
  NSString * MD5 = [[NSString stringWithFormat:@"%@", imageData] MD5];
  [filePath appendFormat:@"%@", MD5];
  
  if(save) {
    [CustomDefaults setCustomString:MD5 forKey:INVOICE_LEFT_SIGNATURE_PATH_KEY];
  } else {
    [contents setObject:MD5 forKey:@"leftSignatureFilePath"];
  }
  
  [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:[[NSDictionary alloc] init]];
  [imageData writeToFile:filePath atomically:YES];
}


-(void)removeLeftSignatureImageAndSave:(BOOL)save {
  NSString *signFilePath = [contents objectForKey:@"leftSignatureFilePath"];
  
  if((![signFilePath isEqualToString:INVOICE_LEFT_SIGNATURE_PATH] && !save) || save) {
    NSString *imagePath = save?INVOICE_LEFT_SIGNATURE_PATH:signFilePath;
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",imagePath];
    
    if ((![filePath isEqual:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"]]) && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
  }
  
  if(save) {
    [CustomDefaults setCustomString:@"" forKey:INVOICE_LEFT_SIGNATURE_PATH_KEY];
  } else {
    [contents setObject:@"" forKey:@"leftSignatureFilePath"];
  }
}

- (void)removeLeftCommonSignatureKey {
  [CustomDefaults setCustomString:@"" forKey:INVOICE_LEFT_SIGNATURE_PATH_KEY];
}

-(void)setLeftSignatureDate:(NSDate*)sender {
	if (sender && [sender isKindOfClass:[NSDate class]]) {
		[contents setObject:sender forKey:@"leftSignatureDate"];
	} else {
		[data_manager logSetterErrorFromClass:[self class] forProperty:@"leftSignatureDate" sentValue:sender withDefaultSetValue:@"today"];
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		[contents setObject:[date_formatter dateFromString:[date_formatter stringFromDate:[NSDate date]]] forKey:@"leftSignatureDate"];
	}
}

-(void)setLeftSignatureFrame:(CGRect)sender {
	[contents setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:sender]] forKey:@"leftSignatureFrame"];
}

- (void)saveLeftSignatureFrame:(CGRect)sender {
  [CustomDefaults setCustomObjects:[NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:sender]] forKey:INVOICE_LEFT_FRAME_KEY];
}

- (void)removeTempSignatures {
  [self removeRightSignatureImageAndSave:NO];
  [self removeLeftSignatureImageAndSave:NO];
}

#pragma mark - DESCRIPTION

-(NSString*)description
{
	return contents.description;
}

-(void)repairSignatures
{
	if(![[contents objectForKey:@"rightSignatureFilePath"] isEqual:@""])
	{
		NSString *filePath = [[NSString alloc] initWithString:[contents objectForKey:@"rightSignatureFilePath"]];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[contents setObject:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:@"rightSignatureFilePath"];
		}
	}
	
	if(![[contents objectForKey:@"leftSignatureFilePath"] isEqual:@""])
	{
		NSString *filePath = [[NSString alloc] initWithString:[contents objectForKey:@"leftSignatureFilePath"]];
		
		if([[filePath componentsSeparatedByString:@"/Documents/"] count] > 1)
		{
			[contents setObject:[[filePath componentsSeparatedByString:@"/Documents/"] objectAtIndex:1] forKey:@"leftSignatureFilePath"];
		}
	}
}

@end