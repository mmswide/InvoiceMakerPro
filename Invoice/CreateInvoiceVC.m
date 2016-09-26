 //
//  CreateInvoiceVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/15/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "CreateInvoiceVC.h"

#import "Defines.h"
#import "CellWithPicker.h"
#import "CellWithPush.h"
#import "CellWithText.h"
#import "ClientsVC.h"
#import "AddNoteVC.h"
#import "SelectProjectVC.h"
#import "CellWithCheck.h"
#import "CellWithEditField.h"
#import "ProfileVC.h"
#import "AddClientAddressVC.h"


@interface CreateInvoiceVC ()

<UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
AlertViewDelegate,
SignatureAndDateCreatorDelegate,
AddItemDelegate,
AddClientAddressVCDelegate>

@end

@implementation CreateInvoiceVC

@synthesize delegate;

-(id)initForCreationWithDelegate:(id<InvoiceCreatorDelegate>)del {
	self = [super init];
	
	if (self) {
		delegate = del;
	}
	
	return self;
}

-(id)initWithInvoice:(InvoiceOBJ*)sender delegate:(id<InvoiceCreatorDelegate>)del {
	self = [super init];
	
	if (self) {
		delegate = del;
		theInvoice = [[InvoiceOBJ alloc] initWithInvoice:sender];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad {
	[super viewDidLoad];
  
  moduleType = ModuleInvoiceType;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
  isNewInvoice = NO;
	if (!theInvoice) {
    [topBarView setText:@"New Invoice"];
  
    theInvoice = [[InvoiceOBJ alloc] init];
    isNewInvoice = YES;
  } else {
    [topBarView setText:@"Edit Invoice"];
  }

  [theInvoice removeTermsRowInInvoiceSection];
  [theInvoice addProjectFieldsToDetails];
	
  if(isNewInvoice) {
    NSString *pref = [InvoiceDefaults invoicePref];
    if ([[theInvoice number] isEqual:[NSString stringWithFormat:@"%@00001", pref]]) {
      numberOfDocuments = (int)[CustomDefaults customIntegerForKey:kNumberOfInvoicesKeyForNSUserDefaults];
      [theInvoice setNumber:numberOfDocuments];
      [theInvoice setStringNumber:[theInvoice number]];
      numberOfDocuments++;
    }
  }
	
  if(iPad) {
    [self addIpadTableViews];
  } else {
    myTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 42) style:UITableViewStyleGrouped];
    [myTableView setDataSource:self];
    [myTableView setDelegate:self];
    [myTableView setBackgroundColor:[UIColor clearColor]];
    [myTableView setSeparatorColor:[UIColor clearColor]];
    [myTableView layoutIfNeeded];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 42)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [myTableView setBackgroundView:bgView];
    
    [theSelfView addSubview:myTableView];
  }
	
	theToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[theToolbar.prevButton setAlpha:0.0];
	[theToolbar.nextButton setAlpha:0.0];
	[theToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[theSelfView addSubview:theToolbar];
	
	percentage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	[percentage setTitle:[NSString stringWithFormat:@"%c", '%'] forState:UIControlStateNormal];
	[percentage setTitleColor:app_tab_selected_color forState:UIControlStateSelected];
	[percentage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[percentage.titleLabel setFont:HelveticaNeueLight(17)];
	[percentage addTarget:self action:@selector(percentage:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar addSubview:percentage];
	
	value = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
	[value setTitle:[NSString stringWithFormat:@"%c", '$'] forState:UIControlStateNormal];
	[value setTitleColor:app_tab_selected_color forState:UIControlStateSelected];
	[value setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[value.titleLabel setFont:HelveticaNeueLight(17)];
	[value setSelected:YES];
	[value addTarget:self action:@selector(value:) forControlEvents:UIControlEventTouchUpInside];
	[theToolbar addSubview:value];
	
	[self hidePercentageAndValue];
	
	[self.view addSubview:topBarView];
  
  openedInvoice = [[InvoiceOBJ alloc] initWithInvoice:theInvoice];
}

#pragma mark - FUNCTIONS

- (BOOL)isFilledIn {
    NSString * message = @"";
    
    if ([[theInvoice client] contentsDictionary].count == 0) {
        message = @"Please select a client.";
    }
    
    if ([theInvoice products].count == 0 && [message isEqual:@""]) {
        message = @"Please select at least one product or service.";
    }
    
    if (![message isEqual:@""]) {
        [[[AlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
        return NO;
    }
    
    return YES;
}

-(void)cancel:(UIButton*)sender {
  if(![theInvoice isEqualToObject:openedInvoice] || hasChanges) {
    AlertView *alertView = [[AlertView alloc] initWithTitle:@"" message:@"Would you like to save?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]];
    alertView.tag = AlertViewSaveChangesTag;
    [alertView showInWindow];
  } else {
    [theInvoice removeTempSignatures];
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

-(void)done:(UIButton*)sender {
  [activeTextField resignFirstResponder];
  
  if([self isFilledIn]) {
    if ([delegate respondsToSelector:@selector(creatorViewController:createdInvoice:)]) {
      [delegate creatorViewController:self createdInvoice:theInvoice];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

-(void)showPercentageAndValue {
	[percentage setAlpha:1.0];
	[value setAlpha:1.0];
}

-(void)hidePercentageAndValue {
	[percentage setAlpha:0.0];
	[value setAlpha:0.0];
}

-(void)percentage:(UIButton*)sender {
	[percentage setSelected:YES];
	[value setSelected:NO];
}

-(void)value:(UIButton*)sender {
	[percentage setSelected:NO];
	[value setSelected:YES];
}

- (BaseOBJ *)baseObject {
    return theInvoice;
}

- (BOOL)useOtherTopBar {
    return NO;
}

- (void)saveObject {
  [super saveObject];
  [self done:nil];
}

- (NSString *)numberOfDocumentsKey {
  return kNumberOfInvoicesKeyForNSUserDefaults;
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
  if(iPad) {
    switch (tableView.tag) {
      case TableTitleAndCompanyTag:
        return 2;
        break;
        
        case TableDetailsTag:
        return 1;
        break;
        
        case TableClientAndProductsTag:
        return 2;
        break;
        
        case TableOptionalInfoTag:
        return 1;
        break;
        
        case TableFiguresTag:
        return 1;
        break;
        
        case TableMarkAsOpenTag:
        return 1;
        break;
        
      default:
        break;
    }
    return 0;
  } else {
    return 8;
  }
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:section];
  
	switch (convertedSection) {
		case SectionTitle: {
			return 1;
			
			break;
		}
      
    case SectionYourCompany: {
      return 1;
      
      break;
    }
			
		case SectionDetails: {
			return [self numberOfRowsInDetailsSection] + 1;
			
			break;
		}
            
    case SectionClient: {
        return [self numberOfRowsInClientSection];
        break;
    }
						
		case SectionProductsAndServices: {
			return [[theInvoice products] count] + 1;
			
			break;
		}
			
		case SectionFigure: {
			return [self numberOfRowsInFigureSection];
			break;
		}

		case SectionOptionalInfo: {
			return 4;
			break;
		}
			
		case SectionMarcAsOpen: {
			return 1;
			break;
		}
			
		default:
			break;
	}
	
	return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];
  
	UITableViewCell * theCell = [self cellInSection:(int)convertedSection atRow:(int)indexPath.row];
	
	return theCell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:section];
  if(convertedSection == SectionMarcAsOpen) return nil;
  
	UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
	[view setBackgroundColor:[UIColor clearColor]];
	
	UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, tableView.frame.size.width - 44, 30)];
	[title setTextAlignment:NSTextAlignmentLeft];
	[title setTextColor:app_title_color];
	[title setFont:HelveticaNeueMedium(15)];
	[title setBackgroundColor:[UIColor clearColor]];
	[view addSubview:title];
  
  if(convertedSection == SectionProductsAndServices || convertedSection == SectionFigure || convertedSection == SectionDetails || convertedSection == SectionClient) {
      NSInteger buttonWidth = 50;
      UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width - buttonWidth, 0, buttonWidth, view.frame.size.height)];
      editButton.tag = convertedSection;
      [editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
      [editButton.titleLabel setFont:HelveticaNeueLight(15)];
      [editButton setTitle:(tableView.isEditing && currentEditingSection == convertedSection)?@"Done":@"Edit" forState:UIControlStateNormal];
      [editButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
      [editButton addTarget:self action:@selector(editSectionPressed:) forControlEvents:UIControlEventTouchUpInside];
      [view addSubview:editButton];
  }
	
	switch (convertedSection) {
		case SectionTitle: {
			[title setText:@"Title"];
			break;
		}
      
    case SectionYourCompany: {
      [title setText:@"Your company"];
      break;
    }
			
		case SectionDetails: {
			[title setText:@"Details"];
			break;
		}
		
    case SectionClient: {
        [title setText:@"Client"];
        break;
    }
      
		case SectionProductsAndServices: {
			[title setText:@"Products and Services"];
			break;
		}
			
		case SectionFigure: {
			[title setText:@"Figures"];
			break;
		}
			
		case SectionOptionalInfo: {
			[title setText:@"Optional Info"];
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
  if([self sectionTagInTable:tableView section:section] == SectionMarcAsOpen) {
    return 0;
  }
	return 30.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];
  
  if(!tableView.isEditing) {
      BaseTableCell *theCell = (BaseTableCell *)[tableView cellForRowAtIndexPath:indexPath];
      [theCell animateSelection];

      [self selectedCellInSection:(int)convertedSection atRow:(int)indexPath.row];
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
  } else {
    if (convertedSection == SectionClient) {
      if(indexPath.row != ClientAddClient) {
        [self setClientVisibility:YES atIndex:indexPath.row];
      }
    } else if(convertedSection == SectionFigure) {
      [self setFigureVisibility:YES atIndex:indexPath.row];
    } else if (convertedSection == SectionDetails) {
      if([self detailTypeAtIndex:indexPath.row] != DetailAddNewLine) {
        [self setDetailsVisibility:YES atIndex:indexPath.row];
      }
    }
  }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];
  
  if(tableView.isEditing) {
    if (convertedSection == SectionClient) {
      if(indexPath.row != ClientAddClient) {
        [self setClientVisibility:NO atIndex:indexPath.row];
      }
    } else if(convertedSection == SectionFigure) {
        [self setFigureVisibility:NO atIndex:indexPath.row];
    } else if (convertedSection == SectionDetails) {
        if([self detailTypeAtIndex:indexPath.row] != DetailAddNewLine) {
            [self setDetailsVisibility:NO atIndex:indexPath.row];
        }
    }
  }
}

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];

  if(currentEditingSection >= 0) {
      BOOL isAllowedRow = [self allowEditingForIndexPath:indexPath];
      
      if (convertedSection == currentEditingSection && isAllowedRow) {
          return YES;
      }
  } else {
      if(convertedSection == SectionDetails) {
          DetailsType type = [self detailTypeAtIndex:indexPath.row];
          return type >= DetailCustom1 && type <= DetailCustom5;
      } else if(convertedSection == SectionProductsAndServices) {
          return indexPath.row < [[theInvoice products] count];
      }
  }
	
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];

  BOOL isAllowedRow = [self allowEditingForIndexPath:indexPath];
  
  if(convertedSection == currentEditingSection && isAllowedRow) {
      return YES;
  }
  return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
  SectionTag convertedSourceSection = [self sectionTagInTable:tableView section:sourceIndexPath.section];
  SectionTag convertedDestinationSection = [self sectionTagInTable:tableView section:destinationIndexPath.section];
  
  BOOL isAllowedRow = [self allowEditingForIndexPath:destinationIndexPath];
  
  if(convertedSourceSection == currentEditingSection &&
     convertedDestinationSection == currentEditingSection &&
     isAllowedRow) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        if(currentEditingSection == SectionClient) {
          [theInvoice moveClientFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
          [self saveClientSettings];
        } else if(currentEditingSection == SectionDetails) {
          [theInvoice moveDetailFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
          [self saveDetailsSettings];
        } else if(currentEditingSection == SectionProductsAndServices) {
          [theInvoice moveProductFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
        } else if (currentEditingSection == SectionFigure) {
          [theInvoice moveFigureFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
          [self saveFigureSettings];
        }
        [self updateCellsTypeInSection:currentEditingSection];
      });
  }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
  
  SectionTag convertedproposedSection = [self sectionTagInTable:tableView section:proposedDestinationIndexPath.section];
  
  if(convertedproposedSection < currentEditingSection) {
    NSInteger firstRow = currentEditingSection == SectionClient?1:0;
      return [NSIndexPath indexPathForRow:firstRow inSection:currentEditingSection];
  } else if (convertedproposedSection > currentEditingSection ||
             (convertedproposedSection == SectionProductsAndServices &&
              proposedDestinationIndexPath.row == [[theInvoice products] count]) ||
             (proposedDestinationIndexPath.row == [self numberOfRowsInDetailsSection] &&
              convertedproposedSection == SectionDetails) ||
             (convertedproposedSection == SectionClient &&
              proposedDestinationIndexPath.row == 0)) {
                 NSUInteger newIndex = 0;
               if(currentEditingSection == SectionClient) {
                 newIndex = 1;
               }
               if(currentEditingSection == SectionDetails) {
                  newIndex = [self numberOfRowsInDetailsSection] - 1;
               } else if (currentEditingSection == SectionProductsAndServices) {
                   newIndex = [[theInvoice products] count];
               } else if (currentEditingSection == SectionFigure) {
                   newIndex = [self numberOfRowsInFigureSection] - 1;
               }
               
               NSInteger realSection = [self sectionIndexForSectionTag:currentEditingSection];
              return [NSIndexPath indexPathForRow:newIndex inSection:realSection];
  }
  return proposedDestinationIndexPath;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];
  
    if(convertedSection == SectionProductsAndServices) {
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[theInvoice products]];
            [temp removeObjectAtIndex:indexPath.row];
            [theInvoice setProducts:temp];
            [tableView reloadData];
            
            [sync_manager updateCloud:[theInvoice contentsDictionary] andPurposeForDelete:0];
        }];
        return @[deleteAction];
    } else if (convertedSection == SectionDetails) {
        DetailsType type = [self detailTypeAtIndex:indexPath.row];
        if(type >= DetailCustom1 && type <= DetailCustom5) {
            UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                [theInvoice removeCustomDetailFieldAtType:[self detailTypeAtIndex:indexPath.row]];
                
                [tableView reloadData];
                
                [sync_manager updateCloud:[theInvoice contentsDictionary] andPurposeForDelete:0];
            }];
            return @[deleteAction];
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
  SectionTag convertedSection = [self sectionTagInTable:tableView section:indexPath.section];
  
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(convertedSection == SectionProductsAndServices) {
            NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:[theInvoice products]];
            [temp removeObjectAtIndex:indexPath.row];
            [theInvoice setProducts:temp];
        } else if (convertedSection == SectionDetails) {
            [theInvoice removeCustomDetailFieldAtType:[self detailTypeAtIndex:indexPath.row]];
        }
        
		[tableView reloadData];
		
		[sync_manager updateCloud:[theInvoice contentsDictionary] andPurposeForDelete:0];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row {
	switch (section) {
		case SectionTitle: {
			return [self titleCellAtRow:row];
			break;
		}
    
    case SectionYourCompany: {
      return [self yourCompanyCellAtRow:row];
      break;
    }
      
    case SectionClient: {
      NSDictionary *clientettings = [[self clientRowsWhenEditing:clientSectionIsEditing] objectAtIndex:row];
      
      NSInteger cellType = [clientettings[TYPE] integerValue];
      BaseTableCell *cell = [self clientCellAtRow:(int)cellType];
      
//      [cell setAutolayoutForValueField];
      
      return cell;
      break;
    }
      
		case SectionDetails: {
        NSArray *settings = [self detailsRowsWhenEditing:detailsSectionIsEditing];
        
        NSInteger cellType = DetailAddNewLine;
        if([settings count] > row) {
            NSDictionary *detailsSettings = [settings objectAtIndex:row];
            cellType = [detailsSettings[TYPE] integerValue];
        }
        BaseTableCell *cell = [self detailedeCellAtRow:(int)cellType];
        [cell setAutolayoutForValueField];
      
			return cell;
			break;
		}
						
		case SectionProductsAndServices: {
            return [self productCellAtRow:row];;
			break;
		}
			
		case SectionFigure: {
      NSDictionary *figureSettings = [[self figureRowsWhenEditing:figureSectionIsEditing] objectAtIndex:row];
      
      NSInteger cellType = [figureSettings[TYPE] integerValue];
      BaseTableCell *cell = [self valuesCellAtRow:(int)cellType];

      [cell setAutolayoutForValueField];
			return cell;
			break;
		}
			
		case SectionOptionalInfo: {
			return [self otherCellAtRow:row];
			break;
		}
			
		case SectionMarcAsOpen: {
			return [self markAsPaidCell];
			break;
		}
			
		default:
			break;
	}
	
	return nil;
}

-(UITableViewCell*)titleCellAtRow:(int)row {
	UITableViewCell * theCell;
	
  UITableView *titleTable = [self tableViewForSection:SectionTitle];
	switch (row) {
		case 0: {
			theCell = [titleTable dequeueReusableCellWithIdentifier:@"tableCellEditField1"];
			
			if (!theCell) {
				theCell = [[CellWithEditField alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"tableCellEditField1"
                                                     width:titleTable.frame.size.width];
			}
			
      [(CellWithEditField*)theCell loadTitle:[theInvoice title] tag:TITLE_CELL_TAG textFieldDelegate:self cellType:kCellTypeSingle andKeyboardType:UIKeyboardTypeDefault];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
	}
	
	return theCell;
}

- (UITableViewCell *)yourCompanyCellAtRow:(int)row {
  CellWithPush * theCell;
  UITableView *yourCompanyTable = [self tableViewForSection:SectionYourCompany];
  
  switch (row) {
    case 0: {
      theCell = [yourCompanyTable dequeueReusableCellWithIdentifier:@"tableYourCompanyCell"];
      
      if (!theCell) {
        theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableYourCompanyCell"
                                                width:yourCompanyTable.frame.size.width];
        [theCell makeValueBigger:YES];
      }
      
      CompanyOBJ *myCompany = [[CompanyOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults]];
      [theCell loadTitle:@"Name" andValue:[myCompany name] cellType:kCellTypeSingle andSize:0];
      [theCell setValueDelegate:self tag:MY_COMPANY_CELL_TAG keyboardType:UIKeyboardTypeDefault];
      [theCell addAccessoryTarget:self action:@selector(selectYourCompanyCell)];
      [theCell setValueEditable:YES];
      [theCell setUserInteractionEnabled:YES];
      [theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
      
      break;
    }
  }
  
  return theCell;
}

-(BaseTableCell*)detailedeCellAtRow:(int)row {
	BaseTableCell * theCell;
  UITableView *detailTable = [self tableViewForSection:SectionDetails];
	
//    if(row == [self numberOfRowsInDetailsSection]) {
//        row = DetailAddNewLine;
//    }
    
	switch (row) {
		case DetailProjNumber: {
			theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellText"
                                                width:detailTable.frame.size.width];
			}
			
			NSString * valueSTR = [theInvoice number];
            
			[(CellWithText*)theCell loadTitle:[theInvoice detailTitleForType:row] andValue:valueSTR tag:555 textFieldDelegate:self cellType:[self detailsCellTypeForRowType:row] andKeyboardType:UIKeyboardTypeDefault];
            [theCell setIsTitleEditable:YES delegate:self tag:DetailsTextfieldTitleOffset + row];
			
			break;
		}
			
		case DetailDate: {
			theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellPicker"
                                                  width:detailTable.frame.size.width];
			}
            
			[(CellWithPicker*)theCell loadTitle:[theInvoice detailTitleForType:row] andValue:[theInvoice date] cellType:[self detailsCellTypeForRowType:row]];
      [theCell setIsTitleEditable:YES delegate:self tag:DetailsTextfieldTitleOffset + row];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case DetailDueDate: {
			theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellPicker"
                                                  width:detailTable.frame.size.width];
			}
            
			if ([[theInvoice dueDate] isEqual:@"01/01/70"]) {
				[(CellWithPicker*)theCell loadTitle:[theInvoice detailTitleForType:row] andValue:@"Due on receipt" cellType:[self detailsCellTypeForRowType:row]];
			} else {
				[(CellWithPicker*)theCell loadTitle:[theInvoice detailTitleForType:row] andValue:[theInvoice dueDate] cellType:[self detailsCellTypeForRowType:row]];
			}
			
      [theCell setIsTitleEditable:YES delegate:self tag:DetailsTextfieldTitleOffset + row];
      
			break;
		}
						
		case DetailTerms: {
			theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellPicker"
                                                  width:detailTable.frame.size.width];
			}
            
			[(CellWithPicker*)theCell loadTitle:[theInvoice detailTitleForType:row] andValue:[TermsManager termsString:[theInvoice terms]] cellType:[self detailsCellTypeForRowType:row]];
            [theCell setIsTitleEditable:YES delegate:self tag:DetailsTextfieldTitleOffset + row];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
            
    case DetailCustom1:
    case DetailCustom2:
    case DetailCustom3:
    case DetailCustom4:
    case DetailCustom5: {
        
      theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellEditField"];
      
      if (!theCell) {
        theCell = [[CellWithEditField alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"tableCellEditField"
                                                     width:detailTable.frame.size.width];
      }
      
      NSDictionary *detailsSettings = [self detailSettingsForType:row defaultTitle:@"Title"];
      
      [(CellWithEditField*)theCell loadTitle:detailsSettings[TITLE]
                                         tag:row + CustomTextfieldTitleOffset
                           textFieldDelegate:self
                                    cellType:[self detailsCellTypeForRowType:row]
                             andKeyboardType:UIKeyboardTypeDefault];
      
      [(CellWithEditField*)theCell setValueField:detailsSettings[VALUE] tag:row + CustomTextfieldValueOffset];
          [theCell setAutolayoutForValueField];
      break;
    }
      
    case DetailProjectName: {
      theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellPushProj"];
      
      if(!theCell) {
        theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPushProj"
                                                width:detailTable.frame.size.width];
      }
      
      [(CellWithPush*)theCell loadTitle:@"Project Name" andValue:[[theInvoice project] projectName] cellType:[self detailsCellTypeForRowType:row] andSize:20.0];
      theCell.canEditvalueField = NO;
      
      break;
    }
      
    case DetailProjectNo: {
      theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellPushProj"];
      
      if(!theCell) {
        theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPushProj"
                                                width:detailTable.frame.size.width];
      }
      
      [(CellWithPush*)theCell loadTitle:@"Project No." andValue:[[theInvoice project] projectNumber] cellType:[self detailsCellTypeForRowType:row] andSize:20.0];
      theCell.canEditvalueField = NO;
      
      break;
    }
      
    case DetailAddNewLine: {
        
      theCell = [detailTable dequeueReusableCellWithIdentifier:@"tableCellPushAddNewLine"];
      
      if (!theCell) {
          theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellPushAddNewLine"
                                                  width:detailTable.frame.size.width];
      }
      [(CellWithPush*)theCell removeValueField];
      theCell.isTitleEditable = NO;
      
      kCellType type = kCellTypeBottom;
      if ([[theInvoice visibleRowsInDetailsSection] count] == 0)
        type = kCellTypeSingle;
      
        [(CellWithPush*)theCell loadTitle:@"Add a new line" andValue:@"" cellType:type andSize:20.0];
        [theCell setCanEditvalueField:NO];
        [theCell setUserInteractionEnabled:[theInvoice numberOfCustomDetailFieldsVisibleOnly:NO] < CUSTOM_FIELDS_MAX_COUNT];
        
        break;
    }
			
		default:
			break;
	}
	
  [theCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return theCell;
}

