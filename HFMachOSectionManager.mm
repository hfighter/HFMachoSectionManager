//
//  HFMachOSectionManager.mm
//
//  Created by hui hong on 2019/9/5.
//  Copyright © 2019 hfighter. All rights reserved.
//

#import "HFMachOSectionManager.h"
#import <mach-o/loader.h>
#import <mach-o/getsect.h>
#import <dlfcn.h>

static char *const HFFuncSectionName = (char *)"__hf_funcsection";

#ifndef __LP64__
typedef struct mach_header headerType;
#else
typedef struct mach_header_64 headerType;
#endif

static headerType* machHeader = NULL;

template <typename T>
T* getDataSection(const headerType *mhdr, const char *sectname,
                  size_t *outBytes, size_t *outCount)
{
    unsigned long byteCount = 0;
    T* data = (T*)getsectiondata(mhdr, "__DATA", sectname, &byteCount);
    if (data == NULL) {
        return NULL;
    }
    if (outBytes) *outBytes = byteCount;
    if (outCount) *outCount = byteCount / sizeof(T);
    return data;
}

headerType* getHeaderType() {
    if (machHeader) {
        return machHeader;
    }
    dl_info info;
    dladdr("", &info);
    machHeader = (headerType *)info.dli_fbase;
    return machHeader;
}

@interface HFMachOSectionManager()
{
    HFFuncDataInfo *funcs;
    size_t outCount;
}

@end

@implementation HFMachOSectionManager

+ (instancetype)sharedInstance {
    static HFMachOSectionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [HFMachOSectionManager new];
        manager->funcs = getDataSection<HFFuncDataInfo>(getHeaderType(), HFFuncSectionName, nil, &manager->outCount);
    });
    return manager;
}

- (void)execFuncArrayOfKey:(NSString *)key {
    if (self->funcs == NULL) {
        return;
    }
    size_t outcount = self->outCount;
    const char *keystr = key.UTF8String;
    for (NSInteger i = 0; i < outcount; i ++) {
        HFFuncDataInfo info = funcs[i];
        if (strcmp(keystr, info.keyValue) == 0) {
            ((void(*)(void))info.func)();
        }
    }
}

- (NSArray *)execFuncReturnArrayOfKey:(NSString *)key {
    if (self->funcs == NULL) {
        return @[];
    }
    size_t outcount = self->outCount;
    const char *keystr = key.UTF8String;
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < outcount; i ++) {
        HFFuncDataInfo info = self->funcs[i];
        if (strcmp(keystr, info.keyValue) == 0) {
            id obj = (__bridge id)((void*(*)(void))info.func)();
            if (obj) {
                [array addObject:obj];
            }
        }
    }
    return array;
}

@end
