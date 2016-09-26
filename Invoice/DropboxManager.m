//
//  DropboxManager.m
//  Invoice
//
//  Created by Dmytro Nosulich on 6/17/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "DropboxManager.h"
#import <DropboxSDK/DropboxSDK.h>
#import "AppDelegate.h"
#import "Defines.h"

@interface DropboxManager () <DBSessionDelegate, DBNetworkRequestDelegate, DBRestClientDelegate> {
  DBRestClient* restClient;
  NSString *currentUploadingFilePath;
}

@property (nonatomic, readonly) DBRestClient* restClient;

@end

@implementation DropboxManager

#pragma mark - Public methods

+ (DropboxManager *)sharedManager {
  static DropboxManager *staticManager;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    staticManager = [DropboxManager new];
  });
  return staticManager;
}

+ (void)startSession {
  NSString* appKey = [self appkey];
  NSString* appSecret = [self appSecret];
  NSString *root = kDBRootAppFolder;
  
  DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
  session.delegate = [DropboxManager sharedManager];
  [DBSession setSharedSession:session];
  
  [DBRequest setNetworkRequestDelegate:[DropboxManager sharedManager]];
}

+ (BOOL)isLinked {
  return [[DBSession sharedSession] isLinked];
}

+ (void)linkFromController:(UIViewController *)controller {
  [[DBSession sharedSession] linkFromController:controller];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
  if ([[DBSession sharedSession] handleOpenURL:url]) {
    if ([[DBSession sharedSession] isLinked]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:DROPBOX_DID_LOGIN_NOTIFICATION object:nil];
    }
    return YES;
  }
  return NO;
}

- (void)uploadFileWithName:(NSString *)name fromPath:(NSString *)path {
  if(DELEGATE.internetIsAvailable) {
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:name toPath:destDir withParentRev:nil fromPath:path];
    currentUploadingFilePath = [path copy];
  } else {
    NSLog(@"can't upload file. No internet connection");
  }
}

#pragma mark - Private methods

+ (NSString *)appkey {
  kApplicationVersion version = app_version;
  
  NSString *appKey = @"";
  switch (version) {
    case kApplicationVersionInvoice: {
      if(free_version) {
        appKey = @"jhifisojh530h7f";
      } else {
        appKey = @"zihe8citpcc4haf";
      }
    }
      break;
      
    case kApplicationVersionQuote: {
      appKey = @"7mr8k5a623a5i4p";
    }
      break;
      
    case kApplicationVersionEstimate: {
      appKey = @"hhrnulc22zd82ks";
    }
      break;
      
    case kApplicationVersionPurchase: {
      appKey = @"516tlau0kdb013e";
    }
      break;
      
    default:
      break;
  }
  
  return appKey;
}

+ (NSString *)appSecret {
  kApplicationVersion version = app_version;
  
  NSString *appSecret = @"";
  switch (version) {
    case kApplicationVersionInvoice: {
      if(free_version) {
        appSecret = @"bc03a94ad85xxt4";
      } else {
        appSecret = @"q92k8go00xzh3f9";
      }
    }
      break;
      
    case kApplicationVersionQuote: {
      appSecret = @"uovsfggtztk84ke";
    }
      break;
      
    case kApplicationVersionEstimate: {
      appSecret = @"37300go4uodlehk";
    }
      break;
      
    case kApplicationVersionPurchase: {
      appSecret = @"0ij39w2y3i705uv";
    }
      break;
      
    default:
      break;
  }
  
  return appSecret;
}

- (DBRestClient*)restClient {
  if (restClient == nil) {
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;
  }
  return restClient;
}

- (void)removeUploadingFileAtPath:(NSString *)path {
  NSFileManager *manager = [NSFileManager defaultManager];
  if([manager fileExistsAtPath:path]) {
    NSError *error = nil;
    [manager removeItemAtPath:path error:&error];
    if(error) {
      NSLog(@"error: %@ to delete file at path: %@", [error localizedDescription], path);
    }
  }
  currentUploadingFilePath = nil;
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
  NSLog(@"df");
}

#pragma mark -
#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
  NSLog(@"File uploaded successfully to path: %@", metadata.path);
  [self removeUploadingFileAtPath:srcPath];
  currentUploadingFilePath = nil;
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
  NSLog(@"File upload failed with error: %@", error);
  
  [self removeUploadingFileAtPath:currentUploadingFilePath];
  currentUploadingFilePath = nil;
}

#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
  outstandingRequests++;
  if (outstandingRequests == 1) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  }
}

- (void)networkRequestStopped {
  outstandingRequests--;
  if (outstandingRequests == 0) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  }
}

@end