- (BaseTableCell *)clientCellAtRow:(int)row {
  BaseTableCell * theCell;
  UITableView *clientTable = [self tableViewForSection:SectionClient];
  
  switch (row) {
    case ClientAddClient: {
      theCell = [clientTable dequeueReusableCellWithIdentifier:@"tableCellPushClient"];
      
      if (!theCell) {
        theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPushClient"
                                                width:clientTable.frame.size.width];
      }
      
      ClientOBJ * theClient = [theInvoice client];
      NSString * name = [theClient firstName];
      
      [(CellWithPush*)theCell loadTitle:@"Client"
                               andValue:name
                               cellType:[self clientCellTypeForRowType:row]
                                andSize:20.0];
      [theCell setValueDelegate:self
                            tag:CLIENT_NAME_CELL_TAG
                   keyboardType:UIKeyboardTypeDefault];
      [(CellWithPush*)theCell addAccessoryTarget:self action:@selector(showClientScreen)];
      
      [(CellWithPush*)theCell setValueEditable:YES];
      [theCell makeValueBigger:YES];
      [theCell setValuePlaceholder:@"Enter client name"];
      [theCell setUserInteractionEnabled:YES];
    }
      break;
      
    case ClientBilling: {
      theCell = [clientTable dequeueReusableCellWithIdentifier:@"tableCellPushArrow"];
      
      if (!theCell) {
        theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPushArrow"
                                                width:clientTable.frame.size.width];
      }
      
      ClientOBJ * theClient = [theInvoice client];
      [(CellWithPush*)theCell loadTitle:[[theClient billingAddress] billingTitle]
                               andValue:@""
                               cellType:[self clientCellTypeForRowType:row]
                                andSize:0.0];
      [theCell makeTitleBigger:YES];
      theCell.canEditvalueField = NO;
      theCell.isTitleEditable = NO;
      [theCell setUserInteractionEnabled:YES];
    }
      break;
      
    case ClientShipping: {
      theCell = [clientTable dequeueReusableCellWithIdentifier:@"tableCellPushArrow"];
      
      if (!theCell) {
        theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPushArrow"
                                                width:clientTable.frame.size.width];
      }
      
      ClientOBJ * theClient = [theInvoice client];
      [(CellWithPush*)theCell loadTitle:[[theClient shippingAddress] shippingTitle]
                               andValue:@""
                               cellType:[self clientCellTypeForRowType:row]
                                andSize:0.0];
      [theCell makeTitleBigger:YES];
      theCell.canEditvalueField = NO;
      theCell.isTitleEditable = NO;
      [theCell setUserInteractionEnabled:YES];
    }
      break;
      
    default:
      break;
  }
  
  [theCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
  return theCell;
}

