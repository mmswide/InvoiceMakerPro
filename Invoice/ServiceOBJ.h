//
//  ServiceOBJ.h
//  Invoice
//
//  Created by XGRoup5 on 8/19/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ProductBaseOBJ.h"

@interface ServiceOBJ : ProductBaseOBJ
{
	NSMutableDictionary * contents;
}

@property(nonatomic, assign) NSInteger indexInCollection;

-(id)init;
-(id)initWithService:(ServiceOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;

@end