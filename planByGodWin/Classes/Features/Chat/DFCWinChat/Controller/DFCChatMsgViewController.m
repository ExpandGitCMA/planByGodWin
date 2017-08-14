//
//  DFCChatMsgViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCChatMsgViewController.h"
#import "DFCButton.h"
#import "DFCInputField.h"
#import "SendMessgeCell.h"
#import "DFCMessageFrameModel.h"
#import "JSImagePickerViewController.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCGrouplistViewController.h"
#import "DFCJoinClass.h"
#import "DFCSeatsLayoutController.h"
#import "StudentInfoViewController.h"
#import "TeacherViewController.h"
#import "PBGJSON.h"
#import "DFCLocalNotificationCenter.h"
@interface DFCChatMsgViewController ()<UITableViewDataSource, UITableViewDelegate,InputFieldDelegate,UITextFieldDelegate,JSImagePickerViewControllerDelegate>
@property(strong,nonatomic)DFCInputField *inputField;
@property(nonatomic,strong)NSMutableArray *arraySource;
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UIView *navigationView;
@property(strong,nonatomic)UILabel*userName;
@property(strong,nonatomic)DFCButton*msgFn;
@property(nonatomic,strong)NSString*msgMQ;//聊天消息
@property(nonatomic,strong)NSString*classCode;//聊天编码
@property(nonatomic,strong)NSString*personalMsg;//单聊群聊
@property(nonatomic,copy)NSString *userMsgCode;
@property(nonatomic,copy)NSString *userMsgName;
@property(nonatomic,strong)DFCJoinClass *joinView;
@property(nonatomic,strong) TeacherViewController *teacher ;
@property(nonatomic,strong) StudentInfoViewController *student;
@property(nonatomic,strong)  DFCSeatsLayoutController*list;
@property(nonatomic,strong)NSString *showMsgCode;
@property(nonatomic,strong) NSDictionary *responseJSON;

@end

@implementation DFCChatMsgViewController
-(instancetype)initWithSendObject:(DFCSendObjectModel *)model{
    if (self = [super init]) {
        if (model.modelType== ModelTypeClass) {//群聊
              self.personalMsg = @"F";
        }else{
                   self.personalMsg = @"T";
        }
        _model = model;
        self.classCode = model.code;
    }
    return self;
}

-(void)setModel:(DFCSendObjectModel *)model{
    self.personalMsg = @"T";
     _model = model;
    self.classCode = model.code;
    _userName.text = model.name;
}


- (void)viewDidLoad {
    [super viewDidLoad];
     [self arraySource];
     [self tableView];
     [self inputField];
     [self msgNotificationCenter];
     [self loadVieData];
     [self addSubNavigationView];
    
    // add by hmy release
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:DFCLogoutNotification
                                object:nil];
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:DFCOnClassNotification
                                object:nil];
}

- (void)kickOut:(NSNotification *)noti {
    UIViewController *presentedViewController = ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController);
    if (presentedViewController) {
        [presentedViewController dismissViewControllerAnimated:YES completion:nil];
        [presentedViewController removeFromParentViewController];
    }
}

-(NSMutableArray*)arraySource{
    if (!_arraySource) {
        _arraySource = [[NSMutableArray alloc]init];
        [self sendMsgCode:_model.code];
    }
    return _arraySource;
}

-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 124, SCREEN_WIDTH-320, SCREEN_HEIGHT-124-50) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setBackgroundColor:kUIColorFromRGB(DefaultColor)];
        UITapGestureRecognizer *top = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shakeAnimation:)];
        [_tableView addGestureRecognizer:top];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arraySource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SendMessgeCell *cell = [SendMessgeCell cellWithTableView:tableView];
    cell.frameMOdel = _arraySource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_arraySource[indexPath.row] rowHeight];
}

-(DFCInputField*)inputField{
    if (!_inputField) {
        _inputField = [DFCInputField initWithDFCInputFieldFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 249) delegate:self];
        _inputField.inputField.delegate = self;
        _inputField.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_inputField];
    }
    return _inputField;
}

-(void)addSubNavigationView{
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH-320, 60)];
    [_navigationView setBackgroundColor:kUIColorFromRGB(DefaultColor)];
    _userName = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-420)/2, (39)/2, 100, 21)];
    [_userName defaultStyle];
    _userName.text = _model.name;
    [self.navigationView addSubview:_userName];
    [self.view addSubview:_navigationView];
}

