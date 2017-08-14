//
//  AMRFileCodecHandler.h
//  Laiwang
//
//  Created by guodi.ggd on 4/10/14.
//  Copyright (c) 2014 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMRFileCodec.h"

@interface AMRFileCodecHandler : NSObject
{
    FILE* _fileEncode;
    struct enc_interface_State* _encodeState;
    int _writeBytes;
}
//added 20140410 guodi.ggd
-(int)PrepareEncode:(const char*)pchAmrFileName;
-(int)EncodeData:(const char*)data dataLen:(int)dataLen;
-(int)EndEncode;

- (int)writeBytes;
@end