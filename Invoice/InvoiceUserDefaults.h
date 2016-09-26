//
//  InvoiceUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "BaseUserDefaults.h"

@interface InvoiceUserDefaults : BaseUserDefaults {
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)saveInvoices:(NSArray*)sender;

-(NSArray*)loadInvoices;

- (NSString *)invoicePref;
- (void)setInvoicePref:(NSString *)pref;

@end
