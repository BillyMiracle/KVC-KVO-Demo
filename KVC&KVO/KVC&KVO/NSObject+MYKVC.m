//
//  NSObject+MYKVC.m
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/15.
//

#import "NSObject+MYKVC.h"
#import <objc/runtime.h>

@implementation NSObject (MYKVC)

- (void)billy_setValue:(id)value forKey:(NSString *)key {
    //1、判断key 是否存在
    if (key == nil || key.length == 0) return;
        
    //2、找setter方法，顺序是：setXXX、_setXXX、 setIsXXX
    // key 首字母要大写 Key
    NSString *Key = key.capitalizedString;
    // key 要大写
    NSString *setKey = [NSString stringWithFormat:@"set%@:", Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:", Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:", Key];
        
    if ([self billy_performSelectorWithMethodName:setKey value:value]) {
        NSLog(@"My KVC goes: %@", setKey);
        return;
    } else if ([self billy_performSelectorWithMethodName:_setKey value:value]){
        NSLog(@"My KVC goes: %@", _setKey);
        return;
    } else if ([self billy_performSelectorWithMethodName:setIsKey value:value]){
        NSLog(@"My KVC goes: %@", setIsKey);
        return;
    }
        
        
    //3、判断是否响应`accessInstanceVariablesDirectly`方法，即间接访问实例变量，返回YES，继续下一步设值，如果是NO，则崩溃
    if (![self.class accessInstanceVariablesDirectly]) {
        @throw [NSException exceptionWithName:@"BillyUnKnownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }
        
    //4、间接访问变量赋值，顺序为：_key、_isKey、key、isKey
    // 4.1 定义一个收集实例变量的可变数组
    NSMutableArray *mArray = [self getIvarListName];
    // _<key> _is<Key> <key> is<Key>
    NSString *_key = [NSString stringWithFormat:@"_%@", key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@", key];
    NSString *isKey = [NSString stringWithFormat:@"is%@", key];
    if ([mArray containsObject:_key]) {
        // 4.2 获取相应的 ivar
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        // 4.3 对相应的 ivar 设置值
        object_setIvar(self, ivar, value);
        return;
    } else if ([mArray containsObject:_isKey]) {
        
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        object_setIvar(self, ivar, value);
        return;
    } else if ([mArray containsObject:key]) {
        
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        object_setIvar(self, ivar, value);
        return;
    } else if ([mArray containsObject:isKey]) {
        
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        object_setIvar(self, ivar, value);
        return;
    }
        
    //5、如果找不到则抛出异常
    @throw [NSException exceptionWithName:@"BillyUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ %@]: this class is not key value coding-compliant for the key name.****",self,NSStringFromSelector(_cmd)] userInfo:nil];
}

- (BOOL)billy_performSelectorWithMethodName:(NSString *)name value:(nullable id)value {
    SEL selecter = NSSelectorFromString(name);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:selecter]) {
        [self performSelector:selecter withObject:value];
        return YES;
    } else {
        return NO;
    }
#pragma clang diagnostic pop
}

- (NSMutableArray *)getIvarListName {
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        //获取实例变量名
        const char*cName = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:cName];
        [array addObject:ivarName];
    }
    return array;
}

//取值
- (nullable id)billy_valueForKey:(NSString *)key {
    
//    1、判断非空
    if (key == nil || key.length == 0) {
        return nil;
    }
    
//    2、找到相关方法：get<Key> <key> countOf<Key>  objectIn<Key>AtIndex
    // key 首字母要大写 Key
    NSString *Key = key.capitalizedString;
    // 拼接方法
    NSString *getKey = [NSString stringWithFormat:@"get%@",Key];
    NSString *countOfKey = [NSString stringWithFormat:@"countOf%@",Key];
    NSString *objectInKeyAtIndex = [NSString stringWithFormat:@"objectIn%@AtIndex:",Key];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(getKey)]) {
        return [self performSelector:NSSelectorFromString(getKey)];
    } else if ([self respondsToSelector:NSSelectorFromString(key)]) {
        return [self performSelector:NSSelectorFromString(key)];
    }
    //集合类型
    else if ([self respondsToSelector:NSSelectorFromString(countOfKey)]) {
        if ([self respondsToSelector:NSSelectorFromString(objectInKeyAtIndex)]) {
            int num = (NSInteger)[self performSelector:NSSelectorFromString(countOfKey)];
            NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
            for (int i = 0; i < num - 1; i++) {
                num = (NSInteger)[self performSelector:NSSelectorFromString(countOfKey)];
            }
            for (int j = 0; j<num; j++) {
                id objc = [self performSelector:NSSelectorFromString(objectInKeyAtIndex) withObject:@(num)];
                [mArray addObject:objc];
            }
            return mArray;
        }
    }

#pragma clang diagnostic pop
    
//    3、判断是否响应`accessInstanceVariablesDirectly`方法，即间接访问实例变量，返回YES，继续下一步设值，如果是NO，则崩溃
    if (![self.class accessInstanceVariablesDirectly]) {
        @throw [NSException exceptionWithName:@"CJLUnKnownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }
    
//    4.找相关实例变量进行赋值，顺序为：_<key>、 _is<Key>、 <key>、 is<Key>
    // 4.1 定义一个收集实例变量的可变数组
    NSMutableArray *mArray = [self getIvarListName];
    // 例如：_name -> _isName -> name -> isName
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    if ([mArray containsObject:_key]) {
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        return object_getIvar(self, ivar);;
    } else if ([mArray containsObject:_isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        return object_getIvar(self, ivar);;
    } else if ([mArray containsObject:key]) {
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        return object_getIvar(self, ivar);;
    } else if ([mArray containsObject:isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        return object_getIvar(self, ivar);;
    }

    return NULL;
}
@end
