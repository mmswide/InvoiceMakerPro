//
//  ProjectOBJ.h
//  Invoice
//
//  Created by Paul on 17/06/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClientOBJ.h"

@interface ProjectOBJ : NSObject
{
	NSMutableDictionary * contents;
}

-(id)init;
-(id)initWithProject:(ProjectOBJ*)sender;
-(id)initWithContentsDictionary:(NSDictionary*)sender;

#pragma mark - GETTERS

-(NSDictionary*)contentsDictionary;
-(NSDictionary*)partiallyContentsDictionary;

-(NSString*)ID;
-(NSString*)projectName;
-(NSString*)projectNumber;
-(ClientOBJ*)client;
-(NSString*)location;
-(NSString*)paid;
-(NSString*)completed;

#pragma mark - SETTERS
-(void)setID:(NSString*)sender;
-(void)setProjectName:(NSString*)sender;
-(void)setProjectNumber:(NSString*)sender;
-(void)setLocation:(NSString*)sender;
-(void)setClient:(NSDictionary*)sender;
-(void)setPaid:(NSString*)sender;
-(void)setCompleted:(NSString*)sender;

-(BOOL)isEqual:(ProjectOBJ*)object;

@end
