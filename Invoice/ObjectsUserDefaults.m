//
//  ObjectsUserDefaults.m
//  Invoice
//
//  Created by XGRoup on 9/5/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "ObjectsUserDefaults.h"

#import "Defines.h"

#define PRODUCTS_FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/products.plist"]
#define CLIENTS_FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/clients.plist"]
#define PROJECTS_FILE_PATH [NSHomeDirectory() stringByAppendingString:@"/Documents/projects.plist"]

@implementation ObjectsUserDefaults

-(id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;
}

+(id)defaultUserDefaults {
	static ObjectsUserDefaults * manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	
	return manager;
}

#pragma mark - PRODUCTS

-(void)createProductsFile {
  NSMutableArray* productsArray = [NSMutableArray new];
  
  if([[NSUserDefaults standardUserDefaults] objectForKey:kProductsKeyForNSUserDefaults]) {
    [productsArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kProductsKeyForNSUserDefaults]];
  }
	
	NSFileManager *manager = [NSFileManager defaultManager];
	if(![manager fileExistsAtPath:PRODUCTS_FILE_PATH]) {
		[manager createFileAtPath:PRODUCTS_FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		
		[productsArray writeToFile:PRODUCTS_FILE_PATH atomically:YES];
	}	
}

-(void)saveProducts:(NSArray*)sender
{
	[sender writeToFile:PRODUCTS_FILE_PATH atomically:YES];
}

-(NSArray*)loadProducts {
  NSFileManager *manager = [NSFileManager defaultManager];
  if([manager fileExistsAtPath:PRODUCTS_FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:PRODUCTS_FILE_PATH];
  }
  
  return [NSArray new];
}

#pragma mark - CLIENTS

-(void)createClientsFile {
  NSMutableArray* clientsArray = [NSMutableArray new];
    
  if([[NSUserDefaults standardUserDefaults] objectForKey:kClientsKeyForNSUserDefaults]) {
    [clientsArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kClientsKeyForNSUserDefaults]];
  }
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:CLIENTS_FILE_PATH]) {
		[manager createFileAtPath:CLIENTS_FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		
		[clientsArray writeToFile:CLIENTS_FILE_PATH atomically:YES];
	}
}

-(void)saveClients:(NSArray*)sender {
	[sender writeToFile:CLIENTS_FILE_PATH atomically:YES];
}

-(NSArray*)loadClients {
  NSFileManager *manager = [NSFileManager defaultManager];
  if([manager fileExistsAtPath:CLIENTS_FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:CLIENTS_FILE_PATH];
  }
  
  return [NSArray new];
}

#pragma mark - PROJECTS

-(void)createProjectsFile {
	NSMutableArray* projectsArray = [NSMutableArray new];
    
  if([[NSUserDefaults standardUserDefaults] objectForKey:kProjectsKeyForNSUserDefaults]) {
    [projectsArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kProjectsKeyForNSUserDefaults]];
  }
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if(![manager fileExistsAtPath:PROJECTS_FILE_PATH]) {
		[manager createFileAtPath:PROJECTS_FILE_PATH contents:[[NSData alloc] init] attributes:nil];
		
		[projectsArray writeToFile:PROJECTS_FILE_PATH atomically:YES];
	}
}

-(void)saveProjects:(NSArray*)sender {
	[sender writeToFile:PROJECTS_FILE_PATH atomically:YES];
}

-(NSArray*)loadProjects {
  NSFileManager *manager = [NSFileManager defaultManager];
  if([manager fileExistsAtPath:PROJECTS_FILE_PATH]) {
    return [[NSMutableArray alloc] initWithContentsOfFile:PROJECTS_FILE_PATH];
  }
  
  return [NSArray new];
}

@end
