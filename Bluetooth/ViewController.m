//
//  ViewController.m
//  Bluetooth
//
//  Created by apple on 16/9/1.
//  Copyright © 2016年 Liancheng. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<GKPeerPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/**
 *  蓝牙连接回话，主要用于发送和接受传输数据
 */
@property (strong, nonatomic) GKSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark ------------- GameKit.framework

- (IBAction)searchDevice:(id)sender {
    GKPeerPickerController *peerPickerController = [[GKPeerPickerController alloc]init];
    peerPickerController.delegate = self;
    [peerPickerController show];
}

- (IBAction)clickSend:(id)sender {
    NSData * data = UIImagePNGRepresentation(self.imageView.image);
    NSError * error = nil;
    [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
    if (error) {
        NSLog(@"发送过程中出现错误，错误信息:%@",error.localizedDescription);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - GKPeerPickerController代理方法
/**
 *  当对方接受蓝牙连接请求后调用此方法
 *
 *  @param picker  蓝牙点对点连接控制器
 *  @param peerID  连接设备蓝牙传输ID
 *  @param session 连接会话
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
    self.session = session;
    NSLog(@"已经连接客户端设备：%@",peerID);
    //设置数据接收处理句柄，相当于代理，一旦数据接收完成后调用 -receiveData:fromPeer:inSession:context:方法处理数据
    [self.session setDataReceiveHandler:self withContext:nil];
    //一旦连接成功关闭窗口
    [picker dismiss];
}

#pragma mark - 蓝牙数据接收方法
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context{
    UIImage *image=[UIImage imageWithData:data];
    self.imageView.image=image;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextinfo:), nil);
    NSLog(@"数据发送成功！");
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextinfo:(void*)contextinfo
{
    if (error) {
        NSLog(@"保存图片失败，原因：%@",error.localizedDescription);
    }else
    {
        NSLog(@"保存图片成功");
    }
}

#pragma mark - UIImagePickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
