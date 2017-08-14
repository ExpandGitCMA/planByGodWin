//
//  NSUserDefaultsManager.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/10.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultsManager : NSObject
+(NSUserDefaultsManager *)shareManager;
@property (strong,nonatomic) NSString * userToken;//判断是否进入聊天框
/**
 *  缓存获取清除账号信息
 */
-(void)setAccounNumber:(NSString *)accounNumber password:(NSString*)password;
-(NSString *)getAccounNumber;
-(NSString *)getPassWord;
-(void)removeAccounNumber;
-(void)removePassWord;

/**
 *  缓存获取教师个人信息
 */
-(void)setTeacherInfoCache:(NSDictionary *)dic;
-(NSDictionary *)getTeacherInfoCache;
-(void)removeAllInfo;


- (NSString *)getTeacherCode;
- (NSString *)getSchoolCode;
- (NSDictionary *)getBasePersonInfo;

-(void)saveUserToken:(NSString *)token;
-(NSString*)getUserToken;
-(NSString*)getUserTypeCode;
- (NSString *)currentCode;
//教师和学生的Name
- (NSString *)currentName;
//教师和学生的手机号
- (NSString *)currentPhone;

//获取学生教师版本登陆
-(void)setUserMarkCode:(NSString *)userMark;
-(NSString*)getUserMarkCode;
-(BOOL)isUserMark;


//保存学生班级classCode
-(void)studentClassCode:(NSString *)code className:(NSString*)className;
-(NSString*)getStudentClassCode;
-(NSString*)getClassName;

//是否具有调整座位权限
- (BOOL)canSetSeatsLayout;

//声音
- (void)setSingleMessageSoundSetting:(BOOL)isOn;
- (BOOL)getSingleMessageSoundSetting;
//群声音
- (void)setMutipleMessageSoundSetting:(BOOL)isOn;
- (BOOL)getMutipleMessageSoundSetting;

// 获取当前版本
- (NSString *)getCurrentVersion;

//录播IP
- (void)setRecordPlayIP:(NSString *)ip;
- (NSString *)getRecordPlayIP;

//获取学校的网络地址
-(void)saveAddressIp:(NSString *)addressIp;
-(NSString*)addressIp;
-(NSString*)amqpUrl;
-(NSString*)baseUrl;
-(NSString*)uploadUrl;

// add by hmy
- (BOOL)isLogin;
- (void)setIsLogin:(BOOL)islogin;

// add by hmy
- (BOOL)isOpeningCourseware;
- (void)setIsOpeningCourseware:(BOOL)isOpeningCourseware;

// add by hmy
- (BOOL)isClosingCourseware;
- (void)setisClosingCourseware:(BOOL)isClosingCourseware;

// add by hmy
- (NSString *)getStudentName;

- (void)setStudentIcon:(NSString *)studentIcon;
- (NSString *)studentIcon;

- (BOOL)isUseLANForClass;
- (void)setIsUseLANForClass:(BOOL)isUseLANForClass;

- (NSString *)lanClassCode;
- (void)setLanClassCode:(NSString *)lanClassCode;

- (NSDictionary *)onClassMessage;
- (void)setOnClassMessage:(NSDictionary *)onClassMessage;

@end
