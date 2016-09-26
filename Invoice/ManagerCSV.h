//
//  ManagerCSV.h
//  Invoice
//
//  Created by Paul on 19/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManagerCSV : NSObject
{
}

+(id)sharedManager;

-(NSString*)createInvoiceCSVFile:(NSArray*)invoiceArray;

-(NSString*)createQuoteCSVFile:(NSArray*)quotesArray;

-(NSString*)createEstimateCSVFile:(NSArray*)estimateArray;

-(NSString*)createPurchaseOrderCSVFile:(NSArray*)poArray;

-(NSString*)createReceiptsCSVFile:(NSArray*)receiptsArray;

-(NSString*)createTimesheetsCSVFile:(NSArray*)timesheetsArray;

-(NSString*)createProductsCSVFile:(NSArray*)productsArray;

-(NSString*)createContactsCSVFile:(NSArray*)clientsArray;

-(NSString*)createProjectsCSVFile:(NSArray*)projectsArray;

@end
