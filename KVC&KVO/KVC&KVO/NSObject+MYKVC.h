//
//  NSObject+MYKVC.h
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MYKVC)

- (void)billy_setValue:(nullable id)value forKey:(NSString *)key;
- (nullable id)billy_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
