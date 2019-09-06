# HFMachoSectionManager
iOS通过将方法指针存入section中，然后在合适的时机取出调用。借此可以实现一些不同模块中的方法统一时机调用，减少模块耦合。建议启动一些初始化方法这样使用，其他的不建议过多使用。

#### 使用方法，直接在类中调用宏即可
```Objective-c
@implementation HFViewA

REGIST_FUNC_SECTION(stagea) {
    NSLog(@"HFViewA REGIST_SECTION");
}

REGIST_ROBJFUNC_SECTION(test, HFViewA) {
    id obj = [HFViewA new];
    NSLog(@"HFViewA pointer %p", obj);
    return obj;
}

@end
```
