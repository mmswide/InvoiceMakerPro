//
//  BaseOBJ.m
//  Invoice
//
//  Created by Dmytro Nosulich on 2/18/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import "BaseOBJ.h"

#import "Defines.h"

@interface BaseOBJ ()


@end

@implementation BaseOBJ

#pragma mark - Fixing bugs methods

- (BOOL)areFiguresSettingsInDetailsFile {
  NSString *key = [NSString stringWithFormat:@"%@_v9.4_wrong_details_settings", NSStringFromClass([self class])];
  BOOL isWrongDataFixed = [[NSUserDefaults standardUserDefaults] boolForKey:key];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  return !isWrongDataFixed;
}

- (BOOL)areFiguresSettingsInDetailsFile2Quote {
  NSString *key = [NSString stringWithFormat:@"%@_v9.4_wrong_details_settings_2_quote", NSStringFromClass([self class])];
  BOOL isWrongDataFixed = [[NSUserDefaults standardUserDefaults] boolForKey:key];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  return !isWrongDataFixed;
}

- (BOOL)removeTermsRowInInvoiceSection {
  if(![self isKindOfClass:[InvoiceOBJ class]]) return NO;
  
  NSString *key = [NSString stringWithFormat:@"%@_v9.4_remove_terms_row", NSStringFromClass([self class])];
  BOOL existTerms = ![[NSUserDefaults standardUserDefaults] boolForKey:key];
  if(existTerms) {
    NSInteger i = 0;
    NSMutableArray *settings = [NSMutableArray arrayWithArray:[self localDetailsSettings]];
    for(i = 0; i < [settings count]; i++) {
      NSDictionary *detail = settings[i];
      if([detail[TYPE] integerValue] == DetailTerms) {
        [settings removeObjectAtIndex:i];
        [data_manager setInvoiceDetailsSettings:settings];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        break;
      }
    }
  }
  
  NSInteger i = 0;
  NSMutableArray *settings = [NSMutableArray arrayWithArray:[self detailsSettings]];
  for(i = 0; i < [settings count]; i++) {
    NSDictionary *detail = settings[i];
    if([detail[TYPE] integerValue] == DetailTerms) {
      [settings removeObjectAtIndex:i];
      [self setDetailsSettings:settings];
      break;
    }
  }
  
  return existTerms;
}

- (BOOL)addProjectFieldsToDetails {
  //set Project fields for saved details settings
  NSString *key = [NSString stringWithFormat:@"%@_v9.8_add_project_fields_to_details", NSStringFromClass([self class])];
  BOOL alreadyAdded = [[NSUserDefaults standardUserDefaults] boolForKey:key];
  if(!alreadyAdded) {
    NSInteger i = 0;
    NSMutableArray *settings = [NSMutableArray arrayWithArray:[self localDetailsSettings]];
    if([settings count] == 0) {
      settings = [NSMutableArray arrayWithArray:[self detailsSettings]];
    }
    BOOL hasProjectFields = NO;
    for(i = 0; i < [settings count]; i++) {
      NSDictionary *detail = settings[i];
      if([detail[TYPE] integerValue] == DetailProjectName ||
         [detail[TYPE] integerValue] == DetailProjectNo) {
        hasProjectFields = YES;
        break;
      }
    }
    
    if(!hasProjectFields) {
      [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                            TYPE: [NSNumber numberWithInteger:DetailProjectName]}];
      [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                            TYPE: [NSNumber numberWithInteger:DetailProjectNo]}];
      [self setAndSaveDetailsSettings:settings];
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
  }
  
  //set Project fields for current object
  NSMutableArray *settings = [NSMutableArray arrayWithArray:[self detailsSettings]];
  NSInteger i = 0;
  BOOL hasProjectFields = NO;
  for(i = 0; i < [settings count]; i++) {
    NSDictionary *detail = settings[i];
    if([detail[TYPE] integerValue] == DetailProjectName ||
       [detail[TYPE] integerValue] == DetailProjectNo) {
      hasProjectFields = YES;
      break;
    }
  }
  
  if(!hasProjectFields) {
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                          TYPE: [NSNumber numberWithInteger:DetailProjectName]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                          TYPE: [NSNumber numberWithInteger:DetailProjectNo]}];
    [self setDetailsSettings:settings];
  }
  
  return !alreadyAdded;
}

- (void)setClientBillingTitleforKey:(NSString *)key1 shippingKey:(NSString *)key2 {
  NSString *billTitle = [CustomDefaults customObjectForKey:key1];
  if(!billTitle || [billTitle length] == 0) {
    billTitle = [CustomDefaults customObjectForKey:kBillingAddressTitleKeyForNSUserDefaults];
  }
  NSString *shippTitle = [CustomDefaults customObjectForKey:key2];
  if(!shippTitle || [shippTitle length] == 0) {
    shippTitle = [CustomDefaults customObjectForKey:kShippingAddressTitleKeyForNSUserDefaults];
  }
  
  ClientOBJ *client = [self client];
  AddressOBJ *billAddr = [client billingAddress];
  [billAddr setBillingTitle:billTitle];
  [client setBillingAddress:[billAddr contentsDictionary]];
  
  AddressOBJ *shippAddr = [client shippingAddress];
  [shippAddr setShippingTitle:shippTitle];
  [client setShippingAddress:[shippAddr contentsDictionary]];
  
  [self setClient:[client contentsDictionary]];
}

#pragma mark - Client section Methods
- (void)setClientSettings:(NSDictionary *)client atIndex:(NSInteger)index {
  if(!client) {
    return;
  }
  
  NSMutableArray *clientSettings = [NSMutableArray arrayWithArray:[self clientSettings]];
  if([clientSettings count] > index) {
    [clientSettings replaceObjectAtIndex:index withObject:client];
    [self setClientSettings:clientSettings];
  }
}

