//
//  DFC_EDResourceView.m
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFC_EDResourceView.h"
#import "DFC_EDTabView.h"

@interface DFC_EDResourceView ()<UICollectionViewDataSource,DFC_EDTabViewDelegate,UICollectionViewDelegateFlowLayout,EDResourceCellDelegate>

@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UIButton *backButton;
@property (nonatomic,weak) UIButton *insertButton;

@property (nonatomic,strong) UIView *tipView;

@property (nonatomic,weak) UICollectionView *listView;
@property (nonatomic,weak) DFC_EDTabView *tabView;
@property (nonatomic,strong) NSMutableArray *contents;

@property (nonatomic,strong) NSMutableArray *selectedItems;     // 所有选择插入的item
@property (nonatomic,strong) DFC_EDResourceItem *selectedItem;  // 编辑可删除的item
@end

@implementation DFC_EDResourceView

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [NSMutableArray array];
    }
    return _contents;
}

- (UIView *)tipView{
    if (!_tipView) {
        _tipView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height - 80)];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.bounds.size.height - 80)/2 -20, self.bounds.size.width - 20, 25)];
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.text = @"你可以添加自定义元素至菜单";
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor darkGrayColor];
        [_tipView addSubview:tipLabel];
        
        UIButton *but = [[UIButton alloc]init];
//        打开编辑工具
        [but setTitle:@"打开编辑工具" forState:UIControlStateNormal];
        but.titleLabel.font = [UIFont systemFontOfSize:15];
        [but setTitleColor:kUIColorFromRGB(ButtonGreenColor) forState:UIControlStateNormal];
        but.frame = CGRectMake((self.bounds.size.width - 100)/2, CGRectGetMaxY(tipLabel.frame) + 5, 100, 30);
        [but addTarget:self action:@selector(showEditor:) forControlEvents:UIControlEventTouchUpInside];
        [_tipView addSubview:but];
    }
    return _tipView;
}

- (NSMutableArray *)selectedItems{
    if (!_selectedItems) {
        _selectedItems = [NSMutableArray array];
    }
    return _selectedItems;
}

+ (instancetype)resourceViewWithFrame:(CGRect)frame{
    return [[self alloc]initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.layer.cornerRadius  = 5;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1;
    self.backgroundColor = [UIColor colorWithRed:206 green:206 blue:206 alpha:1];
    // 导航栏
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.text = @"素材中心";
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    [self addSubview:self.titleLabel];
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
    backButton.showsTouchWhenHighlighted = NO;
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = backButton;
    [self addSubview:backButton];
    
    UIButton *insertButton = [[UIButton alloc]init];
    [insertButton setTitle:@"插入" forState:UIControlStateNormal];
    insertButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [insertButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [insertButton addTarget:self action:@selector(insert) forControlEvents:UIControlEventTouchUpInside];
    self.insertButton = insertButton;
    [self addSubview:insertButton];
    
    // 提示
    [self addSubview:self.tipView];
    
    //  列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(40, 40);
    UICollectionView *listView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height - 80) collectionViewLayout:layout];
    listView.backgroundColor = [UIColor whiteColor];
    listView.dataSource = self;
    listView.delegate = self;
    self.listView = listView;
    [self addSubview:listView];
    
    // tab
    NSArray *icons = @[@"DFC_Tab_Custom",@"DFC_Tab_Animal",@"DFC_Tab_Figure",@"DFC_Tab_Food",@"DFC_Tab_House",@"DFC_Tab_Music",@"DFC_Tab_Science",@"DFC_Tab_Space"];
    DFC_EDTabView *tabview = [DFC_EDTabView tabViewWithFrame:CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width, 40) tabIcons:icons tabItems:nil];
    tabview.delegate = self;
    self.tabView = tabview;
    [self addSubview:tabview];
    
    [self.listView registerNib:[UINib nibWithNibName:@"DFC_EDResourceCell" bundle:nil] forCellWithReuseIdentifier:@"DFC_EDResourceCell"];
    
    // 拉取自定义素材通知
    [DFCNotificationCenter addObserver:self selector:@selector(loadData) name:@"addSuccess" object:nil];
}

