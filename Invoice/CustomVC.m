//
//  CustomVC.m
//  Invoice
//
//  Created by XGRoup on 6/25/14.
//  Copyright (c) 2014 XGRoup. All rights reserved.
//

#import "CustomVC.h"
#import "Defines.h"
#import "CellWithPush.h"
#import "CellWithText.h"
#import "BaseTableCell.h"
#import "AddClientAddressVC.h"
#import "ProfileVC.h"
#import "DropboxManager.h"

#define CELL_HEIGHT 42.f

typedef NS_ENUM(NSInteger, ActionSheetActions) {
    ActionSave,
    ActionPreview,
    ActionEmail,
    ActionPrint,
    ActionCancel,
};

@interface CustomVC () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, AddClientAddressVCDelegate, UITableViewDataSource, UITableViewDelegate> {
  NSArray *ipadTableViews;
  
  UITableView *currentEditingTable;
}

@end

@implementation CustomVC

- (UIStatusBarStyle) preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentEditingSection = -1;
    
    if(![self useOtherTopBar]) {
        topBarView = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, dvc_width, 42 + statusBarHeight) andTitle:@""];
        [topBarView setBackgroundColor:app_bar_update_color];
        
        UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 42 + statusBarHeight - 40, 80, 40)];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [cancel.titleLabel setFont:HelveticaNeueLight(17)];
        [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [topBarView addSubview:cancel];
        
        UIButton * done = [[UIButton alloc] initWithFrame:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 32, 32)];
        [done setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [done setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        [done addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
        [topBarView addSubview:done];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BaseOBJ *)baseObject {
    return nil;
}

- (NSData *)PDFData {
  return [PDFCreator PDFDataFromUIView:[PDFCreator PDFViewFromBaseObject:[self baseObject]]];
}

- (BOOL)useOtherTopBar {
    return YES;
}

- (void)showActionSheet {
  [activeTextField resignFirstResponder];
  
    UIActionSheet *doneActions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Preview", @"Email", @"Print", nil];
    [doneActions showInView:self.view];
}

- (void)saveObject {
  if(isNewInvoice) {
    [CustomDefaults setCustomInteger:numberOfDocuments forKey:[self numberOfDocumentsKey]];
  }
}

- (BOOL)isFilledIn {
    return NO;
}

- (NSString *)numberOfDocumentsKey {
  return @" ";
}

- (void)selectYourCompanyCell {
  ProfileVC * vc = [[ProfileVC alloc] init];
  vc.baseObject = [self baseObject];
  vc.isNewDocument = isNewInvoice;
  [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - iPad view methods

- (UITableView *)customTableWithFrame:(CGRect)frame {
  UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [tableView setScrollEnabled:NO];
  [tableView setBackgroundColor:[UIColor clearColor]];
  [tableView setSeparatorColor:[UIColor clearColor]];
  [tableView layoutIfNeeded];
  
  UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
  [bgView setBackgroundColor:[UIColor clearColor]];
  [tableView setBackgroundView:bgView];
  
  return tableView;
}

- (void)addIpadTableViews {
  BOOL isInvoice = moduleType == ModuleInvoiceType;
  
  CGFloat clientTableOffset = 30.f;
  CGFloat startY = 52.f;
  
  ipadTablesView = [[UIScrollView alloc] initWithFrame:theSelfView.bounds];
  [theSelfView addSubview:ipadTablesView];
  
  CGFloat mainTableHeight = (dvc_height - (isInvoice?30:0)) / 2.5;
  CGFloat markAsOpenHeight = isInvoice?dvc_height / 9.5:0;
  
  //title and company
  UITableView *titleAndComtanyTable = [self customTableWithFrame:CGRectMake(0,
                                                                            startY,
                                                                            dvc_width / 2,
                                                                            mainTableHeight - markAsOpenHeight + 10 - clientTableOffset)];
  titleAndComtanyTable.tag = TableTitleAndCompanyTag;
  
  [ipadTablesView addSubview:titleAndComtanyTable];
  
  //details
  UITableView *detailsTable = [self customTableWithFrame:CGRectMake(dvc_width / 2,
                                                                    startY,
                                                                    dvc_width / 2,
                                                                    mainTableHeight - markAsOpenHeight - clientTableOffset)];
  detailsTable.tag = TableDetailsTag;
  
  [ipadTablesView addSubview:detailsTable];
  
  //client and product
  UITableView *clientAndProductTable = [self customTableWithFrame:CGRectMake(0,
                                                                             CGRectGetMaxY(detailsTable.frame),
                                                                             dvc_width,
                                                                             mainTableHeight - markAsOpenHeight + clientTableOffset)];
  clientAndProductTable.tag = TableClientAndProductsTag;
  
  [ipadTablesView addSubview:clientAndProductTable];
  
  //optional info
  UITableView *optionalInfoTable = [self customTableWithFrame:CGRectMake(0,
                                                                         CGRectGetMaxY(clientAndProductTable.frame),
                                                                         dvc_width / 2,
                                                                         mainTableHeight - markAsOpenHeight)];
  optionalInfoTable.tag = TableOptionalInfoTag;
  
  [ipadTablesView addSubview:optionalInfoTable];
  
  //figures
  UITableView *figuresTable = [self customTableWithFrame:CGRectMake(dvc_width / 2,
                                                                    CGRectGetMaxY(clientAndProductTable.frame),
                                                                    dvc_width / 2,
                                                                    mainTableHeight - markAsOpenHeight)];
  figuresTable.tag = TableFiguresTag;
  
  [ipadTablesView addSubview:figuresTable];
  
  //mark as open
  UITableView *markAsOpenTable = nil;
  if(isInvoice) {
    markAsOpenTable = [self customTableWithFrame:CGRectMake(0,
                                                            CGRectGetMaxY(figuresTable.frame),
                                                            dvc_width,
                                                            ipadTablesView.frame.size.height - CGRectGetMaxY(figuresTable.frame))];
    markAsOpenTable.tag = TableMarkAsOpenTag;
    
    [ipadTablesView addSubview:markAsOpenTable];
  }
  
  ipadTableViews = [[NSArray alloc] initWithObjects:titleAndComtanyTable, detailsTable, clientAndProductTable, optionalInfoTable, figuresTable, markAsOpenTable, nil];
  
  [self layoutAllTableViewsAnimated:NO];
}

- (void)layoutAllTableViewsAnimated:(BOOL)animated {
  CGFloat newY = 0;
  
  CGFloat heightEdgeOffset = 55.f;
  
  [UIView beginAnimations:@"anim" context:nil];
  [UIView setAnimationDuration:animated?0.25f:0];
  UITableView *table = ipadTableViews[TableTitleAndCompanyTag];
  CGRect frame = table.frame;
  frame.size.height = table.contentSize.height;
  table.frame = frame;
  newY = CGRectGetMaxY(frame);
  
  table = ipadTableViews[TableDetailsTag];
  frame = table.frame;
  frame.size.height = ([self numberOfRowsInDetailsSection] + 1) * CELL_HEIGHT + heightEdgeOffset;
  table.frame = frame;
  
  newY = MAX(newY, CGRectGetMaxY(frame));
  
  table = ipadTableViews[TableClientAndProductsTag];
  frame = table.frame;
  frame.size.height = ([self numberOfRowsInClientSection] + [[[self baseObject] products] count] + 1) * CELL_HEIGHT + 1.5 * heightEdgeOffset;
  frame.origin.y = newY;
  table.frame = frame;
  
  newY = CGRectGetMaxY(frame) + heightEdgeOffset / 3;
  
  table = ipadTableViews[TableOptionalInfoTag];
  frame = table.frame;
  frame.size.height = table.contentSize.height;
  frame.origin.y = newY;
  table.frame = frame;
  CGFloat optionalTableMaxY = CGRectGetMaxY(frame);
  
  table = ipadTableViews[TableFiguresTag];
  frame = table.frame;
  frame.size.height = [self numberOfRowsInFigureSection] * CELL_HEIGHT + heightEdgeOffset;
  frame.origin.y = newY;
  table.frame = frame;
  
  newY = MAX(CGRectGetMaxY(frame), optionalTableMaxY);
  
  if([ipadTableViews count] > TableMarkAsOpenTag) {
    table = ipadTableViews[TableMarkAsOpenTag];
    frame = table.frame;
    frame.size.height = table.contentSize.height;
    frame.origin.y = newY;
    table.frame = frame;
    newY = CGRectGetMaxY(frame);
  }
  newY += 10.f;
  ipadTablesView.contentSize = CGSizeMake(ipadTablesView.frame.size.width, newY);
  
  [UIView commitAnimations];
}

- (UITableView *)tableViewForTag:(IpadTableTag)tag {
  if(iPad && moduleType != ModuleOtherType) {
    if([ipadTableViews count] > tag) {
      return ipadTableViews[tag];
    }
  }
  return myTableView;
}

- (UITableView *)tableViewForSection:(SectionTag)tag {
  if(iPad && moduleType != ModuleOtherType) {
    if(tag == SectionTitle || tag == SectionYourCompany) return ipadTableViews[TableTitleAndCompanyTag];
    if(tag == SectionDetails) return ipadTableViews[TableDetailsTag];
    if(tag == SectionClient || tag == SectionProductsAndServices) return ipadTableViews[TableClientAndProductsTag];
    if(tag == SectionOptionalInfo) return ipadTableViews[TableOptionalInfoTag];
    if(tag == SectionFigure) return  ipadTableViews[TableFiguresTag];
    if(tag == SectionMarcAsOpen) return ipadTableViews[TableMarkAsOpenTag];
  }
  
  return myTableView;
}

- (void)reloadTableView {
  if(iPad && moduleType != ModuleOtherType) {
    [ipadTableViews makeObjectsPerformSelector:@selector(reloadData)];
  } else {
    [myTableView reloadData];
  }
}

- (void)removeDelegates {
  if(iPad && moduleType != ModuleOtherType) {
    [ipadTableViews makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
    [ipadTableViews makeObjectsPerformSelector:@selector(setDataSource:) withObject:nil];
  } else {
    [myTableView setDelegate:nil];
    [myTableView setDataSource:nil];
  }
}

- (void)layoutTableView {
  if(iPad && moduleType != ModuleOtherType) {
    [ipadTableViews makeObjectsPerformSelector:@selector(layoutIfNeeded)];
  } else {
    [myTableView layoutIfNeeded];
  }
}

- (SectionTag)sectionTagInTable:(UITableView *)tableView section:(NSInteger)section {
  if(iPad && moduleType != ModuleOtherType) {
    switch (tableView.tag) {
      case TableTitleAndCompanyTag:
        return section;
        break;
        
      case TableDetailsTag:
        return SectionDetails;
        break;
        
      case TableClientAndProductsTag: {
        SectionTag sectionTag = section;
        if(section == 0) {
          sectionTag = SectionClient;
        } else if (section == 1) {
          sectionTag = SectionProductsAndServices;
        }
        return sectionTag;
      }
        break;
        
      case TableOptionalInfoTag:
        return SectionOptionalInfo;
        break;
        
      case TableFiguresTag:
        return SectionFigure;
        break;
        
      case TableMarkAsOpenTag:
        return SectionMarcAsOpen;
        break;
        
      default:
        break;
    }
  }
  return section;
}

- (NSInteger)sectionIndexForSectionTag:(SectionTag)tag {
  if(iPad && moduleType != ModuleOtherType) {
    if(tag == SectionYourCompany || tag == SectionProductsAndServices) {
      return 1;
    }
    return 0;
  } else {
    return tag;
  }
}

#pragma mark - Dropbox saver

- (void)saveOBjectOnDropbox {
  if(isDropboxBackupOn) {
    NSData *fileData = [self PDFData];
    
    NSString *filename = [NSString stringWithFormat:@"%@.pdf", [[self baseObject] number]];
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [fileData writeToFile:localPath atomically:YES];
    
    [[DropboxManager sharedManager] uploadFileWithName:filename fromPath:localPath];
  }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if(buttonIndex != ActionCancel) {
    if(![self isFilledIn]) {
      return;
    }
  }
  switch (buttonIndex) {
    case ActionSave:
      [self saveObject];
      
      //save file on Dropbox
      [self saveOBjectOnDropbox];
      
      break;
      
    case ActionPreview: {
      
      NSData * pdfData = [self PDFData];
      
      UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, dvc_width, dvc_height)];
      [webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"" baseURL:nil];
      [webView setAlpha:0.0];
      [webView setTag:666];
      [DELEGATE.window addSubview:webView];
      
      UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePreview:)];
      [webView addGestureRecognizer:tap];
      [UIView animateWithDuration:0.25 animations:^{
        [webView setAlpha:1.0];
      }];
    }
      
      break;
    case ActionEmail: {
      if ([MFMailComposeViewController canSendMail]) {
        revertPaperSize;
        
        NSString * fileName = [NSString stringWithFormat:@"%@.pdf", [[self baseObject] number]];
        
        MFMailComposeViewController * vc = [[MFMailComposeViewController alloc] init];
        [vc setSubject:[NSString stringWithFormat:@"%@", [[self baseObject] number]]];
        [vc setToRecipients:[NSArray arrayWithObject:[[[self baseObject] client] email]]];
        [vc setMailComposeDelegate:self];
        [vc addAttachmentData:[self PDFData] mimeType:@"application/pdf" fileName:fileName];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
          double delayInSeconds = 0.2f;
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
          dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self presentViewController:vc animated:YES completion:nil];
          });
        } else {
          [self presentViewController:vc animated:YES completion:nil];
        }
      }
      else {
        [[[AlertView alloc] initWithTitle:@"" message:@"You must configure an email account in the device settings to be able to send emails." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
      }
    }
      
      break;
    case ActionPrint: {
      UIPrintInteractionController * pic = [UIPrintInteractionController sharedPrintController];
      
      NSData * temp = [self PDFData];
      
      if (pic && [UIPrintInteractionController canPrintData:temp]) {
        UIPrintInfo * printInfo = [UIPrintInfo printInfo];
        [printInfo setOutputType:UIPrintInfoOutputGeneral];
        [printInfo setJobName:[NSString stringWithFormat:@"Print %@", [[self baseObject] objTitle]]];
        [printInfo setDuplex:UIPrintInfoDuplexNone];
        [printInfo setOrientation:UIPrintInfoOrientationLandscape];
        
        [pic setPrintInfo:printInfo];
        [pic setShowsPageRange:YES];
        [pic setPrintingItem:temp];
        
        void (^completionHandler)(UIPrintInteractionController*, BOOL, NSError*) = ^(UIPrintInteractionController * pic, BOOL completed, NSError * error) {
          
          if (!completed && error) {
            NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
          }
        };
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
          double delayInSeconds = 0.2f;
          dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
          dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [pic presentFromRect:CGRectMake(dvc_width - 40, 42 + statusBarHeight - 40, 32, 32) inView:topBarView animated:YES completionHandler:completionHandler];
          });
        } else {
          [pic presentAnimated:YES completionHandler:completionHandler];
        }
      }
    }
      
      break;
      
    default:
      break;
  }
}