-(UITableViewCell*)productCellAtRow:(int)row {
	BaseTableCell * theCell;
  UITableView *productTable = [self tableViewForSection:SectionProductsAndServices];
	
	if (row < [[theInvoice products] count]) {
        theCell = [productTable dequeueReusableCellWithIdentifier:@"tableCellText"];
        
        if (!theCell) {
            theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"tableCellText"
                                                    width:productTable.frame.size.width];
        }
			
		kCellType type = kCellTypeMiddle;
		
		if (row == 0)
			type = kCellTypeTop;
		
		NSDictionary * dict = [[theInvoice products] objectAtIndex:row];
		
		NSString * classString = [dict objectForKey:@"class"];
		
		if (NSClassFromString(classString) == [ProductOBJ class]) {
			ProductOBJ * theProduct = [[ProductOBJ alloc] initWithContentsDictionary:[[theInvoice products] objectAtIndex:row]];
			[(CellWithText*)theCell loadTitle:[theProduct name] andValue:[data_manager currencyAdjustedValue:[theProduct total]] tag:0 textFieldDelegate:nil cellType:type andKeyboardType:UIKeyboardTypeDefault];
		} else {
			ServiceOBJ * theService = [[ServiceOBJ alloc] initWithContentsDictionary:[[theInvoice products] objectAtIndex:row]];
			[(CellWithText*)theCell loadTitle:[theService name] andValue:[data_manager currencyAdjustedValue:[theService total]] tag:0 textFieldDelegate:nil cellType:type andKeyboardType:UIKeyboardTypeDefault];
		}
		
		[theCell setUserInteractionEnabled:YES];
		[(CellWithText*)theCell setTextFieldEditable:NO];
        [(CellWithText*)theCell setTitleEditableLayout];

	} else {
		theCell = [productTable dequeueReusableCellWithIdentifier:@"tableCellPush"];
		
		if (!theCell) {
			theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:@"tableCellPush"
                                              width:productTable.frame.size.width];
		}
		
		kCellType type = kCellTypeBottom;
		
		if (row == 0)
			type = kCellTypeSingle;
		
		[(CellWithPush*)theCell loadTitle:@"Add Product" andValue:@"" cellType:type andSize:20.0];
    [(CellWithPush*)theCell setValueEditable:NO];
		[theCell setUserInteractionEnabled:YES];
	}
    
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

