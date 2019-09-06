//
//  HFMachOSectionManager.h
//
//  Created by hui hong on 2019/9/5.
//  Copyright © 2019 hfighter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    char *keyValue;
    void* func;
}HFFuncDataInfo;

// __DATA section中注册方法实现
#define REGIST_FUNC_SECTION REGISTFUNCSECT
// __DATA section中注册返回对象的方法
#define REGIST_ROBJFUNC_SECTION REGISTROBJFUNCSECT

#define REGISTFUNCSECT(key) \
static void key(void); \
MARKSECTION(__hf_funcsection) \
static const HFFuncDataInfo __##key = {(char *)(&#key), (void*)(&key)}; \
static void key(void)

#define REGISTROBJFUNCSECT(key, type) \
static type* key##type(void); \
MARKSECTION(__hf_funcsection) \
static const HFFuncDataInfo __##key##type##info = {(char *)(&#key), (void*)(&(key##type))}; \
static type* key##type(void)


// sectname: __hf_funcsection最多只能有一个_连接其他字符串(比如：__hf_func_section不合法)
#define MARKSECTION(sectname) __attribute__((used, section("__DATA," #sectname)))

@interface HFMachOSectionManager : NSObject

+ (instancetype)sharedInstance;
// 通过key，执行所有key的func，func无返回值
- (void)execFuncArrayOfKey:(NSString *)key;
// 通过key，执行所有key的func，func有返回值，返回oc对象
- (NSArray *)execFuncReturnArrayOfKey:(NSString *)key;

@end
