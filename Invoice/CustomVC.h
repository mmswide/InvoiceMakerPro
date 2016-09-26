//
//  CustomVC.h
//  Invoice
//
//  Created by XGRoup on 6/25/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "BaseOBJ.h"

#define TITLE_CELL_TAG 212
#define MY_COMPANY_CELL_TAG 211
#define CLIENT_NAME_CELL_TAG 210

typedef NS_ENUM(NSInteger, ModuleType) {
  ModuleOtherType,
  ModuleInvoiceType,
  ModuleQuoteType,
  ModuleEstimateType,
  ModulePurchaseType,
  ModuleReceiptsType,
  ModuleTimesheetsType
};

typedef NS_ENUM(NSInteger, SectionTag) {
    SectionTitle,
    SectionYourCompany,
    SectionClient,
    SectionDetails,
    SectionProductsAndServices,
    SectionFigure,
    SectionOptionalInfo,
    SectionMarcAsOpen,
    
    //section in addItemVC
    SectionAddItemDetails,
  
    //section in ProfileVC
    SectionProfile
};

typedef NS_ENUM(NSInteger, ProfileSection) {
  ProfileYourCompanySection,
  ProfilePositionSection
};

typedef NS_ENUM(NSInteger, TextfieldTagOffset) {
    TextfieldOffsetTag = 1000000,
    CustomTextfieldTitleOffset = 1000000,
    CustomTextfieldValueOffset = 2000000,
    DetailsTextfieldTitleOffset = 3000000,
    FiguresTextfieldTitleOffset = 4000000,
};

typedef NS_ENUM(NSInteger, TaxSection) {
  TaxType,
  Tax1Rate,
  Tax1Abreviation,
  Tax2Rate,
  Tax2Abreviation,
  TaxRegNo
};

typedef NS_ENUM(NSInteger, AlertViewTag) {
  AlertViewSaveChangesTag
};

typedef NS_ENUM(NSInteger, IpadTableTag) {
  TableTitleAndCompanyTag,
  TableDetailsTag,
  TableClientAndProductsTag,
  TableOptionalInfoTag,
  TableFiguresTag,
  TableMarkAsOpenTag
};

@class TableWithShadow;
@class ScrollWithShadow;
@class ToolBarView;
@class TopBar;

@interface CustomVC : UIViewController {
  TableWithShadow * myTableView;
  ScrollWithShadow * mainScrollView;
  ToolBarView * theToolbar;
  SectionTag currentEditingSection;
  TopBar * topBarView;
  UIView * theSelfView;
  UIScrollView * ipadTablesView;
  
  UITextField *activeTextField;
  
  NSMutableDictionary *sectionSortingDict;
  
  ModuleType moduleType;
  
  int numberOfDocuments;
  
  BOOL clientSectionIsEditing;
  BOOL figureSectionIsEditing;
  BOOL detailsSectionIsEditing;
  BOOL addItemDetailsIsEditing;
  BOOL profileSectionIsEditing;
  BOOL isNewInvoice;
  
  BOOL hasChanges;
}

- (BaseOBJ *)baseObject;

- (NSData *)PDFData;

- (void)saveOBjectOnDropbox;

//iPad view methods
- (void)addIpadTableViews;
- (UITableView *)tableViewForTag:(IpadTableTag)tag;
- (UITableView *)tableViewForSection:(SectionTag)tag;
- (void)reloadTableView;
- (void)removeDelegates;
- (void)layoutTableView;
- (SectionTag)sectionTagInTable:(UITableView *)tableView section:(NSInteger)section;
- (NSInteger)sectionIndexForSectionTag:(SectionTag)tag;
- (void)layoutAllTableViewsAnimated:(BOOL)animated;

//additional methods
- (void)editSectionPressed:(UIButton *)sender;
- (void)updateCellsTypeInSection:(SectionTag)section;
- (void)setCellsEditable:(BOOL)editable inSection:(SectionTag)section;
- (kCellType)cellTypeForRow:(NSInteger)row fromCount:(NSInteger)count;

- (BOOL)allowEditingForIndexPath:(NSIndexPath *)indexPath;

- (void)parseTextFieldEditing:(UITextField *)textField;
- (NSString *)numberOfDocumentsKey;
- (void)selectYourCompanyCell;

- (BOOL)useOtherTopBar;
- (void)saveObject;
- (BOOL)isFilledIn;

//client section methods
- (void)setClientVisibility:(BOOL)visibility atIndex:(NSInteger)index;
- (kCellType)clientCellTypeForRowType:(ClientType)row;
- (kCellType)clientCellTypeForRow:(NSInteger)row;
- (NSInteger)numberOfRowsInClientSection;
- (void)saveClientSettings;

- (NSArray *)clientRowsWhenEditing:(BOOL)editing;

//figure section methods
- (void)setFigureVisibility:(BOOL)visibility atIndex:(NSInteger)index;
- (kCellType)figureCellTypeForRowType:(FigureType)row;
- (kCellType)figureCellTypeForRow:(NSInteger)row;
- (NSInteger)numberOfRowsInFigureSection;
- (void)saveFigureSettings;

- (NSArray *)figureRowsWhenEditing:(BOOL)editing;
- (NSDictionary *)figureSettingsForRow:(NSInteger)row defaultTitle:(NSString *)title;

//details section methods
- (void)setDetailsVisibility:(BOOL)visibility atIndex:(NSInteger)index;
- (kCellType)detailsCellTypeForRowType:(DetailsType)row;
- (kCellType)detailsCellTypeForRow:(NSInteger)row;
- (NSInteger)numberOfRowsInDetailsSection;
- (void)saveDetailsSettings;

- (NSArray *)detailsRowsWhenEditing:(BOOL)editing;
- (NSDictionary *)detailSettingsForType:(DetailsType)type defaultTitle:(NSString *)title;

- (void)addNewCustomDetailField;
- (DetailsType)detailTypeAtIndex:(NSInteger)index;

//details and figures title editing
- (BOOL)isCustomDetailTag:(NSInteger)tag;
- (BOOL)isCustomDetailTitleTag:(NSInteger)tag;
- (BOOL)isCustomDetailValueTag:(NSInteger)tag;
- (DetailsType)detailCustomTypeFromTag:(NSInteger)tag;

- (BOOL)isDetailTag:(NSInteger)tag;
- (DetailsType)detailTypeFromTag:(NSInteger)tag;

- (BOOL)isFigureTag:(NSInteger)tag;
- (FigureType)figureTypeFromTag:(NSInteger)tag;


@end