#pragma mark-监听键盘高度
-(void)keyboardWillChangeFrame:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect frame = [notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat offsetY = frame.origin.y - self.view.frame.size.height;
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, offsetY);
        [self hidesKeyboard];
    }];
}

#pragma mark--------------------------消息发送操作
-(void)sendMessageNetwork:(NSString*)meassge MsgType:(NSInteger)msgType{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    NSString *token = [[NSUserDefaultsManager shareManager]getUserToken];
    [params SafetySetObject:account forKey:@"userCode"];
    [params SafetySetObject:token forKey:@"token"];
    [params SafetySetObject:account forKey:@"senderCode"];
    [params SafetySetObject:self.classCode forKey:@"receiverCode"];
    NSNumber * mqMsgType = @(msgType);
    [params SafetySetObject:mqMsgType forKey:@"msgType"];
    [params SafetySetObject:self.personalMsg forKey:@"personalMsg"];
    NSDictionary*dic =[[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    NSString *content;
    if ([[NSUserDefaultsManager shareManager]isUserMark]) {//学生端
       content= [self msg:meassge imgUrl:dic[@"studentInfo"][@"imgUrl"] name:dic[@"studentInfo"][@"name"]];
    }else{
        content=[self msg:meassge imgUrl:dic[@"teacherInfo"][@"imgUrl"] name:dic[@"teacherInfo"][@"name"]];
    }
    if ([[NSUserBlankSimple shareBlankSimple]isBlankString:meassge]==NO) {
        [params SafetySetObject:content forKey:@"content"];
        @weakify(self)
        [[HttpRequestManager sharedManager]requestPostWithPath:URL_ChatSend params: params completed:^(BOOL ret, id obj) {
            @strongify(self)
            if (ret) {
                switch (msgType) {
                    case MessageTypeText:{
                       [self sendRequest:self.msgMQ MsgType:MessageTypeText];
                    }
                        break;
                    case MessageTypeImage:{
                        [self sendRequest:self.msgMQ MsgType:MessageTypeImage];

                    }
                        break;
                    case MessageTypeEmoji:{
                         [self sendRequest:self.msgMQ MsgType:MessageTypeEmoji];
                    }
                        break;
                    case MessageTypeVoice:{
                    }
                        break;
                    default:
                        break;
                }
                self.inputField.moreView.userInteractionEnabled = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3ull * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                });
            }else{
                DEBUG_NSLog(@"发送消息失败==%@",obj);
               [self showError:@"发送失败请重新发送" ];
            }
        }];
    }else{
        [self showError:@"发送失败请重新发送" ];
    }
}

-(void)showError:(NSString*)error{
    [DFCProgressHUD showErrorWithStatus:error duration:2.0f];
}
-(NSString*)msg:(NSString*)msg imgUrl:(NSString*)imgUrl name:(NSString*)name{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict SafetySetObject:msg forKey:@"msg"];
    [dict SafetySetObject:imgUrl forKey:@"imgUrl"];
    [dict SafetySetObject:name forKey:@"name"];
    NSString*json=[dict JSONString];
    [self matchDataSource:json];
    return json;
}

