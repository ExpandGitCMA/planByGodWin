//
//  DFCStudentListsViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

// 670 * 607

#import "DFCStudentListsViewController.h"
#import "DFCGropMemberModel.h"
#import "DFCStudentListCollectionViewCell.h"
#import "ERSocket.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCSeatLayoutView.h"
#import "DFCStudentWorksViewController.h"
#import "DFCTcpServer.h"

static NSString *kCellIdentify = @"studentCell";

@interface DFCStudentListsViewController () <DFCSeatLayoutViewDelegate, DFCStudentWorksViewControllerDelegate> {
    DFCGroupClassMember *_selectedStudent;
}

@property (weak, nonatomic) IBOutlet UIButton *cancelRecordButton;
@property (weak, nonatomic) IBOutlet DFCSeatLayoutView *seatLayoutView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) DFCGroupClassMember *selectedModel;
@property (nonatomic, strong) DFCStudentWorksViewController *studentWorksViewController;

@end

@implementation DFCStudentListsViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)hasStudentConnect:(NSNotification *)noti {
    [self.seatLayoutView hasStudentConnect:noti];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_initSubview];
    
    self.view.layer.cornerRadius = 15.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
    self.view.layer.borderWidth = 1.0;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setClassCode:(NSString *)classCode {
    _classCode = classCode;
    self.seatLayoutView.classCode = classCode;
    self.textLabel.text = [NSString stringWithFormat:@"学生列表"];
}

- (IBAction)cancelRecordAction:(id)sender {
    [self controlStudentRecord:nil];
    [[ERSocket sharedManager] sendSeatLocaation:nil];
    [self.seatLayoutView reload];
}

- (void)p_initSubview {
    self.seatLayoutView.delegate = self;
    self.seatLayoutView.classCode = _classCode;
    self.seatLayoutView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
}

- (DFCStudentWorksViewController *)studentWorksViewController {
    if (!_studentWorksViewController) {
        _studentWorksViewController = [[DFCStudentWorksViewController alloc] initWithNibName:@"DFCStudentWorksViewController" bundle:nil];
        //_studentWorksViewController.studentCode = _currentClassCode;
        _studentWorksViewController.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _studentWorksViewController.delegate = self;
    }
    return _studentWorksViewController;
}

- (void)studentWorksViewControllerDidBack:(DFCStudentWorksViewController *)vc {
    
}

- (void)studentWorksViewController:(DFCStudentWorksViewController *)vc
                    didSelectImage:(NSString *)imgUrl
                             index:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(studentWorksViewController:didSelectStudent:image:index:)]) {
        [self.delegate studentWorksViewController:vc
                                 didSelectStudent:self.studentWorksViewController.student
                                            image:imgUrl
                                            index:index];
    }
}

- (void)pushStudentWorksController {
    self.studentWorksViewController.student = _selectedStudent;
    [self.navigationController pushViewController:self.studentWorksViewController animated:YES];
}

- (void)seatLayoutView:(DFCSeatLayoutView *)layoutView didSelectStudent:(DFCGroupClassMember *)student {
    _selectedStudent = student;
    [self pushStudentWorksController];

    [[ERSocket sharedManager] sendSeatLocaation:student.seatNo];
    [self controlStudentRecord:student];
}

- (void)controlStudentRecord:(DFCGroupClassMember *)model
{
    if (_selectedModel) {
        NSMutableDictionary *cancelParams = [[NSMutableDictionary alloc] init];
        [cancelParams SafetySetObject:_selectedModel.studentCode forKey:@"studentCode"];
        [cancelParams SafetySetObject:@"00" forKey:@"order"];
        [[HttpRequestManager sharedManager] requestPostWithPath:URL_ControlStudentRecord params:cancelParams completed:^(BOOL ret, id obj) {
            _selectedModel = nil;
            if (model) {
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params SafetySetObject:model.studentCode forKey:@"studentCode"];
                [params SafetySetObject:@"01" forKey:@"order"];
                [params SafetySetObject:[DFCUserDefaultManager getRecordPlayIP] forKey:@"content"];
                [[HttpRequestManager sharedManager] requestPostWithPath:URL_ControlStudentRecord params:params completed:^(BOOL ret, id obj) {
                    if (ret) {
                        _selectedModel = model;
                    }
                }];
            }
            
        }];
    } else {
        if (model) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params SafetySetObject:model.studentCode forKey:@"studentCode"];
            [params SafetySetObject:@"01" forKey:@"order"];
            [params SafetySetObject:[DFCUserDefaultManager getRecordPlayIP] forKey:@"content"];
            [[HttpRequestManager sharedManager] requestPostWithPath:URL_ControlStudentRecord params:params completed:^(BOOL ret, id obj) {
                if (ret) {
                    _selectedModel = model;
                }
            }];
        }
    }
    
}

@end
