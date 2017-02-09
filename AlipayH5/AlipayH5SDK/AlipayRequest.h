//
//  AlipayRequest.h
//  AlipayH5
//
//  Created by 马洪亮 on 2017/2/9.
//  Copyright © 2017年 littleMoney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlipayRequest : NSObject


/*
 * 打开支付宝扫码付自动扫描二维码
 * 参数qrPath：下单接口服务器返回的qrPath字段内容
 */
+ (void)sendRequestToOpenAlipayAutomaticallySweepWithQRPath:(NSString *)qrPath;

@end
