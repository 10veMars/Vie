//
// Created by Fabien Warniez on 2014-05-07.
// Copyright (c) 2014 Fabien Warniez. All rights reserved.
//

#import "FWPatternPickerViewController.h"
#import "FWColorSchemeModel.h"
#import "FWBoardSizeModel.h"
#import "FWPatternCollectionViewCell.h"
#import "FWPatternModel.h"
#import "UIColor+FWAppColors.h"
#import "FWTextField.h"
#import "UIScrollView+FWConvenience.h"
#import "UIFont+FWAppFonts.h"
#import "FWPatternManager.h"
#import "FWDataManager.h"

static NSString * const kFWPatternTileReuseIdentifier = @"PatternTile";
static CGFloat const kFWCollectionViewSideMargin = 26.0f;
static CGFloat const kFWSearchBarContainerTopMargin = 58.0f;
static CGFloat const kFWCellSpacing = 1.0f;

@interface FWPatternPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, FWPatternCollectionViewCellDelegate>

@property (nonatomic, strong) FWPatternManager *patternManager;
@property (nonatomic, strong) NSArray *patterns;
@property (nonatomic, assign) CGFloat lastScrollPosition;

@end

@implementation FWPatternPickerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _patternManager = [[FWDataManager sharedDataManager] patternManager];
        _patterns = [_patternManager patternsForSearchString:nil onlyFavourites:NO];
        _lastScrollPosition = 0.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"main_menu_title", nil);

    [self.collectionView registerClass:[FWPatternCollectionViewCell class] forCellWithReuseIdentifier:kFWPatternTileReuseIdentifier];

    self.navigationItem.backBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@""
                                             style:UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil];

    self.searchBar.placeholder = @"Search";
    self.searchBar.rightImage = [UIImage imageNamed:@"magnifier"];

    self.noResultLabel.text = @"0 results.";
    self.noResultLabel.font = [UIFont largeCondensedRegular];
    self.noResultLabel.textColor = [UIColor darkGrey];
    self.noResultContainer.hidden = YES;

    self.lastScrollPosition = self.collectionView.contentOffset.y;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    CGFloat side = (self.collectionView.bounds.size.width - kFWCellSpacing - 2 * kFWCollectionViewSideMargin) / 2.0f;

    self.collectionViewLayout.itemSize = CGSizeMake(side, side + [FWPatternCollectionViewCell titleBarHeight]);
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark - Accessors

- (void)setColorScheme:(FWColorSchemeModel *)colorScheme
{
    _colorScheme = colorScheme;
    [self.collectionView reloadData];
}

#pragma mark - FWTitleBarDelegate

- (NSString *)titleFor:(FWTitleBar *)titleBar
{
    return @"Patterns";
}

- (void)buttonTappedFor:(FWTitleBar *)titleBar
{
    [self.searchBar resignFirstResponder];
    [self.delegate patternPickerDidClose:self];
}

- (UIImage *)buttonImageFor:(FWTitleBar *)titleBar
{
    return [UIImage imageNamed:@"x"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSUInteger count = [self.patterns count];
        self.noResultContainer.hidden = count > 0;
        return count;
    }
    else
    {
        NSAssert(NO, @"Only 1 section.");
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FWPatternCollectionViewCell *dequeuedCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kFWPatternTileReuseIdentifier forIndexPath:indexPath];
    dequeuedCell.delegate = self;

    FWPatternModel *model = self.patterns[(NSUInteger) indexPath.row];

    dequeuedCell.mainColor = [UIColor lightGrey];
    dequeuedCell.cellPattern = model;
    dequeuedCell.colorScheme = self.colorScheme;
    dequeuedCell.fitsOnCurrentBoard = [model.boardSize isSmallerOrEqualToBoardSize:self.boardSize];

    return dequeuedCell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    FWPatternModel *selectedModel = self.patterns[(NSUInteger) indexPath.row];

    return [selectedModel.boardSize isSmallerOrEqualToBoardSize:self.boardSize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollStep = self.lastScrollPosition - scrollView.contentOffset.y;
    CGRect newFrame = self.searchBarContainer.frame;

    if ([scrollView isBouncingAtTop])
    {
        newFrame.origin.y = kFWSearchBarContainerTopMargin - scrollView.contentOffset.y - scrollView.contentInset.top;
    }
    else
    {
        if (scrollStep < 0) // scrolling down
        {
            newFrame.origin.y += scrollStep;
            if ([self isSearchBarHiddenTooFarUp:newFrame.origin.y])
            {
                newFrame.origin.y = [self yPositionToHideSearchBar];
            }
        }
        else // scrolling up
        {
            if (![scrollView isBouncingAtBottom])
            {
                newFrame.origin.y += scrollStep;
                if ([self isSearchBarTooFarDown:newFrame.origin.y])
                {
                    newFrame.origin.y = [self yPositionToFullyShowSearchBar];
                }
            }
        }
    }

    self.searchBarContainer.frame = newFrame;
    self.lastScrollPosition = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.searchBar isFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - FWPatternCollectionViewCellDelegate

- (void)playButtonTappedFor:(FWPatternCollectionViewCell *)patternCollectionViewCell
{
    FWPatternModel *selectedModel = [self patternModelForCell:patternCollectionViewCell];

    [self.searchBar resignFirstResponder];
    [self.delegate patternPicker:self didSelectCellPattern:selectedModel];
}

- (void)favouriteButtonTappedFor:(FWPatternCollectionViewCell *)patternCollectionViewCell
{
    FWPatternModel *selectedModel = [self patternModelForCell:patternCollectionViewCell];
    selectedModel.favourited = YES;
    [selectedModel.managedObjectContext save:nil];
}

- (void)unfavouriteButtonTappedFor:(FWPatternCollectionViewCell *)patternCollectionViewCell
{
    FWPatternModel *selectedModel = [self patternModelForCell:patternCollectionViewCell];
    selectedModel.favourited = NO;
    [selectedModel.managedObjectContext save:nil];
}

#pragma mark - Private Methods

- (BOOL)isSearchBarHiddenTooFarUp:(CGFloat)newY
{
    return newY < kFWSearchBarContainerTopMargin - self.searchBarContainer.frame.size.height;
}

- (BOOL)isSearchBarTooFarDown:(CGFloat)newY
{
    return newY > kFWSearchBarContainerTopMargin;
}

- (CGFloat)yPositionToHideSearchBar
{
    return kFWSearchBarContainerTopMargin - self.searchBarContainer.frame.size.height;
}

- (CGFloat)yPositionToFullyShowSearchBar
{
    return kFWSearchBarContainerTopMargin;
}

- (FWPatternModel *)patternModelForCell:(FWPatternCollectionViewCell *)patternCollectionViewCell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:patternCollectionViewCell];

    FWPatternModel *selectedModel = self.patterns[(NSUInteger) indexPath.row];

    return selectedModel;
}

#pragma mark - IBActions

- (IBAction)textFieldChanged:(FWTextField *)textField
{
    self.patterns = [self.patternManager patternsForSearchString:textField.text onlyFavourites:NO];

    [self.collectionView reloadData];
}

- (IBAction)hideKeyboard:(FWTextField *)textField
{
    [textField resignFirstResponder];
}

@end
