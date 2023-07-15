//
//  BillyKVCManager.h
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/18.
//

#import <Foundation/Foundation.h>
//#import "NSObject+MYKVO.h"

NS_ASSUME_NONNULL_BEGIN
//定义KeyValueObservingOptions枚举
typedef NS_OPTIONS(NSUInteger, BillyKeyValueObservingOptions) {
    BillyKeyValueObservingOptionNew = 0x01,
    BillyKeyValueObservingOptionOld = 0x02,
};

typedef void(^BillyKVOBlock)(id observer, NSString *keyPath, id oldValue, id newValue);

@interface BillyKVOManager : NSObject
/// 保存监听的observer
@property (nonatomic, weak) NSObject *observer;
/// 保存keyPath
@property (nonatomic, copy) NSString *keyPath;
/// 保存SafeKeyValueObservingOptions
@property (nonatomic, assign) BillyKeyValueObservingOptions options;
/// kvo监听属性变化后的回调block
@property (nonatomic, copy) BillyKVOBlock handleBlock;

/// 初始化KVO数据
/// @param observer observer
/// @param keyPath keyPath
/// @param options options
-(instancetype)initWithObserver:(NSObject *)observer
                        keyPath:(NSString *)keyPath
                        options:(BillyKeyValueObservingOptions)options
                    handleBlock:(BillyKVOBlock)handleBlock;

@end

NS_ASSUME_NONNULL_END
