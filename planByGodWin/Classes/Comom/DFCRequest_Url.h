//
//  DFCRequest_Url.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/10.
//  Copyright © 2016年 DFC. All rights reserved.
//

#ifndef DFCRequest_Url_h
#define DFCRequest_Url_h
#import "NSUserBlankSimple.h"

#pragma mark-planByGodWin_接口

#define SeverEnvironment 2

#if  SeverEnvironment==1  //开发测试网络

#define BASE_API_URL @"http://192.168.2.115:8080/dfcMgr/v1"
//#define BASE_API_URL  @"http://192.168.2.73/v1/"
#define BASE_UPLOAD_URL @"http://192.168.2.73/upload"
#define MQSERVER_CONN @"amqp://dfcdfc:dfc_123_dfc@192.168.2.73:5672"

#elif SeverEnvironment==2  //正式发布网络

#define BASE_API_URL @"http://api.dafenci.com/v1/"

//#define BASE_Store_URL @"http://61.130.5.167"
//#define MQSERVER_CONN @"amqp://dfcdfc:dfc_123_dfc@dfc.dafenci.com:5672"
//#define BASE_UPLOAD_URL @"http://dfc.dafenci.com/upload"

#define BASE_UPLOAD_URL  [[NSUserDefaultsManager shareManager]uploadUrl]
#define MQSERVER_CONN    [[NSUserDefaultsManager shareManager]amqpUrl]

//#define MQSERVER_CONN @"amqp://dfcdfc:dfc_123_dfc@192.168.2.73:5672"
//#define MQSERVER_CONN @"amqp://dfcdfc:dfc_123_dfc@dfc.dafenci.com:5672"

#endif
#define user_Teacher                    @"01"//表示ios教师端
#define user_Student                    @"02"//表示ios学生端

#define URL_TokenGet                @"token/get"

#define URL_NetworkTest            @"network/test"
#define URL_SchoolList                @"school/list"//获取全部学校
#define URL_Login                       @"teacher/login"
#define URL_ChatSend                 @"chat/send"//消息发送

#define URL_FileUpload              @"file/upload"//文件上传
#define URL_UserInfo                @"teacher/get"//教师个人信息
#define URL_UpdateUserInfo          @"teacher/update"//修改教师个人信息
#define URL_ModifyTeacherPsw        @"teacher/updatepassword"//修改教师密码
#define URL_AddCourseware           @"courseware/add"//添加课件
#define URL_CoursewareList          @"courseware/teachercourseware"//教师服务器端课件列表
#define URL_CoursewareSendToClass   @"courseware/send2class"//发送课件给班级
#define URL_CoursewareSendToStudent @"courseware/send2student"//发送课件给学生
#define URL_CoursewareSendToTeacher @"courseware/send2teacher"//发送课件给老师
#define URL_CoursewareListStudent   @"courseware/studentcourseware"//学生服务器课件列表

#define URL_SetSeatLayout           @"recordbroadcast/adjustSeatNo"//调整座位布局
#define URL_ControlStudentRecord    @"recordbroadcast/ctrlStudent"//控制学生录播

#define URL_CloudFileList           @"cloudfile/get"//云文件列表
#define URL_CloudFile             @"cloudfile/getDirAndFile"//云文件夹
#define URL_SchoolClass        @"class/schoolclass" // 全校班级
#define URL_TeacherClass     @"class/teacherclass" // 教师班级

