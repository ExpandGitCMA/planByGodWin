//
//  NSUserDefaultsManager.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/10.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "NSUserDefaultsManager.h"
#import "DFCUtility.h"
#import "NSUserDataSource.h"

static NSString *const userTokenCache       = @"token";

static NSString *const studentIconKey   = @"studentIconKey";
static NSString *const isClosingCoursewareKey   = @"isClosingCoursewareKey";
static NSString *const isOpeningCoursewareKey   = @"isOpeningCoursewareKey";
static NSString *const isLoginKey   = @"isLogin";
static NSString *const schoolCodeCache   = @"schoolCode";
static NSString *const accounCache       = @"accounCache";
static NSString *const passwordCache     = @"passwordCache";
static NSString *const personalCache     = @"personalCache";
static NSString *const studentCache      = @"studentCache";
static NSString *const presentTimerCache = @"presentTimerCache";
static NSString *const userMarkCache     = @"userMarkCache";
static NSString *const schoolAddressIP   = @"schoolAddressIP";
static NSString *const classNameCache    = @"classNameCache";
static NSString *const classCodeCache    = @"classCode";
static NSString *const fileIndexCache    = @"fileIndexCache";
static NSString *const syllabusIndex     = @"syllabusIndexCache";
static NSString *const termInfoDic       = @"termInfoDic";
static NSString *const userMark            = @"userMark";
static NSString *const studentCodeCache    = @"studentCodeCache";
static NSString *const studentClassName    = @"studentClassName";

// add by hmy
static NSString *const isUseLANForClassKey    = @"isUseLANForClassKey";
static NSString *const lanClassCodeKey    = @"lanClassCodeKey";
static NSString *const onClassMessageKey    = @"onClassMessageKey";

@interface NSUserDefaultsManager()
@property (strong,nonatomic) NSUserDefaults *userDefaults;
@end

@implementation NSUserDefaultsManager

+ (id)allocWithZone:(NSZone *)zone{
    return [self shareManager];
}

+(NSUserDefaultsManager *)shareManager{
    static NSUserDefaultsManager *userDefMag = nil;
    if (userDefMag == nil) {
        static dispatch_once_t dispatch;
        dispatch_once(&dispatch, ^{
            userDefMag = [[super allocWithZone:NULL] init];
            [[NSNotificationCenter defaultCenter] addObserver:userDefMag selector:@selector(sendToken:) name:MQUserToken object:nil];
        });
    }
    return userDefMag;
}

- (void)sendToken:(NSNotification *)token{
    _userToken = [token object];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MQUserToken object:nil];
}
-(NSUserDefaults *)getUserDefaults{
    if (_userDefaults == nil) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}


-(void)setAccounNumber:(NSString *)accounNumber password:(NSString*)password{
    if (accounNumber != nil) {
        NSUserDefaults* user = [self getUserDefaults];
        [user setObject:accounNumber forKey:accounCache];
        [user setObject:password forKey:passwordCache];
        [user synchronize];
    } else {
        DEBUG_NSLog(@"accountNumber = nil");
    }
}
-(NSString *)getAccounNumber{
    NSUserDefaults* user = [self getUserDefaults];
    NSString* accounNumber = [user objectForKey:accounCache];
    return accounNumber;
}

-(NSString *)getPassWord{
    NSUserDefaults* user = [self getUserDefaults];
    NSString* password = [user objectForKey:passwordCache];
    return password;
}
-(void)removeAccounNumber{
    NSUserDefaults *user = [self getUserDefaults];
   [user removeObjectForKey:accounCache];
    [user synchronize];
}

-(void)removePassWord{
    NSUserDefaults *user = [self getUserDefaults];
    [user removeObjectForKey:passwordCache];

    // add by hmy 移除token
    [user removeObjectForKey:userTokenCache];
    _userToken = nil;
    [user removeObjectForKey:personalCache];
    
    [user synchronize];
}

