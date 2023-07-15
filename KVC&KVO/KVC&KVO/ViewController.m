//
//  ViewController.m
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/2.
//

#import "ViewController.h"
#import "Student.h"
#import <objc/runtime.h>
#import "SecondViewController.h"
#import "NSObject+MYKVO.h"

@interface ViewController () {
    Person *me;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self dictionaryTest];
    
    me = [[Person alloc] init];
    // setter
//    me.name = @"Billy";
//    NSLog(@"%@", me.name);
    // KVC
//    [me setValue:@"BILLY" forKey:@"name"];
//    [me billy_setValue:@"Billy" forKey:@"name"];
//    [me billy_valueForKey:@"name"];
//    NSLog(@"%@", [me valueForKey:@"name"]);
//    NSLog(@"%@", [[me valueForKey:@"name"] class]);
//    [me showVariables];
//    [self printClasses:[me class]];
//    [me addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
//    [self printClasses:[me class]];
//    [me addObserver:self forKeyPath:@"memberVariable" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self printClassAllMethod:objc_getClass("NSKVONotifying_Person")];
//    [self printClassAllMethod:objc_getClass("Person")];
//    [self printClassAllMethod:objc_getClass("Student")];
//    [me removeObserver:self forKeyPath:@"name" context:nil];
//    me.name = @"Billy";
    
    
//    [me addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    
    
//    [me addObserver:self forKeyPath:@"dataArray" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [me billyAddObserver:self keyPath:@"name" options:BillyKeyValueObservingOptionNew context:nil handleBlock:^(id  _Nonnull observer, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@ %@", oldValue, newValue);
    }];
    
}
- (void)viewDidAppear:(BOOL)animated {
//    SecondViewController *sec = [[SecondViewController alloc] init];
//    [self presentViewController:sec animated:YES completion:nil];
}

- (void)dictionaryTest {
    NSDictionary* dict = @{@"name":@"Cooci",
                           @"nick":@"KC",
                           @"subject":@"iOS",
                           @"age":@18,
                           @"height":@180};
    Student *peter = [[Student alloc] init];
    // 字典转模型
    [peter setValuesForKeysWithDictionary:dict];
    NSLog(@"%@", peter);
    // 键数组转模型到字典
    NSArray *array = @[@"name",@"age"];
    NSDictionary *dic = [peter dictionaryWithValuesForKeys:array];
    NSLog(@"%@",dic);
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"name"]) {
//        NSLog(@"%@", change);
//    } else if ([keyPath isEqualToString:@"dataArray"]) {
//        NSLog(@"%@", change);
//    }
    NSLog(@"%@", change);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    me.currentData += 10;
//    me.totalData += 1;
//    [[me mutableArrayValueForKey:@"dataArray"] addObject:@"1"];
//    [me.dataArray addObject:@"1"];
    me.name = @"Billy";
//    me->memberVariable = @"Billy Member";
//    [self printClasses:[Person class]];

}

#pragma mark - 遍历类以及子类
- (void)printClasses:(Class)cls {
    int count = objc_getClassList(NULL, 0);
    NSMutableArray *array = [NSMutableArray arrayWithObject:cls];
    Class* classes = (Class*)malloc(sizeof(Class)*count);
    objc_getClassList(classes, count);
    for (int i = 0; i < count; i++) {
        if (cls == class_getSuperclass(classes[i])) {
            [array addObject:classes[i]];
        }
    }
    free(classes);
    NSLog(@"%@'s classes = %@", cls, array);
}

#pragma mark - 遍历方法-ivar-property
- (void)printClassAllMethod:(Class)cls {
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i<count; i++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        IMP imp = class_getMethodImplementation(cls, sel);
        NSLog(@"%@ - %p", NSStringFromSelector(sel), imp);
    }
    free(methodList);
}





@end
