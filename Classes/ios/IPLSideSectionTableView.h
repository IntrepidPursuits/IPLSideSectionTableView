//
//  IPLSideSectionTableView.h
//
//  Copyright (c) 2012 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPLMessageInterceptor.h"

extern const CGFloat kIPLSideSectionTableViewAutohideHideDuration;
extern const CGFloat kIPLSideSectionTableViewAutohideShowDuration;
extern const CGFloat kIPLSideSectionTableViewAutohideHideDelay;


@class IPLSideSectionTableView;


@protocol IPLSideSectionTableViewDelegate <UITableViewDelegate>

@optional
- (UIView *)tableView:(IPLSideSectionTableView *)tableView viewForSideViewInSection:(NSInteger)section;
- (CGFloat)tableView:(IPLSideSectionTableView *)tableView heightForSideViewInSection:(NSInteger)section;
- (void)tableViewWillHideSideViews:(IPLSideSectionTableView *)tableView;
- (void)tableViewWillShowSideViews:(IPLSideSectionTableView *)tableView;

@end


@interface IPLSideSectionTableView : UITableView <UITableViewDelegate> {
    IPLMessageInterceptor <IPLSideSectionTableViewDelegate> *delegateInterceptor;
    IPLMessageInterceptor <UITableViewDataSource> *dataSourceInterceptor;
}

@property (nonatomic, assign) BOOL autoHideEnabled;
@property (nonatomic, strong) NSMutableArray *sideHeaderViews;

@property (nonatomic, assign) id <IPLSideSectionTableViewDelegate> delegate;
@property (nonatomic, assign) id <UITableViewDataSource> dataSource;

@end