-(void)setTeacherInfoCache:(NSDictionary *)dic{
    if (dic!=nil) {
        NSUserDefaults *user = [self getUserDefaults];
        [user setObject:dic forKey:personalCache];
        [user synchronize];
    
        NSDictionary *studentInfo = dic[@"studentInfo"];
        [self setStudentIcon:studentInfo[@"imgUrl"]];
    }
}
-(NSDictionary *)getTeacherInfoCache{
    NSUserDefaults *user = [self getUserDefaults];
    NSDictionary *dic = [user objectForKey:personalCache];
    return dic;
}
//教师和学生的手机号
- (NSString *)currentPhone{
    if ([DFCUtility isCurrentTeacher]) {
        NSDictionary *dic = [self getTeacherInfoCache];
        NSString *code = dic[@"teacherInfo"][@"mobile"];
        return code;
    } else {
        NSDictionary *dic = [self getTeacherInfoCache];
        NSString *code = dic[@"studentInfo"][@"tel"];
        return code;
    }
}

//教师和学生的Code
- (NSString *)currentCode{
    if ([DFCUtility isCurrentTeacher]) {
        NSDictionary *dic = [self getTeacherInfoCache];
        NSString *code = dic[@"teacherInfo"][@"teacherCode"];
        return code;
    } else {
        NSDictionary *dic = [self getTeacherInfoCache];
        NSString *code = dic[@"studentInfo"][@"studentCode"];
        return code;
    }
}

//教师和学生的Name
- (NSString *)currentName{
    if ([DFCUtility isCurrentTeacher]) {
        NSDictionary *dic = [self getTeacherInfoCache];
        NSString *code = dic[@"teacherInfo"][@"name"];
        return code;
    } else {
        NSDictionary *dic = [self getTeacherInfoCache];
        NSString *code = dic[@"studentInfo"][@"name"];
        return code;
    }
}

//获取全局 token
-(NSString*)getUserToken{
    NSDictionary *dic = [self getTeacherInfoCache];
    if (!([dic objectForKey:userTokenCache]==nil)) {
        NSString* token =   [dic objectForKey:userTokenCache];
        return token;
    }else{
        NSUserDefaults *user = [self getUserDefaults];
        NSString* token =   [user objectForKey:userTokenCache];
        return token;
    }
    return NULL;
}

-(void)saveUserToken:(NSString *)token{
    if (token!=nil) {
        NSUserDefaults *user = [self getUserDefaults];
        [user setObject:token forKey:userTokenCache];
        [user synchronize];
    }
}

//获取登陆身份
-(NSString*)getUserTypeCode{
    NSDictionary *dic = [self getTeacherInfoCache];
    NSString *code = dic[@"teacherInfo"][@"userType"];
    return code;
}

-(void)removeAllInfo{
    NSUserDefaults *user = [self getUserDefaults];
    [user removeObjectForKey:personalCache];
    [user removeObjectForKey:studentCache];
    [user removeObjectForKey:userTokenCache];
    _userToken = nil;
    [user synchronize];
    [[NSUserDataSource sharedInstanceDataDAO]removeDataAllObjects];
}

- (NSString *)getTeacherCode
{
    NSUserDefaults *user = [self getUserDefaults];
    NSDictionary *dic = [user objectForKey:personalCache];
    NSDictionary *dic2 = [dic objectForKey:@"teacherInfo"];
    return [dic2 objectForKey:@"teacherCode"];
}

- (NSString *)getSchoolCode{
    NSUserDefaults *user = [self getUserDefaults];
    NSDictionary *dic = [user objectForKey:personalCache];
    if ([[NSUserDefaultsManager shareManager]isUserMark]) {//学生
        NSString*schoolCode = dic[@"schoolInfo"][@"schoolCode"];
        return schoolCode;
    }else{
        NSDictionary *dic2 = [dic objectForKey:@"teacherInfo"];
        if (!dic2) {
            dic2 = [dic objectForKey:@"schoolInfo"];
        }
        return [dic2 objectForKey:@"schoolCode"];
    }
    return NULL;
}