- (void)moveClientFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  NSMutableArray *clientSettings = [NSMutableArray arrayWithArray:[self clientSettings]];
  
  id object = [clientSettings objectAtIndex:fromIndex];
  [clientSettings removeObjectAtIndex:fromIndex];
  [clientSettings insertObject:object atIndex:toIndex];
  [self setClientSettings:clientSettings];
}

- (NSArray *)savedClientSettings {
  NSMutableArray *savedSettings = [NSMutableArray arrayWithArray:[self localClientSettings]];
  if([savedSettings count] > 0) {
    return savedSettings;
  } else {
    return [self newClientSettings];
  }
}

- (NSArray *)visibleRowsInClientSection {
  NSMutableArray *rows = [NSMutableArray arrayWithArray:[[self clientSettings] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
    return [evaluatedObject[VISIBILITY] boolValue];
  }]]];
  
  return rows;
}

- (BOOL)isVisibleClientType:(ClientType)clientType {
  BOOL visible = NO;
  for(NSDictionary *clientSettings in [self clientSettings]) {
    if([clientSettings[TYPE] integerValue] == clientType) {
      visible = [clientSettings[VISIBILITY] boolValue];
      break;
    }
  }
  return visible;
}

- (NSArray *)clientFieldsOrder {
  NSMutableArray *order = [NSMutableArray new];
  
  for(NSDictionary *clientField in [self visibleRowsInClientSection]) {
    if([clientField[TYPE] integerValue] != ClientAddClient) {
      [order addObject:clientField[TYPE]];
    }
  }
  
  return order;
}

#pragma mark - Figure section Methods

- (void)setFigureSettings:(NSDictionary *)figure atIndex:(NSInteger)index {
    if(!figure) {
        return;
    }
    
    NSMutableArray *figureSettings = [NSMutableArray arrayWithArray:[self figuresSettings]];
    if([figureSettings count] > index) {
        [figureSettings replaceObjectAtIndex:index withObject:figure];
        [self setFiguresSettings:figureSettings];
    }
}

- (void)moveFigureFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSMutableArray *figureSettings = [NSMutableArray arrayWithArray:[self figuresSettings]];
    
    id object = [figureSettings objectAtIndex:fromIndex];
    [figureSettings removeObjectAtIndex:fromIndex];
    [figureSettings insertObject:object atIndex:toIndex];
    [self setFiguresSettings:figureSettings];
}

- (NSArray *)savedFigureSettings {
    NSArray *savedSettings = [self localFigureSettings];
    NSMutableArray *settings = nil;
    if([savedSettings count] > 0) {
        settings = [NSMutableArray arrayWithArray:savedSettings];
    } else {
        return [self newFigureSettings];
    }
    
    BOOL has_tax1 = ![[self tax1Name] isEqual:@""];
    BOOL has_tax2 = ![[self tax2Name] isEqual:@""];
    
    NSDictionary *tax1 = nil;
    NSDictionary *tax2 = nil;
    for(NSDictionary *figure in settings) {
        if([figure[TYPE] integerValue] == FigureTax1) {
            tax1 = figure;
        } else if ([figure[TYPE] integerValue] == FigureTax2) {
            tax2 = figure;
        }
        if(tax1 && tax2) break;
    }
    
    if(has_tax1) {
        if(!tax1) {
            [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                                  TYPE: [NSNumber numberWithInteger:FigureTax1]}];
        }
    } else {
        [settings removeObject:tax1];
    }
    if(has_tax2) {
        if(!tax2) {
            [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                                  TYPE: [NSNumber numberWithInteger:FigureTax2]}];
        }
    } else {
        [settings removeObject:tax2];
    }
    
    return settings;
}

- (NSArray *)visibleRowsInFigureSection {
    NSMutableArray *rows = [NSMutableArray arrayWithArray:[[self figuresSettings] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject[VISIBILITY] boolValue];
    }]]];
    
    return rows;
}

- (BOOL)isVisibleFigureType:(FigureType)figureType {
    BOOL visible = NO;
    for(NSDictionary *figureSettings in [self figuresSettings]) {
        if([figureSettings[TYPE] integerValue] == figureType) {
            visible = [figureSettings[VISIBILITY] boolValue];
            break;
        }
    }
    return visible;
}

#pragma mark - Details section Methods

- (void)setDetailsSettings:(NSDictionary *)details atIndex:(NSInteger)index {
    if(!details) {
        return;
    }
    
    NSMutableArray *detilsSettings = [NSMutableArray arrayWithArray:[self detailsSettings]];
    if([detilsSettings count] > index) {
        [detilsSettings replaceObjectAtIndex:index withObject:details];
        [self setDetailsSettings:detilsSettings];
    }
}

- (void)moveDetailFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSMutableArray *detailsSettings = [NSMutableArray arrayWithArray:[self detailsSettings]];
    
    id object = [detailsSettings objectAtIndex:fromIndex];
    [detailsSettings removeObjectAtIndex:fromIndex];
    [detailsSettings insertObject:object atIndex:toIndex];
    [self setDetailsSettings:detailsSettings];
}

- (NSArray *)savedDetailsSettingsWithCustomFields:(BOOL)withCustom; {
    NSMutableArray *savedSettings = [NSMutableArray arrayWithArray:[self localDetailsSettings]];
    if([savedSettings count] > 0) {
        if(!withCustom) {
            for(NSInteger i = 0; i < [savedSettings count]; i++) {
                DetailsType type = [savedSettings[i][TYPE] integerValue];
                if(type >= DetailCustom1 && type <= DetailCustom5) {
                    [savedSettings removeObjectAtIndex:i];
                    i = MAX(0, --i);
                }
            }
        }
        
        return savedSettings;
    } else {
        return [self newDetailsSettings];
    }
}

