//___FILEHEADER___

#import "___FILEBASENAME___.h"

@interface ___FILEBASENAMEASIDENTIFIER___ ()

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation ___FILEBASENAMEASIDENTIFIER___ {
    NSInteger _pageSize;
    NSInteger _pageIndex;
}

- (instancetype)init {
    if (self = [super init]) {
        _pageSize = 10;
        _pageIndex = 1;
        self.dataList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startLoadData {
    _pageIndex = 1;
    [self startLoadingData:_pageIndex];
}

- (void)loadMoreData {
    _pageIndex ++;
    [self startLoadingData:_pageIndex];
}

- (void)startLoadingData:(NSInteger)pageIndex {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL hasMore = YES;
        if (_pageIndex > 3) {
            hasMore = NO;
        }
        if (_pageIndex == 1) {
            [self.dataList removeAllObjects];
        }
        [self.dataList addObjectsFromArray:[[UIFont familyNames] subarrayWithRange:NSMakeRange(self.dataList.count, _pageSize)]];
        if ([self.delegate respondsToSelector:@selector(didEndLoadData:)]) {
            [self.delegate didEndLoadData:hasMore];
        }
    });
}

@end
