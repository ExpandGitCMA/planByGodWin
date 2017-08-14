//
//  DFCCreateFileViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCreateFileViewController.h"
#import "DFCCreateFileModel.h"
#import "DFCFiletitelView.h"
@interface DFCCreateFileViewController ()
@property(nonatomic,strong)NSArray *arraySource;
@property(nonatomic,strong)UILabel*titel;
@property(nonatomic,strong)DFCFiletitelView*titelView;
@property (nonatomic, weak) id <DFCCreateFileDelegate> delegate;
@end

@implementation DFCCreateFileViewController

-(instancetype)initWithDelegate:(id<DFCCreateFileDelegate>)delgate{
    if (self = [super init]) {
        _delegate = delgate;
    }
    return self;
}
-(NSArray*)arraySource{
    if (_arraySource==nil) {
        _arraySource = [DFCCreateFileModel parseJsonWithObj];
    }
    return _arraySource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView = [self titelView];
}

-(DFCFiletitelView*)titelView{
    if (!_titelView) {
        _titelView = [[DFCFiletitelView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
        _titelView.backgroundColor = [UIColor clearColor];
    }
     return  _titelView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(didCreateFileType:)]) {
        [self.delegate didCreateFileType:indexPath.row];
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arraySource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    DFCCreateFileModel *model = [_arraySource SafetyObjectAtIndex:indexPath.row];
    cell.textLabel.text = model.titel;
    cell.imageView.image = [UIImage imageNamed:model.url];
    // Configure the cell...
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(200, 64*_arraySource.count+45);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