- (NSArray *)visibleRowsInDetailsSection {
    NSMutableArray *rows = [NSMutableArray arrayWithArray:[[self detailsSettings] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject[VISIBILITY] boolValue];
    }]]];
    
    return rows;
}

- (BOOL)isVisibleDetailType:(DetailsType)detailsType {
    BOOL visible = NO;
    for(NSDictionary *detailsSettings in [self detailsSettings]) {
        if([detailsSettings[TYPE] integerValue] == detailsType) {
            visible = [detailsSettings[VISIBILITY] boolValue];
            break;
        }
    }
    return visible;
}

- (void)setTitle:(NSString *)title ForDetailType:(DetailsType)type {
    if([title length] > 0) {
        NSArray *details = [self detailsSettings];
        NSInteger i = 0;
        for(NSDictionary *detailsSettings in details) {
            if([detailsSettings[TYPE] integerValue] == type) {
              NSMutableDictionary *newDetail = [NSMutableDictionary dictionaryWithDictionary:detailsSettings];
              [newDetail setObject:title forKey:TITLE];
              [self setDetailsSettings:newDetail atIndex:i];
              break;
            }
            i++;
        }
    }
}

#pragma mark - AddItem Details section methods

- (void)setAddItemDetailsSettings:(NSDictionary *)details atIndex:(NSInteger)index {
    if(!details) {
        return;
    }
    
    NSMutableArray *detilsSettings = [NSMutableArray arrayWithArray:[self addItemDetailsSettings]];
    if([detilsSettings count] > index) {
        [detilsSettings replaceObjectAtIndex:index withObject:details];
        [self setAddItemDetailsSettings:detilsSettings];
    }
}

- (void)moveAddItemDetailFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSMutableArray *detailsSettings = [NSMutableArray arrayWithArray:[self addItemDetailsSettings]];
    
    id object = [detailsSettings objectAtIndex:fromIndex];
    [detailsSettings removeObjectAtIndex:fromIndex];
    [detailsSettings insertObject:object atIndex:toIndex];
    [self setAddItemDetailsSettings:detailsSettings];
}

- (NSArray *)savedAddItemDetailsSettings {
    NSMutableArray *savedSettings = [NSMutableArray arrayWithArray:[self localAddItemDetailsSettings]];
    if([savedSettings count] > 0) {
        return savedSettings;
    } else {
        return [self newAddItemDetailsSettings];
    }
}

- (NSArray *)visibleRowsInAddItemDetailsSection {
    NSMutableArray *rows = [NSMutableArray arrayWithArray:[[self addItemDetailsSettings] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject[VISIBILITY] boolValue];
    }]]];
    
    return rows;
}

- (BOOL)isVisibleAddItemDetailType:(AddItemDetailType)detailsType {
    BOOL visible = NO;
    for(NSDictionary *detailsSettings in [self addItemDetailsSettings]) {
        if([detailsSettings[TYPE] integerValue] == detailsType) {
            visible = [detailsSettings[VISIBILITY] boolValue];
            break;
        }
    }
    return visible;
}

#pragma mark - Profile section Methods

- (void)setProfileSettings:(NSDictionary *)details atIndex:(NSInteger)index; {
  if(!details) {
    return;
  }
  
  NSMutableArray *detilsSettings = [NSMutableArray arrayWithArray:[self profileSettings]];
  if([detilsSettings count] > index) {
    [detilsSettings replaceObjectAtIndex:index withObject:details];
    [self setProfileSettings:detilsSettings];
  }
}

- (void)moveProfileFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex; {
  NSMutableArray *detailsSettings = [NSMutableArray arrayWithArray:[self profileSettings]];
  
  id object = [detailsSettings objectAtIndex:fromIndex];
  [detailsSettings removeObjectAtIndex:fromIndex];
  [detailsSettings insertObject:object atIndex:toIndex];
  [self setProfileSettings:detailsSettings];
}

- (NSArray *)savedProfileSettingsWithCustomFields:(BOOL)withCustom; {
  NSMutableArray *savedSettings = [NSMutableArray arrayWithArray:[self localProfileSettings]];
  if([savedSettings count] > 0) {
    if(!withCustom) {
      for(NSInteger i = 0; i < [savedSettings count]; i++) {
        ProfileType type = [savedSettings[i][TYPE] integerValue];
        if(type >= ProfileCustom1) {
          [savedSettings removeObjectAtIndex:i];
          i = MAX(0, --i);
        }
      }
    }
    
    return savedSettings;
  } else {
    return [self newProfileSettings];
  }
}

- (NSArray *)visibleRowsInProfileSection; {
  NSMutableArray *rows = [NSMutableArray arrayWithArray:[[self profileSettings] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
    return [evaluatedObject[VISIBILITY] boolValue];
  }]]];
  
  return rows;
}

- (BOOL)isVisibleProfileType:(ProfileType)type; {
  BOOL visible = NO;
  for(NSDictionary *detailsSettings in [self profileSettings]) {
    if([detailsSettings[TYPE] integerValue] == type) {
      visible = [detailsSettings[VISIBILITY] boolValue];
      break;
    }
  }
  return visible;
}

- (void)setTitle:(NSString *)title forProfileType:(ProfileType)type; {
  if([title length] > 0) {
    NSArray *details = [self profileSettings];
    NSInteger i = 0;
    for(NSDictionary *detailsSettings in details) {
      if([detailsSettings[TYPE] integerValue] == type) {
        NSMutableDictionary *newDetail = [NSMutableDictionary dictionaryWithDictionary:detailsSettings];
        [newDetail setObject:title forKey:TITLE];
        [self setProfileSettings:newDetail atIndex:i];
        break;
      }
      i++;
    }
  }
}

#pragma mark - Overridden methods

