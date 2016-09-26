//
//  SettingsVC.m
//  Invoice
//
//  Created by XGRoup5 on 8/13/13.
//  Copyright (c) 2013 XGRoup. All rights reserved.
//

#import "SettingsVC.h"

#import "Defines.h"
#import "CellWithPush.h"
#import "CellWithPicker.h"
#import "CellWithText.h"
#import "ProfileVC.h"
#import "DefaultNoteVC.h"
#import "PasscodeLockVC.h"
#import "TemplatesVC.h"
#import "MKStoreManager.h"
#import "CellWithSwitch.h"
#import "CellWithLabel.h"
#import "CellWithImage.h"
#import "CCropImage.h"
#import "LanguageVC.h"

#define INVOICE_PREF_FIELD_INDEX 212
#define QUOTE_PREF_FIELD_INDEX 213
#define ESTIMATE_PREF_FIELD_INDEX 214
#define PURCHASE_PREF_FIELD_INDEX 215

@interface SettingsVC ()
<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
ImageCropperDelegate,
AlertViewDelegate>

@end

@implementation SettingsVC

-(id)init
{
	self = [super init];
	
	if (self)
	{
//		fiscalYearArray = [[NSMutableArray alloc] initWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
		taxTypeArray = [[NSMutableArray alloc] initWithObjects:@"No Tax", @"Single Tax", @"Compound Tax", nil];
	}
	
	return self;
}

#pragma mark - VIEW DID LOAD

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	firstTime = YES;
	
	theSelfView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, dvc_width, dvc_height)];
	[theSelfView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:theSelfView];
		
	[self.view setBackgroundColor:app_background_color];
	
	topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@"Settings"];
	[topBarView setBackgroundColor:app_bar_update_color];
	
	mainTableView = [[TableWithShadow alloc] initWithFrame:CGRectMake(0, 42, dvc_width, dvc_height - 87) style:UITableViewStyleGrouped];
	[mainTableView setDataSource:self];
	[mainTableView setDelegate:self];
	[mainTableView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setSeparatorColor:[UIColor clearColor]];
	
	[theSelfView addSubview:mainTableView];
	
	UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height - 87)];
	[bgView setBackgroundColor:[UIColor clearColor]];
	[mainTableView setBackgroundView:bgView];
	
	[self.view addSubview:topBarView];
}

#pragma mark - Private methods

- (NSString *)numberWithPref:(NSString *)pref number:(int)temp {
    NSString *value = @"";
    if (temp < 10)
    {
        value = [NSString stringWithFormat:@"%@0000%d", pref, temp];
    }
    else if (temp < 100)
    {
        value = [NSString stringWithFormat:@"%@000%d", pref, temp];
    }
    else if (temp < 1000)
    {
        value = [NSString stringWithFormat:@"%@00%d", pref, temp];
    }
    else if (temp < 10000)
    {
        value = [NSString stringWithFormat:@"%@0%d", pref, temp];
    }
    else
    {
        value = [NSString stringWithFormat:@"%@%d", pref, temp];
    }
    return value;
}

