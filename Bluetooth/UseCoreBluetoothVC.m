//
//  UseCoreBluetoothVC.m
//  Bluetooth
//
//  Created by apple on 16/9/1.
//  Copyright © 2016年 Liancheng. All rights reserved.
//

#import "UseCoreBluetoothVC.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface UseCoreBluetoothVC ()<CBPeripheralManagerDelegate>

NS_ASSUME_NONNULL_BEGIN
/**
 *  外围设备管理器
 */
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
/**
 *  订阅此外围设备的中心设备
 */
@property (strong, nonatomic) NSMutableArray * centralDevicesOfOrderPeripheralManager;
/**
 *  外围设备特征
 */
@property (strong, nonatomic) CBMutableCharacteristic *characteristicM;
/**
 *  日志记录
 */
@property (weak, nonatomic) IBOutlet UITextView *log;
NS_ASSUME_NONNULL_END

@end

@implementation UseCoreBluetoothVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"外围设备";
    NSLog(@"%@",[self uuid]);
    // Do any additional setup after loading the view.
}

#pragma mark - 外围设备

/**
 *  创建外围设备
 *
 *  1. 创建外围设备CBPeripheralManager对象并指定代理。
 *   2. 创建特征CBCharacteristic、服务CBSerivce并添加到外围设备
 *   3. 外围设备开始广播服务（startAdvertisting:）。
 *   4. 和中央设备CBCentral进行交互。
 */
- (IBAction)Start:(id)sender {
    self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
}

#pragma mark - CBPeripheralManagerDelegate
//外围设备已经更新状态
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"BLE已经打开");
            [self writeToLog:@"BLE已经打开"];
            //添加服务
            [self setupService];
            break;
            
        default:
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            [self writeToLog:@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备."];
            break;
    }
}

//外围设备已经添加服务
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error{
    if (error) {
        NSLog(@"向外围设备添加服务失败，失败原因:%@",error.localizedDescription);
        [self writeToLog:[NSString stringWithFormat:@"向外围设备添加服务失败，失败原因:%@",error.localizedDescription]];
        return;
    }
    //成功添加服务后开始广播
    NSDictionary * dic = @{CBAdvertisementDataLocalNameKey:kPeripheralName};
    [self.peripheralManager startAdvertising:dic];
    NSLog(@"向外围设备添加了服务并开始广播...");
    [self writeToLog:@"向外围设备添加了服务并开始广播..."];
}

//外围设备已经开始了广播
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error{
    if (error) {
        NSLog(@"启动广播过程中发生错误，错误信息：%@",error.localizedDescription);
        [self writeToLog:[NSString stringWithFormat:@"启动广播过程中发生错误，错误信息：%@",error.localizedDescription]];
        return;
    }
    NSLog(@"启动广播...");
    [self writeToLog:@"启动广播..."];
}

//中心设备已经订阅特征
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"中心设备：%@ 已订阅特征：%@.",central,characteristic);
    [self writeToLog:[NSString stringWithFormat:@"中心设备：%@ 已订阅特征：%@.",central.identifier.UUIDString,characteristic.UUID]];
    //发现中心设备并存储
    if (![self.centralDevicesOfOrderPeripheralManager containsObject:central]) {
        [self.centralDevicesOfOrderPeripheralManager addObject:central];
    }
    
    /*中心设备订阅成功后外围设备可以更新特征值发送到中心设备,一旦更新特征值将会触发中心设备的代理方法：
     -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
     */
    
    //    [self updateCharacteristicValue];
}

//取消订阅特征
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"didUnsubscribeFromCharacteristic");
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(CBATTRequest *)request{
    NSLog(@"didReceiveWriteRequests");
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict{
    NSLog(@"willRestoreState");
}

#pragma mark - 创建特征、服务并添加服务到外围设备
/**
 *  创建特征、服务并添加服务到外围设备
 */
- (void)setupService{
    //1.创建特征
    //创建特征的UUID对象
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
    //特征值
//    NSString *valueStr = kPeripheralName;
//    NSData * value = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
    //创建特征
    /**
     *  参数
     *
     *  uuid:特征标识
     *
     *  properties:特征的属性，例如:可通知、可读、可写等
     *
     *  value:特征值
     *
     *  permissions:特征的权限
     */
    CBMutableCharacteristic * characteristcM = [[CBMutableCharacteristic alloc]initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    self.characteristicM = characteristcM;
    
    //2.创建服务
    //创建服务的UUID对象
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    //创建服务
    CBMutableService * serviceM = [[CBMutableService alloc]initWithType:serviceUUID primary:YES];
    [serviceM setCharacteristics:@[characteristcM]];
    
    //将服务添加的外围设备
    [self.peripheralManager addService:serviceM];
}

#pragma mark - 更新特征值
- (void)updateCharacteristicValue{
    //特征值
    NSString *valueStr = [NSString stringWithFormat:@"%@ --%@",kPeripheralName,[NSData data]];;
    NSData *value = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
    //更新特征值
    [self.peripheralManager updateValue:value forCharacteristic:self.characteristicM onSubscribedCentrals:nil];
    [self writeToLog:[NSString stringWithFormat:@"更新特征值：%@",valueStr]];
}

- (IBAction)update:(id)sender {
    [self updateCharacteristicValue];
}

- (void)writeToLog:(NSString *)str{
    self.log.text = [NSString stringWithFormat:@"%@\n%@",self.log.text,str];
}


#pragma mark - 中央设备

#pragma mark - 懒加载
- (NSMutableArray *)centralDevicesOfOrderPeripheralManager{
    if (!_centralDevicesOfOrderPeripheralManager) {
        _centralDevicesOfOrderPeripheralManager = [NSMutableArray array];
    }
    return _centralDevicesOfOrderPeripheralManager;
}

-(NSUUID *)uuid {
    NSUUID *uuid = [UIDevice currentDevice].identifierForVendor;
    return uuid;
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
