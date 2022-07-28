//___FILEHEADER___

#import "___FILEBASENAME___.h"
#import "___VARIABLE_ViewModel___.h"
#import "___VARIABLE_Proxy___.h"
#import "___VARIABLE_TableViewCell___.h"
#import "Masonry.h"

@interface ___FILEBASENAMEASIDENTIFIER___ () <___VARIABLE_ViewModel___Delegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ___VARIABLE_ViewModel___ *viewModel;
@property (nonatomic, strong) ___VARIABLE_Proxy___ *proxy;

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubviews];
    [self startLoadData];
}

- (void)startLoadData {
    [self.viewModel startLoadData];
}

- (void)setupSubviews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
}

#pragma mark - ___VARIABLE_ViewModel___Delegate

- (void)didEndLoadData:(BOOL)hasMore {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    if (hasMore) {
        [self.tableView.mj_footer resetNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.tableView reloadData];
}

#pragma mark - getters | setters

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.delegate = self.proxy;
        tableView.dataSource = self.proxy;
        NSArray *classs = @[
            [UITableViewCell class],
            [___VARIABLE_TableViewCell___ class],
        ];
        [classs enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tableView registerClass:obj forCellReuseIdentifier:NSStringFromClass(obj)];
        }];
        NSArray *headersClasss = @[
        ];
        [headersClasss enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tableView registerClass:obj forHeaderFooterViewReuseIdentifier:NSStringFromClass(obj)];
        }];
        _tableView = tableView;
    }
    return _tableView;
}

- (___VARIABLE_Proxy___ *)proxy {
    if (!_proxy) {
        _proxy = [[___VARIABLE_Proxy___ alloc] initWithViewModel:self.viewModel];
    }
    return _proxy;
}

- (___VARIABLE_ViewModel___ *)viewModel {
    if (!_viewModel) {
        _viewModel = [[___VARIABLE_ViewModel___ alloc] init];
        _viewModel.delegate = self;
    }
    return _viewModel;
}

@end
