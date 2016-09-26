//
//  ManagerCSV.m
//  Invoice
//
//  Created by Paul on 19/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ManagerCSV.h"

#import "InvoiceOBJ.h"
#import "ClientOBJ.h"
#import "AddressOBJ.h"
#import "ProjectOBJ.h"
#import "ProductOBJ.h"
#import "QuoteOBJ.h"
#import "EstimateOBJ.h"
#import "PurchaseOrderOBJ.h"
#import "ClientOBJ.h"
#import "ProjectOBJ.h"
#import "ReceiptOBJ.h"
#import "Defines.h"

@implementation ManagerCSV

+(id)sharedManager
{
	static ManagerCSV * manager;
	
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

#pragma mark - CSV FILE

-(NSString*)createInvoiceCSVFile:(NSArray*)invoiceArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"invoice.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	int maxProductCount = 0;
	
	for(InvoiceOBJ *invoice in invoiceArray)
	{
		if([invoice products].count > maxProductCount)
			maxProductCount = (int)[invoice products].count;
	}
		
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	writeString = [NSMutableString stringWithFormat:@"Nr.,Title,Number,\"Client First Name\",\"Client Last Name\",\"Client Company\",\"Billing\",\"Billing Address\",\"Billing City\",\"Billing State\",\"Billing ZIP\",\"Billing Country\",\"Shipping\",\"Shipping Address\",\"Shipping City\",\"Shipping State\",\"Shipping ZIP\",\"Shipping Country\",Date,\"Due Date\",\"Project Name\",\"Project Number\",Terms"];
	
	for(int i=0;i<maxProductCount;i++)
	{
		writeString = [NSMutableString stringWithFormat:@"%@,\"Product %d Name\",\"Product %d Quantity\",\"Product %d Discount\",\"Product %d Total\"",writeString,i+1,i+1,i+1,i+1];
	}
	
	writeString = [NSMutableString stringWithFormat:@"%@,Subtotal,Discount,\"Discount Percentage\",Shipping,Total,Paid,\"Balance Due\",\"Balance Due Paid\",\"Other Comments\",\"Note 1\",\"Note 2\"",writeString];
	
	int count = 1;
	
	for(InvoiceOBJ *invoice in invoiceArray)
	{
		NSString *invoiceString = [NSMutableString stringWithFormat:@"%d",count];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice title]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice number]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[invoice client] firstName]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[invoice client] lastName]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[invoice client] company]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] billingAddress] billingTitle]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@ %@ %@\"",invoiceString,[[[invoice client] billingAddress] addressLine1],[[[invoice client] billingAddress] addressLine2],[[[invoice client] billingAddress] addressLine3]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] billingAddress] city]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] billingAddress] state]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] billingAddress] ZIP]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] billingAddress] country]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] shippingAddress] shippingTitle]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@ %@ %@\"",invoiceString,[[[invoice client] shippingAddress] addressLine1],[[[invoice client] shippingAddress] addressLine2],[[[invoice client] shippingAddress] addressLine3]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] shippingAddress] city]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] shippingAddress] state]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] shippingAddress] ZIP]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[[invoice client] shippingAddress] country]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice date]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice dueDate]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[invoice project] projectName]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[[invoice project] projectNumber]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[TermsManager termsString:[invoice terms]]];
						
		for(NSDictionary *product in [invoice products])
		{
			ProductOBJ *productObject = [[ProductOBJ alloc] initWithContentsDictionary:product];
					
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[productObject name]];
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[productObject quantity]];
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[productObject discount]];
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[productObject total]];
		}
		
		for(int i=(int)[invoice products].count;i<maxProductCount;i++)
		{
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"-\"",invoiceString];
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"-\"",invoiceString];
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"-\"",invoiceString];
			invoiceString = [NSMutableString stringWithFormat:@"%@,\"-\"",invoiceString];
		}
				
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice subtotal]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice discount]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%1.f\"",invoiceString,[invoice discountPercentage]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice shippingValue]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice total]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice paid]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice balanceDue]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%2.f\"",invoiceString,[invoice balanceDuePaid]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice otherCommentsText]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice note]];
		invoiceString = [NSMutableString stringWithFormat:@"%@,\"%@\"",invoiceString,[invoice bigNote]];
		
		writeString = [NSMutableString stringWithFormat:@"%@\n%@",writeString,invoiceString];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createQuoteCSVFile:(NSArray*)quotesArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"quote.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	int maxProducts = 0;
	
	for(QuoteOBJ *quote in quotesArray)
	{
		if([quote products].count > maxProducts)
			maxProducts = (int)[quote products].count;
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:[NSString stringWithFormat:@"\"Nr.\",\"Title\",\"Quote No.\",\"Client First Name\",\"Client Last Name\",\"Client Company\",\"Billing\",\"Billing Address\",\"Billing City\",\"Billing State\",\"Billing ZIP\",\"Billing Country\",\"Shipping\",\"Shipping Address\",\"Shipping City\",\"Shipping State\",\"Shipping ZIP\",\"Shipping Country\",\"Project Name\",\"Project Number\""]];
	
	for(int i=0;i<maxProducts;i++)
	{
		[writeString setString:[NSString stringWithFormat:@"%@,\"Product %d Name\",\"Product %d Quantity\",\"Product %d Discount\",\"Product %d Total\"",writeString,i+1,i+1,i+1,i+1]];
	}
	
	[writeString setString:[NSString stringWithFormat:@"%@,\"Subtotal\",\"Discount\",\"Shipping\",\"Total\",\"Other Comments\",\"Note 1\",\"Note 2\"",writeString]];
	
	int count = 1;
	
	for(QuoteOBJ *quote in quotesArray)
	{
		NSString *quoteString = [NSString stringWithFormat:@"%d",count];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"",quoteString,[quote title],[quote number],[[quote client] firstName],[[quote client] lastName],[[quote client] company]];
		
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] billingAddress] billingTitle]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@ %@ %@\"",quoteString,[[[quote client] billingAddress] addressLine1],[[[quote client] billingAddress] addressLine2],[[[quote client] billingAddress] addressLine3]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] billingAddress] city]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] billingAddress] state]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] billingAddress] ZIP]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] billingAddress] country]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] shippingAddress] shippingTitle]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@ %@ %@\"",quoteString,[[[quote client] shippingAddress] addressLine1],[[[quote client] shippingAddress] addressLine2],[[[quote client] shippingAddress] addressLine3]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] shippingAddress] city]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] shippingAddress] state]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] shippingAddress] ZIP]];
		quoteString = [NSString stringWithFormat:@"%@,\"%@\"",quoteString,[[[quote client] shippingAddress] country]];
		
		quoteString = [NSString stringWithFormat:@"%@,\"%@\",\"%@\"",quoteString,[[quote project] projectName],[[quote project] projectNumber]];
				
		for(NSDictionary *temp in [quote products])
		{
			ProductOBJ *product = [[ProductOBJ alloc] initWithContentsDictionary:temp];
			
			quoteString = [NSString stringWithFormat:@"%@,\"%@\",\"%.2f\",\"%.2f\",\"%.2f\"",quoteString,[product name],[product quantity],[product discount],[product total]];
		}
		
		for(int i=(int)[quote products].count;i<maxProducts;i++)
		{
			quoteString = [NSString stringWithFormat:@"%@,\"-\",\"-\",\"-\",\"-\"",quoteString];
		}
		
		quoteString = [NSString stringWithFormat:@"%@,\"%.2f\",\"%.2f\",\"%.2f\",\"%.2f\",\"%@\",\"%@\",\"%@\"",quoteString,[quote subtotal],[quote discount],[quote shippingValue],[quote total],[quote otherCommentsText],[quote note],[quote bigNote]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,quoteString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];

	return root;
}