// 上课交互
#define URL_ClassroomEntry     @"classroom/entry" // 教师班级
#define URL_ClassroomExit     @"classroom/exit" // 教师班级
#define URL_ClassroomLock     @"classroom/lock" // 教师班级
#define URL_ClassroomUnlock     @"classroom/unlock" // 教师班级
#define URL_ClassroomPageNo     @"classroom/pageno" // 教师班级
#define URL_ClassroomNotOperate     @"classroom/notoperate" // 课件可见不可操作
#define URL_StudentCommitFile   @"classroom/addfile" // 教师班级
#define URL_StudentLogin            @"student/login"
#define URL_StudentClass            @"class/studentclass"//学生所在班级
#define URL_ClassMember           @"class/member"//班级成员
#define URL_ClassTeacherclass     @"class/teacherclass"//教师所教班级
#define URL_FileUpload                @"file/upload"//文件上传
#define URL_UserInfo                   @"teacher/get"//教师个人信息
#define URL_StudentInfo               @"student/get"//学生个人信息
#define URL_UpdateUserInfo         @"teacher/update"//修改教师个人信息
#define URL_UpdateStudent          @"student/update"//修改学生个人信息
#define URL_ModifyTeacherPsw     @"teacher/updatepassword"//修改教师密码
#define URL_ModifyStudentPsw     @"student/updatepassword"// 修改学生密码

#define URL_TeacherList               @"teacher/allTeacher"

#define URL_DeleteCoursewareInCloud @"courseware/deleteCourseware" // 删除云盘中的课件

// add 云盘上传
#define URL_AddCoursewareToCloud @"courseware/addCourseware"   // 上传到云盘（文件、缩略图）

// 商城
#define URL_CoursewareListForStore  @"store/getCourseware"  // 获取商城课件列表
#define URL_GetAllSubject @"subject/get"    // 获取科目
#define URL_GetAllStage @"stage/get"    // 获取学段

#define URL_AddCoursewareToStore @"store/addCourseware"    // 上传课件到商城
#define URL_DeleteCoursewareInStore @"store/deleteCourseware" // 删除我的商城中课件
#define URL_UpdateCoursewareInfoInStore @"store/updateCourseware" // 编辑上传到商城的课件信息
#define URL_PreviewCoursewareInStore @"store/previewCourseware"    // 答享圈课件预览次数增加
#define URL_DownloadCoursewareInStore @"store/downloadCourseware"   // 商城课件下载次数增加
#define URL_GetPayOrderInfoURL  @"store/buyCourseware"   // 购买商城课件订单信息
#define URL_SelectCoursewareIsPurchased  @"store/orderRecord"   // 查看课件是否已经购买
#define URL_CommentCoursewareInStore @"store/addComment"    //  评价课件
#define URL_GetCommentsOfCoursewareInStore @"store/getComment"    //  获取课件评价

#define URL_GetPersonalSellRecords @"store/sellOrderList"    //  获取个人课件售出记录
#define URL_GetPersonalBuyRecords @"store/orderList"    //  获取个人课件购买记录
#define URL_DeleteOrder @"store/deleteOrder" // 删除订单

#define URL_AddAlipayAccounts @"store/bindAlipay"    //  绑定支付宝账号
#define URL_UpdateAlipayAccounts @"store/updateAlipay"    //  修改支付宝账号
#define URL_Incash @"store/withdraw"    //  提现
#define URL_GetFundRecord @"store/fundRecord"   // 收支明细
#define URL_GetAccountInfo @"store/getAlipayInfo"  //  获取账号信息、余额

// 关联课件
#define URL_GetAllVideosInCloud @"cloudfile/getVideo" // 获取云文件中的视频
#define URL_BindFileForCoursewareInStore @"store/bindVideo"    // 绑定文件（视频）
#define URL_GetContactedFileInfo @"store/getCoursewareVideo"   // 获取课件关联视频
#define URL_UnbindFile @"store/unbindVideo"  // 解绑文件

// 自定义素材库
#define URL_GetCustomResources  @"face/get" // 获取自定义素材库资源
#define URL_AddResourceToCustom @"face/add" // 添加到素材库
#define URL_DeleteResourceFromCustom @"face/delete" //  删除指定素材

#define URL_GetVerifyCode @"common/authcode/get"   // 获取验证码
#define URL_GrabCrash @"common/crash"   // 捕获异常

#endif /* DFCRequest_Url_h */


