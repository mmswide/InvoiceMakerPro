//
//  ObjectsUserDefaults.h
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectsUserDefaults : NSObject {	
}

+(id)defaultUserDefaults;

#pragma mark - PRODUCTS

-(void)createProductsFile;

-(void)saveProducts:(NSArray*)sender;

-(NSArray*)loadProducts;

#pragma mark - CLIENTS

-(void)createClientsFile;

-(void)saveClients:(NSArray*)sender;

-(NSArray*)loadClients;

#pragma mark - PROJECTS

-(void)createProjectsFile;

-(void)saveProjects:(NSArray*)sender;

-(NSArray*)loadProjects;

@end
