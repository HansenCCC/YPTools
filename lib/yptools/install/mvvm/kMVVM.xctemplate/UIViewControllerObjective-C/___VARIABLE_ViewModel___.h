//___FILEHEADER___

___IMPORTHEADER_cocoaTouchSubclass___

NS_ASSUME_NONNULL_BEGIN

@protocol ___FILEBASENAMEASIDENTIFIER___Delegate <NSObject>

- (void)didEndLoadData:(BOOL)hasMore;

@end

@interface ___FILEBASENAMEASIDENTIFIER___ : NSObject

@property (nonatomic, weak) id <___FILEBASENAMEASIDENTIFIER___Delegate> delegate;
@property (nonatomic, readonly) NSMutableArray *dataList;

- (void)startLoadData;

- (void)loadMoreData;

@end

NS_ASSUME_NONNULL_END
