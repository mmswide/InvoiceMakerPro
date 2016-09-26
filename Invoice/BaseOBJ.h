//
//  BaseOBJ.h
//  Invoice
//
//  Created by Dmytro Nosulich on 2/18/15.
//  Copyright (c) 2015 XGRoup. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TYPE         @"figure_type"
#define VISIBILITY   @"figure_visibility"
#define TITLE        @"title"
#define VALUE        @"value"

#define FIGURES_SETTINGS            @"figures_settings"
#define DETAILS_SETTINGS            @"details_settings"
#define ADDITEM_DETAILS_SETTINGS    @"additem_details_settings"
#define PROFILE_SETTINGS            @"profile_settings"
#define CLIENT_SETTINGS             @"client_settings"

#define CUSTOM_FIELDS_MAX_COUNT 5

typedef NS_ENUM(NSInteger, ClientType) {
  ClientAddClient,
  ClientBilling,
  ClientShipping
};

typedef NS_ENUM(NSInteger, DetailsType) {
  DetailProjNumber,
  DetailDate,
  DetailDueDate,
  DetailTerms,
  DetailCustom1,
  DetailCustom2,
  DetailCustom3,
  DetailCustom4,
  DetailCustom5,
  DetailProjectName,
  DetailProjectNo,
  DetailAddNewLine
};

typedef NS_ENUM(NSInteger, FigureType) {
  FigureSubtotal,
  FigureDiscount,
  FigureTax1,
  FigureTax2,
  FigureShipping,
  FigureTotal,
  FigurePaid,
  FigureBalanceDue
};

typedef NS_ENUM(NSInteger, AddItemDetailType) {
  RowAddItem,
  RowDescription,
  RowRate,
  RowCode,
  RowQuantity,
  RowDiscount,
  RowTotal,
  RowCustom1,
  RowCustom2
};

typedef NS_ENUM(NSInteger, ProfileType) {
  ProfileLogo,
  ProfileName,
  ProfileWebsite,
  ProfileEmail,
  ProfileAddress,
  ProfilePhone,
  ProfileMobile,
  ProfileFax,
  ProfileCustom1,
  ProfileCustom2,
  ProfileCustom3,
  ProfileCustom4,
  ProfileCustom5,
  ProfileAddNewLine
};

@class ClientOBJ;

@interface BaseOBJ : NSObject {
    NSMutableDictionary * contents;
}

//bug fixing
- (BOOL)areFiguresSettingsInDetailsFile;
- (BOOL)areFiguresSettingsInDetailsFile2Quote;
- (BOOL)removeTermsRowInInvoiceSection;
- (BOOL)addProjectFieldsToDetails;

- (NSString *)objLanguageKey;
- (NSString *)objTitle;

- (void)removeLeftCommonSignatureKey;
- (void)removeRightCommonSignatureKey;

- (void)setClientBillingTitleforKey:(NSString *)key1 shippingKey:(NSString *)key2;

//main methods
-(NSDictionary*)contentsDictionary;

-(ClientOBJ*)client;
-(void)setClient:(NSDictionary*)sender;
-(NSString*)number;

-(NSString*)tax1Name;
-(NSString*)tax2Name;

-(NSArray*)products;
-(void)setProducts:(NSArray*)sender;

- (BOOL)isEqualToObject:(BaseOBJ *)object;

- (void)removeTempSignatures;

//always show methods
-(BOOL)alwaysShowSignatureLeft;
-(void)setAlwaysShowSignatureLeft:(BOOL)show;
-(NSString *)alwaysShowLeftSignatureKey;

-(BOOL)alwaysShowSignatureRight;
-(void)setAlwaysShowSignatureRight:(BOOL)show;
-(NSString *)alwaysShowRightSignatureKey;

-(BOOL)alwaysShowNote;
-(void)setAlwaysShowNote:(BOOL)show;
-(NSString *)alwaysShowNoteKey;

-(BOOL)alwaysShowOtherComments;
-(void)setAlwaysShowOtherComments:(BOOL)show;
-(NSString *)alwaysShowOptionalInfoKey;

// --- additional methods ---
- (void)moveProductFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

//client
- (BOOL)isVisibleClientType:(ClientType)clientType;
- (void)setClientSettings:(NSDictionary *)details atIndex:(NSInteger)index;
- (void)moveClientFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (NSArray *)visibleRowsInClientSection;

//details
- (BOOL)isVisibleDetailType:(DetailsType)figureType;
- (void)setDetailsSettings:(NSDictionary *)details atIndex:(NSInteger)index;
- (void)moveDetailFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (NSArray *)visibleRowsInDetailsSection;

