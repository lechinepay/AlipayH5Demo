//
//  ViewController.m
//  AlipayH5
//
//  Created by 马洪亮 on 2016/12/24.
//  Copyright © 2016年 littleMoney. All rights reserved.
//

#import "ViewController.h"
#import "RequestHUD.h"
#import "AlipayRequest.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#define IOS_CELLULAR   @"pdp_ip0"
#define IOS_WIFI       @"en0"
#define IOS_VPN        @"utun0"
#define IP_ADDR_IPv4   @"ipv4"
#define IP_ADDR_IPv6   @"ipv6"

@interface ViewController () <NSURLSessionDelegate, UITextFieldDelegate>
{
    int _money;
}
@property(nonatomic,strong)UITextField * moneyTF;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildContentView];
}

- (void)buildContentView {
    CGFloat sizeWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sizeHeight = [UIScreen mainScreen].bounds.size.height;
    float left = 40;
    
    UIImageView * LePAYimage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    LePAYimage.frame = CGRectMake(left, 100, sizeWidth - left * 2, 100);
    [self.view addSubview:LePAYimage];
    
    UIColor * textColor = [UIColor lightGrayColor];
    UILabel * goods = [[UILabel alloc]initWithFrame:CGRectMake(left, CGRectGetMaxY(LePAYimage.frame) + 20, sizeWidth - left * 2, 30)];
    goods.textColor = [UIColor blackColor];
    goods.font = [UIFont systemFontOfSize:16];
    NSString * goodsStr = @"商品名称： 测试商品";
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:goodsStr];
    [attributeString setAttributes:@{NSForegroundColorAttributeName:textColor} range:NSMakeRange(0, 5)];
    goods.attributedText = attributeString;
    [self.view addSubview:goods];
    
    UILabel * price = [[UILabel alloc]initWithFrame:CGRectMake(left, CGRectGetMaxY(goods.frame) + 8, 85, 30)];
    price.text = @"商品单价：";
    price.textColor = textColor;
    price.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:price];
    
    UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 30)];
    lbl.textColor = [UIColor blackColor];
    lbl.text = @"元";
    lbl.font = [UIFont systemFontOfSize:16];
    self.moneyTF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(price.frame), CGRectGetMinY(price.frame), sizeWidth - CGRectGetMaxX(price.frame) - left, 30)];
    self.moneyTF.placeholder = @"请输入商品价格";
    self.moneyTF.font = [UIFont systemFontOfSize:16];
    self.moneyTF.borderStyle = UITextBorderStyleRoundedRect;
    self.moneyTF.keyboardType = UIKeyboardTypeDecimalPad;
    self.moneyTF.rightViewMode = UITextFieldViewModeAlways;
    self.moneyTF.rightView = lbl;
    self.moneyTF.delegate = self;
    [self.view addSubview:self.moneyTF];
    
    // 支付按钮
    UIColor * buttonColor = [UIColor colorWithRed:0.241 green:0.703 blue:0.201 alpha:1.00];
    UIButton * button  =[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(left, CGRectGetMaxY(self.moneyTF.frame) + 40, sizeWidth - left * 2, 44);
    [button setTitle:@"支付宝H5支付" forState:UIControlStateNormal];
    [button setTitleColor:buttonColor forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    button.layer.borderColor = buttonColor.CGColor;
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 底部图片
    UIImageView * bottomPicture = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg"]];
    bottomPicture.frame = CGRectMake(0, CGRectGetMaxY(button.frame) + 20, sizeWidth, sizeHeight - 354);
    [self.view addSubview:bottomPicture];
    
    UILabel * VersionNum  = [[UILabel alloc]init];
    VersionNum.text = @"版本号v1.0.0";
    VersionNum.font = [UIFont systemFontOfSize:15];
    VersionNum.textAlignment = NSTextAlignmentCenter;
    VersionNum.textColor = [UIColor lightGrayColor];
    VersionNum.frame = CGRectMake(0, sizeHeight - 50, sizeWidth, 20);
    [self.view addSubview:VersionNum];
    
    UILabel * company  = [[UILabel alloc]init];
    company.text = @"Zhejiang Le Xinfu Finance Information Service Co., Ltd.";
    company.font = [UIFont systemFontOfSize:12];
    company.textAlignment = NSTextAlignmentCenter;
    company.textColor = [UIColor grayColor];
    company.frame = CGRectMake(0, sizeHeight - 25, sizeWidth, 20);
    [self.view addSubview:company];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



#pragma mark - textField delegate
// demo此处限制金额最多可输入6位整数，两位小数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length == 0 && [string isEqualToString:@"."]) {
        return NO;
    }
    NSCharacterSet * numbers;
    NSRange pointRange = [textField.text rangeOfString:@"."];
    if ( (pointRange.length > 0) && (pointRange.location < range.location  || pointRange.location > range.location + range.length) ) {
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    }
    else {
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    NSString * tempStr = [textField.text stringByAppendingString:string];
    NSArray * array = [tempStr componentsSeparatedByString:@"."];
    if (array.count == 1) {
        if (tempStr.length >= 6) {
            textField.text = [tempStr substringToIndex:5];
        }
    }
    else{
        if ([array[1] length] >= 2) {
            textField.text = [NSString stringWithFormat:@"%@.%@", array[0], [array[1] substringWithRange:NSMakeRange(0, 1)]];
        }
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    // 注意：商品价格以分为单位。 0.01 * 100表示100分，即0.01元
    _money = [textField.text floatValue] * 100;
}



#pragma mark - event
- (void)buttonClick {
    // 下单
    [self.view endEditing:YES];
    [RequestHUD showWithMaskType:RequestHUDMaskTypeGradient];
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL * urlStr = [NSURL URLWithString:@"https://openapi.lechinepay.com/lepay.appapi/order/add.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlStr];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString * mchId = @"32002";
    NSString * cmpAppId = @"35002";
    NSString * param = [NSString stringWithFormat:@"version=%@&encoding=%@&signature=%@&reqReserved=%@&mchId=%@&subMchId=%@&agentMchId=%@&agentMchAppId=%@&cmpAppId=%@&payTypeCode=%@&outTradeNo=%@&tradeTime=%@&amount=%@&summary=%@&summaryDetail=%@&returnUrl=%@&deviceId=%@&deviceIp=%@", @"1.0.0",@"UTF-8",@"+Lepay_TEST",@"+Lepay_TEST",mchId,@"+Lepay_TEST",@"+Lepay_TEST",@"+Lepay_TEST",cmpAppId,@"alipay.h5pay.ms",[self generateTradeNO],[self TradeTime],[NSString stringWithFormat:@"%d",_money],@"支付宝H5支付",@"+Lepay_TEST",@"http://unionpay95516.com/lepayStatus/nativeAppResult.html?unifypay_pay_status=2",@"+Lepay_TEST",[self getIPAddress:YES]];
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        [RequestHUD dismiss];
        if (data) {
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"dic = %@", dic);
            if ([dic[@"respCode"] isEqualToString:@"000000"] ) {
                // 跳转到支付宝
                NSString * qrPath = dic[@"qrPath"];
                [AlipayRequest sendRequestToOpenAlipayAutomaticallySweepWithQRPath:qrPath];
            }
            else {
                [self showAlertViewWithMessage:dic[@"respMsg"]];
            }
        }
        else {
            [RequestHUD showErrorWithStatus:@"网络连接错误"];
        }
        [session invalidateAndCancel];
    }];
    [dataTask resume];
}



#pragma mark - private
-(void)showAlertViewWithMessage:(NSString *)message{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * onClickAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    }];
    [alertController addAction:onClickAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


// 跳过验证https
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential * card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}


// 随机生成订单号
- (NSString *)generateTradeNO {
    static int kNumber = 16;
    NSString *sourceStr = @"0123456789abcdefghijklmnopqrstuvwxyz";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString * oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


// 获取交易时间
- (NSString *)TradeTime {
    NSString * date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    date = [formatter stringFromDate:[NSDate date]];
    return date;
}


// 获取当前设备的IP地址
- (NSString *)getIPAddress:(BOOL)preferIPv4{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

// 获取设备IP地址
- (NSDictionary *)getIPAddresses{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP)) {
                continue;
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
