//
//  sz_imagePickerViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/21.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_imagePickerViewController.h"

@interface sz_imagePickerViewController ()

@end

@implementation sz_imagePickerViewController
{
    likes_NavigationView *_sz_nav;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"相册" andLeftImage:[UIImage imageNamed:@"sz_camera_cancel"] andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