- (NSDictionary *)getBasePersonInfo{
    NSUserDefaults *user = [self getUserDefaults];
    NSDictionary *dic = [user objectForKey:personalCache];
    NSDictionary *personInfo = [dic objectForKey:@"teacherInfo"];
    NSMutableDictionary *baseInfo = [[NSMutableDictionary alloc] init];
    [baseInfo setValue:[personInfo objectForKey:@"imgUrl"] forKey:@"imgUrl"];
    [baseInfo setValue:[personInfo objectForKey:@"accountNo"] forKey:@"accountNo"];
    [baseInfo setValue:[personInfo objectForKey:@"name"] forKey:@"name"];
    NSString *sex = nil;
    if ([[personInfo objectForKey:@"sex"] isEqualToString:@"M"]) {
        sex = @"男";
    } else {
        sex = @"女";
    }
    [baseInfo setValue:sex forKey:@"sex"];
    [baseInfo setValue:[personInfo objectForKey:@"mobile"] forKey:@"mobile"];
    NSDictionary *schoolInfo = [user objectForKey:@"schoolInfo"];
    [baseInfo setValue:[schoolInfo objectForKey:@"schoolName"] forKey:@"schoolName"];
    return baseInfo;
}


-(void)setUserMarkCode:(NSString *)userMark{
    if (userMark!=nil) {
        NSUserDefaults* user = [self getUserDefaults];
        [user setObject:userMark forKey:userMarkCache];
        [user synchronize];
    }
}
-(NSString*)getUserMarkCode{
    NSUserDefaults* user = [self getUserDefaults];
    NSString* userMark = [user objectForKey:userMarkCache];
    return userMark;
}
-(BOOL)isUserMark{
    NSUserDefaults* user  = [self getUserDefaults];
    NSString* userMark     = [user objectForKey:userMarkCache];
    if ([userMark isEqualToString:user_Teacher]){
        return NO; //教师登陆
    } else {
        return YES; //学生登陆
    }
//    
//    NSUserDefaults *user = [self getUserDefaults];
//    BOOL isNot = [user boolForKey:userMark];
//    //学生YES   教师NO
//    return isNot;
}

-(void)studentClassCode:(NSString *)code className:(NSString*)className{
    NSUserDefaults *user = [self getUserDefaults];
    [user setObject:code forKey:studentCodeCache];
    [user setObject:className forKey:studentClassName];
    [user synchronize];
}
-(NSString*)getStudentClassCode{
    NSUserDefaults* user = [self getUserDefaults];
    NSString* classCode = [user objectForKey:studentCodeCache];
    return classCode ;
}
-(NSString*)getClassName{
    NSUserDefaults* user = [self getUserDefaults];
    NSString* className = [user objectForKey:studentClassName];
    return className ;
}


/**
 是否具有调整座位权限
 */
- (BOOL)canSetSeatsLayout
{
    NSString *userType = [self getUserTypeCode];
    NSString *studentClassJob = [[[self getTeacherInfoCache] objectForKey:@"studentInfo"] objectForKey:@"classJob"];
    return [userType isEqualToString:@"01"] || [studentClassJob isEqualToString:@"班长"] || [DFCUtility isCurrentTeacher];
}


/**
 声音
 */
- (void)setSingleMessageSoundSetting:(BOOL)isOn
{
    NSUserDefaults *user = [self getUserDefaults];
    [user setBool:isOn forKey:@"singleMessageSound"];
    [user synchronize];
}

- (BOOL)getSingleMessageSoundSetting
{
    NSUserDefaults *user = [self getUserDefaults];
    return [user boolForKey:@"singleMessageSound"];
}


/**
 群声音
 */
- (void)setMutipleMessageSoundSetting:(BOOL)isOn
{
    NSUserDefaults *user = [self getUserDefaults];
    [user setBool:isOn forKey:@"mutipleMessageSound"];
    [user synchronize];
}

- (BOOL)getMutipleMessageSoundSetting
{
    NSUserDefaults *user = [self getUserDefaults];
    return [user boolForKey:@"mutipleMessageSound"];
}
/**
 获取当前版本号
 */
