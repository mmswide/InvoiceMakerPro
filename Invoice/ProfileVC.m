//
//  ProfileVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "ProfileVC.h"

#import "Defines.h"
#import "AddressVC.h"
#import "CCropImage.h"
#import "BaseTableCell.h"
#import "CellWithPush.h"
#import "CellWithEditField.h"
#import "CellWithText.h"
#import "PhotoLogoCell.h"
#import "CellWithSwitch.h"
#import "TaxEditorVC.h"


@interface ProfileVC ()
<UITextFieldDelegate,
UIScrollViewDelegate,
AlertViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
ImageCropperDelegate,
UITableViewDataSource,
UITableViewDelegate> {
  
  BOOL isNewEditingField;
}

@end

@implementation ProfileVC

-(id)init {
	self = [super init];
	
	if (self) {
		height = dvc_height - 87;
		
		if ([CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults] && [[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults] isKindOfClass:[NSDictionary class]]) {
			myCompany = [[CompanyOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults]];
		} else {
			myCompany = [[CompanyOBJ alloc] init];
						
			[CustomDefaults setCustomObjects:[myCompany contentsDictionary] forKey:kCompanyKeyForNSUserDefaults];
		}
	}
	
	return self;
}

-(void)remakeForFirstUse {
	height = dvc_height - 42;
	
	[[self.view viewWithTag:88888] removeFromSuperview];
	[(UIButton*)[self.view viewWithTag:99999] removeTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[(UIButton*)[self.view viewWithTag:99999] addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dismiss:(UIButton*)sender {
	[CustomDefaults setCustomObjects:[myCompany contentsDictionary] forKey:kCompanyKeyForNSUserDefaults];
	
  TaxEditorVC *taxVC = [[TaxEditorVC alloc] init];
  [self.navigationController pushViewController:taxVC animated:YES];
}

- (BaseOBJ *)baseObject {
  if(!_baseObject) {
    _baseObject = myCompany;
  }
  return _baseObject;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];
			
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Profile"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	BackButton * backButton = [[BackButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 70, 40) andTitle:@"Back"];
	[backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
	[backButton setTag:88888];
	[topBarView addSubview:backButton];
	
	UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 60, 42 + statusBarHeight - 40, 60, 40)];
	[done setTitle:@"Done" forState:UIControlStateNormal];
	[done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[done setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[done.titleLabel setFont:HelveticaNeueLight(17)];
	[done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
	[done setTag:99999];
	[topBarView addSubview:done];
  
  myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42) style:UITableViewStyleGrouped];
  [myTableView setDataSource:self];
  [myTableView setDelegate:self];
  myTableView.scrollEnabled = YES;
  [myTableView setBackgroundColor:[UIColor clearColor]];
  [myTableView setSeparatorColor:[UIColor clearColor]];
  [myTableView layoutIfNeeded];
  
  [theSelfView addSubview:myTableView];
  
  UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
  [bgView setBackgroundColor:[UIColor clearColor]];
  [myTableView setBackgroundView:bgView];
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
  [theToolbar.prevButton setAlpha:0.0];
  [theToolbar.nextButton setAlpha:0.0];
	[theToolbar.doneButton addTarget:self action:@selector(closeTextField:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	[self.view addSubview:topBarView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [myTableView reloadData];
}

#pragma mark - FUNCTIONS

-(void)back:(UIButton*)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)done:(UIButton*)sender {
  [CustomDefaults setCustomObjects:[myCompany contentsDictionary] forKey:kCompanyKeyForNSUserDefaults];
  if([_baseObject isKindOfClass:[CompanyOBJ class]] || _isNewDocument) {
    [[self baseObject] saveProfileSettings];
  }
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)openAddressView:(UIButton*)sender
{
	AddressVC * vc = [[AddressVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)openLogoPicker:(UIButton*)sender
{
	[activeTextField resignFirstResponder];
	
	NSMutableArray * buttons = [[NSMutableArray alloc] init];
	[buttons addObject:@"Library"];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		[buttons addObject:@"Camera"];
	}
	
	if ([myCompany logo])
	{
		[buttons addObject:@"Remove"];
	}
	
	[[[AlertView alloc] initWithTitle:@"Change LOGO Image" message:@"Select Image Source:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:buttons] showInWindow];
}

- (SectionTag)sectionTag:(NSInteger)sectionIndex {
  return sectionIndex + SectionProfile;
}

- (NSInteger)sectionIndex:(SectionTag)sectionTag {
  return MAX(sectionTag - SectionProfile, 0);
}

- (NSInteger)indexOfProfileType:(ProfileType)type {
  NSArray *detailsRows = [self profileRowsWhenEditing:profileSectionIsEditing];
  NSInteger typeIndex = 0;
  for(NSDictionary *details in detailsRows) {
    if([details[TYPE] integerValue] == type) {
      break;
    }
    typeIndex++;
  }
  return typeIndex;
}

#pragma mark - Editing section methods

- (void)setProfileVisibility:(BOOL)visibility atIndex:(NSInteger)index {
  NSMutableDictionary *profileSettings = [NSMutableDictionary dictionaryWithDictionary:[[[self baseObject] profileSettings] objectAtIndex:index]];
  [profileSettings setObject:[NSNumber numberWithBool:visibility] forKey:VISIBILITY];
  [[self baseObject] setProfileSettings:profileSettings atIndex:index];
  [self saveProfileSettings];
}

- (kCellType)profileCellTypeForRowType:(ProfileType)row {
  NSArray *profileRows = [self profileRowsWhenEditing:profileSectionIsEditing];
  NSInteger index = 0;
  for(;index < [profileRows count]; index++) {
    NSDictionary *profileSettings = profileRows[index];
    if([profileSettings[TYPE] integerValue] == row) {
      break;
    }
  }
  
  kCellType cellType = [self cellTypeForRow:index fromCount:[profileRows count] + 1];
  
  return cellType;
}

- (kCellType)profileCellTypeForRow:(NSInteger)row {
  NSArray *profileRows = [self profileRowsWhenEditing:profileSectionIsEditing];
  return [self cellTypeForRow:row fromCount:[profileRows count] + 1];
}

- (NSInteger)numberOfRowsInProfileSection {
  return [[self profileRowsWhenEditing:profileSectionIsEditing] count];
}

- (void)saveProfileSettings {
  if([_baseObject isKindOfClass:[CompanyOBJ class]] || _isNewDocument) {
    [[self baseObject] saveProfileSettings];
  }
}

- (NSArray *)profileRowsWhenEditing:(BOOL)editing {
  NSArray *profileRows = nil;
  if(profileSectionIsEditing) {
    profileRows = [[self baseObject] profileSettings];
  } else {
    profileRows = [[self baseObject] visibleRowsInProfileSection];
  }
  return profileRows;
}

- (NSDictionary *)profileSettingsForType:(ProfileType)type defaultTitle:(NSString *)title {
  NSArray *profileRows = [self profileRowsWhenEditing:profileSectionIsEditing];
  NSMutableDictionary *profileSettings = nil;
  for(NSInteger index = 0;index < [profileRows count]; index++) {
    profileSettings = profileRows[index];
    if([profileSettings[TYPE] integerValue] == type) {
      break;
    }
  }
  
  if(profileSettings[TITLE] == nil) {
    [[self baseObject] setTitle:title forProfileType:type];
    profileSettings = [NSMutableDictionary dictionaryWithDictionary:profileSettings];
    [profileSettings setObject:title forKey:TITLE];
  }
  
  return profileSettings;
}

- (void)addNewCustomProfileField {
  [[self baseObject] addCustomProfileField];
  
  NSInteger newRow = [self numberOfRowsInProfileSection];
  [myTableView beginUpdates];
  [myTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newRow - 1 inSection:ProfileYourCompanySection]] withRowAnimation:UITableViewRowAnimationFade];
  [myTableView endUpdates];
  [self saveProfileSettings];
  [myTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (ProfileType)profileTypeAtIndex:(NSInteger)index {
  NSArray *profileRows = [self profileRowsWhenEditing:profileSectionIsEditing];
  if(index < [profileRows count]) {
    NSDictionary *profileSettings = [profileRows objectAtIndex:index];
    return [profileSettings[TYPE] integerValue];
  }
  return ProfileAddNewLine;
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  return 2;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case ProfileYourCompanySection: {
      NSInteger count = [self numberOfRowsInProfileSection] + 1;
      return count;
      
      break;
    }
      
    case ProfilePositionSection: {
      return 1;
      break;
    }
      
    default:
      break;
  }
  
  return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  UITableViewCell * theCell = [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
  
  return theCell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
  [view setBackgroundColor:[UIColor clearColor]];
  
  UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, dvc_width - 44, 30)];
  [title setTextAlignment:NSTextAlignmentLeft];
  [title setTextColor:app_title_color];
  [title setFont:HelveticaNeueMedium(15)];
  [title setBackgroundColor:[UIColor clearColor]];
  [view addSubview:title];
  
  if(section == ProfileYourCompanySection) {
    NSInteger buttonWidth = 50;
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - buttonWidth, 0, buttonWidth, view.frame.size.height)];
    editButton.tag = SectionProfile;
    [editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [editButton.titleLabel setFont:HelveticaNeueLight(15)];
    [editButton setTitle:(tableView.isEditing && currentEditingSection == [self sectionTag:section])?@"Done":@"Edit" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [editButton addTarget:self action:@selector(editSectionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:editButton];
  }
  
  switch (section) {
    case ProfileYourCompanySection: {
      [title setText:@"Your company"];
      break;
    }
      
    case ProfilePositionSection: {
      [title setText:@"Position"];
      break;
    }
      
    default:
      break;
  }
  
  return view;
}

#pragma mark - TABLE VIEW DELEGATE

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return 42.0f;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  return 30.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  if(!tableView.isEditing) {
    BaseTableCell *theCell = (BaseTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [theCell animateSelection];
    
    [self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  } else {
    if(indexPath.section == ProfileYourCompanySection) {
      if([self profileTypeAtIndex:indexPath.row] != ProfileAddNewLine) {
        [self setProfileVisibility:YES atIndex:indexPath.row];
      }
    }
  }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  if(tableView.isEditing) {
    if (indexPath.section == ProfileYourCompanySection) {
      if([self profileTypeAtIndex:indexPath.row] != ProfileAddNewLine) {
        [self setProfileVisibility:NO atIndex:indexPath.row];
      }
    }
  }
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
  if(currentEditingSection >= 0) {
    BOOL isAllowedRow = indexPath.row < [self numberOfRowsInProfileSection];
    
    if (indexPath.section == [self sectionIndex:currentEditingSection] && isAllowedRow) {
      return YES;
    }
  } else {
    if(indexPath.section == ProfileYourCompanySection) {
      ProfileType type = [self profileTypeAtIndex:indexPath.row];
      return type >= ProfileCustom1 && type <= ProfileCustom5;
    }
  }
  
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  BOOL isAllowedRow = indexPath.row < [self numberOfRowsInProfileSection];
  
  if(indexPath.section == [self sectionIndex:currentEditingSection] && isAllowedRow) {
    return YES;
  }
  return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
  BOOL isAllowedRow = destinationIndexPath.row < [self numberOfRowsInProfileSection];
  
  if(sourceIndexPath.section == [self sectionIndex:currentEditingSection] &&
     destinationIndexPath.section == [self sectionIndex:currentEditingSection] &&
     isAllowedRow) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if(currentEditingSection == SectionProfile) {
        [[self baseObject] moveProfileFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
        [self saveProfileSettings];
      }
      [self updateCellsTypeInSection:[self sectionIndex:currentEditingSection]];
    });
  }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
  if (proposedDestinationIndexPath.section > ProfileYourCompanySection ||
      (proposedDestinationIndexPath.row == [self numberOfRowsInProfileSection] &&
        proposedDestinationIndexPath.section == ProfileYourCompanySection)) {
        NSUInteger newIndex = [self numberOfRowsInProfileSection] - 1;
        return [NSIndexPath indexPathForRow:newIndex inSection:[self sectionIndex:currentEditingSection]];
  }
  return proposedDestinationIndexPath;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ProfileYourCompanySection) {
    ProfileType type = [self profileTypeAtIndex:indexPath.row];
    if(type >= ProfileCustom1 && type <= ProfileCustom5) {
      UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [[self baseObject] removeCustomProfileFieldAtType:[self profileTypeAtIndex:indexPath.row]];
        [tableView reloadData];
      }];
      return @[deleteAction];
    }
  }
  
  return nil;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    if (indexPath.section == ProfileYourCompanySection) {
      [[self baseObject] removeCustomProfileFieldAtType:[self profileTypeAtIndex:indexPath.row]];
    }
    [tableView reloadData];
  }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

#pragma mark - Cell generation
-(UITableViewCell*)cellInSection:(int)section atRow:(int)row {
  switch (section) {
    case ProfileYourCompanySection: {
      NSArray *settings = [self profileRowsWhenEditing:profileSectionIsEditing];
      
      ProfileType cellType = ProfileAddNewLine;
      if([settings count] > row) {
        NSDictionary *detailsSettings = [settings objectAtIndex:row];
        cellType = [detailsSettings[TYPE] integerValue];
      }
      BaseTableCell *cell = [self yourCompanyCellAtRow:(int)cellType];
      [cell setAutolayoutForValueField];
      return cell;
    }
      break;
      
    case ProfilePositionSection:
      return [self positionCellAtRow:row];
      break;
      
    default:
      break;
  }
  return nil;
}

- (BaseTableCell *)yourCompanyCellAtRow:(NSInteger)row {
  BaseTableCell *cell = nil;

  switch (row) {
    case ProfileLogo: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPhoto"];
      
      if (!cell) {
        cell = [[PhotoLogoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPhoto"];
      }
      
      [(PhotoLogoCell *)cell loadTitle:@"Logo"
                              andValue:[myCompany logo]
                              cellType:[self profileCellTypeForRowType:row]
                               andSize:20.f];
    }
    
      break;
      
    case ProfileName: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!cell) {
        cell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText" width:myTableView.frame.size.width];
      }
      
      [(CellWithText*)cell loadTitle:@"Name"
                            andValue:[myCompany name]
                                 tag:(int)row
                   textFieldDelegate:self
                            cellType:[self profileCellTypeForRowType:row]
                     andKeyboardType:UIKeyboardTypeDefault];
      [cell makeValueBigger:YES];
      [cell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
    }
      
      break;
      
    case ProfileWebsite: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!cell) {
        cell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText" width:myTableView.frame.size.width];
      }
      
      [(CellWithText*)cell loadTitle:@"Website"
                            andValue:[myCompany website]
                                 tag:(int)row
                   textFieldDelegate:self
                            cellType:[self profileCellTypeForRowType:row]
                     andKeyboardType:UIKeyboardTypeURL];
      [cell makeValueBigger:YES];
    }
      
      break;
      
    case ProfileEmail: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!cell) {
        cell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText" width:myTableView.frame.size.width];
      }
      
      [(CellWithText*)cell loadTitle:@"Email"
                            andValue:[myCompany email]
                                 tag:(int)row
                   textFieldDelegate:self
                            cellType:[self profileCellTypeForRowType:row]
                     andKeyboardType:UIKeyboardTypeEmailAddress];
      [cell makeValueBigger:YES];
    }
      
      break;
      
    case ProfileAddress: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPushAddress"];
      
      if (!cell) {
        cell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPushAddress" width:myTableView.frame.size.width];
      }
      [(CellWithPush*)cell removeValueField];
      
      [(CellWithPush*)cell loadTitle:@"Address"
                            andValue:@""
                            cellType:[self profileCellTypeForRowType:row]
                             andSize:0];
      [cell setCanEditvalueField:NO];
    }
      
      break;
      
    case ProfilePhone: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!cell) {
        cell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText" width:myTableView.frame.size.width];
      }
      
      [(CellWithText*)cell loadTitle:@"Phone"
                            andValue:[myCompany phone]
                                 tag:(int)row
                   textFieldDelegate:self
                            cellType:[self profileCellTypeForRowType:row]
                     andKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
      [cell makeValueBigger:YES];
    }
      
      break;
      
    case ProfileMobile: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!cell) {
        cell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText" width:myTableView.frame.size.width];
      }
      
      [(CellWithText*)cell loadTitle:@"Mobile"
                            andValue:[myCompany mobile]
                                 tag:(int)row
                   textFieldDelegate:self
                            cellType:[self profileCellTypeForRowType:row]
                     andKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
      [cell makeValueBigger:YES];
    }
      
      break;
      
    case ProfileFax: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!cell) {
        cell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText" width:myTableView.frame.size.width];
      }
      
      [(CellWithText*)cell loadTitle:@"Fax"
                            andValue:[myCompany fax]
                                 tag:(int)row
                   textFieldDelegate:self
                            cellType:[self profileCellTypeForRowType:row]
                     andKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
      [cell makeValueBigger:YES];
    }
      
      break;
      
    case ProfileCustom1:
    case ProfileCustom2:
    case ProfileCustom3:
    case ProfileCustom4:
    case ProfileCustom5: {
      
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellEditField"];
      
      if (!cell) {
        cell = [[CellWithEditField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellEditField" width:myTableView.frame.size.width];
      }
      
      NSDictionary *detailsSettings = [self profileSettingsForType:row defaultTitle:@"Title"];
      
      [(CellWithEditField*)cell loadTitle:detailsSettings[TITLE]
                                      tag:(int)row
                        textFieldDelegate:self
                                 cellType:[self profileCellTypeForRowType:row]
                          andKeyboardType:UIKeyboardTypeDefault];
      
      [(CellWithEditField*)cell setValueField:detailsSettings[VALUE] tag:row + CustomTextfieldValueOffset];
      [cell setAutolayoutForValueField];
    }
      break;
      
    case ProfileAddNewLine: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellPushAddNewLine"];
      
      if (!cell) {
        cell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPushAddNewLine" width:myTableView.frame.size.width];
      }
      [(CellWithPush*)cell removeValueField];
      
      [(CellWithPush*)cell loadTitle:@"Add a new line"
                            andValue:@""
                            cellType:kCellTypeBottom andSize:20.0];
      [cell setCanEditvalueField:NO];
      [cell setUserInteractionEnabled:[[self baseObject] numberOfCustomProfileFieldsVisibleOnly:NO] < CUSTOM_FIELDS_MAX_COUNT];
    }
      break;
      
    default:
      break;
  }
  
  [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
  
  return cell;
}

