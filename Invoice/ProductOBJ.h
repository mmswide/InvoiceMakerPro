//
//  ProductOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ProductBaseOBJ.h"


@interface ProductOBJ : ProductBaseOBJ

{
	NSMutableDictionary * contents;
}

@property(nonatomic, assign) NSInteger indexInCollection;

-(id)init;
-(id)initWithProduct:(ProductOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;
-(id)initForTemplate;

#pragma mark - GETTERS

-(NSString*)code;

#pragma mark - SETTERS

-(void)setCode:(NSString*)sender;

@end