#pragma mark - TABLE VIEW DATASOURCE

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 8;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section){
		case 0: {
			kApplicationVersion version = app_version;
			
			switch (version) {
				case kApplicationVersionInvoice: {
					return 12;
					break;
				}
					
				case kApplicationVersionQuote: {
					return 4;
					break;
				}
					
				case kApplicationVersionEstimate: {
					return 4;
					break;
				}
					
				case kApplicationVersionPurchase: {
					return 4;
					break;
				}
					
				case kApplicationVersionReceipts: {
					return 3;
					break;
				}
					
				case kApplicationVersionTimesheets: {
					return 3;
					break;
				}
					
				default:
					break;
			}
			
			break;
		}
			
		case 1: {
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
      
			if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"No Tax"]) {
				return 1;
			} else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
				return 4;
			} else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Compound Tax"]) {
				return 6;
			}
			
			break;
		}
			
		case 2: {
			return 2;
			break;
		}
			
		case 3: {
			return 8;
			break;
		}
		
		case 4: {
			return 2;
			break;
		}
			
		case 5: {
			return 1;
			break;
		}
		
		case 6: {
			return 1;
			break;
		}
			
		case 7: {
			return 3;
			
			break;
		}
			
		default:
			break;
	}
	
	return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	if ([tableView isKindOfClass:[TableWithShadow class]]) {
		[(TableWithShadow*)tableView didScroll];
	}
	
	return [self cellInSection:(int)indexPath.section atRow:(int)indexPath.row];
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
	
	switch (section) {
		case 0: {
			[title setText:@"Company"];
			break;
		}
			
		case 1: {
			[title setText:@"Tax"];
			break;
		}
			
		case 2: {
			[title setText:@"Business"];
			break;
		}
			
		case 3: {
			[title setText:@"Document"];
			break;
		}
			
		case 4: {
			[title setText:@"Customize"];
			break;
		}
			
		case 5: {
			[title setText:@"Security"];
			break;
		}
		
		case 6: {
			[title setText:@"Sync"];
			break;
		}
			
		case 7: {
			[title setText:@"Support"];
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
	return 42.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell * theCell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == 3 && indexPath.row == 0) {
		[UIView animateWithDuration:0.25 animations:^{
			[(CellWithPush*)theCell colorOn];
		} completion:^(BOOL finished) {
			[(CellWithPush*)theCell performSelector:@selector(colorOff) withObject:nil afterDelay:2];
			[self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
		}];
	} else {
		if ([theCell isKindOfClass:[CellWithPush class]]) {
			[(CellWithPush*)theCell animateSelection];
		} else if ([theCell isKindOfClass:[CellWithPicker class]]) {
			[(CellWithPicker*)theCell animateSelection];
		} else if ([theCell isKindOfClass:[CellWithText class]]) {
			[(CellWithText*)theCell animateSelection];
		}
		
		[self selectedCellInSection:(int)indexPath.section atRow:(int)indexPath.row];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if([cell respondsToSelector:@selector(setCellWidth:)])
    [(BaseTableCell *)cell setCellWidth:tableView.frame.size.width];
}

#pragma mark - SCROLL VIEW DELEGATE

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
	if ([scrollView isKindOfClass:[TableWithShadow class]])
		[(TableWithShadow*)scrollView didScroll];
}

#pragma mark - CELL GENERATION

-(UITableViewCell*)cellInSection:(int)section atRow:(int)row {
	switch (section) {
		case 0: {
			return [self companyCellAtRow:row];
			break;
		}
			
		case 1: {
			return [self taxCellAtRow:row];
			break;
		}
			
		case 2: {
			return [self businessCellAtRow:row];
			break;
		}
			
		case 3: {
			return [self documentCellAtRow:row];
			break;
		}
			
		case 4: {
			return [self customizeCellAtRow:row];
			break;
		}
			
		case 5: {
			return [self securityCellAtRow:row];
			break;
		}
			
		case 6: {
			return [self syncCellAtRow:row];
			break;
		}

		case 7: {
			return [self supportCellAtRow:row];
			break;
		}
						
		default:
			break;
	}
	
	return nil;
}

-(UITableViewCell*)companyCellAtRow:(int)row {
	BaseTableCell * theCell;
	
	switch (row) {
		case 0: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell) {
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Profile" andValue:@"" cellType:kCellTypeTop andSize:0.0];
            [theCell makeTitleBigger:NO];
			
			break;
		}
			
		case 1: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
      
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
			
			[(CellWithPicker*)theCell loadTitle:@"Terms" andValue:[TermsManager termsString:[[settingsDictionary objectForKey:@"terms"] intValue]] cellType:kCellTypeMiddle];
            [theCell makeTitleBigger:NO];
			
			break;
		}
			
		case 2: {
			kApplicationVersion version = app_version;
			switch (version) {
				case kApplicationVersionInvoice: {
					theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
					
					if (!theCell) {
						theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
					}
					
					int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfInvoicesKeyForNSUserDefaults];
					
                    NSString *pref = [InvoiceDefaults invoicePref];
                    NSString * value = [self numberWithPref:pref number:temp];
					
					[(CellWithText*)theCell loadTitle:@"Invoice Number" andValue:value tag:555 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
					[theCell setUserInteractionEnabled:YES];
					
					break;
				}
					
				case kApplicationVersionQuote: {
					theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
					if (!theCell) {
						theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
					}
					
					int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfQuotesKeyForNSUserDefaults];
					
					NSString * value = [self numberWithPref:[QuoteDefaults quotePref] number:temp];
					
					[(CellWithText*)theCell loadTitle:@"Quote Number" andValue:value tag:444 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
					[theCell setUserInteractionEnabled:YES];
					
					break;
				}
					
				case kApplicationVersionEstimate: {
					theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
					if (!theCell) {
						theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
					}
					
					int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfEstimatesKeyForNSUserDefaults];
					
					NSString * value = [self numberWithPref:[EstimateDefaults estimatePref] number:temp];
					
					[(CellWithText*)theCell loadTitle:@"Estimate Number" andValue:value tag:333 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
					[theCell setUserInteractionEnabled:YES];
					
					break;
				}
					
				case kApplicationVersionPurchase: {
					theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
					if (!theCell) {
						theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
					}
					
					int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfPurchaseOrdersKeyForNSUserDefaults];
					
					NSString * value = [self numberWithPref:[PurchaseDefaults purchasePref] number:temp];
					
					[(CellWithText*)theCell loadTitle:@"P.Os Number" andValue:value tag:222 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
					[theCell setUserInteractionEnabled:YES];
					
					break;
				}
					
				case kApplicationVersionReceipts: {
					theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
					if (!theCell) {
						theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
					}
					
					int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfRecipeKeyForNSUserDefaults];
					
					NSString * value = [self numberWithPref:@"RT" number:temp];
					
					[(CellWithText*)theCell loadTitle:@"Receipt Number" andValue:value tag:221 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
					[theCell setUserInteractionEnabled:YES];
					
					break;
				}
					
				case kApplicationVersionTimesheets: {
					theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
					if (!theCell) {
						theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
					}
					
					int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfTimesheetKeyForNSUserDefaults];
					
					NSString * value = [self numberWithPref:@"TS" number:temp];
					
					[(CellWithText*)theCell loadTitle:@"Timesheet Number" andValue:value tag:220 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
					[theCell setUserInteractionEnabled:YES];
					
					break;
				}
					
				default:
					break;
			}
            break;
		}
            
        case 3: {
            kApplicationVersion version = app_version;
            switch (version) {
                case kApplicationVersionInvoice: {
                    theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
                    if (!theCell) {
                        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
                    }
                    
                    [(CellWithText*)theCell loadTitle:@"Invoice Prefix" andValue:[InvoiceDefaults invoicePref] tag:INVOICE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeAlphabet];
                    [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
                    [theCell setUserInteractionEnabled:YES];
                    [theCell makeTitleBigger:NO];
                    
                    break;
                }
                    
                case kApplicationVersionQuote: {
                    theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
                    if (!theCell) {
                        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
                    }
                    
                    [(CellWithText*)theCell loadTitle:@"Quote Prefix" andValue:[QuoteDefaults quotePref] tag:QUOTE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeAlphabet];
                    [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
                    [theCell setUserInteractionEnabled:YES];
                    [theCell makeTitleBigger:NO];
                    
                    break;
                }
                    
                case kApplicationVersionEstimate: {
                    theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
                    if (!theCell) {
                        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
                    }
                    
                    [(CellWithText*)theCell loadTitle:@"Estimate Prefix" andValue:[EstimateDefaults estimatePref] tag:ESTIMATE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeAlphabet];
                    [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
                    [theCell setUserInteractionEnabled:YES];
                    [theCell makeTitleBigger:NO];
                    
                    break;
                }
                    
                case kApplicationVersionPurchase: {
                    theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
                    if (!theCell) {
                        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
                    }
                    
                    [(CellWithText*)theCell loadTitle:@"P.O. Prefix" andValue:[PurchaseDefaults purchasePref] tag:PURCHASE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeAlphabet];
                    [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
                    [theCell setUserInteractionEnabled:YES];
                    [theCell makeTitleBigger:NO];
                    
                    break;
                }
                    default:
                    break;
            }
            break;
        }
            
		case 4: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfQuotesKeyForNSUserDefaults];
			
			NSString * value = [self numberWithPref:[QuoteDefaults quotePref] number:temp];
			
			[(CellWithText*)theCell loadTitle:@"Quote Number" andValue:value tag:444 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
			
			break;
		}
            
        case 5: {
            theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            [(CellWithText*)theCell loadTitle:@"Quote Prefix" andValue:[QuoteDefaults quotePref] tag:QUOTE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeAlphabet];
            [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
            [theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
            
            break;
        }
			
		case 6: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfEstimatesKeyForNSUserDefaults];
			
			NSString * value = [self numberWithPref:[EstimateDefaults estimatePref] number:temp];
			
			[(CellWithText*)theCell loadTitle:@"Estimate Number" andValue:value tag:333 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
			
			break;
		}
            
        case 7: {
            theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            [(CellWithText*)theCell loadTitle:@"Estimate Prefix" andValue:[EstimateDefaults estimatePref] tag:ESTIMATE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeAlphabet];
            [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
            [theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
            
            break;
        }
			
		case 8: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfPurchaseOrdersKeyForNSUserDefaults];
			
			NSString * value = [self numberWithPref:[PurchaseDefaults purchasePref] number:temp];
			
			[(CellWithText*)theCell loadTitle:@"P.Os Number" andValue:value tag:222 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
			
			break;
		}
            
        case 9: {
            theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
            if (!theCell) {
                theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
            }
            
            [(CellWithText*)theCell loadTitle:@"P.O. Prefix" andValue:[PurchaseDefaults purchasePref] tag:PURCHASE_PREF_FIELD_INDEX textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeAlphabet];
            [(CellWithText*)theCell setAutoCapitalizationType:UITextAutocapitalizationTypeWords];
            [theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
            
            break;
        }
			
		case 10: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfRecipeKeyForNSUserDefaults];
			
			NSString * value = [self numberWithPref:@"RT" number:temp];
			
			[(CellWithText*)theCell loadTitle:@"Receipt Number" andValue:value tag:221 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:NO];
			
			break;
			
		}
			
		case 11: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfTimesheetKeyForNSUserDefaults];
			
			NSString * value = [self numberWithPref:@"TS" number:temp];
			
			[(CellWithText*)theCell loadTitle:@"Timesheet Number" andValue:value tag:220 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
            [theCell makeTitleBigger:YES];
			
			break;
		}
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

-(UITableViewCell*)taxCellAtRow:(int)row {
	BaseTableCell * theCell;
	
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	switch (row) {
		case TaxType: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			kCellType type = kCellTypeTop;
			
			if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"No Tax"]) {
				type = kCellTypeSingle;
			}
			
			[(CellWithPicker*)theCell loadTitle:@"Tax Type" andValue:[settingsDictionary objectForKey:@"taxType"] cellType:type];
			
			break;
		}
			
		case Tax1Rate: {
      theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
      }
      
      [(CellWithText*)theCell loadTitle:@"Rate:" andValue:[NSString stringWithFormat:@"%@ %c", [settingsDictionary objectForKey:@"taxRate1"], '%'] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
      [(CellWithText*)theCell setActiveValueOnSelection:YES];
      [theCell setUserInteractionEnabled:YES];
      
			break;
		}
			
		case Tax1Abreviation: {
      theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
      }
      
      [(CellWithText*)theCell loadTitle:@"Abreviation:" andValue:[settingsDictionary objectForKey:@"taxAbreviation1"] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
      [(CellWithText*)theCell setActiveValueOnSelection:YES];
      [theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case Tax2Rate: {
      if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
        theCell = [self taxRegNoCellFromTable:mainTableView];
      } else {
        theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
        
        if (!theCell) {
          theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
        }
        
        [(CellWithText*)theCell loadTitle:@"Rate:" andValue:[NSString stringWithFormat:@"%@ %c", [settingsDictionary objectForKey:@"taxRate2"], '%'] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDecimalPad];
        [(CellWithText*)theCell setActiveValueOnSelection:YES];
        [theCell setUserInteractionEnabled:YES];
      }
			
			break;
		}
      
    case Tax2Abreviation: {
      theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
      
      if (!theCell) {
        theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
      }
      
      [(CellWithText*)theCell loadTitle:@"Abreviation:" andValue:[settingsDictionary objectForKey:@"taxAbreviation2"] tag:row textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
      [(CellWithText*)theCell setActiveValueOnSelection:YES];
      [theCell setUserInteractionEnabled:YES];
      break;
    }
      
    case TaxRegNo: {
      theCell = [self taxRegNoCellFromTable:mainTableView];
      break;
    }
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

- (BaseTableCell *)taxRegNoCellFromTable:(UITableView *)tableView {
  BaseTableCell *theCell = [tableView dequeueReusableCellWithIdentifier:@"tableCellText"];
  
  if (!theCell) {
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
  }
  
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
  [(CellWithText*)theCell loadTitle:@"Tax Reg No." andValue:[settingsDictionary objectForKey:@"taxRegNo"] tag:888 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeDefault];
  [theCell setUserInteractionEnabled:YES];
  return theCell;
}

-(UITableViewCell*)documentCellAtRow:(int)row
{
	BaseTableCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Default Template" andValue:@"" cellType:kCellTypeTop andSize:0.0];
            
            [theCell setTitleEditableLayout];
            [theCell setAutolayoutForValueField];
			
			break;
		}
			
		case 1:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Default Note" andValue:@"" cellType:kCellTypeMiddle andSize:0.0];
            
            [theCell setTitleEditableLayout];
            [theCell setAutolayoutForValueField];
			
			break;
		}
			
		case 2:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Currency symbol" andValue:[data_manager currency] tag:111 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyDone];
            
            [theCell setTitleEditableLayout];
            [theCell setAutolayoutForValueField];
            [(CellWithText*)theCell makeTitleBigger:NO];
			
			break;
		}
			
		case 3:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Currency placement" andValue:[data_manager currencyPlacementString] tag:0 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setTextFieldEditable:NO];
			[(CellWithText*)theCell resize:42];
            
            [theCell setTitleEditableLayout];
            [theCell setAutolayoutForValueField];
            
            [(CellWithText*)theCell makeTitleBigger:YES];
			
			break;
		}
			
		case 4:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Thousand symbol" andValue:[data_manager thousandSymbol] tag:199 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			
			[(CellWithText*)theCell changeFontTo:HelveticaNeueMedium(26)];
			[(CellWithText*)theCell resize:42];
            
      [theCell setTitleEditableLayout];
      [theCell setAutolayoutForValueField];
      [(CellWithText*)theCell makeTitleBigger:NO];
			
			break;
		}
			
		case 5:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Decimal symbol" andValue:[data_manager decimalSymbol] tag:198 textFieldDelegate:self cellType:kCellTypeMiddle andKeyboardType:UIKeyboardTypeDefault];
			
			[(CellWithText*)theCell changeFontTo:HelveticaNeueMedium(26)];
			[(CellWithText*)theCell resize:42];
            
      [theCell setTitleEditableLayout];
      [theCell setAutolayoutForValueField];
      [(CellWithText*)theCell makeTitleBigger:NO];
						
			break;
		}
			
		case 6: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			[(CellWithPicker*)theCell loadTitle:@"Decimal placement" andValue:[data_manager stringForDecimalPlacement] cellType:kCellTypeMiddle];
            [(CellWithPicker*)theCell resize];
			
			break;
		}
			
		case 7: {
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPicker"];
			
			if (!theCell) {
				theCell = [[CellWithPicker alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPicker"];
			}
			
			[date_formatter setDateFormat:[DELEGATE userSelectedDateFormat]];
			
			[(CellWithPicker*)theCell loadTitle:@"Date Format" andValue:[date_formatter stringFromDate:[NSDate date]] cellType:kCellTypeBottom];
            [(CellWithPicker*)theCell resize];
			
			break;
		}
			
		default:
			break;
	}
	
	return theCell;
}

