//
//  DropboxManager.h
//  Invoice
//
//  Created by Dmytro Nosulich on 6/17/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropboxManager : NSObject {
}

+ (DropboxManager *)sharedManager;
+ (void)startSession;
+ (BOOL)isLinked;
+ (void)linkFromController:(UIViewController *)controller;
+ (BOOL)handleOpenURL:(NSURL *)url;

- (void)uploadFileWithName:(NSString *)name fromPath:(NSString *)path;

@end