-(void)closePreview:(UITapGestureRecognizer*)sender {
    [UIView animateWithDuration:0.25 animations:^{
        [[DELEGATE.window viewWithTag:666] setAlpha:0.0];
    } completion:^(BOOL finished) {
        [[DELEGATE.window viewWithTag:666] removeFromSuperview];
    }];
}

#pragma mark - MAIL COMPOSER DELEGATE

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if(result == MFMailComposeResultFailed && error != nil) {
        [[[UIAlertView alloc] initWithTitle:@"Failed to send email" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - AddClientAddressVCDelegate
- (void)didEditedClientAddress:(ClientOBJ *)client {
  [[self baseObject] setClient:[client contentsDictionary]];
}


#pragma mark - TableView Additional Methods

- (kCellType)cellTypeForRow:(NSInteger)row fromCount:(NSInteger)count {
    return count == 1?kCellTypeSingle:((row == count - 1)?kCellTypeBottom:(row == 0)?kCellTypeTop:kCellTypeMiddle);
}

- (void)updateCellsTypeInSection:(SectionTag)section {
  UITableView *editingTable = [self tableViewForSection:section];
  
  NSInteger realSection = [self sectionIndexForSectionTag:section];
  NSInteger rowsNumber = [editingTable numberOfRowsInSection:realSection];
  for(NSInteger row = 0; row < rowsNumber; row++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:realSection];
    BaseTableCell *cell = (BaseTableCell *)[editingTable cellForRowAtIndexPath:indexPath];
    kCellType type = [self cellTypeForRow:row fromCount:rowsNumber];
    if([cell respondsToSelector:@selector(setCellType:)]) {
      [cell setCellType:type];
    }
  }
}

- (void)setCellsEditable:(BOOL)editable inSection:(SectionTag)section {
  UITableView *editingTable = [self tableViewForSection:section];
  
  NSInteger realSection = [self sectionIndexForSectionTag:section];
  NSInteger rowsNumber = [editingTable numberOfRowsInSection:realSection];
  for(NSInteger row = 0; row < rowsNumber; row++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:realSection];
    BaseTableCell *cell = (BaseTableCell *)[editingTable cellForRowAtIndexPath:indexPath];
    [cell setCanEditvalueField:editable];
    [cell setIsTitleEditable:editable];
  }
}

- (void)editSectionPressed:(UIButton *)sender {
  UITableView *editingTableView = [self tableViewForSection:sender.tag];
  
  if((editingTableView.isEditing && currentEditingSection != sender.tag) ||
     (editingTableView != currentEditingTable && currentEditingTable != nil)) {
      return;
  }
  
  NSInteger senderSection = sender.tag;
  if(sender.tag == SectionAddItemDetails || sender.tag == SectionProfile) {
      senderSection = 0;
  }
  NSInteger originalSenderSection = senderSection;
  
  if(iPad && moduleType != ModuleOtherType) {
    senderSection = [self sectionIndexForSectionTag:senderSection];
  }
    
  editingTableView.allowsMultipleSelectionDuringEditing = sender.tag == SectionFigure || sender.tag == SectionDetails || sender.tag == SectionAddItemDetails || sender.tag == SectionProfile || sender.tag == SectionClient;
    
  currentEditingSection = sender.tag;
  [sender setTitle:editingTableView.isEditing?@"Edit":@"Done" forState:UIControlStateNormal];
  BOOL isTableViewEditing = !editingTableView.isEditing;
  if (currentEditingSection == SectionProductsAndServices) {
    [editingTableView setEditing:isTableViewEditing animated:YES];
  }
  
  if(!isTableViewEditing) {
      currentEditingSection = -1;
    currentEditingTable = nil;
  } else {
    currentEditingTable = editingTableView;
  }
  
  if(sender.tag == SectionFigure || sender.tag == SectionDetails || sender.tag == SectionAddItemDetails || sender.tag == SectionClient || sender.tag == SectionProfile) {
    figureSectionIsEditing = isTableViewEditing && sender.tag == SectionFigure;
    detailsSectionIsEditing = isTableViewEditing && sender.tag == SectionDetails;
    addItemDetailsIsEditing = isTableViewEditing && sender.tag == SectionAddItemDetails;
    profileSectionIsEditing = isTableViewEditing && sender.tag == SectionProfile;
    clientSectionIsEditing = isTableViewEditing && sender.tag == SectionClient;
    BOOL isSectionEditing = figureSectionIsEditing || detailsSectionIsEditing || addItemDetailsIsEditing || profileSectionIsEditing || clientSectionIsEditing;
    
    //find rows which need to insert or delete
    NSMutableArray *editedRows = [NSMutableArray new];
    
    NSArray *objectFigureSettings = [self settingsForSection:sender.tag];
    for(NSInteger i = 0; i < [objectFigureSettings count]; i++) {
      NSDictionary *figureSettings = [objectFigureSettings objectAtIndex:i];
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:senderSection];
      
      if(![[figureSettings objectForKey:VISIBILITY] boolValue]) {
        [editedRows addObject:indexPath];
      }
    }
    if([editedRows count] > 0) {
      [self layoutAllTableViewsAnimated:YES];
//      [CATransaction begin];
//      [CATransaction setCompletionBlock:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//          [self layoutAllTableViewsAnimated:YES];
//        });
//      }];
      
      [editingTableView beginUpdates];
      if(isSectionEditing) {
        [editingTableView insertRowsAtIndexPaths:editedRows withRowAnimation:UITableViewRowAnimationFade];
      } else {
        [editingTableView deleteRowsAtIndexPaths:editedRows withRowAnimation:UITableViewRowAnimationFade];
      }
      [editingTableView endUpdates];
      
//      [CATransaction commit];
    }
    if(!isSectionEditing) {
        [editingTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }
    
    //select visible rows
    [editingTableView setEditing:isTableViewEditing animated:YES];
    
    for(NSInteger i = 0; i < [objectFigureSettings count]; i++) {
      NSDictionary *figureSettings = [objectFigureSettings objectAtIndex:i];
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:senderSection];
      if([[figureSettings objectForKey:VISIBILITY] boolValue]) {
        if(isSectionEditing) {
          [editingTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
      }
    }
    
    [self updateCellsTypeInSection:originalSenderSection];
    [self setCellsEditable:!isSectionEditing inSection:originalSenderSection];
  }
}

- (BOOL)allowEditingForIndexPath:(NSIndexPath *)indexPath {
    BOOL isAllowedRow = NO;
    switch (currentEditingSection) {
      case SectionClient: {
        isAllowedRow = indexPath.row != ClientAddClient;
      }
        break;
        
      case SectionDetails: {
          isAllowedRow = indexPath.row < [self numberOfRowsInDetailsSection];
      }
          break;
          
      case SectionFigure: {
          isAllowedRow = YES;
          break;
      }
          
      case SectionProductsAndServices: {
          isAllowedRow = indexPath.row < [[[self baseObject] products] count];
          break;
      }
        
        default:
            break;
    }
    
    return isAllowedRow;
}

- (void)parseTextFieldEditing:(UITextField *)textField {
  UITableView *editingTable = myTableView;
  
  NSString *editedValue = textField.text == nil || textField.text.length == 0?textField.placeholder:textField.text;
  if([self isCustomDetailTag:textField.tag]) {
    DetailsType type = [self detailCustomTypeFromTag:textField.tag];
    if([self isCustomDetailTitleTag:textField.tag]) {
        [[self baseObject] setTitle:editedValue ForDetailType:type];
    } else if ([self isCustomDetailValueTag:textField.tag]) {
        [[self baseObject] setValue:editedValue forDetailType:type];
    }
    [self saveDetailsSettings];
    
    editingTable = [self tableViewForSection:SectionDetails];
  } else if ([self isDetailTag:textField.tag]) {
    DetailsType detailType = [self detailTypeFromTag:textField.tag];
    [[self baseObject] setDetailTitle:editedValue forType:detailType];
  
    editingTable = [self tableViewForSection:SectionDetails];
  } else if ([self isFigureTag:textField.tag]) {
    FigureType figureType = [self figureTypeFromTag:textField.tag];
    [[self baseObject] setFigureTitle:editedValue forType:figureType];
  
    editingTable = [self tableViewForSection:SectionFigure];
  }
  
  [editingTable reloadData];
}

- (NSArray *)settingsForSection:(SectionTag)section {
    switch (section) {
      case SectionClient: {
        return [[self baseObject] clientSettings];
      }
        break;
        
        case SectionFigure:
            return [[self baseObject] figuresSettings];
            break;
            
        case SectionDetails:
            return [[self baseObject] detailsSettings];
            break;
            
        case SectionAddItemDetails:
            return [[self baseObject] addItemDetailsSettings];
            break;
        
        case SectionProfile:
            return [[self baseObject] profileSettings];
        break;
        
        default:
            break;
    }
    return nil;
}

#pragma mark - Client section methods

- (void)setClientVisibility:(BOOL)visibility atIndex:(NSInteger)index {
  NSMutableDictionary *figureSettings = [NSMutableDictionary dictionaryWithDictionary:[[[self baseObject] clientSettings] objectAtIndex:index]];
  [figureSettings setObject:[NSNumber numberWithBool:visibility] forKey:VISIBILITY];
  [[self baseObject] setClientSettings:figureSettings atIndex:index];
  [self saveClientSettings];
}

- (kCellType)clientCellTypeForRowType:(ClientType)row {
  NSArray *figureRows = [self clientRowsWhenEditing:clientSectionIsEditing];
  NSInteger index = 0;
  for(;index < [figureRows count]; index++) {
    NSDictionary *figureSettings = figureRows[index];
    if([figureSettings[TYPE] integerValue] == row) {
      break;
    }
  }
  
  kCellType cellType = [self cellTypeForRow:index fromCount:[figureRows count]];
  
  return cellType;
}

- (kCellType)clientCellTypeForRow:(NSInteger)row {
  NSArray *figureRows = [self clientRowsWhenEditing:clientSectionIsEditing];
  return [self cellTypeForRow:row fromCount:[figureRows count]];
}

- (NSInteger)numberOfRowsInClientSection {
  NSInteger count = [[self clientRowsWhenEditing:clientSectionIsEditing] count];
  
  return count;
}

- (void)saveClientSettings {
  if(isNewInvoice) {
    [[self baseObject] saveClientSettings];
  }
}

- (NSArray *)clientRowsWhenEditing:(BOOL)editing {
  NSArray *figureRows = nil;
  if(clientSectionIsEditing) {
    figureRows = [[self baseObject] clientSettings];
  } else {
    figureRows = [[self baseObject] visibleRowsInClientSection];
  }
  return figureRows;
}

#pragma mark - Figure section methods

- (void)setFigureVisibility:(BOOL)visibility atIndex:(NSInteger)index {
    NSMutableDictionary *figureSettings = [NSMutableDictionary dictionaryWithDictionary:[[[self baseObject] figuresSettings] objectAtIndex:index]];
    [figureSettings setObject:[NSNumber numberWithBool:visibility] forKey:VISIBILITY];
    [[self baseObject] setFigureSettings:figureSettings atIndex:index];
    [self saveFigureSettings];
}

- (kCellType)figureCellTypeForRowType:(FigureType)row {
    NSArray *figureRows = [self figureRowsWhenEditing:figureSectionIsEditing];
    NSInteger index = 0;
    for(;index < [figureRows count]; index++) {
        NSDictionary *figureSettings = figureRows[index];
        if([figureSettings[TYPE] integerValue] == row) {
            break;
        }
    }
    
    kCellType cellType = [self cellTypeForRow:index fromCount:[figureRows count]];
    
    return cellType;
}

- (kCellType)figureCellTypeForRow:(NSInteger)row {
    NSArray *figureRows = [self figureRowsWhenEditing:figureSectionIsEditing];
    return [self cellTypeForRow:row fromCount:[figureRows count]];
}

- (NSInteger)numberOfRowsInFigureSection {
    NSInteger count = [[self figureRowsWhenEditing:figureSectionIsEditing] count];
    
    return count;
}

- (void)saveFigureSettings {
    if(isNewInvoice) {
        [[self baseObject] saveFigureSettings];
    }
}

- (NSArray *)figureRowsWhenEditing:(BOOL)editing {
    NSArray *figureRows = nil;
    if(figureSectionIsEditing) {
        figureRows = [[self baseObject] figuresSettings];
    } else {
        figureRows = [[self baseObject] visibleRowsInFigureSection];
    }
    return figureRows;
}

- (NSDictionary *)figureSettingsForRow:(NSInteger)row defaultTitle:(NSString *)title {
    NSMutableDictionary *figureSettings = [NSMutableDictionary dictionaryWithDictionary:[[self figureRowsWhenEditing:figureSectionIsEditing] objectAtIndex:row]];
    if(figureSettings[TITLE] == nil) {
        [[self baseObject] setTitle:title ForDetailType:row];
        [figureSettings setObject:title forKey:TITLE];
    }
    
    return figureSettings;
}

#pragma mark - Details section methods

- (void)setDetailsVisibility:(BOOL)visibility atIndex:(NSInteger)index {
    NSMutableDictionary *detailsSettings = [NSMutableDictionary dictionaryWithDictionary:[[[self baseObject] detailsSettings] objectAtIndex:index]];
    [detailsSettings setObject:[NSNumber numberWithBool:visibility] forKey:VISIBILITY];
    [[self baseObject] setDetailsSettings:detailsSettings atIndex:index];
    [self saveDetailsSettings];
}

- (kCellType)detailsCellTypeForRowType:(DetailsType)row {
    NSArray *detailsRows = [self detailsRowsWhenEditing:detailsSectionIsEditing];
    NSInteger index = 0;
    for(;index < [detailsRows count]; index++) {
        NSDictionary *detailsSettings = detailsRows[index];
        if([detailsSettings[TYPE] integerValue] == row) {
            break;
        }
    }
    
    kCellType cellType = [self cellTypeForRow:index fromCount:[detailsRows count] + 1];
    
    return cellType;
}

- (kCellType)detailsCellTypeForRow:(NSInteger)row {
    NSArray *detailsRows = [self detailsRowsWhenEditing:detailsSectionIsEditing];
    return [self cellTypeForRow:row fromCount:[detailsRows count] + 1];
}

- (NSInteger)numberOfRowsInDetailsSection {
    return [[self detailsRowsWhenEditing:detailsSectionIsEditing] count];
}

- (void)saveDetailsSettings {
    if(isNewInvoice) {
        [[self baseObject] saveDetailsSettings];
    }
}

- (NSArray *)detailsRowsWhenEditing:(BOOL)editing {
    NSArray *detailsRows = nil;
    if(detailsSectionIsEditing) {
        detailsRows = [[self baseObject] detailsSettings];
    } else {
        detailsRows = [[self baseObject] visibleRowsInDetailsSection];
    }
    return detailsRows;
}

- (NSDictionary *)detailSettingsForType:(DetailsType)type defaultTitle:(NSString *)title {
    NSArray *detailRows = [self detailsRowsWhenEditing:detailsSectionIsEditing];
    NSMutableDictionary *detailSettings = nil;
    for(NSInteger index = 0;index < [detailRows count]; index++) {
        detailSettings = detailRows[index];
        if([detailSettings[TYPE] integerValue] == type) {
            break;
        }
    }
    
    if(detailSettings[TITLE] == nil) {
        [[self baseObject] setTitle:title ForDetailType:type];
        detailSettings = [NSMutableDictionary dictionaryWithDictionary:detailSettings];
        [detailSettings setObject:title forKey:TITLE];
    }
    
    return detailSettings;
}

- (void)addNewCustomDetailField {
  [[self baseObject] addCustomDetailField];
  
  UITableView *editingTableView = [self tableViewForSection:SectionDetails];
  
  NSInteger realSection = [self sectionIndexForSectionTag:SectionDetails];
  
  NSInteger newRow = [self numberOfRowsInDetailsSection];
  
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    [self layoutAllTableViewsAnimated:YES];
  }];
  [editingTableView beginUpdates];
  [editingTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newRow - 1 inSection:realSection]] withRowAnimation:UITableViewRowAnimationFade];
  [editingTableView endUpdates];
  [CATransaction commit];
  [self saveDetailsSettings];
  [editingTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (DetailsType)detailTypeAtIndex:(NSInteger)index {
    NSArray *detailsRows = [self detailsRowsWhenEditing:detailsSectionIsEditing];
    if(index < [detailsRows count]) {
        NSDictionary *detailSettings = [detailsRows objectAtIndex:index];
        return [detailSettings[TYPE] integerValue];
    }
    return DetailAddNewLine;
}

#pragma mark - Details and figures title indexes

- (BOOL)isCustomDetailTag:(NSInteger)tag {
    return [self isCustomDetailTitleTag:tag] || [self isCustomDetailValueTag:tag];
}

- (BOOL)isCustomDetailTitleTag:(NSInteger)tag {
    return tag >= (CustomTextfieldTitleOffset + DetailCustom1) && tag <= (CustomTextfieldTitleOffset + DetailCustom5);
}

- (BOOL)isCustomDetailValueTag:(NSInteger)tag {
    return tag >= (CustomTextfieldValueOffset + DetailCustom1) && tag <= (CustomTextfieldValueOffset + DetailCustom5);
}

- (DetailsType)detailCustomTypeFromTag:(NSInteger)tag {
    DetailsType type;
    type = tag - CustomTextfieldValueOffset;
    if(type < 0) {
        type = tag - CustomTextfieldTitleOffset;
    }
    return type;
}

- (BOOL)isDetailTag:(NSInteger)tag {
    return tag >= (DetailsTextfieldTitleOffset + DetailProjNumber) && tag <= (DetailsTextfieldTitleOffset + DetailTerms);
}

- (DetailsType)detailTypeFromTag:(NSInteger)tag {
    return tag - DetailsTextfieldTitleOffset;
}

- (BOOL)isFigureTag:(NSInteger)tag {
    return tag >= (FiguresTextfieldTitleOffset + FigureSubtotal) && tag <= (FiguresTextfieldTitleOffset + FigureBalanceDue);
}

- (FigureType)figureTypeFromTag:(NSInteger)tag {
    return tag - FiguresTextfieldTitleOffset;
}

@end