-(void)matchDataSource:(NSString *)JSONString{
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    _responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
}
#pragma mark-组装聊天消息自己发送本地显示
-(void)sendRequest:(NSString*)textField MsgType:(NSInteger)msgType{
    NSDictionary*dic = [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    NSString*name = dic[@"teacherInfo"][@"name"];
    NSString*imgUrl = dic[@"teacherInfo"][@"imgUrl"];
    NSArray *message = [ [NSString stringWithFormat:@"%@,%@,%@",name,imgUrl,textField]  componentsSeparatedByString:@","];
    if ([self.msgMQ isEqualToString:textField]&&[[NSUserBlankSimple shareBlankSimple]isBlankString:textField]==NO) {
        [self sendMessage:message type:MessageFromMe msgType:(MsgType)msgType];
    }else{
         DEBUG_NSLog(@"发送失败请重新发送");
    }
}

#pragma mark-聊天消息发送到显示页面显示
- (void)sendMessage:(NSArray *)message type:(MessageFrom)type msgType:(MsgType)msgType{
    DFCChatModel *model = [[DFCChatModel alloc] init];
    model.type = @(type);
    model.messageType = msgType;
    model.name = [_responseJSON objectForKey:@"name"];
    model.url = [_responseJSON objectForKey:@"imgUrl"];
    model.text = [_responseJSON objectForKey:@"msg"];
    model.userName = self.userName.text;
    model.classCode = self.classCode;
    model.userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"HH:mm:ss";
    NSDateFormatter *timer = [[NSDateFormatter alloc] init];
    timer.dateFormat = @"MM-dd hh:mm";
    model.time = [timer stringFromDate:[NSDate date]];
    model.code = [matter stringFromDate:[NSDate date]];
    [model save];
    DFCMessageFrameModel *frameModel = [[DFCMessageFrameModel alloc] init];
    frameModel.model = model;
      [_arraySource addObject:frameModel];
    _inputField.inputField.text = nil;
    [self loadVieData];
}

-(void)photoPiker{
   JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    [imagePicker showImagePickerInController:[UIApplication sharedApplication].keyWindow.rootViewController animated:YES];
}

#pragma mark-图片消息发送调用
- (void)imagePickerDidSelectImage:(UIImage *)image url:(NSURL *)fileUrl{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    @weakify(self)
    [[HttpRequestManager sharedManager] upLoadImageHead:fileUrl cacheImage:image params:params completed:^(BOOL ret, id obj) {
        @strongify(self)
        if (ret) {
            DEBUG_NSLog(@"obj==%@",obj);
            _inputField.moreView.userInteractionEnabled = NO;
            self.msgMQ = obj;
            [self sendMessageNetwork:obj MsgType: MessageTypeImage];
        } else {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [DFCProgressHUD showSuccessWithStatus:obj[@"msg"] duration:2];
            }
            else{
                [DFCProgressHUD showSuccessWithStatus:obj duration:2];
            }
        }
    }];
}

#pragma mark-获取接收到MQ网络消息对象
- (void)sendMessNot:(NSNotification *)note{
    NSDictionary *dic = [note object];
    [self msgSendMessage:dic];
}

-(void)msgSendMessage:(NSDictionary*)dic{
    self.showMsgCode = self.classCode;
    NSString *receiverCode ;
    NSInteger msgType = [[dic objectForKey:@"msgType"] integerValue];
    if ([[dic objectForKey:@"personalMsg"]isEqualToString:@"F"]) {//群聊
         receiverCode = [dic objectForKey:@"receiverCode"];
        [DFCLocalNotificationCenter sendLocalNotification:nil subTitle:nil body:nil type:DFCMessageObjectCountTypeMultiple];
    }else{
         receiverCode = [dic objectForKey:@"senderCode"];
        [DFCLocalNotificationCenter sendLocalNotification:nil subTitle:nil body:nil type:DFCMessageObjectCountTypeSingle];
    }
    [self sendMQMsg:[dic objectForKey:@"content"] type:MessageFromOther msgType:(MsgType)msgType MsgCode:receiverCode];
}
#pragma mark-接收MQ消息显示
- (void)sendMQMsg:(NSString*)message type:(MessageFrom)type msgType:(MsgType)msgType MsgCode:(NSString*)msgCode{
    DFCChatModel *model = [[DFCChatModel alloc] init];
    model.type = @(type);//消息的发送者
    model.messageType = msgType;
    NSData *JSONData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    model.name = [responseJSON objectForKey:@"name"];
    model.url = [responseJSON objectForKey:@"imgUrl"];
    model.text = [responseJSON objectForKey:@"msg"];
    model.userName = @"接收MQ消息显示";
    model.classCode = msgCode;

    model.userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    NSDateFormatter *matter = [[NSDateFormatter alloc] init];
    matter.dateFormat = @"HH:mm:ss";
    NSDateFormatter *timer = [[NSDateFormatter alloc] init];
    timer.dateFormat = @"MM-dd hh:mm";
    model.time = [timer stringFromDate:[NSDate date]];
    model.code = [matter stringFromDate:[NSDate date]];
    [model save];
    DFCMessageFrameModel *frameModel = [[DFCMessageFrameModel alloc] init];
    frameModel.model = model;
    if ([self.showMsgCode isEqualToString:msgCode]) {
         [_arraySource addObject:frameModel];
    }
    _inputField.inputField.text = nil;
    [self loadVieData];
}

