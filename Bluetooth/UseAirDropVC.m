//
//  UseAirDropVC.m
//  Bluetooth
//
//  Created by apple on 16/9/8.
//  Copyright © 2016年 Liancheng. All rights reserved.
//

#import "UseAirDropVC.h"

@interface UseAirDropVC ()

@end

@implementation UseAirDropVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL * url = [NSURL URLWithString:@"https://www.baidu.com"];
    UIImage * image = [UIImage imageNamed:@"1"];
    NSArray * arr = @[image];
    UIActivityViewController * activityVC = [[UIActivityViewController alloc]initWithActivityItems:arr applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
//    activityVC.excludedActivityTypes = excludedActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
    // Do any additional setup after loading the view.
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