- (NSArray *)localClientSettings {
  NSAssert(NO, @"This method should be overridden by subclasses");
  return nil;
}

- (void)saveClientSettings {
  NSAssert(NO, @"This method should be overridden by subclasses");
}

- (NSArray *)localFigureSettings {
    NSAssert(NO, @"This method should be overridden by subclasses");
    return nil;
}

- (void)saveFigureSettings {
    NSAssert(NO, @"This method should be overridden by subclasses");
}

- (NSArray *)localDetailsSettings {
    NSAssert(NO, @"This method should be overridden by subclasses");
    return nil;
}

- (void)setAndSaveDetailsSettings:(NSArray *)details {
  NSAssert(NO, @"This method should be overridden by subclasses");
}

- (void)saveDetailsSettings {
    NSAssert(NO, @"This method should be overridden by subclasses");
}

- (NSArray *)localAddItemDetailsSettings {
    NSAssert(NO, @"This method should be overridden by subclasses");
    return nil;
}

- (void)saveAddItemDetailsSettings {
    NSAssert(NO, @"This method should be overridden by subclasses");
}

- (void)setAndSaveAddItemDetailsSettings:(NSArray *)settings {
  NSAssert(NO, @"This method should be overridden by subclasses");
}

- (NSArray *)localProfileSettings {
  NSAssert(NO, @"This method should be overridden by subclasses");
  return nil;
}

- (void)saveProfileSettings {
  NSAssert(NO, @"This method should be overridden by subclasses");
}

-(NSString*)tax1Name {
    NSAssert(NO, @"This method should be overridden by subclasses");
    return nil;
}

-(NSString*)tax2Name {
    NSAssert(NO, @"This method should be overridden by subclasses");
    return nil;
}

- (NSString *)objLanguageKey {
    NSAssert(NO, @"This method should be averridden by subclasses");
    return nil;
}

- (NSString *)objTitle {
    NSAssert(NO, @"This method should be averridden by subclasses");
    return nil;
}

-(ClientOBJ*)client {
    NSAssert(NO, @"This method should be averridden by subclasses");
    return nil;
}

- (void)setClient:(NSDictionary *)sender {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

-(NSString*)number {
    NSAssert(NO, @"This method should be averridden by subclasses");
    return nil;
}

-(NSDictionary*)contentsDictionary {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

- (void)removeLeftCommonSignatureKey {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

- (void)removeRightCommonSignatureKey {
  NSAssert(NO, @"This method should be averridden by subclasses");
}

#pragma mark - Products methods

- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSMutableArray *products = [NSMutableArray arrayWithArray:[self products]];
    if([products count] > 0) {
        id object = [products objectAtIndex:fromIndex];
        [products removeObjectAtIndex:fromIndex];
        [products insertObject:object atIndex:toIndex];
        [self setProducts:products];
    }
}

-(NSArray*)products
{
    if ([[contents allKeys] containsObject:@"products"] && [[contents objectForKey:@"products"] isKindOfClass:[NSArray class]])
    {
        return [contents objectForKey:@"products"];
    }
    else
    {
        [data_manager logGetterErrorFromClass:[self class] forProperty:@"products" containedValue:[contents objectForKey:@"products"] withDefautReturnValue:@"empty array"];
        return [NSArray array];
    }
}

-(void)setProducts:(NSArray*)sender
{
    if (sender && [sender isKindOfClass:[NSArray class]])
    {
        [contents setObject:sender forKey:@"products"];
    }
    else
    {
        [data_manager logSetterErrorFromClass:[self class] forProperty:@"products" sentValue:sender withDefaultSetValue:@"empty array"];
        [contents setObject:[NSArray array] forKey:@"products"];
    }
}

#pragma mark - Other methods

- (BOOL)isEqualToObject:(BaseOBJ *)object {
  if(![object isKindOfClass:[BaseOBJ class]]) return NO;
  
  return [contents isEqualToDictionary:[object contentsDictionary]];
}

- (void)removeTempSignatures {
  NSAssert(NO, @"This method should be overridden by subclasses");
}

#pragma mark - ALWAYS SHOW MEYHODS

-(BOOL)alwaysShowSignatureLeft {
  NSString *key = [self alwaysShowLeftSignatureKey];
  if([CustomDefaults containValueForKey:key]) {
    return [CustomDefaults customBoolForKey:key];
  } else {
    [CustomDefaults setCustomBool:YES forKey:key];
    return YES;
  }
}

-(void)setAlwaysShowSignatureLeft:(BOOL)show {
  [CustomDefaults setCustomBool:show forKey:[self alwaysShowLeftSignatureKey]];
}

- (NSString *)alwaysShowLeftSignatureKey {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(BOOL)alwaysShowSignatureRight {
  NSString *key = [self alwaysShowRightSignatureKey];
  if([CustomDefaults containValueForKey:key]) {
    return [CustomDefaults customBoolForKey:key];
  } else {
    [CustomDefaults setCustomBool:YES forKey:key];
    return YES;
  }
}

-(void)setAlwaysShowSignatureRight:(BOOL)show {
  [CustomDefaults setCustomBool:show forKey:[self alwaysShowRightSignatureKey]];
}

- (NSString *)alwaysShowRightSignatureKey {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(BOOL)alwaysShowNote {
  NSString *key = [self alwaysShowNoteKey];
  if([CustomDefaults containValueForKey:key]) {
    return [CustomDefaults customBoolForKey:key];
  } else {
    [CustomDefaults setCustomBool:YES forKey:key];
    return YES;
  }
}

-(void)setAlwaysShowNote:(BOOL)show {
  [CustomDefaults setCustomBool:show forKey:[self alwaysShowNoteKey]];
}

- (NSString *)alwaysShowNoteKey {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

-(BOOL)alwaysShowOtherComments {
  NSString *key = [self alwaysShowOptionalInfoKey];
  if([CustomDefaults containValueForKey:key]) {
    return [CustomDefaults customBoolForKey:key];
  } else {
    [CustomDefaults setCustomBool:YES forKey:key];
    return YES;
  }
}

-(void)setAlwaysShowOtherComments:(BOOL)show {
  [CustomDefaults setCustomBool:show forKey:[self alwaysShowOptionalInfoKey]];
}

- (NSString *)alwaysShowOptionalInfoKey {
  NSAssert(NO, @"This method should be averridden by subclasses");
  return nil;
}

#pragma mark - Client methods
- (NSArray *)newClientSettings {
  NSMutableArray *settings = [NSMutableArray new];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ClientAddClient]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ClientBilling]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ClientShipping]}];
  
  return settings;
}

