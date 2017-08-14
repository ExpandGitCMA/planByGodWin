//
//  AMRFileCodecHandler.m
//  Laiwang
//
//  Created by guodi.ggd on 4/10/14.
//  Copyright (c) 2014 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import "AMRFileCodecHandler.h"

#define _GSMAMR_ENC_H_
#define mode_h
#import "interf_enc.h"
#include "sp_dec.h"
#include "mode.h"
#include <stdio.h>
#include <strings.h>

@implementation AMRFileCodecHandler

- (id)init
{
    if (self = [super init]) {
        [self resetData];
    }
    return self;
}


- (void)resetData
{
    _fileEncode = NULL;
    _encodeState = NULL;
    _writeBytes = 0;
}


- (int)writeBytes
{
    return _writeBytes;
}


-(int)PrepareEncode:(const char*)pchAmrFileName
{
    _fileEncode = fopen(pchAmrFileName, "wb");
    if( _fileEncode ==  NULL )
    {
        return -1;
    }
    
    _encodeState = Encoder_Interface_init(0);
    _writeBytes = fwrite(AMR_MAGIC_NUMBER, sizeof(char), strlen(AMR_MAGIC_NUMBER), _fileEncode);
    
    return 0;
}


-(int)EncodeData:(const char*)data dataLen:(int)dataLen
{
    int encodeLen = 0;
    if(data != NULL && dataLen > 0)
    {
        enum Mode req_mode = MR67;
        UWord8 serial_data[32];
        Word16 speech[PCM_FRAME_SIZE];
        
        // 大于等于一帧数据
        if( dataLen >= PCM_FRAME_SIZE*2 )
        {
            int dataLen2 = dataLen;
            char* data2 = (char*)data;
            while (dataLen2 >= PCM_FRAME_SIZE*2)  // 小于一帧的情况，需要再次调用本函数
            {
                memcpy(speech, data2, PCM_FRAME_SIZE*2);//PCM_FRAME_SIZE*sizeof(Word16)
                int byte_counter = Encoder_Interface_Encode(_encodeState, req_mode, speech, serial_data, 0);
                
                encodeLen += PCM_FRAME_SIZE*2;
                _writeBytes += byte_counter;
                fwrite(serial_data, sizeof (UWord8), byte_counter, _fileEncode );
                fflush(_fileEncode);
                
                dataLen2 -= PCM_FRAME_SIZE*2;
                data2 += PCM_FRAME_SIZE*2;
            }
        }
        else // 小于一帧数据
        {
            memcpy(speech, data, dataLen);
            int byte_counter = Encoder_Interface_Encode(_encodeState, req_mode, speech, serial_data, 0);
            
            encodeLen = dataLen;
            _writeBytes += byte_counter;
            fwrite(serial_data, sizeof (UWord8), byte_counter, _fileEncode );
            fflush(_fileEncode);
        }
    }
    
    return encodeLen;
}


-(int)EndEncode
{
    if( _encodeState == NULL )
    {
        return -1;
    }
    
    Encoder_Interface_exit(_encodeState);
    if( _fileEncode != NULL )
    {
        fclose(_fileEncode);
        _fileEncode = NULL;
    }
    
    _fileEncode = NULL;
    _encodeState = NULL;
    _writeBytes = 0;
    
    return 0;
}


- (void)dealloc
{
    if(_encodeState) {
        Encoder_Interface_exit(_encodeState);
    }
    if( _fileEncode != NULL )
    {
        fclose(_fileEncode);
        _fileEncode = NULL;
    }
    
    _fileEncode = NULL;
    _encodeState = NULL;
    _writeBytes = 0;
}
@end