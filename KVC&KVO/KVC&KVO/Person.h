//
//  Person.h
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/3.
//

#import <Foundation/Foundation.h>
#import "NSObject+MYKVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject {
    NSString *_name;
    NSString *_isName;
    NSString *name;
    NSString *isName;
    @public
    NSString *memberVariable;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int age;

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float totalData;
@property (nonatomic, assign) float currentData;

@property (nonatomic, strong) NSMutableArray *dataArray;

- (void)showVariables;

//@property (nonatomic, strong) NSString *_name;
//@property (nonatomic, strong) NSString *_isName;
//@property (nonatomic, strong) NSString *isName;

@end

NS_ASSUME_NONNULL_END
