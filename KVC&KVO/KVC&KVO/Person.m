//
//  Person.m
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/3.
//

#import "Person.h"

@interface Person()

@property (nonatomic, strong) NSString *privateName;

@end

@implementation Person

@dynamic name;

- (void)setName:(NSString *)name {
    _privateName = [name copy];
}

//- (void)_setName:(NSString *)name {
//    _privateName = [name copy];
//}

//- (void)setIsName:(NSString *)name {
//    _privateName = [name copy];
//}

+ (BOOL)accessInstanceVariablesDirectly {
    // + (BOOL)accessInstanceVariables直接返回YES，如果键值编码方法的默认实现在找不到属性的访问器方法时应直接访问相应的实例变量。如果不应该，则返回NO。NSObject此方法的实现返回YES。子类可以重写它以返回NO，在这种情况下，其他方法将不会访问实例变量。
    return YES;
}

- (void)showVariables {
    NSLog(@"name: %@", self->name);
    NSLog(@"_name: %@", self->_name);
    NSLog(@"isName: %@", self->isName);
    NSLog(@"_isName: %@", self->_isName);
}

- (instancetype)init {
    self = [super init];
//    self->name = 9;
//    self->_name = @"_name";
//    self->_isName = @9;
//    self->isName = @"isName";
    _currentData = 0;
    _progress = 0;
    _totalData = 0;
    _dataArray = [[NSMutableArray alloc] init];
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"setValue:forUndefinedKey:");
}

//- (NSString *)getName {
//    NSLog(@"getName");
//    return nil;
//}

- (NSString *)name {
//    NSLog(@"name");
    return self.privateName;
}

//- (NSString *)isName {
//    NSLog(@"isName");
//    return nil;
//}

//- (NSString *)_name {
//    NSLog(@"_name");
//    return nil;
//}

- (int)countOfName {
    return 3;
}

//- (id)objectInNameAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"name%ld", index];
//}
//
//- (NSArray *)nameAtIndexes:(NSIndexSet *)indexes {
//    NSArray *array = @[@"name1", @"name2", @"name3"];
//    return [array objectsAtIndexes:indexes];
//}

//- (NSEnumerator *)enumeratorOfName {
//    NSSet *set = [[NSSet alloc] initWithArray:@[@"name1", @"name2", @"name3"]];
//    return set.objectEnumerator;
//}
//
//- (id)memberOfName:(NSString *)name {
//    NSSet *set = [[NSSet alloc] initWithArray:@[@"name1", @"name2", @"name3"]];
//    return [set member:name];
//}

//+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
//    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
//    if ([key isEqualToString:@"progress"]) {
//        NSArray *affectingKeys = @[@"totalData", @"currentData"];
//        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
//    }
//    return keyPaths;
//}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingProgress {
    return [NSSet setWithObjects:@"totalData", @"currentData", nil];
}

- (float)progress {
    return _currentData / _totalData;
}



@end
