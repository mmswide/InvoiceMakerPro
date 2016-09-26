//
//  QuoteUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "BaseUserDefaults.h"

@interface QuoteUserDefaults : BaseUserDefaults {
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)saveQuotes:(NSArray*)sender;

-(NSArray*)loadQuotes;

- (NSString *)quotePref;
- (void)setQuotePref:(NSString *)pref;

@end
