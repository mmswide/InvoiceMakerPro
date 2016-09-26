//
//  TermsManager.h
//  Invoice
//
//  Created by XGRoup5 on 8/30/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	
	kTerms7Days = 0,
	kTerms14Days,
	kTerms21Days,
	kTerms30Days,
	kTerms45Days,
	kTerms60Days,
	kTerms180Days,
	kTermsDueOnReceipt
	
} kTerms;

@interface TermsManager : NSObject

+(NSString*)termsString:(kTerms)terms;
+(NSDate*)dueDateFromThisDate:(NSDate*)date withTerms:(kTerms)terms;

@end