-(UITableViewCell*)customizeCellAtRow:(int)row
{
	BaseTableCell *theCell;

	switch (row)
	{
		case 0:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellImage"];
			
			if (!theCell) {
				theCell = [[CellWithImage alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellImage"];
			}
			
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
      
      NSString *imagePath = [NSHomeDirectory() stringByAppendingString:[settingsDictionary objectForKey:@"background_image"]];
      
			if([imagePath isEqual:@""])
			{
				NSData *imageData = [[NSData alloc] init];
				
				[(CellWithImage*)theCell loadTitle:@"Background" andValue:imageData tag:0 cellType:kCellTypeTop];
			}
			else
			{
				NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
                
				[(CellWithImage*)theCell loadTitle:@"Background" andValue:imageData tag:0 cellType:kCellTypeTop];
			}
						
			break;
		}
			
		case 1:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Language" andValue:@"" cellType:kCellTypeBottom andSize:0.0];

			break;
		}
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

-(UITableViewCell*)securityCellAtRow:(int)row
{
	BaseTableCell * theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
	
	if (!theCell)
	{
		theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
	}
	
	NSString * value = @"Off";
	
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	if ([[settingsDictionary objectForKey:@"passwordLock"] isEqual:@"1"])
		value = @"On";
	
	[(CellWithPush*)theCell loadTitle:@"Password Lock" andValue:value cellType:kCellTypeSingle andSize:0.0];
	
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
    
	return theCell;
}

-(UITableViewCell*)businessCellAtRow:(int)row
{
	BaseTableCell * theCell;
	
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	switch (row)
	{
		case 0:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Business Reg. Name" andValue:[settingsDictionary objectForKey:@"businessName"] tag:777 textFieldDelegate:self cellType:kCellTypeTop andKeyboardType:UIKeyboardTypeDefault];
			[(CellWithText*)theCell setReturnkeyType:UIReturnKeyDone];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		case 1:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellText"];
			
			if (!theCell)
			{
				theCell = [[CellWithText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellText"];
			}
			
			[(CellWithText*)theCell loadTitle:@"Business Reg. Number" andValue:[settingsDictionary objectForKey:@"businessNumber"] tag:666 textFieldDelegate:self cellType:kCellTypeBottom andKeyboardType:UIKeyboardTypeDecimalPad];
			[theCell setUserInteractionEnabled:YES];
			
			break;
		}
			
		default:
			break;
	}
  
  [theCell setTitleEditableLayout];
  [theCell setAutolayoutForValueField];
  [theCell makeTitleBigger:YES];
	
	return theCell;
}

-(UITableViewCell*)syncCellAtRow:(int)row
{
	UITableViewCell *theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellSwitch"];
	
	if(!theCell)
	{
		theCell = [[CellWithSwitch alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellSwitch"];
	}
	
	[(CellWithSwitch*)theCell loadTitle:@"Sync via iCloud" andValue:[CustomDefaults customStringForKey:kSyncValue] cellType:kCellTypeSingle];
	
	return theCell;
}

-(UITableViewCell*)supportCellAtRow:(int)row
{
	BaseTableCell * theCell;
	
	switch (row)
	{
		case 0:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Send Feedback" andValue:@"" cellType:kCellTypeTop andSize:0.0];
            [(CellWithPush*)theCell makeTitleBigger:NO];
			
			break;
		}
			
		case 1:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellLabel"];
			
			if (!theCell)
			{
				theCell = [[CellWithLabel alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellLabel"];
			}
			
			kCellType type = kCellTypeMiddle;
			
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
      
			[(CellWithLabel*)theCell loadTitle:@"Version" andValue:[NSString stringWithFormat:@"%@",[settingsDictionary objectForKey:@"version"]] tag:0 cellType:type];
			
			break;
		}
			
		case 2:
		{
			theCell = [mainTableView dequeueReusableCellWithIdentifier:@"tableCellPush"];
			
			if (!theCell)
			{
				theCell = [[CellWithPush alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCellPush"];
			}
			
			[(CellWithPush*)theCell loadTitle:@"Restore purchases" andValue:@"" cellType:kCellTypeBottom andSize:0.0];
			[(CellWithPush*)theCell makeTitleBigger:YES];
			break;
		}
			
		default:
			break;
	}
    
    [theCell setTitleEditableLayout];
    [theCell setAutolayoutForValueField];
	
	return theCell;
}

#pragma mark - CELL SELECTION

-(void)selectedCellInSection:(int)section atRow:(int)row
{
	switch (section)
	{
		case 0:
		{
			[self selectedCompanyCellAtRow:row];
			break;
		}
			
		case 1:
		{
			[self selectedTaxCellAtRow:row];
			break;
		}
			
		case 2:
		{
			[self selectedBusinessCellAtRow:row];
			break;
		}
			
		case 3:
		{
			[self selectedDocumentCellAtRow:row];
			break;
		}
			
		case 4:
		{
			[self selectedCustomizeCellAtRow:row];
			break;
		}
			
		case 5:
		{
			[self selectedSecurityCellAtRow:row];
			break;
		}
			
		case 7:
		{
			[self selectedSupportCellAtRow:row];
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedCompanyCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//profile
			ProfileVC * vc = [[ProfileVC alloc] init];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 1:
		{
			//terms
			[self openPickerForCase:kPickerCaseTerms];
			
			break;
		}
			
		case 2:
		{
			kApplicationVersion version = app_version;
			
			switch (version)
			{
				case kApplicationVersionInvoice:
				{
					[(UITextField*)[self.view viewWithTag:555] becomeFirstResponder];
					break;
				}
					
				case kApplicationVersionQuote:
				{
					[(UITextField*)[self.view viewWithTag:444] becomeFirstResponder];
					break;
				}
					
				case kApplicationVersionEstimate:
				{
					[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
					break;
				}
					
				case kApplicationVersionPurchase:
				{
					[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
					break;
				}
					
				case kApplicationVersionReceipts:
				{
					[(UITextField*)[self.view viewWithTag:221] becomeFirstResponder];
					break;
				}
					
				case kApplicationVersionTimesheets:
				{
					[(UITextField*)[self.view viewWithTag:220] becomeFirstResponder];
					break;
				}
					
				default:
					break;
			}
			
			break;
		}
			
		case 3:
		{
			[(UITextField*)[self.view viewWithTag:444] becomeFirstResponder];
			break;
		}
			
		case 4:
		{
			[(UITextField*)[self.view viewWithTag:333] becomeFirstResponder];
			break;
		}
			
		case 5:
		{
			[(UITextField*)[self.view viewWithTag:222] becomeFirstResponder];
			break;
		}
			
		case 6:
		{
			[(UITextField*)[self.view viewWithTag:221] becomeFirstResponder];
			break;
		}
			
		case 7:
		{
			[(UITextField*)[self.view viewWithTag:220] becomeFirstResponder];
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedTaxCellAtRow:(int)row {
	switch (row) {
		case TaxType: {
			//tax type
			[self openPickerForCase:kPickerCaseTaxType];
			
			break;
		}
			
		case Tax1Rate: {
			//tax 1
			[(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
			
			break;
		}
      
    case Tax1Abreviation: {
      [(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
      break;
    }
			
		case Tax2Rate: {
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
      
			if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"]) {
				//tax reg no.
				[(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
			} else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Compound Tax"]) {
				//tax 2
				[(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
			}
			
			break;
		}
      
    case Tax2Abreviation: {
      [(UITextField*)[self.view viewWithTag:row] becomeFirstResponder];
      
      break;
    }
			
		case TaxRegNo: {
			//tax reg no.
			[(UITextField*)[self.view viewWithTag:888] becomeFirstResponder];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedDocumentCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			//default template
			TemplatesVC * vc = [[TemplatesVC alloc] init];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 1:
		{
			//default note
			DefaultNoteVC * vc = [[DefaultNoteVC alloc] init];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		case 2:
		{
			[(UITextField*)[self.view viewWithTag:111] becomeFirstResponder];
			
			break;
		}
			
		case 3:
		{
			[data_manager changeCurrencyPlacement];
			[mainTableView reloadData];
			
			break;
		}
			
		case 4:
		{
			[(UITextField*)[self.view viewWithTag:199] becomeFirstResponder];
			
//			[data_manager changeThousandSymbol];
//			[mainTableView reloadData];
			
			break;
		}
			
		case 5:
		{
			[(UITextField*)[self.view viewWithTag:198] becomeFirstResponder];
/*			[data_manager changeDecimalSymbol];
			[mainTableView reloadData]; */
			
			break;
		}
			
		case 6:
		{
			[data_manager changeDecimalPlacement];
			[mainTableView reloadData];
			
			break;
		}
			
		case 7:
		{
			[self openPickerForCase:kPickerCaseDateFormat];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedCustomizeCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			NSMutableArray * buttons = [[NSMutableArray alloc] init];
			[buttons addObject:@"Library"];
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				[buttons addObject:@"Camera"];
			}
      
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
			
			if (![[settingsDictionary objectForKey:@"background_image"] isEqual:@""])
			{
				[buttons addObject:@"Remove"];
			}
			
			AlertView *alertView = [[AlertView alloc] initWithTitle:@"Change Background Image" message:@"Select Image Source:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:buttons];
			alertView.tag = 1;
			[alertView showInWindow];
					
			break;
		}
			
		case 1:
		{
			LanguageVC *vc = [[LanguageVC alloc] init];
			[self.navigationController pushViewController:vc animated:YES];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedSecurityCellAtRow:(int)row
{
	//password lock
	
	PasscodeLockVC * vc = [[PasscodeLockVC alloc] init];
	[self.navigationController pushViewController:vc animated:YES];
}

-(void)selectedBusinessCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{
			[(UITextField*)[self.view viewWithTag:777] becomeFirstResponder];
			
			break;
		}
			
		case 1:
		{
			[(UITextField*)[self.view viewWithTag:666] becomeFirstResponder];
			
			break;
		}
			
		default:
			break;
	}
}

-(void)selectedSupportCellAtRow:(int)row
{
	switch (row)
	{
		case 0:
		{			
			//send feedback
			[[UIApplication sharedApplication] openURL:APPSTORE_LINK];
			
			break;
		}
			
		case 1:
		{
			//version
			
			break;
		}
			
		case 2:
		{
			//restore
			[DELEGATE.storeManager restorePurchases];
			
			break;
		}
			
		default:
			break;
	}
}

#pragma mark - OPEN PICKER

-(void)openPickerForCase:(kPickerCase)type
{
	if ([self.navigationController.view viewWithTag:101010] && current_picker_type == type)
		return;
	
  [activeTextField resignFirstResponder];
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
	[(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:777] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:666] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:221] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:220] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:199] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:198] resignFirstResponder];
	
	current_picker_type = type;
	
	UIView * viewWithPicker = [[UIView alloc] initWithFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
	[viewWithPicker setBackgroundColor:[UIColor clearColor]];
	[viewWithPicker setTag:101010];
	[viewWithPicker.layer setMasksToBounds:YES];
	[self.navigationController.view addSubview:viewWithPicker];
	
	UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, keyboard_height)];
	picker.backgroundColor = [UIColor whiteColor];
	[picker setDelegate:self];
	[picker setDataSource:self];
	
	if (!iPad)
	{
		[picker setTransform:CGAffineTransformMakeScale(1.09, 1.09)];
	}
	else
	{
		[picker setTransform:CGAffineTransformMakeScale(1.0, (float)(keyboard_height) / 216.0f)];
	}
	
	[picker setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
	[viewWithPicker addSubview:picker];
	
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	switch (current_picker_type)
	{
		case kPickerCaseTerms:
		{
			[picker selectRow:[[settingsDictionary objectForKey:@"terms"] intValue] inComponent:0 animated:YES];
			[picker reloadAllComponents];
			break;
		}
		
		case kPickerCaseTaxType:
		{
			[picker selectRow:[taxTypeArray indexOfObject:[settingsDictionary objectForKey:@"taxType"]] inComponent:0 animated:YES];
			[picker reloadAllComponents];
			break;
		}
			
		case kPickerCaseDateFormat:
		{
			[picker selectRow:[[CustomDefaults customObjectForKey:@"user_selected_date_format"] intValue] inComponent:0 animated:YES];
			[picker reloadAllComponents];
			break;
		}
			
		default:
			break;
	}
	
	UIView * indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[indicator setBackgroundColor:app_tab_selected_color];
	[indicator setCenter:CGPointMake(dvc_width / 2, keyboard_height / 2)];
	[indicator setAlpha:0.2];
	[indicator setUserInteractionEnabled:NO];
	[viewWithPicker addSubview:indicator];
	
	ToolBarView * thePikerToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[thePikerToolbar.prevButton setAlpha:0.0];
	[thePikerToolbar.nextButton setAlpha:0.0];
	[thePikerToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[thePikerToolbar setTag:999];
	[theSelfView addSubview:thePikerToolbar];
	
	[UIView animateWithDuration:0.25 animations:^{
		
		[viewWithPicker setFrame:CGRectMake(0, dvc_height - keyboard_height + 20, dvc_width, keyboard_height)];
		[thePikerToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[mainTableView setFrame:CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
		if (mainTableView && [mainTableView respondsToSelector:@selector(didScroll)])
			[mainTableView didScroll];
		
	}];
}

-(void)closePicker:(UIButton*)sender
{
	if (current_picker_type == kPickerCaseTaxType)
	{
		[self checkTaxConfiguration];
	}
  
  if(activeTextField) {
    [activeTextField resignFirstResponder];
    activeTextField = nil;
  }
    
	[(UITextField*)[self.view viewWithTag:888] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:777] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:666] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:555] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:444] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:333] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:222] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:221] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:220] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:111] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:199] resignFirstResponder];
	[(UITextField*)[self.view viewWithTag:198] resignFirstResponder];
  [(UITextField*)[self.view viewWithTag:INVOICE_PREF_FIELD_INDEX] resignFirstResponder];
  [(UITextField*)[self.view viewWithTag:QUOTE_PREF_FIELD_INDEX] resignFirstResponder];
  [(UITextField*)[self.view viewWithTag:ESTIMATE_PREF_FIELD_INDEX] resignFirstResponder];
  [(UITextField*)[self.view viewWithTag:PURCHASE_PREF_FIELD_INDEX] resignFirstResponder];
		
	[UIView animateWithDuration:0.25 animations:^{
    [[self.navigationController.view viewWithTag:101010] setFrame:CGRectMake(0, dvc_height + 60, dvc_width, keyboard_height)];
    [[self.view viewWithTag:999] setFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
        
    [mainTableView setFrame:CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, dvc_width, dvc_height - 87)];
        
    if (mainTableView && [mainTableView respondsToSelector:@selector(didScroll)]) {
      [mainTableView didScroll];
    }
	} completion:^(BOOL finished) {
		[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
		[[self.view viewWithTag:999] removeFromSuperview];
	}];
}

#pragma mark - PICKERVIEW DATASOURCE

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (current_picker_type)
	{
		case kPickerCaseTerms:
		{
			return 8;
			break;
		}
			
		case kPickerCaseTaxType:
		{
			return taxTypeArray.count;
			break;
		}
			
		case kPickerCaseDateFormat:
		{
			return 3;
			break;
		}
			
		default:
			break;
	}
	
	return 0;
}

-(UIView*)pickerView:(UIPickerView*)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view
{
	UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 30)];
	[theView setBackgroundColor:[UIColor clearColor]];
	
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, dvc_width - 60, 30)];
	[label setTextAlignment:NSTextAlignmentLeft];
	[label setTextColor:[UIColor darkGrayColor]];
	[label setFont:HelveticaNeue(15)];
	[label setBackgroundColor:[UIColor clearColor]];
	[theView addSubview:label];
	
	if (row == [pickerView selectedRowInComponent:component])
	{
		[label setTextColor:[UIColor blackColor]];
	}
	
	switch (current_picker_type)
	{
		case kPickerCaseTerms:
		{
			[label setText:[TermsManager termsString:(int)row]];
			break;
		}
			
		case kPickerCaseTaxType:
		{
			[label setText:[taxTypeArray objectAtIndex:row]];
			break;
		}
			
		case kPickerCaseDateFormat:
		{
			[date_formatter setDateFormat:[DELEGATE formatForType:(int)row]];
			[label setText:[date_formatter stringFromDate:[NSDate date]]];
			break;
		}
			
		default:
			break;
	}
	
	return theView;
}

#pragma mark - PICKERVIEW DELEGATE

-(CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	[pickerView reloadAllComponents];
	
	switch (current_picker_type)
	{
		case kPickerCaseTerms:
		{
			[settingsDictionary setObject:[NSNumber numberWithInt:(int)row] forKey:@"terms"];
			
			break;
		}
			
		case kPickerCaseTaxType:
		{
			[settingsDictionary setObject:[taxTypeArray objectAtIndex:row] forKey:@"taxType"];
			
			if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"No Tax"])
			{
				[settingsDictionary setObject:@"" forKey:@"taxAbreviation1"];
				[settingsDictionary setObject:@"0.0" forKey:@"taxRate1"];
				
				[settingsDictionary setObject:@"" forKey:@"taxAbreviation2"];
				[settingsDictionary setObject:@"0.0" forKey:@"taxRate2"];

				[CustomDefaults setCustomBool:NO forKey:kDefaultTaxable];
			}
			else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"])
			{
				[settingsDictionary setObject:@"" forKey:@"taxAbreviation2"];
				[settingsDictionary setObject:@"0.0" forKey:@"taxRate2"];
			}
			
			break;
		}
			
		case kPickerCaseDateFormat:
		{
			[CustomDefaults setCustomObjects:[NSNumber numberWithInteger:row] forKey:@"user_selected_date_format"];
			break;
		}
			
		default:
			break;
	}
	
	[CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
  [mainTableView reloadData];
}

#pragma mark - TEXTFIELD DELEGATE

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
  activeTextField = textField;
  
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
	
	if((UIButton*)[DELEGATE.window viewWithTag:998877] != nil) {
		[(UIButton*)[DELEGATE.window viewWithTag:998877] removeFromSuperview];
	}
	
	if (textField.tag < 666 && textField.tag > 111 && textField.tag != 199 && textField.tag != 198 && !((textField.tag >= INVOICE_PREF_FIELD_INDEX && textField.tag <= PURCHASE_PREF_FIELD_INDEX))) {
		int value = [[textField.text stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""] intValue];
		
		[textField setText:[NSString stringWithFormat:@"%d", value]];
	}

	UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, dvc_width, dvc_height)];
	[closeButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[closeButton setBackgroundColor:[UIColor clearColor]];
	[closeButton setTag:998877];
	[DELEGATE.window addSubview:closeButton];
	
	ToolBarView * thePikerToolbar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, dvc_height, dvc_width, 40)];
	[thePikerToolbar.prevButton setAlpha:0.0];
	[thePikerToolbar.nextButton setAlpha:0.0];
	[thePikerToolbar.doneButton addTarget:self action:@selector(closePicker:) forControlEvents:UIControlEventTouchUpInside];
	[thePikerToolbar setTag:999];
	[theSelfView addSubview:thePikerToolbar];
	
	[UIView animateWithDuration:0.25 animations:^{
		[thePikerToolbar setFrame:CGRectMake(0, dvc_height - keyboard_height - 40, dvc_width, 40)];
		[mainTableView setFrame:CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, dvc_width, dvc_height - 82 - keyboard_height)];
		
		if (mainTableView && [mainTableView respondsToSelector:@selector(didScroll)])
			[mainTableView didScroll];
	} completion:^(BOOL finished) {
		if ([textField.superview isKindOfClass:[CellWithText class]]) {
			[mainTableView scrollToRowAtIndexPath:[mainTableView indexPathForCell:(CellWithText*)textField.superview] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		}
	}];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if(textField.tag == Tax1Rate || textField.tag == Tax2Rate) {
    activeTextField = textField;
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    if ([value floatValue] == 0.0f) {
      [textField setText:@" %"];
    }
    
    UITextPosition *positionBeginning = [textField endOfDocument];
    
    UITextRange *textRange = [textField textRangeFromPosition:positionBeginning
                                                  toPosition:positionBeginning];
    
    // Calculate the new position, - for left and + for right
    UITextPosition *newPosition = [textField positionFromPosition:textRange.start offset:-2];
    
    // Construct a new range using the object that adopts the UITextInput, our textfield
    UITextRange *newMiddleRange = [textField textRangeFromPosition:newPosition
                                                   toPosition:newPosition];
    UITextRange *newRange = [textField textRangeFromPosition:newPosition toPosition:newMiddleRange.start];

    [textField setSelectedTextRange:newRange];
  }
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField {
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
  
	if (textField.tag == 888) {
		[settingsDictionary setObject:textField.text forKey:@"taxRegNo"];
	} else if (textField.tag == 777) {
		[settingsDictionary setObject:textField.text forKey:@"businessName"];
	} else if (textField.tag == 666) {
		[settingsDictionary setObject:textField.text forKey:@"businessNumber"];
	} else if (textField.tag == 555) {
		int x = [textField.text intValue];
		if (x < 1)
			x = 1;
		
    [CustomDefaults setCustomInteger:x forKey:kNumberOfInvoicesKeyForNSUserDefaults];
    
    int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfInvoicesKeyForNSUserDefaults];
    
    NSString *pref = [InvoiceDefaults invoicePref];
    NSString * value = [self numberWithPref:pref number:temp];
    
    [textField setText:value];
	} else if (textField.tag == 444) {
		int x = [textField.text intValue];
		if (x < 1)
			x = 1;
		
		[CustomDefaults setCustomInteger:x forKey:kNumberOfQuotesKeyForNSUserDefaults];
		
		int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfQuotesKeyForNSUserDefaults];
		
        NSString * value = [self numberWithPref:[QuoteDefaults quotePref] number:temp];
		
		[textField setText:value];
	} else if (textField.tag == 333) {
		int x = [textField.text intValue];
		if (x < 1)
			x = 1;
		
		[CustomDefaults setCustomInteger:x forKey:kNumberOfEstimatesKeyForNSUserDefaults];
		
		int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfEstimatesKeyForNSUserDefaults];
		
        NSString * value = [self numberWithPref:[EstimateDefaults estimatePref] number:temp];
		
		[textField setText:value];
	} else if (textField.tag == 222) {
		int x = [textField.text intValue];
		if (x < 1)
			x = 1;
		
		[CustomDefaults setCustomInteger:x forKey:kNumberOfPurchaseOrdersKeyForNSUserDefaults];
		
		int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfPurchaseOrdersKeyForNSUserDefaults];
		
        NSString * value = [self numberWithPref:[PurchaseDefaults purchasePref] number:temp];
		
		[textField setText:value];
	} else if (textField.tag == 221) {
		int x = [textField.text intValue];
		
		if(x < 1)
			x = 1;
		
		[CustomDefaults setCustomInteger:x forKey:kNumberOfRecipeKeyForNSUserDefaults];
				
		int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfRecipeKeyForNSUserDefaults];
		
        NSString * value = [self numberWithPref:@"RT" number:temp];
		
		[textField setText:value];
	} else if (textField.tag == 220) {
		int x = [textField.text intValue];
		
		if(x < 1)
			x = 1;
		
		[CustomDefaults setCustomInteger:x forKey:kNumberOfTimesheetKeyForNSUserDefaults];
		
		int temp = (int)[CustomDefaults customIntegerForKey:kNumberOfTimesheetKeyForNSUserDefaults];
		
        NSString * value = [self numberWithPref:@"TS" number:temp];
		
		[textField setText:value];
	} else if (textField.tag == 111) {
		[data_manager setCurrency:textField.text];
	} else if (textField.tag == 199) {
		if([textField.text isEqual:@""] || textField.text == nil) {
			AlertView *alert = [[AlertView alloc] initWithTitle:@"" message:@"Please set a character for thousands separator symbol!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			alert.tag = 199;
			[alert showInWindow];
		} else {
			[data_manager changeThousandSymbol:textField.text];
		}
	} else if (textField.tag == 198) {
		if([textField.text isEqual:@""] || textField.text == nil) {
			AlertView *alert = [[AlertView alloc] initWithTitle:@"" message:@"Please set a character for decimal separator symbol!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			alert.tag = 198;
			[alert showInWindow];
		} else {
			[data_manager changeDecimalSymbol:textField.text];
		}
    } else if (textField.tag == INVOICE_PREF_FIELD_INDEX) {
        [InvoiceDefaults setInvoicePref:textField.text];
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else if (textField.tag == QUOTE_PREF_FIELD_INDEX) {
        [QuoteDefaults setQuotePref:textField.text];
        kApplicationVersion version = app_version;
        NSInteger rowIndex = version == kApplicationVersionInvoice?4:2;
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else if (textField.tag == ESTIMATE_PREF_FIELD_INDEX) {
        [EstimateDefaults setEstimatePref:textField.text];
        kApplicationVersion version = app_version;
        NSInteger rowIndex = version == kApplicationVersionInvoice?6:2;
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else if (textField.tag == PURCHASE_PREF_FIELD_INDEX) {
        [PurchaseDefaults setPurchasePref:textField.text];
        kApplicationVersion version = app_version;
        NSInteger rowIndex = version == kApplicationVersionInvoice?8:2;
        [mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
		
  
  //tax editing
  BOOL taxEdited = NO;
  if(textField.tag == Tax1Rate) {
    taxEdited = YES;
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    [settingsDictionary setObject:value forKey:@"taxRate1"];
  } else if (textField.tag == Tax1Abreviation) {
    taxEdited = YES;
    [settingsDictionary setObject:textField.text forKey:@"taxAbreviation1"];
  } else if (textField.tag == Tax2Rate) {
    taxEdited = YES;
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    [settingsDictionary setObject:value forKey:@"taxRate2"];
  } else if(textField.tag == Tax2Abreviation) {
    taxEdited = YES;
    [settingsDictionary setObject:textField.text forKey:@"taxAbreviation2"];
  }
  [CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
  
  if(taxEdited) {
    [DELEGATE checkTaxConfiguration];
    if(![DELEGATE tax_misconfigured]) {
      [data_manager makeProductsAndServicesTaxable];
    }
  }
  
  if(textField.tag == Tax1Rate || textField.tag == Tax2Rate) {
    NSString *value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
    if([value floatValue] == 0) {
      textField.text = @"0.0 %";
    } else if (![textField.text containsString:@"%"]) {
      value = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
      textField.text = [NSString stringWithFormat:@"%@ %@", value, @"%"];
    }
  }
  
	[[self.navigationController.view viewWithTag:101010] removeFromSuperview];
	[[self.view viewWithTag:999] removeFromSuperview];
	
	if((UIButton*)[DELEGATE.window viewWithTag:998877] != nil) {
		[(UIButton*)[DELEGATE.window viewWithTag:998877] removeFromSuperview];
	}
		
	[UIView animateWithDuration:0.25 animations:^{
		[mainTableView setFrame:CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, dvc_width, dvc_height - 87)];
		if (mainTableView && [mainTableView respondsToSelector:@selector(didScroll)]) {
			[mainTableView didScroll];
        }
	}];
	
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
	[textField resignFirstResponder];
	
	return YES;
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	if (textField.tag != 198 && textField.tag != 199 && !(textField.tag >= INVOICE_PREF_FIELD_INDEX && textField.tag <= PURCHASE_PREF_FIELD_INDEX))
		return YES;
	
	NSString * result = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
    if((textField.tag >= INVOICE_PREF_FIELD_INDEX && textField.tag <= PURCHASE_PREF_FIELD_INDEX)) {
        return result.length <= 4;
    }
    
	if(result.length > 1)
		return NO;
	
	return YES;
}

#pragma mark - IMAGE PICKER DELEGATE

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[DELEGATE addLoadingView];
		
	});
	
	float delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		UIImage * selectedImage = [[UIImage alloc] initWithData:UIImagePNGRepresentation([data_manager scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage] andResolution:640])];
		
		CCropImage * cropper = [[CCropImage alloc] initWithFrame:CGRectMake(0, 20, dvc_width, dvc_height) imageData:UIImageJPEGRepresentation(selectedImage, 1.0f) andTag:1.0];
		[cropper setDelegate:self];
		[self.navigationController.view addSubview:cropper];
		
		if (iPad)
		{
			[popOver dismissPopoverAnimated:YES];
		}
		else
		{
			[picker dismissViewControllerAnimated:YES completion:nil];
		}
		
		[DELEGATE removeLoadingView];
		
	});
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IMAGE CROPPER DELEGATE

-(void)cropperDidCropImage:(UIImage*)image
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/background_image.png"];
	
	if(![manager fileExistsAtPath:path])
	{
		[manager createFileAtPath:path contents:[[NSData alloc] init] attributes:nil];
        
        NSData *data = [[NSData alloc] init];
        [data writeToFile:path atomically:YES];
	}
	
	NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
	
	[imageData writeToFile:path atomically:YES];
	
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
	[settingsDictionary setObject:@"/Documents/background_image.png" forKey:@"background_image"];
	
	[CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
	
	[mainTableView reloadData];
}

#pragma mark - CHECK TAX

-(void)checkTaxConfiguration
{
  NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
    
    BOOL tax_misconfigured = NO;
	
	if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Single Tax"])
	{
		NSString * abr1 = [settingsDictionary objectForKey:@"taxAbreviation1"];
		NSString * rate1 = [settingsDictionary objectForKey:@"taxRate1"];
		
		if ([abr1 isEqual:@""] || [rate1 floatValue] == 0.0f)
		{
			tax_misconfigured = YES;
		}
	}
	else if ([[settingsDictionary objectForKey:@"taxType"] isEqual:@"Compound Tax"])
	{
		NSString * abr1 = [settingsDictionary objectForKey:@"taxAbreviation1"];
		NSString * rate1 = [settingsDictionary objectForKey:@"taxRate1"];
		
		NSString * abr2 = [settingsDictionary objectForKey:@"taxAbreviation2"];
		NSString * rate2 = [settingsDictionary objectForKey:@"taxRate2"];
		
		if ([abr1 isEqual:@""] || [rate1 floatValue] == 0.0f || [abr2 isEqual:@""] || [rate2 floatValue] == 0.0f)
		{
			tax_misconfigured = YES;
		}
	}
	
	[DELEGATE setTax_misconfigured:tax_misconfigured];
}

#pragma mark - ALERT VIEW DELEGATE

-(void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 1)
	{
		UIImagePickerController * picker = [[UIImagePickerController alloc] init];
		[picker setDelegate:self];
		
		if (buttonIndex == 1)
		{
			[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		}
		else if (buttonIndex == 2 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		{
			[picker setSourceType:UIImagePickerControllerSourceTypeCamera];
		}
		else
		if(buttonIndex != 0)
		{
      NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] initWithDictionary:[CustomDefaults customObjectForKey:kSettingsKeyForNSUserDefaults]];
      
			NSFileManager *manager = [NSFileManager defaultManager];
			NSString *path = [NSHomeDirectory() stringByAppendingString:[settingsDictionary objectForKey:@"background_image"]];
		
			[manager removeItemAtPath:path error:nil];
			
			[settingsDictionary setObject:@"" forKey:@"background_image"];
			
			[CustomDefaults setCustomObjects:settingsDictionary forKey:kSettingsKeyForNSUserDefaults];
			
			[mainTableView reloadData];
			
			return;
		}
		else
		{
			return;
		}
		
		if (iPad)
		{
			popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
			[popOver presentPopoverFromRect:CGRectMake(dvc_width - 80, 11 * 42 + 10, 38, 38) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else
		{
			[self.navigationController presentViewController:picker animated:YES completion:nil];
		}
		
		return;
	}
	
	[(UITextField*)[self.view viewWithTag:alertView.tag] becomeFirstResponder];
}

#pragma mark - VIEW CONTROLLER FUNCTIONS

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [mainTableView layoutIfNeeded];
    [mainTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self checkTaxConfiguration];

  [mainTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(void)dealloc
{
	[mainTableView setDelegate:nil];
}

@end