- (NSArray *)clientSettings {
  if([[contents allKeys] containsObject:CLIENT_SETTINGS] && [[contents objectForKey:CLIENT_SETTINGS] isKindOfClass:[NSArray class]]) {
    return [contents objectForKey:CLIENT_SETTINGS];
  } else {
    [data_manager logGetterErrorFromClass:[self class] forProperty:@"clientSettings" containedValue:[contents objectForKey:CLIENT_SETTINGS] withDefautReturnValue:@"array"];
    return [self newClientSettings];
  }
}

- (void)setClientSettings:(NSArray *)client {
  if(client && [client isKindOfClass:[NSArray class]]) {
    [contents setObject:client forKey:CLIENT_SETTINGS];
  } else {
    [data_manager logSetterErrorFromClass:[self class] forProperty:@"clientSetings" sentValue:client withDefaultSetValue:@"array"];
    [contents setObject:[self newClientSettings] forKey:CLIENT_SETTINGS];
  }
}

#pragma mark - Figure methods
- (NSArray *)newFigureSettings {
    BOOL has_tax1 = ![[self tax1Name] isEqual:@""];
    BOOL has_tax2 = ![[self tax2Name] isEqual:@""];
    
    BOOL visibility = YES;
    
    NSMutableArray *settings = [NSMutableArray new];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:visibility],
                          TYPE: [NSNumber numberWithInteger:FigureSubtotal]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:visibility],
                          TYPE: [NSNumber numberWithInteger:FigureDiscount]}];
    if(has_tax1) {
        [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:visibility],
                              TYPE: [NSNumber numberWithInteger:FigureTax1]}];
        if(has_tax2) {
            [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:visibility],
                                  TYPE: [NSNumber numberWithInteger:FigureTax2]}];
        }
    }
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:visibility],
                          TYPE: [NSNumber numberWithInteger:FigureShipping]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:visibility],
                          TYPE: [NSNumber numberWithInteger:FigureTotal]}];
    
    return settings;
}

- (NSArray *)figuresSettings {
    if([[contents allKeys] containsObject:FIGURES_SETTINGS] && [[contents objectForKey:FIGURES_SETTINGS] isKindOfClass:[NSArray class]]) {
        return [contents objectForKey:FIGURES_SETTINGS];
    } else {
        [data_manager logGetterErrorFromClass:[self class] forProperty:@"figuresSettings" containedValue:[contents objectForKey:FIGURES_SETTINGS] withDefautReturnValue:@"array"];
        return [self newFigureSettings];
    }
}

- (void)setFiguresSettings:(NSArray *)figures {
    if(figures && [figures isKindOfClass:[NSArray class]]) {
        [contents setObject:figures forKey:FIGURES_SETTINGS];
    } else {
        [data_manager logSetterErrorFromClass:[self class] forProperty:@"leftSignatureDate" sentValue:figures withDefaultSetValue:@"array"];
        [contents setObject:[self newFigureSettings] forKey:FIGURES_SETTINGS];
    }
}

#pragma mark - Add item Details methods

- (NSArray *)newAddItemDetailsSettings {
    NSMutableArray *settings = [NSMutableArray new];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:RowAddItem]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:RowDescription]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:RowRate]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                          TYPE: [NSNumber numberWithInteger:RowCode]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:RowQuantity]}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                          TYPE: [NSNumber numberWithInteger:RowDiscount]}];
  
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                          TYPE: [NSNumber numberWithInteger:RowCustom1],
                          TITLE: @"Title",
                          VALUE: @""}];
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                          TYPE: [NSNumber numberWithInteger:RowCustom2],
                          TITLE: @"Title",
                          VALUE: @""}];
  
    [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:RowTotal]}];
    
    return settings;
}

- (NSArray *)addItemDetailsSettings {
    if([[contents allKeys] containsObject:ADDITEM_DETAILS_SETTINGS] && [[contents objectForKey:ADDITEM_DETAILS_SETTINGS] isKindOfClass:[NSArray class]]) {
        return [contents objectForKey:ADDITEM_DETAILS_SETTINGS];
    } else {
        [data_manager logGetterErrorFromClass:[self class] forProperty:@"addItemDetailsSettings" containedValue:[contents objectForKey:ADDITEM_DETAILS_SETTINGS] withDefautReturnValue:@"array"];
        return [self newAddItemDetailsSettings];
    }
}

- (void)setAddItemDetailsSettings:(NSArray *)details {
    if(details && [details isKindOfClass:[NSArray class]]) {
        [contents setObject:details forKey:ADDITEM_DETAILS_SETTINGS];
    } else {
        [data_manager logSetterErrorFromClass:[self class] forProperty:@"addItemDetailsSettings" sentValue:details withDefaultSetValue:@"array"];
        [contents setObject:[self newAddItemDetailsSettings] forKey:ADDITEM_DETAILS_SETTINGS];
    }
}

