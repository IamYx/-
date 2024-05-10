//
//  DyPlayerViewController.m
//  HistoryToday
//
//  Created by 姚肖 on 2023/5/10.
//

#import "DyPlayerViewController.h"
#import "DyPlayerTableViewCell.h"
#import "YXFileManager.h"
#import "UIAlertController+Short.h"
#import "MJRefresh.h"
#import <Today-Swift.h>

@interface DyPlayerViewController ()<UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>

@property (nonatomic, strong)UITableView *mTableView;
@property (nonatomic, strong)NSMutableArray *mArray;
@property (nonatomic, assign)NSInteger currIndex;

@end

@implementation DyPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"video";

    [self refresh];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(downloadFile)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEnterbackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)onEnterbackground {
    [self leaveStopPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self autoPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self leaveStopPlay];
}

- (void)leaveStopPlay {
    DyPlayerTableViewCell *cell = [_mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currIndex inSection:0]];
    [cell.dyPlayC mPause];
    //过一秒再停止一次
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell.dyPlayC mPause];
    });
}
 
- (void)refresh {
    
    DyPlayerTableViewCell *cell = [_mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currIndex inSection:0]];
    [cell.dyPlayC mPause];
    [cell.dyPlayC mStop];
    
    [_mTableView removeFromSuperview];
    _mTableView = nil;
    
    self.currIndex = 0;
    
    self.mArray = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.mTableView];
    
    __weak DyPlayerViewController *weakSelf = self;
    _mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
        [weakSelf.mTableView.mj_header endRefreshing];
    }];
    
    for (NSString *name in [YXFileManager outPutFileFromGroup:@"dyVideo"]) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", [YXFileManager filePath:@"dyVideo"], name];
        NSArray *topArr = (NSArray *)([YXFileManager getValueForKey:TOPVideo][@"dic"]);
        if ([topArr containsObject:path]) {
            [self.mArray insertObject:path atIndex:0];
        } else {
            [self.mArray addObject:path];
        }
    }
    
    [self.mTableView reloadData];
    
    [self autoPlay];
}

- (void)autoPlay {
    __weak DyPlayerViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DyPlayerTableViewCell *cell = [weakSelf.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.currIndex inSection:0]];
        [cell.dyPlayC mPlay];
    });
}

- (void)downloadFile {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"地址" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertC shortShowAlert:@[@"地址"] actions:@"预览" vc:self actionBlock:^(NSInteger index, NSArray * _Nonnull values) {
        
        AddVideoViewController *vc = [[AddVideoViewController alloc] init];
        vc.urlStr = values.firstObject;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
}

- (UITableView *)mTableView {
    if (!_mTableView) {
        _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarHeight + 44, UIScreenWidth, UIScreenHeight - statusBarHeight - 44 - kSafeAreaHeight - 44) style:UITableViewStylePlain];
        [_mTableView registerClass:[DyPlayerTableViewCell class] forCellReuseIdentifier:@"mCell"];
        _mTableView.delegate = self;
        _mTableView.dataSource = self;
        _mTableView.pagingEnabled = YES;
    }
    return _mTableView;
}

- (void)longTapAction:(UILongPressGestureRecognizer *)longTap {
    
    __weak DyPlayerViewController *weakSelf = self;
    NSIndexPath *indexPath = [weakSelf.mTableView indexPathForCell:(DyPlayerTableViewCell *)longTap.view];
    NSString *path = weakSelf.mArray[indexPath.row];
    
    __block NSMutableArray *array = [(NSArray *)([YXFileManager getValueForKey:TOPVideo][@"dic"]) mutableCopy];
    if (!array) {
        array = [[NSMutableArray alloc] init];
    }
    
    NSString *topTit = [array containsObject:path] ? @"取消置顶" : @"置顶";
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertC shortShowSheet:@"" actions:@[@"删除", @"导出", topTit, @"清除全部置顶", @"取消"] vc:self actionBlock:^(NSInteger index) {
        if (index == 0) {
            [((DyPlayerTableViewCell *)longTap.view).dyPlayC mStop];
            [weakSelf.mArray removeObjectAtIndex:indexPath.row];
            [weakSelf.mTableView reloadData];
            
            [YXFileManager deleteFileWithPath:path];
            //如果置顶了的话删除置顶
            if ([array containsObject:path]) {
                [array removeObject:path];
            }
            [YXFileManager saveValue:@{@"dic" : array} key:TOPVideo];
        } else if (index == 1) {
            UIDocumentPickerViewController *documentPickerVC = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:path] inMode:UIDocumentPickerModeExportToService];
            // 设置代理
            documentPickerVC.delegate = weakSelf;
            // 设置模态弹出方式
            documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [weakSelf.navigationController presentViewController:documentPickerVC animated:YES completion:nil];
        } else if (index == 2) {
            if ([array containsObject:path]) {
                [array removeObject:path];
            } else {
                if (array.count == 0) {
                    [array addObject:path];
                } else {
                    [array insertObject:path atIndex:0];
                }
            }
            [YXFileManager saveValue:@{@"dic" : array} key:TOPVideo];
        } else if (index == 3) {
            array = [[NSMutableArray alloc] init];
            [YXFileManager saveValue:@{@"dic" : array} key:TOPVideo];
            [weakSelf refresh];
        }
    }];
    
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // 获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        // 通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            // 读取文件
//            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            //NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                // 读取出错
            } else {
                // 上传
//                NSLog(@"fileName : %@", fileName);
            }
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        // 授权失败
    }
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DyPlayerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.dyPlayC.playing) {
        [cell.dyPlayC mPause];
        [cell.heeMusicView stop];
    } else {
        [cell.dyPlayC mrePlay];
        [cell.heeMusicView start];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DyPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mCell"];
    [cell startPlay:_mArray[indexPath.row]];
    
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    [cell addGestureRecognizer:longTap];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UIScreenHeight - statusBarHeight - 44 - kSafeAreaHeight - 44;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *centerIndexPath = [self.mTableView indexPathForRowAtPoint:CGPointMake(CGRectGetMidX(self.mTableView.bounds), CGRectGetMidY(self.mTableView.bounds))];
//    NSLog(@"=== %ld", centerIndexPath.row);
    NSArray *visibleIndexPaths = [self.mTableView indexPathsForVisibleRows];
    if ([visibleIndexPaths containsObject:centerIndexPath]) {
//        NSLog(@"cell scrolled to center of screen");
    }
    
    if (self.currIndex != centerIndexPath.row) {
//        NSLog(@"==== %ld", centerIndexPath.row);
        
        DyPlayerTableViewCell *cellT = [self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currIndex inSection:0]];
        [cellT.dyPlayC mPause];
        
        DyPlayerTableViewCell *cell = [self.mTableView cellForRowAtIndexPath:centerIndexPath];
        [cell.dyPlayC mPlay];
        [cell.heeMusicView start];
        
        self.currIndex = centerIndexPath.row;
    }
}

@end
