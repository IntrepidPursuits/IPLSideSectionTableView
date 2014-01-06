//
//  IPLSideSectionTableView.m
//
//  Copyright (c) 2012 Intrepid Pursuits. All rights reserved.
//

#import "IPLSideSectionTableView.h"

const CGFloat kIPLSideSectionTableViewAutohideHideDuration = 0.8;
const CGFloat kIPLSideSectionTableViewAutohideShowDuration = 0.3;
const CGFloat kIPLSideSectionTableViewAutohideHideDelay = 0.5;

@interface IPLSideSectionTableView ()

@property (nonatomic, assign) BOOL userIsScrolling;

@end

@implementation IPLSideSectionTableView

@dynamic delegate, dataSource;
@synthesize userIsScrolling = _userIsScrolling;
@synthesize autoHideEnabled = _autoHideEnabled, sideHeaderViews = _sideHeaderViews;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Property Methods

- (id<IPLSideSectionTableViewDelegate>)delegate {
    return (id)[super delegate];
}

- (void)setDelegate:(id<IPLSideSectionTableViewDelegate>)newDelegate {
    [super setDelegate:nil];
    delegateInterceptor.receiver = newDelegate;
    [super setDelegate:(id)delegateInterceptor];
}

- (id<UITableViewDataSource>)dataSource {
    return (id)[super dataSource];
}

- (void)setDataSource:(id<UITableViewDataSource>)newDataSource {
    [super setDataSource:nil];
    dataSourceInterceptor.receiver = newDataSource;
    [super setDataSource:(id)dataSourceInterceptor];
}

#pragma mark - Private Methods