-(UITableViewCell*)valuesCellAtRow:(int)row {
	BaseTableCell * theCell;
  UITableView *valuesTable = [self tableViewForSection:SectionFigure];

	switch (row) {
		case FigureSubtotal: {
			theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellText"
                                                width:valuesTable.frame.size.width];
			}
			
			[(CellWithText*)theCell loadTitle:[theInvoice figureTitleForType:row] andValue:[data_manager currencyAdjustedValue:[theInvoice subtotal]] tag:0 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureSubtotal] andKeyboardType:UIKeyboardTypeDefault];
			[theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:NO];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
      //111111
			
			break;
		}

		case FigureDiscount: {
			theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellText"
                                                width:valuesTable.frame.size.width];
			}
			
            //[NSString stringWithFormat:@"Discount (%.2f%c)", [theInvoice discountPercentage], '%']
			[(CellWithText*)theCell loadTitle:[theInvoice figureTitleForType:row]
							 andValue:[data_manager currencyAdjustedValue:[theInvoice discount]] tag:111 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureDiscount] andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:YES];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
			
			break;
		}
			
		case FigureTax1: {
      theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
              
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellText"
                                                width:valuesTable.frame.size.width];
      }
      
      NSString * title = [NSString stringWithFormat:@"%@ (%.2f%c)", [theInvoice tax1Name], [theInvoice tax1Percentage], '%'];
      
      NSString * val = [data_manager currencyAdjustedValue:[theInvoice tax1Value]];
      
      [(CellWithText*)theCell loadTitle:title andValue:val tag:0 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureTax1] andKeyboardType:UIKeyboardTypeDefault];
      [theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:NO];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
      //111111
			
			break;
		}
			
		case FigureTax2: {
      theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
  
      if (!theCell) {
          theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellText"
                                                  width:valuesTable.frame.size.width];
      }
      
      NSString * title = [NSString stringWithFormat:@"%@ (%.2f%c)", [theInvoice tax2Name], [theInvoice tax2Percentage], '%'];
      
      NSString * val = [data_manager currencyAdjustedValue:[theInvoice tax2Value]];
      
      [(CellWithText*)theCell loadTitle:title andValue:val tag:0 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureTax2] andKeyboardType:UIKeyboardTypeDefault];
      [theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:NO];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
      //111111

			break;
		}
			
		case FigureShipping: {
      theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
          theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellText"
                                                  width:valuesTable.frame.size.width];
      }
      
      [(CellWithText*)theCell loadTitle:[theInvoice figureTitleForType:row] andValue:[data_manager currencyAdjustedValue:[theInvoice shippingValue]]
                          tag:222 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureShipping] andKeyboardType:UIKeyboardTypeDecimalPad];
      [theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:YES];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
      
			break;
		}
			
		case FigureTotal: {
      theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
          theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellText"
                                                  width:valuesTable.frame.size.width];
      }
      
      [(CellWithText*)theCell loadTitle:[theInvoice figureTitleForType:row] andValue:[data_manager currencyAdjustedValue:[theInvoice total]] tag:0 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureTotal] andKeyboardType:UIKeyboardTypeDefault];
      [theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:NO];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
      //111111
		
			break;
		}
			
		case FigurePaid: {
      theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
          theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"tableCellText"
                                                  width:valuesTable.frame.size.width];
      }
      
      [(CellWithText*)theCell loadTitle:[theInvoice figureTitleForType:row] andValue:[data_manager currencyAdjustedValue:[theInvoice paid]] tag:333 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigurePaid] andKeyboardType:UIKeyboardTypeDecimalPad];
      [theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:YES];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
			
			break;
		}
			
		case FigureBalanceDue: {
			theCell = [valuesTable dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellText"
                                                width:valuesTable.frame.size.width];
			}
			
			[(CellWithText*)theCell loadTitle:[theInvoice figureTitleForType:row] andValue:[data_manager currencyAdjustedValue:[theInvoice total] - [theInvoice paid]]
								tag:0 textFieldDelegate:self cellType:[self figureCellTypeForRowType:FigureBalanceDue] andKeyboardType:UIKeyboardTypeDefault];
			[theCell setUserInteractionEnabled:YES];
      [theCell setIsEditingMode:valuesTable.isEditing];
      [theCell setCanEditvalueField:NO];
      [theCell setIsTitleEditable:YES delegate:self tag:FiguresTextfieldTitleOffset + row];
      //111111
			
			break;
		}
			
		default:
			break;
	}
	
    [theCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return theCell;
}

