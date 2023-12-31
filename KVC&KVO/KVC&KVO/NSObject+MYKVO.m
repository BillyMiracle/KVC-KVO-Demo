//
//  NSObject+MYKVO.m
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/18.
//

#import "NSObject+MYKVO.h"
//#import "BillyKVOManager.h"

static NSString *const billyKVOPrefix = @"BillyKVONotifying_";
static NSString *const billyInfoArray = @"BillyInfoArray";

@implementation NSObject (SafeKVO)

//+(void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        //将dealloc方法交换，安全移除KVO
//        [self safeHookOriginInstanceMethod:NSSelectorFromString(@"dealloc") newInstanceMethod:@selector(safeDealloc)];
//    });
//}
+ (BOOL)billyHookOriginInstanceMethod:(SEL)originSel newInstanceMethod:(SEL)newSel {
    Class cls = self;
    Method oldMethod = class_getInstanceMethod(cls, originSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    if (!newMethod) {//新的方法不存在
        return NO;
    }
    if (!oldMethod) {//老的方法不存在则添加
        class_addMethod(cls, originSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
        method_setImplementation(newMethod, imp_implementationWithBlock(^(id self, SEL _cmd) {
            NSLog(@"被交换的方法不存在");
        }));
    }
    BOOL didAddMethod = class_addMethod(cls, originSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {//已经添加
        class_replaceMethod(cls, newSel, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
    return YES;
}
- (void)billyAddObserver:(NSObject *)observer
               keyPath:(NSString *)keyPath
               options:(BillyKeyValueObservingOptions)options
               context:(nullable void *)context
           handleBlock:(BillyKVOBlock)handleBlock {
    [self judgeSetterMethodFromeKeyPath:keyPath];
    //获得派生类
    Class newClass = [self billyKVONotifingObservingKVOWithKeyPath:keyPath];
    //修改isa指针指向派生类
    object_setClass(self, newClass);
    //保存信息
    BillyKVOManager *info = [[BillyKVOManager alloc] initWithObserver:observer keyPath:keyPath options:options handleBlock:handleBlock];
    NSMutableArray *infoArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(billyInfoArray));
    if (!infoArray) {
        infoArray = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(billyInfoArray), infoArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [infoArray addObject:info];
}
- (void)billyRemoveObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    NSMutableArray *infoArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(billyInfoArray));
    if (infoArray.count <= 0) {
        return;
    }
    for (BillyKVOManager *info in infoArray) {
        if ([info.keyPath isEqualToString:keyPath]) {
            [infoArray removeObject:info];
            //清空数组
            objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(billyInfoArray), infoArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    if (infoArray.count == 0) {
        //isa重新指向父类
        Class superClass = [self class];
        object_setClass(self, superClass);
    }
}
//动态生成KVO的派生类NSObservingKVO
- (Class)billyKVONotifingObservingKVOWithKeyPath:(NSString *)keyPath {
    NSString *oldClassName = NSStringFromClass(object_getClass(self));
    //kSafeKVOPrefix = @"SafeKVONotifying_"
    NSString *newClassName = [NSString stringWithFormat:@"%@%@", billyKVOPrefix, oldClassName];
    Class newClass = NSClassFromString(newClassName);
    if (newClass) {//防止重复创建
        return newClass;
    }
    //不存在则创建
    //申请class
    newClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    //注册类
    objc_registerClassPair(newClass);
    //添加class
    SEL classSel = NSSelectorFromString(@"class");
    Method classMethod = class_getInstanceMethod([self class], classSel);
    const char *classType = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, classSel, (IMP)billy_class, classType);
    //添加重写的setter
    SEL setterSel = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod([self class], setterSel);
    const char *setterType = method_getTypeEncoding(setterMethod);
    class_addMethod(newClass, setterSel, (IMP)billy_setter, setterType);
    
    //派生类dealloc，主要是为了不移除KVO监听时自动处理的
    SEL dealSel = NSSelectorFromString(@"dealloc");
    Method dealMethod = class_getInstanceMethod([self class], dealSel);
    const char *dealType = method_getTypeEncoding(dealMethod);
    class_addMethod(newClass, dealSel, (IMP)billy_dealloc, dealType);
    return newClass;
}
#pragma mark - 验证setter方法是否存在
- (void)judgeSetterMethodFromeKeyPath:(NSString *)keyPath {
    Class superClass = object_getClass(self);
    //根据keyPath获得setter方法
    SEL setterSelector = NSSelectorFromString(setterForGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(superClass, setterSelector);
    if (!setterMethod) {//不存在则抛出异常
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"没有找到当前%@的setter方法",keyPath] userInfo:nil];
    }
}

#pragma mark - 移除KVO
- (void)billyDealloc {
    //获得父类
    Class superClass = [self class];
    //isa指针重新指向父类
    object_setClass(self, superClass);
    //执行dealloc
    [self billyDealloc];
}
#pragma mark - kvoDealloc
static void billy_dealloc(id self, SEL _cmd) {
    NSLog(@"派生类移除了");
    //获得父类
    Class superClass = [self class];
    //isa指针重新指向父类
    object_setClass(self, superClass);
    
}
#pragma mark - setter
static void billy_setter(id self, SEL _cmd, id newValue) {
    NSString *keyPath = getterForSetter(NSStringFromSelector(_cmd));
    //获得原来的值
    id oldValue = [self valueForKey:keyPath];
    //消息转发，转发给父类处理(setKeyPath:)
    void (*billy_msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
    struct objc_super superStruct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self)),
    };
    billy_msgSendSuper(&superStruct, _cmd, newValue);
    //获得信息数据
    NSMutableArray *infoArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(billyInfoArray));
    for (BillyKVOManager *info in infoArray) {
        if ([info.keyPath isEqualToString:keyPath]) {
            if (info.handleBlock) {//有block回调
                info.handleBlock(info.observer, info.keyPath, oldValue, newValue);
            }
            //实现observeValueForKeyPath：可监听值的变化
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary<NSKeyValueChangeKey,id> *change = [NSMutableDictionary dictionaryWithCapacity:1];
                // 对新旧值进行处理
                if (info.options & BillyKeyValueObservingOptionNew) {
                    [change setObject:newValue forKey:NSKeyValueChangeNewKey];
                }
                if (info.options & BillyKeyValueObservingOptionOld) {
                    [change setObject:@"" forKey:NSKeyValueChangeOldKey];
                    if (oldValue) {
                        [change setObject:oldValue forKey:NSKeyValueChangeOldKey];
                    }
                }
                //消息发送给观察者
                // (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
                SEL observerSEL = @selector(observeValueForKeyPath:ofObject:change:context:);
//                objc_msgSend(id _Nullable self, SEL _Nonnull op, ...)
                void (*billy_msgSend)(id, SEL, NSString *, id, NSDictionary<NSKeyValueChangeKey, id> *, void *) = (void *)objc_msgSend;
                billy_msgSend(info.observer, observerSEL, keyPath, self, change, NULL);
            });
        }
    }
}

#pragma mark - 获得父类，主要是派生类的父类
static Class billy_class(id self, SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}
#pragma mark - 从get方法获取set方法的名称 key ===>>> setKey:
static NSString *setterForGetter(NSString *getter){
    
    if (getter.length <= 0) {
        return nil;
    }
    NSString *firstString = [[getter substringToIndex:1] uppercaseString];
    NSString *leaveString = [getter substringFromIndex:1];
    
    return [NSString stringWithFormat:@"set%@%@:", firstString, leaveString];
}

#pragma mark - 从set方法获取getter方法的名称 set<Key>:===> key
static NSString *getterForSetter(NSString *setter){
    
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) { return nil;}
    
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    return  [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
}
@end