- (void)setup {
    delegateInterceptor = (id)[[IPLMessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    [super setDelegate:(id)delegateInterceptor];
    
    dataSourceInterceptor = (id)[[IPLMessageInterceptor alloc] init];
    dataSourceInterceptor.middleMan = self;
    [super setDataSource:(id)dataSourceInterceptor];
    
    self.autoHideEnabled = YES;
}

- (void)hideSideLabels {
    [UIView animateWithDuration:kIPLSideSectionTableViewAutohideShowDuration
                          delay:kIPLSideSectionTableViewAutohideHideDelay
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         if ([delegateInterceptor.receiver respondsToSelector:@selector(tableViewWillHideSideViews:)]) {
                             [delegateInterceptor.receiver tableViewWillHideSideViews:self];
                         }
                         
                         for (UIView *sideLabel in self.sideHeaderViews) {
                             if ((id)sideLabel != [NSNull null]) {
                                 // Move left and fade out
                                 // Looks better fading out halfway off the screen, rather than fully off the screen
                                 sideLabel.transform = CGAffineTransformMakeTranslation(0 - CGRectGetMaxX(sideLabel.frame)/2, sideLabel.transform.ty);
                                 sideLabel.alpha = 0;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         ;
                     }];

}

- (void)showSideLabels {
        [UIView animateWithDuration:kIPLSideSectionTableViewAutohideShowDuration
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if ([delegateInterceptor.receiver respondsToSelector:@selector(tableViewWillShowSideViews:)]) {
                                 [delegateInterceptor.receiver tableViewWillShowSideViews:self];
                             }
                             
                             for (UIView *sideLabel in self.sideHeaderViews) {
                                 if ((id)sideLabel != [NSNull null]) {
                                     // Remove x translation and fade in.
                                     sideLabel.transform = CGAffineTransformMakeTranslation(0, sideLabel.transform.ty);
                                     sideLabel.alpha = 1;
                                 }
                             }
                         }
                         completion:^(BOOL finished) {
                             ;
                         }];
}

- (void)positionSideView:(UIView *)sideView inSection:(NSInteger)section {
    // Side views need to be translated off screen if the next side view would overlap it.
    
    if (section + 1 >= [self.sideHeaderViews count]) {
        // Side view is last side view, which should never need to be translated
        sideView.transform = CGAffineTransformMakeTranslation(sideView.transform.tx, 0);
        return;
    }
    
    UIView *nextSideView = [self.sideHeaderViews objectAtIndex:section + 1];
    if ((id)nextSideView != [NSNull null]) {
        CGRect nextSectionRect = [self rectForSection:section + 1];
        CGFloat sideViewHeight = 0;
        
        if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:heightForSideViewInSection:)]) {
            sideViewHeight = [delegateInterceptor.receiver tableView:self heightForSideViewInSection:section];
        }
        
        // Position the side view directly above the next one, or at the top of the table view.
        sideView.transform = CGAffineTransformMakeTranslation(0,
                                                              MIN(0, (nextSectionRect.origin.y
                                                                      - self.contentOffset.y
                                                                      - sideViewHeight)));
    } else {
        // There doesn't appear to be a next side view, so we should not translate this one.
        sideView.transform = CGAffineTransformMakeTranslation(sideView.transform.tx, 0);
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([delegateInterceptor.receiver respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
    
    self.userIsScrolling = YES;
    if (self.autoHideEnabled) {
        [self showSideLabels];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (int i = 0; i < [self numberOfSections]; i++) {
        UIView *sideView = [self.sideHeaderViews objectAtIndex:i];
        if ((id)sideView != [NSNull null]) {
            [self positionSideView:sideView inSection:i];
        }
    }
    
    if ([delegateInterceptor.receiver respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.userIsScrolling = NO;
    if (self.autoHideEnabled) {
        [self hideSideLabels];
    }
    
    if ([delegateInterceptor.receiver respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate && !scrollView.isDecelerating) {
        self.userIsScrolling = NO;
        if (self.autoHideEnabled) {
            [self hideSideLabels];
        }
    }

    if ([delegateInterceptor.receiver respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [delegateInterceptor.receiver tableView:tableView heightForHeaderInSection:section];
    } else if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:viewForHeaderInSection:)] && self.sectionHeaderHeight > 0) {
        return self.sectionHeaderHeight;
    } else {
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // Side views work as subviews of header views.
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIView *oldHeaderView = nil;
    
    if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        oldHeaderView = [delegateInterceptor.receiver tableView:tableView viewForHeaderInSection:section];
    }
    
    if (oldHeaderView) {
        // If we have an existing header view, we want to add it as a subview to our new header view.
        headerView.frame = oldHeaderView.frame;
        oldHeaderView.frame = headerView.bounds;
        [headerView addSubview:oldHeaderView];
    }
    
    if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:viewForSideViewInSection:)]) {
        UIView *sideHeaderView = [delegateInterceptor.receiver tableView:self viewForSideViewInSection:section];
        if (sideHeaderView) {
            // If we have a side view we want to put it in a clear container view so that we can control the alpha and translations.
            // If we controlled the alpha/translations directly, we might override what was already set.
            UIView *containerView = [[UIView alloc] initWithFrame:sideHeaderView.frame];
            containerView.backgroundColor = [UIColor clearColor];
            sideHeaderView.frame = containerView.bounds;
            [containerView addSubview:sideHeaderView];
            [self.sideHeaderViews replaceObjectAtIndex:section withObject:containerView];
            [headerView addSubview:containerView];
            
            [self positionSideView:containerView inSection:section];
            
            // If side views should currently be hidden, we need to set the alpha and position correctly
            if (!self.userIsScrolling) {
                containerView.alpha = 0;
                containerView.transform = CGAffineTransformMakeTranslation(0 - CGRectGetMaxX(containerView.frame)/2, containerView.transform.ty);
            }
        }
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    
    // Padding row:
    // 1. Add up the heights of all the other rows, plus the header and footer heights.
    // 2. If the side view is taller, pad the section with the difference.
    if (indexPath.row == [delegateInterceptor.receiver tableView:tableView numberOfRowsInSection:section]) {
        CGFloat sideViewHeight = 0;
        if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:heightForSideViewInSection:)]) {
            sideViewHeight = [delegateInterceptor.receiver tableView:self heightForSideViewInSection:section];
        }
        
        CGFloat sectionHeight = [self tableView:tableView heightForHeaderInSection:section];
        for (int i = 0; i < [delegateInterceptor.receiver tableView:self numberOfRowsInSection:section]; i++) {
            sectionHeight += [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        
        if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
            sectionHeight += [delegateInterceptor.receiver tableView:tableView heightForFooterInSection:section];
        } else if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:viewForFooterInSection:)] && self.sectionFooterHeight > 0) {
            sectionHeight += self.sectionFooterHeight;
        }
        
        CGFloat paddingHeight = 0;
        
        if (sectionHeight < sideViewHeight) {
            paddingHeight = sideViewHeight - sectionHeight;
        }
        
        return paddingHeight;
    }
    // Normal row
    else if ([delegateInterceptor.receiver respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [delegateInterceptor.receiver tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return self.rowHeight;
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // We need an extra padding row at the bottom in case the side view is taller than all the rows
    return [dataSourceInterceptor.receiver tableView:tableView numberOfRowsInSection:section] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    
    // Padding row: empty cell
    if (indexPath.row == [tableView numberOfRowsInSection:section] - 1) {
        static NSString *paddingCellIdentifier = @"IPLTableViewPaddingCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paddingCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paddingCellIdentifier];
            cell.userInteractionEnabled = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    // Normal row
    else {
        return [dataSourceInterceptor.receiver tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableView Methods

- (void)reloadData {
    // First build our list of side views placeholders
    NSInteger sectionCount = [delegateInterceptor.receiver numberOfSectionsInTableView:self];
    self.sideHeaderViews = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++) {
        [self.sideHeaderViews addObject:[NSNull null]];
    }
    
    [super reloadData];
}

@end
