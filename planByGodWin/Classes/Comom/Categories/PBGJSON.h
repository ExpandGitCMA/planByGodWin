//
//  PBGJSON.h
//  PBGContainerDemo
//
//  Created by libin on 14/11/19.
//  Copyright (c) 2014年 PBG. All rights reserved.
//

@interface NSArray (PBGJSONSerializing)
- (NSString *)JSONString;
@end

@interface NSDictionary (PBGJSONSerializing)
- (NSString *)JSONString;
@end

@interface NSString (PBGJSONSerializing)
- (id)JSONObject;
@end
