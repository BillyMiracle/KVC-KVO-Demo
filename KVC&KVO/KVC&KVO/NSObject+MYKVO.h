//
//  NSObject+MYKVO.h
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/18.
//

#import <Foundation/Foundation.h>
#import "BillyKVOManager.h"
#import <objc/runtime.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MYKVO)

- (void)billyAddObserver:(NSObject *)observer
               keyPath:(NSString *)keyPath
               options:(BillyKeyValueObservingOptions)options
               context:(nullable void *)context
           handleBlock:(BillyKVOBlock)handleBlock;

- (void)billyRemoveObserver:(NSObject *)observer
                  keyPath:(NSString *)keyPath;


@end

NS_ASSUME_NONNULL_END