-(NSString*)createEstimateCSVFile:(NSArray*)estimateArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"estimate.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	int maxProducts = 0;
	
	for(EstimateOBJ *estimate in estimateArray)
	{
		if([estimate products].count > maxProducts)
			maxProducts = (int)[estimate products].count;
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:[NSString stringWithFormat:@"\"Nr.\",\"Title\",\"Quote No.\",\"Client First Name\",\"Client Last Name\",\"Client Company\",\"Billing\",\"Billing Address\",\"Billing City\",\"Billing State\",\"Billing ZIP\",\"Billing Country\",\"Shipping\",\"Shipping Address\",\"Shipping City\",\"Shipping State\",\"Shipping ZIP\",\"Shipping Country\",\"Project Name\",\"Project Number\""]];
	
	for(int i=0;i<maxProducts;i++)
	{
		[writeString setString:[NSString stringWithFormat:@"%@,\"Product %d Name\",\"Product %d Quantity\",\"Product %d Discount\",\"Product %d Total\"",writeString,i+1,i+1,i+1,i+1]];
	}
	
	[writeString setString:[NSString stringWithFormat:@"%@,\"Subtotal\",\"Discount\",\"Shipping\",\"Total\",\"Other Comments\",\"Note 1\",\"Note 2\"",writeString]];
	
	int count = 1;
	
	for(EstimateOBJ *estimate in estimateArray)
	{
		NSString *estimateString = [NSString stringWithFormat:@"%d",count];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"",estimateString,[estimate title],[estimate number],[[estimate client] firstName],[[estimate client] lastName],[[estimate client] company]];
		
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] billingAddress] billingTitle]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@ %@ %@\"",estimateString,[[[estimate client] billingAddress] addressLine1],[[[estimate client] billingAddress] addressLine2],[[[estimate client] billingAddress] addressLine3]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] billingAddress] city]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] billingAddress] state]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] billingAddress] ZIP]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] billingAddress] country]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] shippingAddress] shippingTitle]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@ %@ %@\"",estimateString,[[[estimate client] shippingAddress] addressLine1],[[[estimate client] shippingAddress] addressLine2],[[[estimate client] shippingAddress] addressLine3]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] shippingAddress] city]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] shippingAddress] state]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] shippingAddress] ZIP]];
		estimateString = [NSString stringWithFormat:@"%@,\"%@\"",estimateString,[[[estimate client] shippingAddress] country]];
		
		estimateString = [NSString stringWithFormat:@"%@,\"%@\",\"%@\"",estimateString,[[estimate project] projectName],[[estimate project] projectNumber]];
				
		for(NSDictionary *temp in [estimate products])
		{
			ProductOBJ *product = [[ProductOBJ alloc] initWithContentsDictionary:temp];
			
			estimateString = [NSString stringWithFormat:@"%@,\"%@\",\"%.2f\",\"%.2f\",\"%.2f\"",estimateString,[product name],[product quantity],[product discount],[product total]];
		}
		
		for(NSInteger i=[estimate products].count;i<maxProducts;i++)
		{
			estimateString = [NSString stringWithFormat:@"%@,\"-\",\"-\",\"-\",\"-\"",estimateString];
		}
		
		estimateString = [NSString stringWithFormat:@"%@,\"%.2f\",\"%.2f\",\"%.2f\",\"%.2f\",\"%@\",\"%@\",\"%@\"",estimateString,[estimate subtotal],[estimate discount],[estimate shippingValue],[estimate total],[estimate otherCommentsText],[estimate note],[estimate bigNote]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,estimateString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createPurchaseOrderCSVFile:(NSArray*)poArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"purchaseorder.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	NSInteger maxProducts = 0;
	
	for(PurchaseOrderOBJ *purchase in poArray)
	{
		if([purchase products].count > maxProducts)
			maxProducts = [purchase products].count;
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:[NSString stringWithFormat:@"\"Nr.\",\"Title\",\"Quote No.\",\"Client First Name\",\"Client Last Name\",\"Client Company\",\"Billing\",\"Billing Address\",\"Billing City\",\"Billing State\",\"Billing ZIP\",\"Billing Country\",\"Shipping\",\"Shipping Address\",\"Shipping City\",\"Shipping State\",\"Shipping ZIP\",\"Shipping Country\",\"Project Name\",\"Project Number\""]];
	
	for(int i=0;i<maxProducts;i++)
	{
		[writeString setString:[NSString stringWithFormat:@"%@,\"Product %d Name\",\"Product %d Quantity\",\"Product %d Discount\",\"Product %d Total\"",writeString,i+1,i+1,i+1,i+1]];
	}
	
	[writeString setString:[NSString stringWithFormat:@"%@,\"Subtotal\",\"Discount\",\"Shipping\",\"Total\",\"Other Comments\",\"Note 1\",\"Note 2\"",writeString]];
	
	int count = 1;
	
	for(PurchaseOrderOBJ *purchase in poArray)
	{
		NSString *purchaseString = [NSString stringWithFormat:@"%d",count];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"",purchaseString,[purchase title],[purchase number],[[purchase client] firstName],[[purchase client] lastName],[[purchase client] company]];
		
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] billingAddress] billingTitle]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@ %@ %@\"",purchaseString,[[[purchase client] billingAddress] addressLine1],[[[purchase client] billingAddress] addressLine2],[[[purchase client] billingAddress] addressLine3]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] billingAddress] city]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] billingAddress] state]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] billingAddress] ZIP]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] billingAddress] country]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] shippingAddress] shippingTitle]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@ %@ %@\"",purchaseString,[[[purchase client] shippingAddress] addressLine1],[[[purchase client] shippingAddress] addressLine2],[[[purchase client] shippingAddress] addressLine3]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] shippingAddress] city]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] shippingAddress] state]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] shippingAddress] ZIP]];
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\"",purchaseString,[[[purchase client] shippingAddress] country]];
		
		purchaseString = [NSString stringWithFormat:@"%@,\"%@\",\"%@\"",purchaseString,[[purchase project] projectName],[[purchase project] projectNumber]];
		
		for(NSDictionary *temp in [purchase products])
		{
			ProductOBJ *product = [[ProductOBJ alloc] initWithContentsDictionary:temp];
			
			purchaseString = [NSString stringWithFormat:@"%@,\"%@\",\"%.2f\",\"%.2f\",\"%.2f\"",purchaseString,[product name],[product quantity],[product discount],[product total]];
		}
		
		for(NSInteger i=[purchase products].count;i<maxProducts;i++)
		{
			purchaseString = [NSString stringWithFormat:@"%@,\"-\",\"-\",\"-\",\"-\"",purchaseString];
		}
		
		purchaseString = [NSString stringWithFormat:@"%@,\"%.2f\",\"%.2f\",\"%.2f\",\"%.2f\",\"%@\",\"%@\",\"%@\"",purchaseString,[purchase subtotal],[purchase discount],[purchase shippingValue],[purchase total],[purchase otherCommentsText],[purchase note],[purchase bigNote]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,purchaseString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createReceiptsCSVFile:(NSArray*)receiptsArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"receipts.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:@"\"Nr.\",\"Title\",\"Receipt No.\",\"Category\",\"Project Name\",\"Project Number\",\"Vendor First Name\",\"Vendor Last Name\",\"Vendor Company\",\"Billing\",\"Billing Address\",\"Billing City\",\"Billing State\",\"Billing ZIP\",\"Billing Country\",\"Shipping\",\"Shipping Address\",\"Shipping City\",\"Shipping State\",\"Shipping ZIP\",\"Shipping Country\",\"Date\",\"Subtotal\",\"Tax 1 Name\",\"Tax 1 Percentage\",\"Tax 1 Value\",\"Tax 2 Name\",\"Tax 2 Percentage\",\"Tax 2 Value\",\"Total\",\"Description\""];
	
	int count = 1;
	
	[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
	
	for(ReceiptOBJ *receipt in receiptsArray)
	{
		NSMutableString *receiptString = [NSMutableString stringWithFormat:@"%d",count];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[receipt title]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[receipt number]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[receipt category]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[receipt project] projectName]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[receipt project] projectNumber]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[receipt client] firstName]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[receipt client] lastName]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[receipt client] company]]];
		
		NSString *billingAddress = [NSString stringWithFormat:@"%@ %@ %@",[[[receipt client] billingAddress] addressLine1],[[[receipt client] billingAddress] addressLine2],[[[receipt client] billingAddress] addressLine3]];
		NSString *shippingAddress = [NSString stringWithFormat:@"%@ %@ %@",[[[receipt client] shippingAddress] addressLine1],[[[receipt client] shippingAddress] addressLine2],[[[receipt client] shippingAddress] addressLine3]];
				
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] billingAddress] billingTitle]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,billingAddress]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] billingAddress] city]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] billingAddress] state]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] billingAddress] ZIP]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] billingAddress] country]]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] shippingAddress] shippingTitle]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,shippingAddress]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] shippingAddress] city]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] shippingAddress] state]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] shippingAddress] ZIP]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[receipt client] shippingAddress] country]]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[date_formatter stringFromDate:[receipt date]]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[receipt total] forSign:[receipt sign]]]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[receipt tax1Name]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[NSString stringWithFormat:@"%@%c",[data_manager valueAdjusted:[receipt tax1ShowValue]],'%']]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[receipt tax1Percentage] forSign:[receipt sign]]]];

		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[receipt tax2Name]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[NSString stringWithFormat:@"%@%c",[data_manager valueAdjusted:[receipt tax2ShowValue]],'%']]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[receipt tax2Percentage] forSign:[receipt sign]]]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[receipt getTotal] forSign:[receipt sign]]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[receipt receiptDescription]]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,receiptString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createTimesheetsCSVFile:(NSArray*)timesheetsArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"timesheets.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	NSInteger maxServices = 0;
	
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		if([timesheet services].count > maxServices)
		{
			maxServices = [timesheet services].count;
		}
	}

	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	[writeString setString:@"\"Nr.\",\"Title\",\"Timesheet No.\",\"Client First Name\",\"Client Last Name\",\"Client Company\",\"Billing\",\"Billing Address\",\"Billing City\",\"Billing State\",\"Billing ZIP\",\"Billing Country\",\"Shipping\",\"Shipping Address\",\"Shipping City\",\"Shipping State\",\"Shipping ZIP\",\"Shipping Country\",\"Date\",\"Project Name\",\"Project Number\""];
	
	for(int i=0;i<maxServices;i++)
	{
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Start Time\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Finish Time\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Break Time\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Overtime\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Duration\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Subtotal\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Discount Percentage\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Discount Value\"",writeString,i+1]];
		[writeString setString:[NSString stringWithFormat:@"%@,\"Service %d Total\"",writeString,i+1]];
	}
	
	[writeString setString:[NSString stringWithFormat:@"%@,\"Subtotal\",\"Discount Percentage\",\"Discount Value\",\"Total\",\"Other Comments Title\",\"Other Comments\",\"1st Page Note\",\"2nd Page Note\"",writeString]];
	
	int count = 1;
	
	for(TimeSheetOBJ *timesheet in timesheetsArray)
	{
		NSMutableString *receiptString = [NSMutableString stringWithFormat:@"%d",count];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[timesheet title]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[timesheet number]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[timesheet client] firstName]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[timesheet client] lastName]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[timesheet client] company]]];
		
		NSString *billingAddress = [NSString stringWithFormat:@"%@ %@ %@",[[[timesheet client] billingAddress] addressLine1],[[[timesheet client] billingAddress] addressLine2],[[[timesheet client] billingAddress] addressLine3]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] billingAddress] billingTitle]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,billingAddress]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] billingAddress] city]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] billingAddress] state]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] billingAddress] ZIP]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] billingAddress] country]]];

		NSString *shippingAddress = [NSString stringWithFormat:@"%@ %@ %@",[[[timesheet client] shippingAddress] addressLine1],[[[timesheet client] shippingAddress] addressLine2],[[[timesheet client] shippingAddress] addressLine3]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] shippingAddress] shippingTitle]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,shippingAddress]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] shippingAddress] city]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] shippingAddress] state]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] shippingAddress] ZIP]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[[timesheet client] shippingAddress] country]]];
		
		[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[date_formatter stringFromDate:[timesheet date]]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[timesheet project] projectName]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[timesheet project] projectNumber]]];
		
		[date_formatter setDateFormat:@"HH:mm"];
		
		for(int i=0;i<[timesheet services].count;i++)
		{
			ServiceTimeOBJ *time = [timesheet serviceTimeAtIndex:i];
			
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[[time product] name]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[date_formatter stringFromDate:[time startTime]]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[date_formatter stringFromDate:[time finishTime]]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[time breakString]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[time overtimeString]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[time duration]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[time subtotal]]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[NSString stringWithFormat:@"%@%c",[data_manager valueAdjusted:[time discountShowPercentage]],'%']]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[time discountPercentage]]]];
			[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[time getTotal]]]];
		}
		
		for(NSInteger i=[timesheet services].count;i<maxServices;i++)
		{
			[receiptString setString:[NSString stringWithFormat:@"%@,\"-\",\"-\",\"-\",\"-\",\"-\",\"-\",\"-\",\"-\",\"-\",\"-\"",receiptString]];
		}
		
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[timesheet subtotal]]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@%c\"",receiptString,[data_manager valueAdjusted:[timesheet getDiscountShowValue]],'%']];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[timesheet discount]]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[data_manager currencyAdjustedValue:[timesheet getTotalValue]]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[timesheet otherCommentsTitle]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[timesheet otherComments]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[timesheet note]]];
		[receiptString setString:[NSString stringWithFormat:@"%@,\"%@\"",receiptString,[timesheet bigNote]]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,receiptString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createProductsCSVFile:(NSArray*)productsArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"products.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:@"\"Nr.\",\"Name\",\"Type\",\"Price\",\"Unit\",\"Code\",\"Taxable\",\"Description\""];
	
	int count = 1;
	
	for(ProductOBJ *product in productsArray)
	{
		NSString *productString = [NSString stringWithFormat:@"%d",count];
		productString = [NSString stringWithFormat:@"%@,\"%@\"",productString,[product name]];
		if([[product contentsDictionary].allKeys containsObject:@"code"])
			productString = [NSString stringWithFormat:@"%@,\"Product\"",productString];
		else
			productString = [NSString stringWithFormat:@"%@,\"Service\"",productString];
		productString = [NSString stringWithFormat:@"%@,\"%.2f\"",productString,[product price]];
		productString = [NSString stringWithFormat:@"%@,\"%@\"",productString,[product unit]];
		if([[product contentsDictionary].allKeys containsObject:@"code"])
			productString = [NSString stringWithFormat:@"%@,\"%@\"",productString,[product code]];
		else
			productString = [NSString stringWithFormat:@"%@,\"-\"",productString];
		productString = [NSString stringWithFormat:@"%@,\"%d\"",productString,[product taxable]];
		productString = [NSString stringWithFormat:@"%@,\"%@\"",productString,[product note]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,productString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createContactsCSVFile:(NSArray*)clientsArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"contacts.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:@"\"Nr.\",\"Company Name\",\"Company Website\",\"Company Email\",\"Company Phone\",\"Company Fax\",\"Client First Name\",\"Client Last Name\",\"Client Title\",\"Client Mobile\",\"Client Terms\",\"Client Note\",\"Address 1 Title\",\"Address 1 Address Line 1\",\"Address 1 Address Line 2\",\"Address 1 Address Line 3\",\"Address 1 City\",\"Address 1 State\",\"Address 1 ZIP\",\"Address 1 Country\",\"Address 2 Title\",\"Address 2 Address Line 1\",\"Address 2 Address Line 2\",\"Address 2 Address Line 3\",\"Address 2 City\",\"Address 2 State\",\"Address 2 ZIP\",\"Address 2 Country\""];
	
	int count = 1;
	
	for(ClientOBJ *client in clientsArray)
	{
		NSString *clientString = [NSString stringWithFormat:@"%d",count];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client company]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client website]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client email]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client phone]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client fax]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client firstName]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client lastName]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client title]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client mobile]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[TermsManager termsString:[client terms]]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[client note]];
		
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] billingTitle]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] addressLine1]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] addressLine2]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] addressLine3]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] city]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] state]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] ZIP]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client billingAddress] country]];
		
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] shippingTitle]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] addressLine1]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] addressLine2]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] addressLine3]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] city]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] state]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] ZIP]];
		clientString = [NSString stringWithFormat:@"%@,\"%@\"",clientString,[[client shippingAddress] country]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,clientString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

-(NSString*)createProjectsCSVFile:(NSArray*)projectsArray
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *root = [documentsDir stringByAppendingPathComponent:@"projects.csv"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] removeItemAtPath:root error:nil];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:root])
	{
		[[NSFileManager defaultManager] createFileAtPath: root contents:nil attributes:nil];
	}
	
	NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
	
	[writeString setString:@"\"Nr.\",\"Name\",\"Number\",\"Company Name\",\"Company Webiste\",\"Company Email\",\"Company Phone\",\"Company Fax\",\"Client First Name\",\"Client Last Name\",\"Client Title\",\"Client Mobile\",\"Address 1 Title\",\"Address 1 Address Line 1\",\"Address 1 Address Line 2\",\"Address 1 Address Line 3\",\"Address 1 City\",\"Address 1 State\",\"Address 1 ZIP\",\"Address 1 Country\",\"Address 2 Title\",\"Address 2 Address Line 1\",\"Address 2 Address Line 2\",\"Address 2 Address Line 3\",\"Address 2 City\",\"Address 2 State\",\"Address 2 ZIP\",\"Address 2 Country\",\"Client Terms\",\"Client Note\",\"Paid\",\"Completed\""];
	
	int count = 1;
	
	for(ProjectOBJ *project in projectsArray)
	{
		NSString *projectString = [NSString stringWithFormat:@"%d",count];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[project projectName]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[project projectNumber]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] company]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] website]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] email]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] phone]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] fax]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] firstName]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] lastName]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] title]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] mobile]];
		
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] billingTitle]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] addressLine1]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] addressLine2]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] addressLine3]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] city]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] state]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] ZIP]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] billingAddress] country]];
		
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] billingTitle]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] addressLine1]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] addressLine2]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] addressLine3]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] city]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] state]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] ZIP]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[[project client] shippingAddress] country]];
		
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[TermsManager termsString:[[project client] terms]]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[[project client] note]];
		
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[project paid]];
		projectString = [NSString stringWithFormat:@"%@,\"%@\"",projectString,[project completed]];
		
		[writeString setString:[NSString stringWithFormat:@"%@\n%@",writeString,projectString]];
		
		count++;
	}
	
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:root];
	[handle truncateFileAtOffset:[handle seekToEndOfFile]];
	[handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return root;
}

@end