- (NSArray *)productFieldsOrder {
    NSMutableArray *fieldsOrder = [NSMutableArray new];
  
    NSArray *visibleRows = [self visibleRowsInAddItemDetailsSection];
    for(NSDictionary *field in visibleRows) {
      [fieldsOrder addObject:field[TYPE]];
    }
  
    return fieldsOrder;
}

- (void)setTitle:(NSString *)title forAddItemType:(AddItemDetailType)type {
  if([title length] > 0) {
    NSArray *details = [self addItemDetailsSettings];
    NSInteger i = 0;
    for(NSDictionary *detailsSettings in details) {
      if([detailsSettings[TYPE] integerValue] == type) {
        NSMutableDictionary *newDetail = [NSMutableDictionary dictionaryWithDictionary:detailsSettings];
        [newDetail setObject:title forKey:TITLE];
        [self setAddItemDetailsSettings:newDetail atIndex:i];
        break;
      }
      i++;
    }
  }
}

- (void)setValue:(NSString *)value forAddItemType:(AddItemDetailType)type {
  if(value != nil) {
    NSArray *details = [self addItemDetailsSettings];
    NSInteger i = 0;
    for(NSDictionary *detailsSettings in details) {
      if([detailsSettings[TYPE] integerValue] == type) {
        NSMutableDictionary *newDetail = [NSMutableDictionary dictionaryWithDictionary:detailsSettings];
        [newDetail setObject:value forKey:VALUE];
        [self setAddItemDetailsSettings:newDetail atIndex:i];
        break;
      }
      i++;
    }
  }
}

- (void)removeCustomAddItemFieldAtType:(AddItemDetailType)type {
  NSMutableArray *newDetails = [NSMutableArray arrayWithArray:[self addItemDetailsSettings]];
  for(NSInteger i = 0; i < newDetails.count; i++) {
    NSDictionary *detailSetting = newDetails[i];
    if([detailSetting[TYPE] integerValue] == type) {
      [newDetails removeObjectAtIndex:i];
      [self setAddItemDetailsSettings:newDetails];
      break;
    }
  }
}

#pragma mark - Details methods

- (NSArray *)newDetailsSettings {
    NSArray *settings = @[@{VISIBILITY: [NSNumber numberWithBool:YES],
                          TYPE: [NSNumber numberWithInteger:DetailProjNumber]},
                          @{VISIBILITY: [NSNumber numberWithBool:NO],
                            TYPE: [NSNumber numberWithInteger:DetailProjectName]},
                          @{VISIBILITY: [NSNumber numberWithBool:NO],
                            TYPE: [NSNumber numberWithInteger:DetailProjectNo]}];

    return settings;
}

- (NSArray *)detailsSettings {
    if([[contents allKeys] containsObject:DETAILS_SETTINGS] && [[contents objectForKey:DETAILS_SETTINGS] isKindOfClass:[NSArray class]]) {
        return [contents objectForKey:DETAILS_SETTINGS];
    } else {
        [data_manager logGetterErrorFromClass:[self class] forProperty:@"detailsSettings" containedValue:[contents objectForKey:DETAILS_SETTINGS] withDefautReturnValue:@"array"];
        return [self newDetailsSettings];
    }
}

- (void)setDetailsSettings:(NSArray *)details {
    if(details && [details isKindOfClass:[NSArray class]]) {
        [contents setObject:details forKey:DETAILS_SETTINGS];
    } else {
        [data_manager logSetterErrorFromClass:[self class] forProperty:@"newDetailsSettings" sentValue:details withDefaultSetValue:@"array"];
        [contents setObject:[self newDetailsSettings] forKey:DETAILS_SETTINGS];
    }
}

#pragma mark - Profile methods

- (NSArray *)newProfileSettings {
  NSMutableArray *settings = [NSMutableArray new];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileLogo]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileName]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                        TYPE: [NSNumber numberWithInteger:ProfileWebsite]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                        TYPE: [NSNumber numberWithInteger:ProfileEmail]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:YES],
                        TYPE: [NSNumber numberWithInteger:ProfileAddress]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                        TYPE: [NSNumber numberWithInteger:ProfilePhone]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                        TYPE: [NSNumber numberWithInteger:ProfileMobile]}];
  [settings addObject:@{VISIBILITY: [NSNumber numberWithBool:NO],
                        TYPE: [NSNumber numberWithInteger:ProfileFax]}];
  
  return settings;
}

- (NSArray *)profileSettings {
  if([[contents allKeys] containsObject:PROFILE_SETTINGS] && [[contents objectForKey:PROFILE_SETTINGS] isKindOfClass:[NSArray class]]) {
    return [contents objectForKey:PROFILE_SETTINGS];
  } else {
    [data_manager logGetterErrorFromClass:[self class] forProperty:@"profileSettings" containedValue:[contents objectForKey:PROFILE_SETTINGS] withDefautReturnValue:@"array"];
    return [self newProfileSettings];
  }
}

- (void)setProfileSettings:(NSArray *)details {
  if(details && [details isKindOfClass:[NSArray class]]) {
    [contents setObject:details forKey:PROFILE_SETTINGS];
  } else {
    [data_manager logSetterErrorFromClass:[self class] forProperty:@"newProfileSettings" sentValue:details withDefaultSetValue:@"array"];
    [contents setObject:[self newProfileSettings] forKey:PROFILE_SETTINGS];
  }
}

#pragma mark - Details custom fields methods

- (NSDictionary *)addCustomDetailField {
    NSInteger fieldsCount = [self numberOfCustomDetailFieldsVisibleOnly:NO];
    NSDictionary *newField = nil;
    
    if(fieldsCount < CUSTOM_FIELDS_MAX_COUNT) {
        newField = @{VISIBILITY: [NSNumber numberWithBool:YES],
                           TYPE: [NSNumber numberWithInteger:[self newCustomDetailFieldType]],
                          TITLE: @"Title",
                          VALUE: @""};
        NSMutableArray *newDetails = [NSMutableArray arrayWithArray:[self detailsSettings]];
        [newDetails addObject:newField];
        [self setDetailsSettings:newDetails];
    }
    
    return newField;
}