/**
 拉取自定义素材
 */
- (void)loadData{
    if (self.contents.count) {
        [self.contents removeAllObjects];
    }
    DEBUG_NSLog(@"====1=====");
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetCustomResources identityParams:[@{@"userCode":userCode} mutableCopy] completed:^(BOOL ret, id obj) {
        DEBUG_NSLog(@"%@",obj);
        if (ret) {
            NSArray *infoList = obj[@"favoriteInfoList"];
            for (NSDictionary *dict in infoList) {
                DFC_EDResourceItem *item = [DFC_EDResourceItem resourceItemWithDict:dict];
                [self.contents addObject:item];
            }
            if(self.contents.count){
                self.listView.hidden =NO;
                [self.listView reloadData];
            }
        }else {
//            [DFCProgressHUD showErrorWithStatus:obj];
        }
    }];
}

#pragma mark - DFC_EDTabViewDelegate
- (void)tabview:(DFC_EDTabView *)tabView didSelectTab:(DFCTabType)type{
    if (self.contents.count) {
        [self.contents removeAllObjects];
    }
    
    if (self.selectedItems.count) {
        [self.selectedItems removeAllObjects];
        [self setInsertTitle];
    }
    
//    self.editable = type == DFCTabCustom;
    
    NSString *fileName;
    NSString *title;
    NSString *tabType;
    switch (type) {
        case DFCTabCustom:
        {
            DEBUG_NSLog(@"自定义");
//            fileName = @"space.plist";
            title = @"自定义素材";
//            tabType = @"";
            [self loadData];
        }
            break;
        case DFCTabAnimal:
        {
            DEBUG_NSLog(@"DFCTabAnimal");
            fileName = @"animal.plist";
            title = @"动物";
            tabType = @"animal";
        }
            break;
            
        case DFCTabPeople:
        {
            DEBUG_NSLog(@"DFCTabPeople");
            fileName = @"people.plist";
            title = @"人物";
            tabType = @"people";
        }
            break;
            
        case DFCTabTableware:
        {
            DEBUG_NSLog(@"DFCTabTableware");
            fileName = @"food.plist";
            title = @"食物";
            tabType = @"food";
        }
            break;
            
        case DFCTabHouse:
        {
            DEBUG_NSLog(@"DFCTabHouse");
            fileName = @"house.plist";
            title = @"家";
            tabType = @"house";
        }
            break;
            
        case DFCTabMusic:
        {
            DEBUG_NSLog(@"DFCTabMusic");
            fileName = @"music.plist";
            title = @"音乐";
            tabType = @"music";
        }
            break;
            
        case DFCTabScience:
        {
            DEBUG_NSLog(@"DFCTabScience");
            fileName = @"science.plist";
            title = @"科学";
            tabType = @"science";
        }
            break;
            
        case DFCTabSpace:
        {
            DEBUG_NSLog(@"DFCTabSpace");
            fileName = @"space.plist";
            title = @"太空";
            tabType = @"space";
        }
            break;
            
        default:
            break;
    }
    
    self.titleLabel.text = title;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"resources" ofType:@"bundle"];
    
    if (fileName.length ==0) {  // 自定义
        self.listView.hidden = self.contents.count == 0;
    }else {
        self.listView.hidden = NO;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSArray *a = [[NSArray alloc]initWithContentsOfFile:filePath];
        for (NSDictionary *dic in a) {
            NSString *name = dic[@"name"];
            DFC_EDResourceItem *item = [[DFC_EDResourceItem alloc]init];
            item.icon = name;
            NSString *fileName = [NSString stringWithFormat:@"%@@2x.png",name];
            NSString *imgPath = [[bundlePath stringByAppendingPathComponent:tabType] stringByAppendingPathComponent:fileName];
            item.selected = NO;
            item.editable = type == DFCTabCustom;
            item.path = imgPath;
            [self.contents addObject:item];
        }
        
//        [UIView animateWithDuration:0 animations:^{ 
            [self.listView reloadData];
//        }];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  self.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFC_EDResourceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFC_EDResourceCell" forIndexPath:indexPath];
    cell.delegate = self;
    if (self.contents.count) {
        cell.resourceItem = [self.contents objectAtIndex:indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DFC_EDResourceItem *resourceItem = [self.contents objectAtIndex:indexPath.item];
    if (self.selectedItem){ // 编辑可删除状态
//        resourceItem.editable = NO;
        self.selectedItem.editable = NO;
        self.selectedItem = nil;
        [self.listView reloadItemsAtIndexPaths:@[indexPath]];
    }else {
        resourceItem.selected = !resourceItem.selected;
        if (resourceItem.selected) {
            if (![self.selectedItems containsObject:resourceItem]) {
                [self.selectedItems addObject:resourceItem];
            }
        }else {
            if ([self.selectedItems containsObject:resourceItem]) {
                [self.selectedItems removeObject:resourceItem];
            }
        }
        [self.listView reloadItemsAtIndexPaths:@[indexPath]];
        [self setInsertTitle];
    }
}

#pragma mark - EDResourceCellDelegate
- (void)editItemInResourceCell:(DFC_EDResourceCell *)cell{
    
    if (cell.resourceItem.selected) {         // 选中时，则不响应长按编辑事件
        self.selectedItem.editable = NO;
        cell.resourceItem.editable = YES;
        self.selectedItem = cell.resourceItem;
        
        [self.listView reloadData];
    }
}

- (void)deleteItemInResourceCell:(DFC_EDResourceCell *)cell{
    
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:cell.resourceItem.itemID forKey:@"faceId"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_DeleteResourceFromCustom identityParams:params completed:^(BOOL ret, id obj) {
        DEBUG_NSLog(@"%@",obj);
        if (ret) {
            [self.contents removeObject:cell.resourceItem];
            [self.listView reloadData];
        }else {
            //            [DFCProgressHUD showErrorWithStatus:obj];
        }
    }];
}

- (void)setInsertTitle{
    if (self.selectedItems.count) {
        NSString *title = [NSString stringWithFormat:@"插入(%ld)",self.selectedItems.count];
        [self.insertButton setTitle:title forState:UIControlStateNormal];
    }else {
        [self.insertButton setTitle:@"插入" forState:UIControlStateNormal];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat margin = (self.bounds.size.width - 4*40)/5;
    return UIEdgeInsetsMake(3, margin, 3, margin);
}

- (void)back{
    DEBUG_NSLog(@"退出素材中心");
    if (self.delegate && [self.delegate respondsToSelector:@selector(exitResourceView)]) {
        [self.delegate exitResourceView];
    }
}

- (void)insert{
    DEBUG_NSLog(@"插入素材");
    if (self.delegate && [self.delegate respondsToSelector:@selector(inserPictures:)]) {
        [self.delegate inserPictures:self.selectedItems];
    }
}

- (void)showEditor:(UIButton *)sender{
    DEBUG_NSLog(@"打开编辑器");
    if (self.delegate && [self.delegate respondsToSelector:@selector(openEditor)]) {
        [self.delegate openEditor];
    }
}

- (void)layoutSubviews{
    self.titleLabel.frame = CGRectMake((self.bounds.size.width-80)/2 - 12, 5, 80, 30);
    self.backButton.frame = CGRectMake(5, 5, 30, 30);
    self.insertButton.frame = CGRectMake(self.bounds.size.width - 60 - 2, 5, 60, 30);
    self.tabView.frame = CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width, 40);
}


@end
