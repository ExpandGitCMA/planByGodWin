//
//  DFCSeatsLayoutController.m
//  planByGodWin
//
//  Created by zeros on 17/1/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSeatsLayoutController.h"
#import "DFCGropMemberModel.h"
#import "DFCStudentListCollectionViewCell.h"
#import "DFCGrouplistViewController.h"
#import "StudentInfoViewController.h"

static NSInteger line = 8;//列数（第一排（最靠近讲台的那一排）的人数）
static NSInteger row = 7;//行数

@interface DFCSeatsLayoutController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collection;

@property (nonatomic, copy) NSString *classCode;
@property (nonatomic, copy) NSString *className;

@property (nonatomic, assign) BOOL canPan;
@property (nonatomic, strong) NSMutableArray *studentList;
@property (nonatomic, strong) NSMutableArray *cellAttributesArray;

@end

@implementation DFCSeatsLayoutController

- (instancetype)initWithClass:(NSString *)classCode name:(NSString *)className{
    if (self = [super init]) {
        _classCode = classCode;
        _className = className;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    [self initData];
}

#pragma mark - 学生座位转换
- (NSString *)netToLocalForStudent:(NSString *)seatNo
{
    NSInteger netNo = [seatNo intValue];
    NSInteger localNo = netNo + line - 2 - 2 * ((netNo - 1) % line);
    return [NSString stringWithFormat:@"%02lu", localNo];
}

- (NSString *)localToNetForStudent:(NSString *)seatNo
{
    NSInteger localNo = [seatNo intValue];
    NSInteger netNo = (localNo / line + 1) * line - localNo % line;
    return [NSString stringWithFormat:@"%02lu", netNo];
}

#pragma mark - 教师座位转换
- (NSString *)netToLoacalForTeacher:(NSString *)seatNo
{
    NSInteger netNo = [seatNo intValue];
    NSInteger localNo = (row - 1 - (netNo - 1) / line) * line + (netNo - 1) % line;
    return [NSString stringWithFormat:@"%02lu", localNo];
}

- (NSString *)localToNetForTeacher:(NSString *)seatNo
{
    NSInteger localNo = [seatNo intValue];
    NSInteger netNo = (row - 1 - localNo / line) * line + localNo % line + 1;
    return [NSString stringWithFormat:@"%02lu", netNo];
}


- (void)initData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:_classCode forKey:@"classCode"];
    NSArray *list = @[@{@"studentCode":@"123", @"seat":@"123"}, @{@"studentCode":@"321", @"seat":@"321"}];
    NSData *json = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    [params SafetySetObject:str forKey:@"test"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassMember params:params completed:^(BOOL ret, id obj) {
        if (ret) {
             DEBUG_NSLog(@"obj==%@",obj);
            NSArray *list = obj[@"studentInfoList"];
            self.studentList = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in list) {
                DFCGroupClassMember *model = [[DFCGroupClassMember alloc] init];
                model.address  = [dic objectForKey:@"address"];
                model.imgUrl = [dic objectForKey:@"imgUrl"];
                model.certNo   = [dic objectForKey:@"certNo"];
                model.classJob  = [dic objectForKey:@"classJob"];
                model.name = [dic objectForKey:@"name"];
                model.qq  = [dic objectForKey:@"qq"];
                //model.sex  = [dic objectForKey:@"sex"];
                if ([[dic objectForKey:@"sex"] isEqualToString:@"M"]) {
                    model.sex = @"男";
                } else {
                    model.sex = @"女";
                }
                model.studentCode = [dic objectForKey:@"studentCode"];
                model.birthday  = [dic objectForKey:@"birthday"];
                model.tel = [dic objectForKey:@"tel"];
                model.seatNo = [dic objectForKey:@"seatNo"];
                model.parentName = [dic objectForKey:@"parentName"];
                [self.studentList addObject:model];
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                DFCGroupClassMember *model = (DFCGroupClassMember *)evaluatedObject;
                return model.seatNo != nil;
            }];
            NSArray *result = [self.studentList filteredArrayUsingPredicate:predicate];
            if (result.count) {
                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DFCGroupClassMember *model = (DFCGroupClassMember *)obj;
                    if ([DFCUtility isCurrentTeacher]) {
                        model.seatNo = [self netToLoacalForTeacher:model.seatNo];
                    } else {
                        model.seatNo = [self netToLocalForStudent:model.seatNo];
                    }
                }];
                //座位图没人的地方进行插空操作
                NSMutableArray *sortArray = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < line * row; i++) {
                    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                        DFCGroupClassMember *model = (DFCGroupClassMember *)evaluatedObject;
                        NSInteger seatNo = [model.seatNo intValue];
                        return seatNo == i;
                    }];
                    NSArray *one = [self.studentList filteredArrayUsingPredicate:pre];
                    if (one.count) {
                        [sortArray addObject:[one firstObject]];
                    } else {
                        DFCGroupClassMember *model = [[DFCGroupClassMember alloc] init];
                        [sortArray addObject:model];
                    }
                }
                self.studentList = sortArray;
            } else {
                NSInteger count = self.studentList.count;
                for (NSInteger i = count; i < line * row; i++) {
                    DFCGroupClassMember *model = [[DFCGroupClassMember alloc] init];
                    [self.studentList addObject:model];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collection reloadData];
            });
        } else {
            
        }
    }];
    self.cellAttributesArray = [[NSMutableArray alloc] init];
}