-(UITableViewCell*)otherCellAtRow:(int)row {
	BaseTableCell * theCell;
  UITableView *otherTable = [self tableViewForSection:SectionOptionalInfo];
	
	switch (row) {
		case 0: {
			theCell = [otherTable dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPush"
                                                width:otherTable.frame.size.width];
			}
			
			[(CellWithPush*)theCell loadTitle:[theInvoice otherCommentsTitle] andValue:[theInvoice otherCommentsText] cellType:kCellTypeTop andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 1: {
			theCell = [otherTable dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPush"
                                                width:otherTable.frame.size.width];
			}
			
      NSString *signTitle = [theInvoice leftSignatureTitle];
      if([signTitle rangeOfString:@"(Left)"].location == NSNotFound) {
        signTitle = [signTitle stringByAppendingString:@" (Left)"];
      }
      
			[(CellWithPush*)theCell loadTitle:signTitle andValue:@"" cellType:kCellTypeMiddle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
		
		case 2: {
			theCell = [otherTable dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPush"
                                                width:otherTable.frame.size.width];
			}
			
      NSString *signTitle = [theInvoice rightSignatureTitle];
      if([signTitle rangeOfString:@"(Right)"].location == NSNotFound) {
        signTitle = [signTitle stringByAppendingString:@" (Right)"];
      }
      
			[(CellWithPush*)theCell loadTitle:signTitle andValue:@"" cellType:kCellTypeMiddle andSize:0.0];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 3: {
			theCell = [otherTable dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"tableCellPush"
                                                width:otherTable.frame.size.width];
			}
			
      [theCell makeValueBigger:YES];
			[(CellWithPush*)theCell loadTitle:@"Note" andValue:[theInvoice note] cellType:kCellTypeBottom andSize:0.0];
      [(CellWithPush*)theCell setAutolayoutForValueField];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		default:
			break;
	}
	
	return theCell;
}

-(UITableViewCell*)markAsPaidCell {
	UITableViewCell* theCell = [[self tableViewForSection:SectionMarcAsOpen] dequeueReusableCellWithIdentifier:@"tableCellCheck"];
	
	if (!theCell) {
		theCell = [[CellWithCheck alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellCheck"];
	}
	    
	if([theInvoice paid] == [theInvoice total])
		[(CellWithCheck*)theCell loadTitle:@"Mark as open" andValue:@"1" cellType:kProjectCellTypeingle];
	else
		[(CellWithCheck*)theCell loadTitle:@"Mark as paid" andValue:@"0" cellType:kProjectCellTypeingle];

	return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row {
	switch (section) {
		case SectionTitle: {
			[self selectedTitleCellAtRow:row];
			break;
		}
      
    case SectionClient: {
      NSDictionary *clientettings = [[self clientRowsWhenEditing:clientSectionIsEditing] objectAtIndex:row];
      
      NSInteger cellType = [clientettings[TYPE] integerValue];
      [self selectedClientCellAtRow:(int)cellType];
      break;
    }
			
		case SectionDetails: {
      NSInteger cellType = DetailAddNewLine;
      NSArray *detailVisibleRows = [self detailsRowsWhenEditing:detailsSectionIsEditing];
      
      if([detailVisibleRows count] > row) {
          NSDictionary *detailsSettings = [detailVisibleRows objectAtIndex:row];
          cellType = [detailsSettings[TYPE] integerValue];
      }
      
			[self selectedDetaildeCellAtRow:(int)cellType];
			break;
		}
    
		case SectionProductsAndServices: {
			[self selectedProductCellAtRow:row];
			break;
		}
			
		case SectionFigure: {
      NSDictionary *figureSettings = [[self figureRowsWhenEditing:figureSectionIsEditing] objectAtIndex:row];
      NSInteger cellType = [figureSettings[TYPE] integerValue];
      
			[self selectedValuesCellAtRow:(int)cellType];
			break;
		}
			
		case SectionOptionalInfo: {
			[self selectedOtherCellAtRow:row];
			break;
		}
			
		case SectionMarcAsOpen: {
			[self selectMarkAsPaidCell];
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedTitleCellAtRow:(int)row {
	switch (row) {
		case 0: {
			EditTitleVC * vc = [[EditTitleVC alloc] initWithInvoice:theInvoice];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
	}
}

-(void)selectedDetaildeCellAtRow:(int)row {
    if(row == [self numberOfRowsInDetailsSection]) {
        row = DetailAddNewLine;
    }
    
	switch (row) {
		case DetailProjNumber: {
			[(UITextField*)[self.view viewWithTag:555] becomeFirstResponder];
			
			break;
		}
			
		case DetailDate: {
			//Date
			[self openPickerForCase:kPickerCaseDate];
			
			break;
		}
			
		case DetailDueDate: {
			//Due Date
			[self openPickerForCase:kPickerCaseDueDate];
			
			break;
		}
			
		case DetailTerms: {
			//Terms
			[self openPickerForCase:kPickerCaseTerms];
			break;
		}
            
    case DetailCustom1:
    case DetailCustom2:
    case DetailCustom3:
    case DetailCustom4:
    case DetailCustom5: {

        break;
    }
      
    case DetailProjectName:
    case DetailProjectNo: {
      SelectProjectVC *vc = [[SelectProjectVC alloc] initWithInvoice:theInvoice];
      [self.navigationController pushViewController:vc animated:YES];
      
      break;
    }
      
    case DetailAddNewLine: {
        [self addNewCustomDetailField];
        
        break;
    }
			
		default:
			break;
	}
}

- (void)showClientScreen {
  ClientsVC * vc = [[ClientsVC alloc] initWithInvoice:theInvoice];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectedClientCellAtRow:(int)row {
  switch (row) {
    case ClientAddClient: {
      [self showClientScreen];
    }
      break;

    case ClientBilling: {
      ClientOBJ * theClient = [theInvoice client];
      theClient.billingKey = kInvoiceBillingAddressTitleKeyForNSUserDefaults;
      AddClientAddressVC * vc = [[AddClientAddressVC alloc] initWithAddresType:kAddresTypeBilling client:theClient];
      vc.delegate = self;
      [self.navigationController pushViewController:vc animated:YES];
    }
      break;
      
    case ClientShipping: {
      ClientOBJ * theClient = [theInvoice client];
      theClient.shippingKey = kInvoiceShippingAddressTitleKeyForNSUserDefaults;
      AddClientAddressVC * vc = [[AddClientAddressVC alloc] initWithAddresType:kAddresTypeShipping client:theClient];
      vc.delegate = self;
      [self.navigationController pushViewController:vc animated:YES];
    }
      break;
      
    default:
      break;
  }
}

- (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView {
    UITextPosition *beginning = textView.beginningOfDocument;
    
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    CGRect rect = [textView firstRectForRange:textRange];
    
    return [textView convertRect:rect fromView:textView.textInputView];
}

-(void)selectedProductCellAtRow:(int)row {
	AddItemVC * vc = [[AddItemVC alloc] initWithInvoice:theInvoice index:row];
	[vc setDelegate:self];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)selectedValuesCellAtRow:(int)row {
	BOOL has_tax1 = NO;
	BOOL has_tax2 = NO;
	
	if (![[theInvoice tax1Name] isEqual:@""]) {
		has_tax1 = YES;
	}
	
	if (![[theInvoice tax2Name] isEqual:@""]) {
		has_tax2 = YES;
	}
	
	switch (row) {
		case 0:{
			//SUBTOTAL
			break;
		}
			
		case 1: {
			//DISCOUNT
			[(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
			
			break;
		}
			
		case 2: {
			if (!has_tax1) {
				//SHIPPING
				[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
			} else {
				//TAX 1
			}
			
			break;
		}
			
		case 3: {
			if (has_tax1) {
				if (!has_tax2) {
					//SHIPPING
					[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
				} else {
					//TAX 2
				}
			}
			else {
				//TOTAL
			}
			
			break;
		}
			
		case 4: {
			if (has_tax1) {
				if (has_tax2) {
					//SHIPPING
					[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
				} else {
					//TOTAL
				}
			} else {
				//PAID
				[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			}
			
			break;
		}
			
		case 5: {
			if (has_tax1) {
				if (has_tax2) {
					//TOTAL
				} else {
					//PAID
					[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
				}
			} else {
				//BALANCE DUE
			}
			
			break;
		}
			
		case 6: {
			if (has_tax1) {
				if (has_tax2) {
					//PAID
					[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
				} else {
					//BALANCE DUE
				}
			}
			
			break;
		}
			
		case 7: {
			//BALANCE DUE
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedOtherCellAtRow:(int)row {
    
	switch (row) {
		case 0: {
			//Other comments
			OtherCommentsVC * vc = [[OtherCommentsVC alloc] initWithInvoice:theInvoice];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
		
		case 1: {
			//Signature Left
			AddSignatureAndDateVC * vc = [[AddSignatureAndDateVC alloc] initWithDelegate:self andInvoice:theInvoice type:kSignatureTypeLeft];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 2: {
			//Signature Right
			AddSignatureAndDateVC * vc = [[AddSignatureAndDateVC alloc] initWithDelegate:self andInvoice:theInvoice type:kSignatureTypeRight];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 3: {
			//Note
			AddNoteVC * vc = [[AddNoteVC alloc] initWithInvoice:theInvoice];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectMarkAsPaidCell {
	if([theInvoice paid] == [theInvoice total])
		[theInvoice setPaid:0.0];
	else
		[theInvoice setPaid:[theInvoice total]];
	
	[[self tableViewForSection:SectionMarcAsOpen] reloadData];
}

#pragma mark - ADD ITEM DELEGATE

-(void)viewController:(AddItemVC*)vc addedProduct:(ProductOBJ*)sender atIndex:(NSInteger)index {
	NSMutableArray * array = [[NSMutableArray alloc] initWithArray:theInvoice.products];
	
	if (index < array.count) {
		[array replaceObjectAtIndex:index withObject:[sender contentsDictionary]];
	} else {
		[array addObject:[sender contentsDictionary]];
	}
	
	[theInvoice setProducts:array];
}

-(void)viewController:(AddItemVC*)vc addedService:(ServiceOBJ*)sender atIndex:(NSInteger)index {
	NSMutableArray * array = [[NSMutableArray alloc] initWithArray:theInvoice.products];
	
	if (index < array.count) {
		[array replaceObjectAtIndex:index withObject:[sender contentsDictionary]];
	} else {
		[array addObject:[sender contentsDictionary]];
	}
	
	[theInvoice setProducts:array];
}

#pragma mark - OPEN PICKER

-(void)openPickerForCase:(kPickerCase)type {
	if ([self.navigationController.view viewWithTag:101010] && current_picker_type == type)
		return;
	
	[self hidePercentageAndValue];
	
	UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[closeAll setBackgroundColor:[UIColor clearColor]];
	[closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeAll setTag:123123];
	[theSelfView addSubview:closeAll];
	[theSelfView bringSubviewToFront:theToolbar];
  
  UITableViewCell * theCell;
	
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
	
	for (int i = 0; i < [theInvoice products].count; i++) {
		[(UITextField*)[self.view viewWithTag:1000 + i] resignFirstResponder];
	}
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	
	current_picker_type = type;
	
	UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
	[viewWithPicker setBackgroundColor:[UIColor clearColor]];
	[viewWithPicker setTag:101010];
	[viewWithPicker.layer setMasksToBounds:YES];
	[self.navigationController.view addSubview:viewWithPicker];

	switch (type) {
		case kPickerCaseTerms: {
			UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			picker.backgroundColor = [UIColor whiteColor];
			[picker setDelegate:self];
			[picker setDataSource:self];
			
			if (!iPad) {
				[picker setTransform:CGAffineTransformMakeScale(1.09, 1.09)];
			} else {
				[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
			}
			
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[viewWithPicker addSubview:picker];
			
			UIView * indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
			[indicator setBackgroundColor:app_tab_selected_color];
			[indicator setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[indicator setAlpha:0.2];
			[indicator setUserInteractionEnabled:NO];
			[viewWithPicker addSubview:indicator];
			
			break;
		}
			
		case kPickerCaseDate: {
			UIDatePicker * picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[picker setDatePickerMode:UIDatePickerModeDate];
			[picker setTag:989898];
			picker.backgroundColor = [UIColor whiteColor];
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			[picker setDate:[date_formatter dateFromString:[theInvoice date]]];
			[viewWithPicker addSubview:picker];
			
			if (iPad) {
				[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
			}
			
			break;
		}
			
		case kPickerCaseDueDate: {
			UIDatePicker * picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
			[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
			[picker setDatePickerMode:UIDatePickerModeDate];
			[picker setTag:989898];
			picker.backgroundColor = [UIColor whiteColor];
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			[picker setDate:[date_formatter dateFromString:[theInvoice dueDate]]];
			[viewWithPicker addSubview:picker];
			
			if (iPad) {
				[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
			}
			
			break;
		}
			
		default:
			break;
	}
	
	[UIView animateWithDuration:0.25 animations:^{
		[viewWithPicker setFrame:CGRectMake(0, dvc_height - keyboard_height + 20, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 42 - keyboard_height)];
	} completion:^(BOOL finished) {
		if (myTableView.contentOffset.y > theCell.frame.origin.y) {
			[myTableView scrollRectToVisible:CGRectMake(0, theCell.frame.origin.y, theCell.frame.size.width, theCell.frame.size.height) animated:YES];
		} else {
			[myTableView scrollRectToVisible:CGRectMake(0, theCell.frame.origin.y + 42, theCell.frame.size.width, theCell.frame.size.height) animated:YES];
		}
	}];
}

-(void)cancelPicker:(UIButton*)sender {
	for (int i = 0; i < [theInvoice products].count; i++) {
		[(UITextField*)[self.view viewWithTag:1000 + i] resignFirstResponder];
	}
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 42)];
	} completion:^(BOOL finished) {
		[self reloadTableView];
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	}];
}

-(void)closePicker:(UIButton*)sender {
	if ([self.navigationController.view viewWithTag:989898] &&
	    [[self.navigationController.view viewWithTag:989898] isKindOfClass:[UIDatePicker class]]) {
		if (current_picker_type == kPickerCaseDate) {
			[theInvoice setDate:((UIDatePicker*)[self.navigationController.view viewWithTag:989898]).date];
		} else if (current_picker_type == kPickerCaseDueDate) {
			[theInvoice setDueDate:((UIDatePicker*)[self.navigationController.view viewWithTag:989898]).date];
		}
	}
	
	for (int i = 0; i < [theInvoice products].count; i++) {
		[(UITextField*)[self.view viewWithTag:1000 + i] resignFirstResponder];
	}
	
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	
	[[self.view viewWithTag:123123] removeFromSuperview];
	
	[UIView animateWithDuration:0.25 animations:^{
		[[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
		[theToolbar setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
		[myTableView setFrame:CGRectMake(myTableView.frame.origin.x, myTableView.frame.origin.y, dvc_width, dvc_height - 42)];
	} completion:^(BOOL finished) {
		[self reloadTableView];
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	}];
}

#pragma mark - PICKERVIEW DATASOURCE

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
	return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 8;
}

-(UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view {
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, dvc_width - 60, 30)];
	[label setTextAlignment:NSTextAlignmentLeft];
	[label setTextColor:[UIColor darkGrayColor]];
	[label setFont:HelveticaNeue(15)];
	[label setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:label];
	
	if (row == [pickerView selectedRowInComponent:component]) {
		[label setTextColor:[UIColor blackColor]];
	}
	
	[label setText:[TermsManager termsString:(int)row]];
	
	return theView;
}

#pragma mark - PICKERVIEW DELEGATE

-(CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component {
	return 30;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[pickerView reloadAllComponents];
	[theInvoice clearDueDate];
	[theInvoice setTerms:(int)row];
	[[self tableViewForSection:SectionDetails] reloadData];
}

#pragma mark - ALERTVIEW DELEGATE

-(void)alertView:(AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	has_alertview = NO;
  
  if(alertView.tag == AlertViewSaveChangesTag) {
    if(buttonIndex == 0) {//NO
      [theInvoice removeTempSignatures];
      [self dismissViewControllerAnimated:YES completion:nil];
    } else {//YES
      [self saveObject];
    }
  }
}

#pragma mark - TEXTFIELD DELEGATE

-(void)next:(UIButton*)sender {
	
}

-(void)prev:(UIButton*)sender {
	
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  activeTextField = textField;
  
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	
  if (textField.tag != 444 && textField.tag != 555 && textField.tag != TITLE_CELL_TAG && textField.tag != MY_COMPANY_CELL_TAG && textField.tag < TextfieldOffsetTag && textField.tag != CLIENT_NAME_CELL_TAG) {
		[textField setText:[data_manager currencyStrippedString:textField.text]];
    
    if ([textField.text floatValue] == 0.0f ) {
      [textField setText:@""];
    }
  }
	
	[UIView animateWithDuration:0.25 animations:^ {
		[theToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[myTableView setFrame:CGRectMake(myTableView.frame.origin.x,
                                     myTableView.frame.origin.y,
                                     dvc_width,
                                     dvc_height - 82 - keyboard_height)];
    if(iPad) {
      if(textField.tag == 111 || textField.tag == 222 || textField.tag == 333 || textField.tag >= FiguresTextfieldTitleOffset) {
        CGRect frame = ipadTablesView.frame;
        frame.origin.y = -keyboard_height;
        ipadTablesView.frame = frame;
      }
    }
	}];
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  activeTextField = nil;
  
  return YES;
}

-(void)textFieldDidBeginEditing:(UITextField*)textField {
  UIButton * closeAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  [closeAll setBackgroundColor:[UIColor clearColor]];
  [closeAll addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
  [closeAll setTag:123123];
  [theSelfView addSubview:closeAll];
  [theSelfView bringSubviewToFront:theToolbar];
  
  if (textField.tag == 111) {
    [self showPercentageAndValue];
  }
  else {
    [self hidePercentageAndValue];
  }
  
  if (textField.tag >= 1000 && textField.tag < TextfieldOffsetTag) {
    [textField setText:@""];
  }
}

-(void)textFieldDidEndEditing:(UITextField*)textField {
	if (has_alertview)
		return;
  
  SectionTag sectionTag = -1;
		
  if(textField.tag == TITLE_CELL_TAG) {
      if([textField.text length] > 0) {
          [theInvoice setTitle:textField.text];
      } else {
          textField.text = [theInvoice title];
      }
    sectionTag = SectionTitle;
  }
  
  if(textField.tag == MY_COMPANY_CELL_TAG) {
    CompanyOBJ *myCompany = [[CompanyOBJ alloc] initWithContentsDictionary:[CustomDefaults customObjectForKey:kCompanyKeyForNSUserDefaults]];
    [myCompany setName:textField.text?:@""];
    [CustomDefaults setCustomObjects:[myCompany contentsDictionary] forKey:kCompanyKeyForNSUserDefaults];
    
    sectionTag = SectionYourCompany;
  }
  
  if(textField.tag == CLIENT_NAME_CELL_TAG) {
    ClientOBJ *client = [theInvoice client];
    [client setFirstName:textField.text];
    [theInvoice setClient:[client contentsDictionary]];
    
    sectionTag = SectionClient;
  }
  
  if(textField.tag >= TextfieldOffsetTag) {
      [self parseTextFieldEditing:textField];
      return;
  }
    
	if (textField.tag >= 1000) {
		if ([textField.text floatValue] == 0.0f) {
			[[self.view viewWithTag:123123] removeFromSuperview];
			
			if (!has_alertview) {
				[[[AlertView alloc] initWithTitle:@"" message:@"Quantity cannot be 0." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] showInWindow];
				has_alertview = YES;
			}
			
			[textField becomeFirstResponder];
			return;
		}
		
		int row = (int)(textField.tag - 1000);
		
		NSDictionary * dict = [[theInvoice products] objectAtIndex:row];
		
		NSString * classString = [dict objectForKey:@"class"];
		
		if (NSClassFromString(classString) == [ProductOBJ class]) {
			ProductOBJ * theProduct = [[ProductOBJ alloc] initWithContentsDictionary:[[theInvoice products] objectAtIndex:row]];
			[theProduct setQuantity:[data_manager trimmedQuantity:[textField.text floatValue]]];
			
			NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[theInvoice products]];
			[array replaceObjectAtIndex:row withObject:[theProduct contentsDictionary]];
			
			[theInvoice setProducts:array];
		} else {
			ServiceOBJ * theService = [[ServiceOBJ alloc] initWithContentsDictionary:[[theInvoice products] objectAtIndex:row]];
			[theService setQuantity:[data_manager trimmedQuantity:[textField.text floatValue]]];
			
			NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[theInvoice products]];
			[array replaceObjectAtIndex:row withObject:[theService contentsDictionary]];
			
			[theInvoice setProducts:array];
		}
	}
	else {
    sectionTag = SectionFigure;
    
		switch (textField.tag) {
			case 111: {
				if (value.selected) {
					[theInvoice setDiscount:[textField.text floatValue]];
				} else {
					float x = [textField.text floatValue];
					float sum = [theInvoice subtotal];
					float y = (x * sum) / 100;
					
					[theInvoice setDiscount:y];
					[textField setText:[NSString stringWithFormat:@"%.2f", y]];
				}
				
				break;
			}
				
			case 222: {
				[theInvoice setShippingValue:[textField.text floatValue]];
				break;
			}
				
			case 333: {
				[theInvoice setPaid:[textField.text floatValue]];
				break;
			}
				
			case 444: {
				[theInvoice setTitle:textField.text];
				break;
			}
				
			case 555: {
				[theInvoice setStringNumber:textField.text];
				break;
			}
				
			default:
				break;
		}
		
		if (textField.tag != 444 && textField.tag != 555 && textField.tag != MY_COMPANY_CELL_TAG && textField.tag != TITLE_CELL_TAG && textField.tag != CLIENT_NAME_CELL_TAG)
			[textField setText:[data_manager currencyAdjustedValue:[textField.text floatValue]]];
	}
	
	[[self tableViewForSection:sectionTag] reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
	[textField resignFirstResponder];
	
	return YES;
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
	if (textField.tag != 444 && textField.tag != 555)
		return YES;
	
	NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (result.length > 14)
		return NO;
	
	return YES;
}

#pragma mark - SIGNATURE AND DATE CREATOR DELEGATE

-(void)creatorViewController:(AddSignatureAndDateVC*)viewController createdSignature:(UIImage*)signature withFrame:(CGRect)frame title:(NSString*)title andDate:(NSDate*)date {
	switch (viewController.signatureType) {
		case kSignatureTypeLeft: {
			[theInvoice setLeftSignature:signature];
			[theInvoice setLeftSignatureDate:date];
			[theInvoice setLeftSignatureTitle:title];
			[theInvoice setLeftSignatureFrame:frame];
      
      if([theInvoice alwaysShowSignatureLeft]) {
        [theInvoice saveLeftSignature:signature];
        [theInvoice saveLeftSignatureTitle:title];
        [theInvoice saveLeftSignatureFrame:frame];
      } else {
        [theInvoice removeLeftCommonSignatureKey];
        [theInvoice saveLeftSignatureTitle:@"Signature"];
      }
			
			break;
		}
			
		case kSignatureTypeRight: {
			[theInvoice setRightSignature:signature];
			[theInvoice setRightSignatureDate:date];
			[theInvoice setRightSignatureTitle:title];
			[theInvoice setRightSignatureFrame:frame];
      
      if([theInvoice alwaysShowSignatureRight]) {
        [theInvoice saveRightSignature:signature];
        [theInvoice saveRightSignatureTitle:title];
        [theInvoice saveRightSignatureFrame:frame];
      } else {
        [theInvoice removeRightCommonSignatureKey];
        [theInvoice saveRightSignatureTitle:@"Signature"];
      }
			
			break;
		}
	}
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
  [self layoutTableView];
  [self reloadTableView];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self layoutAllTableViewsAnimated:NO];
  });
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
  if(iPad) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardWillHideNotification object:nil];
  }
  [self reloadTableView];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)dealloc {
  [self removeDelegates];
}

#pragma mark - NSNotificationCenter

-(void)keyboardFrameChanged:(NSNotification*)notification {
  NSDictionary* info = [notification userInfo];
  
  CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  
  if(to.y == dvc_height + 20) {
      return;
  }
  
  [UIView animateWithDuration:0.25 animations:^{
      theToolbar.frame = CGRectMake(theToolbar.frame.origin.x, to.y - theToolbar.frame.size.height - 20, theToolbar.frame.size.width, theToolbar.frame.size.height);
  [myTableView setFrame:CGRectMake(myTableView.frame.origin.x,
                                   myTableView.frame.origin.y,
                                   dvc_width,
                                   dvc_height - 82 - keyboardSize.height)];
    
  }];
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
  if(ipadTablesView.frame.origin.y != 0) {
    CGRect frame = ipadTablesView.frame;
    frame.origin.y = statusBarHeight;
    ipadTablesView.frame = frame;
  }
}

@end