- (NSString *)getCurrentVersion{
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

/**
 录播服务IP
 */
- (void)setRecordPlayIP:(NSString *)ip
{
    NSUserDefaults *user = [self getUserDefaults];
    [user setObject:ip forKey:@"recordPlayIP"];
    [user synchronize];
}

- (NSString *)getRecordPlayIP
{
    NSUserDefaults *user = [self getUserDefaults];
    return [user objectForKey:@"recordPlayIP"];
}

-(void)saveAddressIp:(NSString *)addressIp{
    if (addressIp!= nil) {
        NSUserDefaults* user = [self getUserDefaults];
        [user setObject:addressIp forKey:schoolAddressIP];
        [user synchronize];
    }
}
-(NSString*)addressIp{
    NSUserDefaults* user = [self getUserDefaults];
    NSString* addressIP = [user objectForKey:schoolAddressIP];
    return addressIP;
}

-(NSString*)amqpUrl{
    return [NSString stringWithFormat:@"%@%@%@",@"amqp://dfcdfc:dfc_123_dfc@",[[NSUserDefaultsManager shareManager]addressIp],@":5672"];
}

-(NSString*)baseUrl{
    return [NSString stringWithFormat:@"%@%@%@",@"http://",[[NSUserDefaultsManager shareManager]addressIp],@"/v1/"];
}

-(NSString*)uploadUrl{
    return [NSString stringWithFormat:@"%@%@%@",@"http://",[[NSUserDefaultsManager shareManager]addressIp],@"/upload"];
}

// add by hmy
- (BOOL)isLogin {
   return [[NSUserDefaults standardUserDefaults] boolForKey:isLoginKey];
}

- (void)setIsLogin:(BOOL)islogin {
    [[NSUserDefaults standardUserDefaults] setBool:islogin
                                            forKey:isLoginKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// add by hmy
- (BOOL)isOpeningCourseware {
    return [[NSUserDefaults standardUserDefaults] boolForKey:isOpeningCoursewareKey];
}

- (void)setIsOpeningCourseware:(BOOL)isOpeningCourseware {
    [[NSUserDefaults standardUserDefaults] setBool:isOpeningCourseware
                                            forKey:isOpeningCoursewareKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// add by hmy
- (BOOL)isClosingCourseware {
    return [[NSUserDefaults standardUserDefaults] boolForKey:isClosingCoursewareKey];
}

- (void)setisClosingCourseware:(BOOL)isClosingCourseware {
    [[NSUserDefaults standardUserDefaults] setBool:isClosingCourseware
                                            forKey:isClosingCoursewareKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isUseLANForClass {
    return [[NSUserDefaults standardUserDefaults] boolForKey:isUseLANForClassKey];
}

- (void)setIsUseLANForClass:(BOOL)isUseLANForClass {
    [[NSUserDefaults standardUserDefaults] setBool:isUseLANForClass
                                            forKey:isUseLANForClassKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getStudentName {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:personalCache];
    NSDictionary *studentInfo = dic[@"studentInfo"];

    return studentInfo[@"name"];
}

- (void)setStudentIcon:(NSString *)studentIcon {
    [[NSUserDefaults standardUserDefaults] setObject: studentIcon
                                            forKey:studentIconKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)studentIcon {
    return [[NSUserDefaults standardUserDefaults] objectForKey:studentIconKey];
}

- (NSString *)lanClassCode {
    return [[NSUserDefaults standardUserDefaults] objectForKey:lanClassCodeKey];
}
- (void)setLanClassCode:(NSString *)lanClassCode {
    [[NSUserDefaults standardUserDefaults] setObject:lanClassCode
                                              forKey:lanClassCodeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)onClassMessage {
    return [[NSUserDefaults standardUserDefaults] objectForKey:onClassMessageKey];
}

- (void)setOnClassMessage:(NSDictionary *)onClassMessage {
    [[NSUserDefaults standardUserDefaults] setObject:onClassMessage
                                              forKey:onClassMessageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
