//
//  BaseUserDefaults.m
//  Invoice
//
//  Created by Dmytro Nosulich on 2/18/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "BaseUserDefaults.h"

@implementation BaseUserDefaults

- (NSString *)figureFileName {
    return [NSString stringWithFormat:@"/Documents/%@.plist", NSStringFromClass([self class])];
}

- (NSString *)detailsFileName {
    return [NSString stringWithFormat:@"/Documents/%@_details.plist", NSStringFromClass([self class])];
}

- (NSString *)addItemDetailsFileName {
    return [NSString stringWithFormat:@"/Documents/%@_additem_details.plist", NSStringFromClass([self class])];
}

- (NSString *)profileDetailsFileName {
  return [NSString stringWithFormat:@"/Documents/%@_profile_details.plist", NSStringFromClass([self class])];
}

- (NSString *)clientFileName {
  return [NSString stringWithFormat:@"/Documents/%@_client_details.plist", NSStringFromClass([self class])];
}

//-------

- (NSArray *)figuresSettings {
    return [[NSMutableArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:[self figureFileName]]];
}

- (void)setFiguresSettings:(NSArray *)settings {
    if(settings) {
        [settings writeToFile:[NSHomeDirectory() stringByAppendingString:[self figureFileName]] atomically:YES];
    }
}
//-------
- (NSArray *)detailsSettings {
    return [[NSMutableArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:[self detailsFileName]]];
}

- (void)setDetailsSettings:(NSArray *)settings {
    if(settings) {
        [settings writeToFile:[NSHomeDirectory() stringByAppendingString:[self detailsFileName]] atomically:YES];
    }
}
//-------
- (NSArray *)addItemDetailsSettings {
    return [[NSMutableArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:[self addItemDetailsFileName]]];
}

- (void)setAddItemDetailsSettings:(NSArray *)settings {
    if(settings) {
        [settings writeToFile:[NSHomeDirectory() stringByAppendingString:[self addItemDetailsFileName]] atomically:YES];
    }
}

//-------
- (NSArray *)profileSettings {
  return [[NSMutableArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:[self profileDetailsFileName]]];
}

- (void)setProfileSettings:(NSArray *)settings {
  if(settings) {
    [settings writeToFile:[NSHomeDirectory() stringByAppendingString:[self profileDetailsFileName]] atomically:YES];
  }
}

//-------
- (NSArray *)clientSettings {
  return [[NSMutableArray alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:[self clientFileName]]];
}

- (void)setClientSettings:(NSArray *)settings {
  if(settings) {
    [settings writeToFile:[NSHomeDirectory() stringByAppendingString:[self clientFileName]] atomically:YES];
  }
}

@end
