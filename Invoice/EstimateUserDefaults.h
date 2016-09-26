//
//  EstimateUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "BaseUserDefaults.h"

@interface EstimateUserDefaults : BaseUserDefaults {
}

+(id)defaultUserDefaults;

-(void)createFile;

-(void)saveEstimates:(NSArray*)sender;

-(NSArray*)loadEstimates;

- (NSString *)estimatePref;
- (void)setEstimatePref:(NSString *)pref;

@end