//figure
- (BOOL)isVisibleFigureType:(FigureType)figureType;
- (void)setFigureSettings:(NSDictionary *)figure atIndex:(NSInteger)index;
- (void)moveFigureFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (NSArray *)visibleRowsInFigureSection;

//additem
- (BOOL)isVisibleAddItemDetailType:(AddItemDetailType)detailsType;
- (void)setAddItemDetailsSettings:(NSDictionary *)details atIndex:(NSInteger)index;
- (void)moveAddItemDetailFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (NSArray *)visibleRowsInAddItemDetailsSection;

//profile
- (BOOL)isVisibleProfileType:(ProfileType)figureType;
- (void)setProfileSettings:(NSDictionary *)details atIndex:(NSInteger)index;
- (void)moveProfileFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (NSArray *)visibleRowsInProfileSection;

// --- client methods ---
- (NSArray *)newClientSettings;
- (NSArray *)clientSettings;
- (void)setClientSettings:(NSArray *)figures;
- (void)saveClientSettings;
- (NSArray *)savedClientSettings;

- (NSArray *)clientFieldsOrder;

- (NSArray *)localClientSettings;

// --- details methods ---
- (NSArray *)newDetailsSettings;
- (NSArray *)detailsSettings;
- (void)setDetailsSettings:(NSArray *)details;
- (void)saveDetailsSettings;
- (NSArray *)savedDetailsSettingsWithCustomFields:(BOOL)withCustom;
- (void)setTitle:(NSString *)title ForDetailType:(DetailsType)type;

- (NSArray *)localDetailsSettings;
- (void)setAndSaveDetailsSettings:(NSArray *)details;

// --- figure methods ---
- (NSArray *)newFigureSettings;
- (NSArray *)figuresSettings;
- (void)setFiguresSettings:(NSArray *)figures;
- (void)saveFigureSettings;
- (NSArray *)savedFigureSettings;

- (NSArray *)localFigureSettings;

//details custom fields
- (NSDictionary *)addCustomDetailField;
- (void)removeCustomDetailFieldAtType:(DetailsType)type;
- (NSUInteger)numberOfCustomDetailFieldsVisibleOnly:(BOOL)visible;
- (void)setValue:(NSString *)value forDetailType:(DetailsType)type;
- (NSArray *)customDetailFieldsVisibleOnly:(BOOL)visible;

// --- add item details methods ---
- (NSArray *)newAddItemDetailsSettings;
- (NSArray *)addItemDetailsSettings;
- (void)setAddItemDetailsSettings:(NSArray *)details;
- (void)saveAddItemDetailsSettings;
- (void)setAndSaveAddItemDetailsSettings:(NSArray *)settings;
- (NSArray *)savedAddItemDetailsSettings;

- (NSArray *)localAddItemDetailsSettings;

- (NSArray *)productFieldsOrder;

//AddItem custom fields
- (void)setTitle:(NSString *)title forAddItemType:(AddItemDetailType)type;
- (void)setValue:(NSString *)value forAddItemType:(AddItemDetailType)type;
- (void)removeCustomAddItemFieldAtType:(AddItemDetailType)type;


// --- Profile methods ---
- (NSArray *)newProfileSettings;
- (NSArray *)profileSettings;
- (void)setProfileSettings:(NSArray *)details;
- (void)saveProfileSettings;
- (NSArray *)savedProfileSettingsWithCustomFields:(BOOL)withCustom;
- (void)setTitle:(NSString *)title forProfileType:(ProfileType)type;

- (NSArray *)localProfileSettings;

//profile custom fields
- (NSDictionary *)addCustomProfileField;
- (void)removeCustomProfileFieldAtType:(ProfileType)type;
- (NSUInteger)numberOfCustomProfileFieldsVisibleOnly:(BOOL)visible;
- (void)setValue:(NSString *)value forProfileType:(ProfileType)type;
- (NSArray *)customProfileFieldsVisibleOnly:(BOOL)visible;

-(BOOL)companyAlignLeft;
-(void)setCompanyAlignLeft:(BOOL)left;

//editing titles in sections
- (NSString *)detailTitleForType:(DetailsType)type;
- (NSString *)figureTitleForType:(FigureType)type;
- (NSString *)addItemDetailTitleForType:(AddItemDetailType)type;

- (void)setDetailTitle:(NSString *)title forType:(DetailsType)type;
- (void)setFigureTitle:(NSString *)title forType:(FigureType)type;
- (void)setAddItemDetailTitle:(NSString *)title forType:(AddItemDetailType)type;

@end