- (void)removeCustomDetailFieldAtType:(DetailsType)type; {
    NSMutableArray *newDetails = [NSMutableArray arrayWithArray:[self detailsSettings]];
    for(NSInteger i = 0; i < newDetails.count; i++) {
        NSDictionary *detailSetting = newDetails[i];
        if([detailSetting[TYPE] integerValue] == type) {
          [newDetails removeObjectAtIndex:i];
          [self setDetailsSettings:newDetails];
          [self saveDetailsSettings];
          break;
        }
    }
}

- (DetailsType)newCustomDetailFieldType {
    DetailsType type = DetailCustom1;
    
    NSMutableArray *customFields = [NSMutableArray arrayWithArray:[self customDetailFieldsVisibleOnly:NO]];
    if(customFields.count > 0) {
        [customFields sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj1[TYPE] compare:obj2[TYPE]];
        }];
        
        for(NSDictionary *customField in customFields) {
            if(([customField[TYPE] integerValue] - type) >= 1) {
                break;
            } else {
                type++;
            }
        }
    }
    
    return type;
}

- (NSUInteger)numberOfCustomDetailFieldsVisibleOnly:(BOOL)visible {
    return [[self customDetailFieldsVisibleOnly:visible] count];
}

- (void)setValue:(NSString *)value forDetailType:(DetailsType)type {
    if(value != nil) {
        NSArray *details = [self detailsSettings];
        NSInteger i = 0;
        for(NSDictionary *detailsSettings in details) {
            if([detailsSettings[TYPE] integerValue] == type) {
              NSMutableDictionary *newDetail = [NSMutableDictionary dictionaryWithDictionary:detailsSettings];
              [newDetail setObject:value forKey:VALUE];
              [self setDetailsSettings:newDetail atIndex:i];
              break;
            }
            i++;
        }
    }
}

- (NSArray *)customDetailFieldsVisibleOnly:(BOOL)visible {
    NSArray *settings = [self detailsSettings];
    NSMutableArray *customFields = [NSMutableArray new];
    
    for(NSDictionary *sett in settings) {
        NSInteger type = [sett[TYPE] integerValue];
        if(type >= DetailCustom1 && type <= DetailCustom5) {
            if(visible) {
                if([sett[VISIBILITY] boolValue]) {
                    [customFields addObject:[sett copy]];
                }
            } else {
                [customFields addObject:[sett copy]];
            }
        }
    }
    return customFields;
}

#pragma mark - Profie custom fields methods

- (NSDictionary *)addCustomProfileField {
  NSInteger fieldsCount = [self numberOfCustomProfileFieldsVisibleOnly:NO];
  NSDictionary *newField = nil;
  
  if(fieldsCount < CUSTOM_FIELDS_MAX_COUNT) {
    newField = @{VISIBILITY: [NSNumber numberWithBool:YES],
                 TYPE: [NSNumber numberWithInteger:[self newCustomProfileFieldType]],
                 TITLE: @"Title",
                 VALUE: @""};
    NSMutableArray *newDetails = [NSMutableArray arrayWithArray:[self profileSettings]];
    [newDetails addObject:newField];
    [self setProfileSettings:newDetails];
  }
  
  return newField;
}

- (void)removeCustomProfileFieldAtType:(ProfileType)type {
  NSMutableArray *newDetails = [NSMutableArray arrayWithArray:[self profileSettings]];
  for(NSInteger i = 0; i < newDetails.count; i++) {
    NSDictionary *detailSetting = newDetails[i];
    if([detailSetting[TYPE] integerValue] == type) {
      [newDetails removeObjectAtIndex:i];
      [self setProfileSettings:newDetails];
      break;
    }
  }
}

- (NSUInteger)numberOfCustomProfileFieldsVisibleOnly:(BOOL)visible {
  return [[self customProfileFieldsVisibleOnly:visible] count];
}

- (void)setValue:(NSString *)value forProfileType:(ProfileType)type {
  if(value != nil) {
    NSArray *details = [self profileSettings];
    NSInteger i = 0;
    for(NSDictionary *detailsSettings in details) {
      if([detailsSettings[TYPE] integerValue] == type) {
        NSMutableDictionary *newDetail = [NSMutableDictionary dictionaryWithDictionary:detailsSettings];
        [newDetail setObject:value forKey:VALUE];
        [self setProfileSettings:newDetail atIndex:i];
        break;
      }
      i++;
    }
  }
}

- (NSArray *)customProfileFieldsVisibleOnly:(BOOL)visible {
  NSArray *settings = [self profileSettings];
  NSMutableArray *customFields = [NSMutableArray new];
  
  for(NSDictionary *sett in settings) {
    NSInteger type = [sett[TYPE] integerValue];
    if(type >= ProfileCustom1 && type <= ProfileCustom5) {
      if(visible) {
        if([sett[VISIBILITY] boolValue]) {
          [customFields addObject:[sett copy]];
        }
      } else {
        [customFields addObject:[sett copy]];
      }
    }
  }
  return customFields;
}

- (ProfileType)newCustomProfileFieldType {
  ProfileType type = ProfileCustom1;
  
  NSMutableArray *customFields = [NSMutableArray arrayWithArray:[self customProfileFieldsVisibleOnly:NO]];
  if(customFields.count > 0) {
    [customFields sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
      return [obj1[TYPE] compare:obj2[TYPE]];
    }];
    
    for(NSDictionary *customField in customFields) {
      if(([customField[TYPE] integerValue] - type) >= 1) {
        break;
      } else {
        type++;
      }
    }
  }
  
  return type;
}

