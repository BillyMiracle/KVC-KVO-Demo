//
//  SecondViewController.m
//  KVC&KVO
//
//  Created by 张博添 on 2022/7/18.
//

#import "SecondViewController.h"
#import "NSObject+MYKVO.h"
#import "Person.h"

@interface SecondViewController ()  {
    Person *me;
}

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    // Do any additional setup after loading the view.
    me = [[Person alloc] init];
//    [me addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
//    me

}

- (void)dealloc {
    [me removeObserver:self forKeyPath:@"name"];
}


@end
