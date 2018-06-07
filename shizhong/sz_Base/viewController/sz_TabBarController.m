//
//  sz_TabBarController.m
//  shizhong
//
//  Created by sundaoran on 15/11/23.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_TabBarController.h"

@interface sz_TabBarController ()

@end

@implementation sz_TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - UIViewControllerRotation Methods

/**
 * 根据其当前选中的控制器设置的是否支持方向来控制
 */

- (BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
