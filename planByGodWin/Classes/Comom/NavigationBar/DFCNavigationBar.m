//
//  DFCNavigationBar.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/13.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCNavigationBar.h"
#import "DFCButtonStyle.h"
#import "IMColor.h"
#import "DFCColorDef_pch.h"
#import "DFCButton.h"
#import "NSUserDefaultsManager.h"

@implementation UINavigationController(DFCNavigationBar)

-(void)setNavigationBarStyle{
    self.navigationBar.tintColor = [UIColor colorWithHex:@"#333333" alpha:1.0];
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 0, 60, 30);
    [bar setImage:[UIImage imageNamed:@"register_back"] forState:UIControlStateNormal];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
}

-(void)setNavigationleftBarClose{
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 0, 60, 30);
    [bar setImage:[UIImage imageNamed:@"close_inClass"] forState:UIControlStateNormal];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:self action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
}

-(void)setNavigationleftBarClose:(id)target action:(SEL)action{
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 10, 60, 30);
    [bar setImage:[UIImage imageNamed:@"close_inClass"] forState:UIControlStateNormal];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
}


-(void)setNavigationBackBarStyle:(id)target action:(SEL)action{
//    
//     DFCButton *bar= [DFCButton buttonWithType:UIButtonTypeCustom];
//    [bar setKey:SubkeyEdgeInsets];
    
    //UIImage *img = [UIImage imageNamed:@"register_back"];
//    _inJoin.frame = CGRectMake(0, 0, _tableView.frame.size.width, img.size.height);
//    [_inJoin setImage: img forState:UIControlStateNormal];
//    [_inJoin setTitle:@"添加班级"  forState:UIControlStateNormal];
//    [_inJoin addTarget:self action:@selector(joinClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *bar= [UIButton buttonWithType:UIButtonTypeCustom];

    bar.frame = CGRectMake(0, 10, 60, 30);
   // bar.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    [bar setImage:[UIImage imageNamed:@"register_back"] forState:UIControlStateNormal];
 
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
}


@end


@implementation DFCNavigationBarItem

+ (NSArray *)setNavigationMessgeBarStyle:(id)target action:(SEL)action{
    NSDictionary *teacherInfo = [[NSUserDefaultsManager shareManager]getTeacherInfoCache][@"teacherEntity"];
    NSString *url = [[teacherInfo objectForKey:@"imgUrl"] substringFromIndex:1];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@",BASE_API_URL,url];
    DEBUG_NSLog(@"imgUrl=%@",imgUrl);
    
//    NSURL * url = [NSURL URLWithString:urlStr];
//    // 根据图片的url下载图片数据
//    dispatch_queue_t xrQueue = dispatch_queue_create("loadImage", NULL); // 创建GCD线程队列
//    dispatch_async(xrQueue, ^{
//        // 异步下载图片
//        UIImage * img = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
//        // 主线程刷新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setImage:img forState:UIControlStateNormal];
//        });
//    });
    
    DFCButton *userImage = [DFCButton buttonWithType:UIButtonTypeCustom];
    userImage.Key = SubkeyUserImage;
    userImage.frame = CGRectMake(0, 0, 30, 30);
    [userImage setButtonImagelayer];
    [userImage setImage:[UIImage imageNamed:@"courseware_default"] forState:UIControlStateNormal];
    [userImage  addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *emptyItem = [[UIBarButtonItem alloc] initWithCustomView:userImage];
    
    DFCButton * userName = [DFCButton buttonWithType:UIButtonTypeCustom];
    userName. Key = SubkeyUserName ;
    userName.frame = CGRectMake(0, 0, 60, 30);
    [userName setTitle:[teacherInfo objectForKey:@"name"]  forState:UIControlStateNormal];
    UIBarButtonItem *backItem =  [[UIBarButtonItem alloc] initWithCustomView:userName];
    return @[backItem,emptyItem];
}




+(UIBarButtonItem*)setNavigationBackBarStyle:(id)target action:(SEL)action{
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 10, 80, 30);
    bar.titleLabel.font = [UIFont systemFontOfSize:16];
     bar.showsTouchWhenHighlighted = YES;
     bar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
     bar.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
     bar.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
     bar.imageView.contentMode = UIViewContentModeCenter;
     bar.imageView.clipsToBounds = NO;
    [bar setImage:[UIImage imageNamed:@"register_back"] forState:UIControlStateNormal];
    [bar setTitle:@"主页"  forState:UIControlStateNormal];
    [bar setBackgroundColor:[UIColor clearColor]];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *backItem =  [[UIBarButtonItem alloc] initWithCustomView:bar];
    return backItem;
}
@end