- (void)setCompanyAlignLeft:(BOOL)left {
  [contents setObject:[NSNumber numberWithBool:left] forKey:kAlignedToRightCompanyInfo];
}

- (BOOL)companyAlignLeft {//kAlignedToRightCompanyInfo
  if ([[contents allKeys] containsObject:kAlignedToRightCompanyInfo]) {
    return [[contents objectForKey:kAlignedToRightCompanyInfo] boolValue];
  } else {
    [data_manager logGetterErrorFromClass:[self class] forProperty:kAlignedToRightCompanyInfo containedValue:[contents objectForKey:kAlignedToRightCompanyInfo] withDefautReturnValue:@"YES"];
    [self setCompanyAlignLeft:YES];
    return YES;
  }
}

#pragma mark - Editing details and figures titles

//public
- (NSString *)detailTitleForType:(DetailsType)type {
    return [self titleForType:type inSection:SectionDetails];
}

- (NSString *)figureTitleForType:(FigureType)type {
    return [self titleForType:type inSection:SectionFigure];
}

- (NSString *)addItemDetailTitleForType:(AddItemDetailType)type {
  if(type >= RowCustom1 && type <= RowCustom2) {
    NSArray *savedAddItemSettings = [self localAddItemDetailsSettings];
    NSString *customTitle = @"";
    for(NSDictionary *field in savedAddItemSettings) {
      if([field[TYPE] integerValue] == type) {
        customTitle = field[TITLE];
        break;
      }
    }
    return customTitle;
  } else {
    return [self titleForType:type inSection:SectionAddItemDetails];
  }
}

- (void)setDetailTitle:(NSString *)title forType:(DetailsType)type {
    [self setTitle:title forType:type sectionType:SectionDetails];
}

- (void)setFigureTitle:(NSString *)title forType:(FigureType)type {
    [self setTitle:title forType:type sectionType:SectionFigure];
}

- (void)setAddItemDetailTitle:(NSString *)title forType:(AddItemDetailType)type {
  if(type >= RowCustom1 && type <= RowCustom2) {
    [self setTitle:title forAddItemType:type];
    
    NSMutableArray *savedAddItemSettings = [NSMutableArray arrayWithArray:[self localAddItemDetailsSettings]];
    for(NSInteger i = 0; i < [savedAddItemSettings count]; i++) {
      NSDictionary *field = savedAddItemSettings[i];
      if([field[TYPE] integerValue] == type) {
        NSMutableDictionary *newField = [NSMutableDictionary dictionaryWithDictionary:field];
        [newField setObject:title?:@"" forKey:TITLE];
        [savedAddItemSettings replaceObjectAtIndex:i withObject:newField];
        [self setAndSaveAddItemDetailsSettings:savedAddItemSettings];
        break;
      }
    }
  } else {
    [self setTitle:title forType:type sectionType:SectionAddItemDetails];
  }
}

//private
- (void)setTitle:(NSString *)title forType:(NSInteger)type sectionType:(SectionTag)section {
    NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
    NSMutableDictionary *editedDict = [NSMutableDictionary dictionaryWithDictionary:languageDict[[self objLanguageKey]]];
    
    NSString *key = @"";
    if(section == SectionDetails) {
        key = [self detailLanguageKeyForType:type];
    } else if (section == SectionFigure) {
        key = [self figureLanguageKeyForType:type];
    } else if (section == SectionAddItemDetails) {
        key = [self addItemDetailLanguageKeyForType:type];
    }
    [editedDict setObject:title forKey:key];
    
    [languageDict setObject:editedDict forKey:[self objLanguageKey]];
    [CustomDefaults setCustomObjects:languageDict forKey:kLanguageKeyForNSUserDefaults];
}

- (NSString *)titleForType:(NSInteger)type inSection:(SectionTag)section {
    NSMutableDictionary *languageDict = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kLanguageKeyForNSUserDefaults]];
    NSDictionary *editedDict = languageDict[[self objLanguageKey]];
    
    NSString *key = @"";
    if(section == SectionDetails) {
        key = [self detailLanguageKeyForType:type];
    } else if (section == SectionFigure) {
        key = [self figureLanguageKeyForType:type];
    } else if (section == SectionAddItemDetails) {
        key = [self addItemDetailLanguageKeyForType:type];
    }
    NSString *title = editedDict[key];
    if(title == nil) {
        if(section == SectionDetails) {
            if(type == DetailTerms) {
                title = @"Terms";
            } else if (type == DetailDate) {
                title = @"Date";
            }
        }
    }
    
    return title;
}

- (NSString *)detailLanguageKeyForType:(DetailsType)type {
    NSString *projNo = [NSString stringWithFormat:@"%@ No", [self objTitle]];
    NSString *projDate = [NSString stringWithFormat:@"%@ date", [self objTitle]];
    NSArray *detailsKeys = @[projNo,
                             projDate,
                             @"Due date",
                             @"Terms",
                             @"", @"", @"", @"", @"",
                             @"Project Name",
                             @"Project No"];
    return detailsKeys[type];
}

- (NSString *)figureLanguageKeyForType:(FigureType)type {
    NSArray *figureKeys = @[@"Subtotal",
                            @"Discount",
                            @"",//tax 1
                            @"",//tax 2
                            @"Shipping",
                            @"Total",
                            @"Paid",
                            @"Balance due"];
    return figureKeys[type];
}

- (NSString *)addItemDetailLanguageKeyForType:(AddItemDetailType)type {
    NSArray *detailKeys = @[@"Item",
                            @"Description",
                            @"Rate",
                            @"Code",
                            @"Qty",
                            @"D(%)",
                            @"Amount"];
    return detailKeys[type];
}

@end
