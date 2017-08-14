//
//  StudentInfoViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "StudentInfoViewController.h"
#import "DFCProfileInfoCell.h"
//#import "DFCMqMsgChatViewController.h"
@interface StudentInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)DFCGroupClassMember *model;
@property(nonatomic,strong)DFCSendObjectModel *object;
@property(nonatomic,strong)UITableView*tableView;
@property(strong,nonatomic)DFCButton *msg;
@property(strong,nonatomic)DFCButton *msgFn;
@end

@implementation StudentInfoViewController
-(instancetype)initWithSendObjectModel:(DFCSendObjectModel *)model{
    if (self = [super init]) {
        _object = model;
    }
    return self;
}
-(instancetype)initWithMsgModel:(DFCGroupClassMember *)model{
    if (self = [super init]) {
        _model = model;
    }
    return self;
}
-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 124, self.view.frame.size.width-100, self.view.frame.size.height-124) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView registerNib:[UINib nibWithNibName:@"DFCProfileInfoCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
#pragma mark <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DFCProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (self.type==MsgFnMsg ) {
        [cell studentSendObject:indexPath model:self.object];
    }else{
        [cell studentInfo:indexPath model:self.model];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
       return 50;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self tableView];
    [self msg];
    [self msgFn];
}
-(void)setNavigationViw{
    [super setNavigationViw];
}
-(void)setNavigationrightItem{
    [super setNavigationrightItem];
    [self.rightItem setImage:[UIImage imageNamed:@"Board_Back"] forState:UIControlStateNormal];
}
-(void)popViewItem:(DFCButton *)sender{
  [self.navigationController popViewControllerAnimated:YES];
}

-(DFCButton*)msg{
    if (!_msg) {
        _msg = [DFCButton buttonWithType:UIButtonTypeCustom];
        _msg.frame = CGRectMake(50, self.view.frame.size.height-115, 200, 45);
//        [_msg setBackgroundColor:[UIColor]]
//        _login = [[DFCButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight,SubkeyLoginWidth, SubkeyLoginHeight)];
        //[_msg setKey:Subkeylogin];
        [_msg setButtonMsgStyle];
        [_msg setBackgroundColor:kUIColorFromRGB(MsgColor)];
        _msg.titleLabel.font = [UIFont systemFontOfSize:15];
        [_msg  setTitle:@"发送消息" forState:UIControlStateNormal];
        [_msg addTarget:self action:@selector(msgViewItem:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_msg];
    }
    return _msg;
}
-(DFCButton*)msgFn{
    if (!_msgFn) {
        _msgFn = [DFCButton buttonWithType:UIButtonTypeCustom];
        _msgFn.frame = CGRectMake(self.view.frame.size.width-255, self.view.frame.size.height-115, 200, 45);
        //        [_msg setBackgroundColor:[UIColor]]
        //        _login = [[DFCButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight,SubkeyLoginWidth, SubkeyLoginHeight)];
        [_msgFn setKey:Subkeylogin];
        [_msgFn  setTitle:@"查看课堂作品" forState:UIControlStateNormal];
//        [_msg addTarget:self action:@selector(msgViewItem:) forControlEvents:UIControlEventTouchUpInside];
        _msgFn.hidden = YES;
        [self.view addSubview:_msgFn];
    }
    return _msg;
}
-(void)msgViewItem:(DFCButton *)sender{
    switch (_type) {
        case MsgFnTable:{
//                DFCMqMsgChatViewController *chatMsgVC = [[DFCMqMsgChatViewController alloc]init];
//            [self.navigationController pushViewController:chatMsgVC animated:YES];
              [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case MsgFnMsg:{
            [self popViewItem:NULL];
        }break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