- (BaseTableCell *)positionCellAtRow:(NSInteger)row {
  BaseTableCell *cell = nil;
  
  switch (row) {
    case 0: {
      cell = [myTableView dequeueReusableCellWithIdentifier:@"tableCellSwitch"];
      
      if(!cell) {
        cell = [[CellWithSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellSwitch"];
      }
      
      [(CellWithSwitch*)cell loadTitle:@"Aligned to left"
                                 andValue:[[self baseObject] companyAlignLeft]?@"YES":@""
                                 cellType:kCellTypeSingle];
      
      [(CellWithSwitch*)cell setSwitchTarget:self
                                    andSelector:@selector(positionSwitchChanged:)];
    }
      
      break;
      
    default:
      break;
  }
  
  return cell;
}

- (void)positionSwitchChanged:(UISwitch *)positionSwitch {
  [[self baseObject] setCompanyAlignLeft:positionSwitch.on];
}

#pragma mark - Cell selection

-(void)selectedCellInSection:(int)section atRow:(int)row {
  switch (section) {
    case ProfileYourCompanySection: {
      NSInteger cellType = ProfileAddNewLine;
      
      if([[self profileRowsWhenEditing:profileSectionIsEditing] count] > row) {
        NSDictionary *detailsSettings = [[self profileRowsWhenEditing:profileSectionIsEditing] objectAtIndex:row];
        cellType = [detailsSettings[TYPE] integerValue];
      }
      
      [self selectedYourCompanyAtRow:(int)cellType];
    }
      break;
      
    default:
      break;
  }
}

- (void)selectedYourCompanyAtRow:(int)row {
  switch (row) {
    case ProfileLogo: {
      [self closeTextField:nil];
      [self openLogoPicker:nil];
    }
      
      break;
      
    case ProfileName:
      
      break;
      
    case ProfileWebsite:
      
      break;
      
    case ProfileEmail:
      
      break;
      
    case ProfileAddress: {
      [self closeTextField:nil];
      [self openAddressView:nil];
    }
      
      break;
      
    case ProfilePhone:
      
      break;
      
    case ProfileMobile:
      
      break;
      
    case ProfileFax:
      
      break;
      
    case ProfileCustom1:
    case ProfileCustom2:
    case ProfileCustom3:
    case ProfileCustom4:
    case ProfileCustom5: {
      
    }
      break;
      
    case ProfileAddNewLine: {
      [self addNewCustomProfileField];
    }
      break;
      
    default:
      break;
  }
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0)
		return;
	
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	[picker setDelegate:self];
	
	if (buttonIndex == 1) {
		[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	} else if (buttonIndex == 2 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[picker setSourceType:UIImagePickerControllerSourceTypeCamera];
	} else {
		[myCompany setLogo:nil];
    [myTableView reloadData];
		return;
	}
	
	if (iPad) {
		popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
		[popOver presentPopoverFromRect:CGRectMake(dvc_width - 80, 8 * 43, 38, 38) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self.navigationController presentViewController:picker animated:YES completion:nil];
	}
}

#pragma mark - IMAGE PICKER DELEGATE

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
	dispatch_async(dispatch_get_main_queue(), ^{
		[DELEGATE addLoadingView];
	});
	
	float delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		UIImage * selectedImage = [[UIImage alloc] initWithData:UIImagePNGRepresentation([data_manager scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage] andResolution:640])];
		
		CCropImage * cropper = [[CCropImage alloc] initWithFrame:CGRectMake(0, 20, dvc_width, dvc_height) imageData:UIImageJPEGRepresentation(selectedImage, 1.0f) andTag:0.0];
		[cropper setDelegate:self];
		[self.navigationController.view addSubview:cropper];
		
		if (iPad) {
			[popOver dismissPopoverAnimated:YES];
		} else {
			[picker dismissViewControllerAnimated:YES completion:nil];
		}
		
		[DELEGATE removeLoadingView];
	});
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
  [myTableView reloadData];
}