#pragma mark-------------------------所有代理事件和点击事件
//-(void)pushController:(DFCButton *)sender{
//    switch (_type) {
//        case Subkeymsg:{
//            _list = [[DFCSeatsLayoutController alloc]initWithClass:_userMsgCode name:_userMsgName];
//            [self.navigationController pushViewController:_list animated:YES];
//        }
//            break;
//        case Subkeypersonal:{
//            _student = [[StudentInfoViewController alloc]initWithMsgModel:_model];
//            _student.type = MsgFnMsg;
//             [self.navigationController pushViewController:_student animated:YES];
//        }
//            break;
//        case Subkeyteacher:{
//            _teacher = [[TeacherViewController alloc]initWithMsgModel:_teacherClass];
//            [self.navigationController pushViewController:_teacher animated:YES];
//        }
//            break;
//        default:
//            break;
//    }
//}
-(void)popViewItem{
    [_teacher popViewItem:NULL];
    [_student popViewItem:NULL];
    [_list backAction];
}


#pragma mark-点击发送语音
-(void)messageVoice:(DFCInputField *)messageVoice sender:(UIButton *)sender{
      [self showKeyboard];
}

#pragma mark-点击发送表情
-(void)messageEmoji:(DFCInputField *)messageEmoji sender:(UIButton *)sender{
    [self showKeyboard];
    self.msgMQ =  _inputField.inputField.text;
    [_inputField.emoji setImage:[UIImage imageNamed:@"chat_bottom_send_nor"] forState:UIControlStateNormal];
    if (![_inputField.inputField.text isEqualToString:@""]&&![_inputField.emojicCode isEqualToString:@""]) {
        [self sendMessageNetwork:_inputField.emojicCode MsgType:MessageTypeEmoji];
        _inputField.inputField.text = nil;
        _inputField.emojicCode = nil;
    }
}

#pragma mark-点击更多功能
-(void)messageMore:(DFCInputField *)messageMore sender:(UIButton *)sender{
    [self showKeyboard];
}

#pragma mark-更多工具(拍照 图片 文件等)
-(void)messageTool:(DFCInputField *)messageTool toolType:(NSInteger)toolType{
    switch (toolType) {
        case 0:{//图片 拍摄
            [self photoPiker];
        }
            break;
        case 1:{//文件发送
        }
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hidesKeyboard];
}

-(void)shakeAnimation:(UIGestureRecognizer *)sender{
      [self hidesKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        self.msgMQ = textField.text;
        [self sendMessageNetwork:textField.text MsgType: MessageTypeText];
        textField.text  = nil;
        return YES;
    }
    return NO;
}

-(void)loadVieData{
    if ([[NSUserBlankSimple shareBlankSimple]isExist:_arraySource]==YES||_arraySource.count>1) {
     [self refreshDataSource:YES];
    }
}
#pragma mark-切换到对应的聊天页面
-(void)sendMsgCode:(NSString*)classCode{
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    NSArray *files = [DFCChatModel findByFormat:@"WHERE userCode = '%@' AND classCode = '%@' ", userCode,classCode];
    for (DFCChatModel *model in  files) {
        [self sendMessage:model];
    }
}

-(void)clearDataSource{
    [_arraySource removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)sendMessage:(DFCChatModel *)model {
    DFCMessageFrameModel *frameModel = [[DFCMessageFrameModel alloc] init];
    frameModel.model = model;
    [_arraySource addObject:frameModel];
    if ([[NSUserBlankSimple shareBlankSimple]isExist:_arraySource]==YES||_arraySource.count>1) {
        [self refreshDataSource:NO];
    }
}
-(void)refreshDataSource:(BOOL)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        NSIndexPath *path = [NSIndexPath indexPathForRow:_arraySource.count-1  inSection:0];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:data];
    });
}

-(void)showKeyboard{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [_inputField.inputField resignFirstResponder];
            _inputField.frame = CGRectMake(0,  self.view.frame.size.height-249, self.view.frame.size.width, 249);
            _tableView.frame = CGRectMake(0, 124, SCREEN_WIDTH-320, SCREEN_HEIGHT-124-50-199);
            [_tableView reloadData];
        }];
    });
}

-(void)hidesKeyboard{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            _inputField.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 249);
            _tableView.frame = CGRectMake(0, 124, SCREEN_WIDTH-320, SCREEN_HEIGHT-124-50);
            [_inputField.emoji setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        }];
    });
}

-(void)msgNotificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessNot:) name:MQMeassge object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MQMeassge object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
