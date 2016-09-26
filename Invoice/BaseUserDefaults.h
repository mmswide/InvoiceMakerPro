//
//  BaseUserDefaults.h
//  Invoice
//
//  Created by Dmytro Nosulich on 2/18/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseUserDefaults : NSObject

- (NSArray *)figuresSettings;
- (void)setFiguresSettings:(NSArray *)settings;

- (NSArray *)detailsSettings;
- (void)setDetailsSettings:(NSArray *)settings;

- (NSArray *)addItemDetailsSettings;
- (void)setAddItemDetailsSettings:(NSArray *)settings;

- (NSArray *)profileSettings;
- (void)setProfileSettings:(NSArray *)settings;

- (NSArray *)clientSettings;
- (void)setClientSettings:(NSArray *)settings;

@end