- (void)initAllViews
{
    self.navigationItem.title = @"座位设置";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = kUIColorFromRGB(CollectionBackgroundColor);
    
    //更多按钮（。。。）
//    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"little"] style:UIBarButtonItemStylePlain target:self action:@selector(moreAction)];
//    self.navigationItem.rightBarButtonItem = more;
    
    //非导航栏更多按钮(...)
//    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
//    [moreButton setImage:[UIImage imageNamed:@"little"] forState:UIControlStateNormal];
//    [moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:moreButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [backButton setImage:[UIImage imageNamed:@"register_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *setButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [setButton setTitle:@"调整座位" forState:UIControlStateNormal];
    [setButton setBackgroundColor:kUIColorFromRGB(ButtonBlueColor)];
    [setButton addTarget:self action:@selector(canPan:) forControlEvents:UIControlEventTouchUpInside];
    setButton.layer.cornerRadius = 5;
    setButton.clipsToBounds = YES;
    [self.view addSubview:setButton];
    [setButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.4);
        make.height.equalTo(44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    setButton.hidden = ![DFCUserDefaultManager canSetSeatsLayout];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collection.delegate = self;
    collection.dataSource = self;
    collection.showsVerticalScrollIndicator = NO;
    collection.backgroundColor = [UIColor clearColor];
    [collection registerNib:[UINib nibWithNibName:@"DFCStudentListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"studentCell"];
    [self.view addSubview:collection];
    self.collection = collection;
    [collection makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backButton.bottom).offset(10);
        make.bottom.equalTo(setButton.top).offset(-20);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
//    [moreButton makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(60);
//        make.height.equalTo(44);
//        make.top.equalTo(self.view).offset(10);
//        make.right.equalTo(self.view);
//        make.bottom.equalTo(collection.top).offset(-10);
//    }];
    
    [backButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(60);
        make.height.equalTo(44);
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view);
        make.bottom.equalTo(collection.top).offset(-10);
    }];
    
    
}


/**
 更多按钮（。。。）
 */
- (void)moreAction{
    DFCGrouplistViewController *list = [[DFCGrouplistViewController alloc]initWithMsgClassCode:_classCode className:_className];
    [self.navigationController pushViewController:list animated:YES];

}

- (void)backAction{
    DEBUG_NSLog(@"返回");
      [self.navigationController popToRootViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
     
}

- (void)canPan:(UIButton *)sender
{
    _canPan  = !_canPan;
    if (_canPan) {
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        [sender setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    } else {
        [sender setTitle:@"调整座位" forState:UIControlStateNormal];
        [sender setBackgroundColor:kUIColorFromRGB(ButtonBlueColor)];
        [self uploadSeatLayout];
    }
}

- (void)uploadSeatLayout
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DFCGroupClassMember *model = (DFCGroupClassMember *)evaluatedObject;
        return model.seatNo != nil;
    }];
    NSArray *result = [self.studentList filteredArrayUsingPredicate:predicate];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (DFCGroupClassMember *model in result) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:model.studentCode forKey:@"studentCode"];
        NSString *seatNo = [NSString stringWithFormat:@"%02lu", [self.studentList indexOfObject:model]];
        if ([DFCUtility isCurrentTeacher]) {
            seatNo = [self localToNetForTeacher:seatNo];
        } else {
            seatNo = [self localToNetForStudent:seatNo];
        }
        [dic setValue:seatNo forKey:@"seatNo"];
        [list addObject:dic];
    }
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
    NSString *seatInfo = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:self.classCode forKey:@"classCode"];
    [params SafetySetObject:seatInfo forKey:@"seatInfo"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_SetSeatLayout params:params completed:^(BOOL ret, id obj) {
        
    }];
    
}

- (void)pan:(UILongPressGestureRecognizer *)sender
{
    if (!_canPan) {
        return;
    }
    DFCStudentListCollectionViewCell *cell = (DFCStudentListCollectionViewCell *)sender.view;
    NSIndexPath *cellIndexPath = [_collection indexPathForCell:cell];
    DFCGroupClassMember *model = _studentList[cellIndexPath.row];
    if (!model.name) {
        return;
    }
    [_collection bringSubviewToFront:cell];
    BOOL isChanged = NO;
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.cellAttributesArray removeAllObjects];
        for (int i = 0; i< self.studentList.count; i++) {
            [self.cellAttributesArray addObject:[_collection layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
    }else if (sender.state == UIGestureRecognizerStateChanged){
        cell.center = [sender locationInView:_collection];
        isChanged = YES;
        
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        if (!isChanged) {
            for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
                if (CGRectContainsPoint(attributes.frame, cell.center) && cellIndexPath != attributes.indexPath) {
                    [self.studentList exchangeObjectAtIndex:cellIndexPath.row withObjectAtIndex:attributes.indexPath.row];
                    break;
                }
            }
            [_collection reloadData];
        }
    }
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 700);
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _studentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DFCStudentListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"studentCell" forIndexPath:indexPath];
    DFCGroupClassMember *model = _studentList[indexPath.row];
    if (model.name) {
        cell.studentModel = model;
        [cell DFC_setLayerCorner];
    } else {
        [cell configForVoid];
    }
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [cell addGestureRecognizer:pan];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_canPan) {
        return;
    }
    DFCGroupClassMember *model = _studentList[indexPath.row];
    if (model.studentCode) {
        StudentInfoViewController *vc = [[StudentInfoViewController alloc]initWithMsgModel:model];
        vc.type =  MsgFnTable;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.bounds.size.width - line - 1) / line;
    CGFloat height = (collectionView.bounds.size.height - row - 1) / row;
    return CGSizeMake(width, height);
}

@end
