//
//  BillyKVCManager.m
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/18.
//

#import "BillyKVOManager.h"

@implementation BillyKVOManager

-(instancetype)initWithObserver:(NSObject *)observer
                        keyPath:(NSString *)keyPath
                        options:(BillyKeyValueObservingOptions)options
                    handleBlock:(BillyKVOBlock)handleBlock{
    self = [super init];
    if (self) {
        self.observer = observer;
        self.keyPath = keyPath;
        self.options = options;
        self.handleBlock = handleBlock;
    }
    return self;
}

@end