#pragma mark - IMAGE CROPPER DELEGATE

-(void)cropperDidCropImage:(UIImage*)image {
	[myCompany setLogo:image];
  [myTableView reloadData];
}

#pragma mark - TEXT FIELD DELEGATE

-(void)nextTextField:(UIButton*)sender {

}

-(void)prevTextField:(UIButton*)sender {

}

-(void)closeTextField:(UIButton*)sender {
  isNewEditingField = NO;
  [activeTextField resignFirstResponder];
  activeTextField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
  isNewEditingField = NO;
	[textField resignFirstResponder];
	
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField {
  if(!isNewEditingField) {
    [UIView animateWithDuration:0.25 animations:^{
      [theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
      [myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 42)];
    }];
  }
	
	return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
	[theToolbar.doneButton setTag:textField.tag];
  
  isNewEditingField = NO;
  if(activeTextField) {
    isNewEditingField = YES;
  }
	
	[UIView animateWithDuration:0.25 animations:^{
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
    [myTableView setFrame:CGRectMake(myTableView.frame.origin.x,
                                     myTableView.frame.origin.y,
                                     dvc_width,
                                     dvc_height - 82 - keyboard_height)];
	}completion:^(BOOL finished) {
    ProfileType type = textField.tag < CustomTextfieldValueOffset?textField.tag:textField.tag - CustomTextfieldValueOffset;
    NSIndexPath *descriptionIP = [NSIndexPath indexPathForRow:[self indexOfProfileType:type] inSection:0];
    [myTableView scrollToRowAtIndexPath:descriptionIP atScrollPosition:UITableViewScrollPositionNone animated:YES];
  }];
	
	return YES;
}



-(void)textFieldDidBeginEditing:(UITextField*)textField {
  activeTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField*)textField {
  if(textField.tag >= CustomTextfieldValueOffset) {
    [[self baseObject] setValue:textField.text forProfileType:textField.tag - CustomTextfieldValueOffset];
  } else {
    switch (textField.tag) {
      case ProfileName:
        [myCompany setName:textField.text];
        break;
        
      case ProfileWebsite:
        [myCompany setWebsite:textField.text];
        break;
        
      case ProfileEmail:
        [myCompany setEmail:textField.text];
        break;
        
      case ProfilePhone:
        [myCompany setPhone:textField.text];
        break;
        
      case ProfileMobile:
        [myCompany setMobile:textField.text];
        break;
        
      case ProfileFax:
        [myCompany setFax:textField.text];
        break;
        
      case ProfileCustom1:
      case ProfileCustom2:
      case ProfileCustom3:
      case ProfileCustom4:
      case ProfileCustom5: {
        [[self baseObject] setTitle:textField.text forProfileType:textField.tag];
      }
        break;
        
      default:
        break;
    }
  }
  
  if(!isNewEditingField) {
    activeTextField = nil;
    if(!myTableView.editing) {
      [myTableView reloadData];
    }
  }
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end