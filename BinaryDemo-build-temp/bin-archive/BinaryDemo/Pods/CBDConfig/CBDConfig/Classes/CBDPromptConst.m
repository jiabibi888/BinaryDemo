//
//  CBDPromptConst.m
//  CarBaDa
//
//  Created by Jabir-Zhang on 2021/1/26.
//  Copyright © 2021 wyj. All rights reserved.
//

#import "CBDPromptConst.h"

//订单填写
NSString * const kPromptOrderNoAddPager = @"请至少添加一位乘客";

NSString * const kPromptOrderTrainNoContentMobile = @"请输入手机号";

NSString * const kPromptOrderErrContentMobile = @"请输入正确手机号";

//价格清单
NSString * const kPromptPriceTypeAdult = @"成人票";
NSString * const kPromptPriceTypeChild = @"儿童票";
NSString * const kPromptPriceTypeDisableSoldier = @"残军票";
NSString * const kPromptPriceTypeInsuran = @"安心出行";
NSString * const kPromptPriceTypeRefundIns = @"退票险";
NSString * const kPromptPriceTypeLuckFree = @"幸运免单";
NSString * const kPromptPriceTypeFaithPackage = @"乘意险";
NSString * const kPromptPriceTypeVipBooking = @"优享预订";
NSString * const kPromptPriceTypeRedWallet = @"红包优惠";
NSString * const kPromptPriceTypeRedCoupon = @"红包";
NSString * const kPromptPriceTypeSuperStewardCardAccPack = @"超级管家卡加速包优惠";
NSString * const kPromptPriceTypeKnockThePreferential = @"立减优惠";
NSString * const kPromptPriceTypeAbcBankAmount = @"农行支付立减";
NSString * const kPromptPriceTypeServiceFee = @"服务费";
NSString * const kPromptPriceTypeTicketDeliveryFee = @"邮寄费";
NSString * const kPromptPriceTypeNightTicketServiceFee = @"夜间出票服务费";
NSString * const kPromptPriceTypeSeatServiceFee = @"指定座席服务费";
NSString * const kPromptPriceTypeOpenNoVertifyFee = @"免核验购票服务费";
NSString * const kPromptPriceTypeFreeAmount = @"幸运免单";
NSString * const kPromptPriceTypeBuyCoupon = @"优惠券购买";
NSString * const kPromptPriceTypeUseCoupon = @"优惠券抵用";
NSString * const kPromptPriceTypeCouponReduce = @"优惠券立减";
NSString * const kPromptPriceTypeDoubleSpeedUp = @"极速出票";
NSString * const kPromptPriceTypeInvoiceMailFee = @"发票邮寄费";
NSString * const kPromptPriceTypeTransferFirstFee = @"第1程票价";
NSString * const kPromptPriceTypeTransferSecondFee = @"第2程票价";
NSString * const kPromptPriceTypeVipCardPrice = @"超级会员";
NSString * const kPromptPriceTypeFreeFeeAmount = @"超级会员免服务费";
NSString * const kPromptPriceTypeVipCardReductAmount = @"超级会员购票立减";
NSString * const kPromptPriceTypeVipCardBuyFee = @"超级会员";

//登录
NSString * const kPromptSignErrUnPd = @"请输入正确的手机号";
NSString * const kPromptRegisteredErrPwd = @"密码需数字与字母的组合，例如12345a";

//常旅
NSString * const kPromptPassgerNoCertiNum = @"证件号不能为空";
NSString * const kPromptPassgerCertiNumLenError = @"身份证号码需18位";
NSString * const kPromptPassgerMultiCertiNoLenError = @"请输入正确证件号";

NSString * const kPromptPassgerErrMobile = @"请填写正确的手机号";
NSString * const kPromptPassgerErrEmail = @"请填写正确的邮箱";
NSString * const kPromptPassgerNoMobile = @"请输入手机号码";
NSString * const kPromptPassgerNoMobileOrEmail = @"请输入手机号码或邮箱地址";
NSString * const kPromptPassgerErrChildAge = @"当前儿童旅客年龄大于18周岁，请修改【乘客类型】为成人";
NSString * const kPromptPassgerAddSuccess = @"添加成功";
NSString * const kPromptPassgerUpdateSuccess = @"修改成功";
NSString * const kPromptPassgerNoBirthDay = @"请选择出生日期";
NSString * const kPromptPassgerAddError = @"您已添加过该证件信息，是否覆盖之前信息？";
NSString * const kPromptPassgerOnlyChild = @"为确保安全，儿童需有成人同行";
NSString * const kPromptPassgerDeletePassenger = @"确定删除常用旅客吗？";
NSString * const kPromptPassgerNoHotelTravellerNameError = @"请填写入住人姓名";
NSString * const kPromptPassgerNoNameError = @"姓名不能为空";
NSString * const kPromptPassgerChineseNameLessTwoWords = @"姓名至少2个字";
NSString * const kPromptPassgerEnglishNameLessThreeWords = @"姓名至少3个字";
NSString * const kPromptPassgerOnlyEnglishOrChinesePrefix = @"姓名仅可用中文&英文开头";
NSString * const kPromptPassgerOnlyChinesePrefix = @"姓名仅支持中文开头";
NSString * const kPromptPassgerErrName = @"请填写正确的乘客姓名";
NSString * const kPromptPassgerNoHotelTravellerPhoneNumber = @"请填写入住人手机号码";
NSString * const kPromptPassgerErrContainChinese = @"身份证号码仅支持数字或X";
NSString * const kPromptPassgerErrOtherCerti = @"证件号码仅支持数字、英文";
NSString * const kPromptPassgerErrNameLength = @"姓名中最多能输入15个字";
NSString * const kPromptPassgerNoPass = @"还没有常旅，快去添加吧";
NSString * const kPromptPassgerListCommonTopTip = @"乘客信息为实际乘车人，为保障您的权益请如实填写哦！";
NSString * const kPromptPassgerListTrainTopTip = @"常旅有变化？下拉刷新试试";
//机票常旅
NSString * const kPromptAirplanePassgerNameLengthError = @"姓名不可超过13个字，请修改";
//意见反馈
NSString * const kPromptOpinionTelephone = @"拨打400-100-0456";

//发票
NSString * const kPromptInvoiceCSPhone = @"4001000456";
NSString * const kPromptInvoiceCSPhoneShow = @"400-100-0456";
NSString * const kPromptInvoiceUnsupportSpecialTip = @"个人类型不支持专票";
//银行卡
NSString * const kPromptMyBankNoResult = @"亲，暂时没有银行卡哦~";

//个人资料
NSString * const kPromptInformationQuit = @"确认退出登录？";

//消息盒子
NSString * const kPromptMsgCenterDeleteOneMsg = @"确定删除这条消息吗？";

//    ================================================== 校园巴士 ===================================================
//首页
NSString * const kPromptSchoolBusErroDate = @"请您选择预售期内的日期。";
NSString * const kPromptSchoolBusSGNoSelSchool = @"请选择出发校园";
NSString * const kPromptSchoolBusSGNoSelCity = @"请选择到达城市";
NSString * const kPromptSchoolBusSRNoSelCity = @"请选择出发城市";
NSString * const kPromptSchoolBusSRNoSelSchool = @"请选择到达校园";
NSString * const kPromptSchoolBusNoResult = @"网络不给力\n请连接网络后点击屏幕重试";
//    ================================================== 城际巴士 ===================================================
//首页
NSString * const kPromptCityBusNoLines = @"抱歉，暂无线路信息！";

//    ==================================================== 旅程 ===================================================
NSString * const kPromptNoNetworkJonery = @"网络不给力\n请连接网络后点击屏幕重试";
//    ================================================== 订单列表 ===================================================
NSString * const kPromptNoResultOrderList = @"亲，暂时没有订单哦~";
//    =================================================全局无网络 ===================================================
NSString * const kPromptNoNetworkAll = @"网络不给力\n请连接网络后点击屏幕重试";
//    ================================================= 卡券列表 ===================================================
NSString * const kPromptNoResultCardTicket = @"亲，暂时没有优惠券哦~";
//    ==================================================== 红包列表 ===================================================
NSString * const kPromptNoResultRedWallet = @"亲，暂时没有红包哦~";
//    ==================================================== 火车票 ===================================================
NSString * const kPromptNoResultTrainList = @"没有找到符合条件的车次";
NSString * const kPromptNoResultInterlineList = @"没有找到符合条件的中转车次";
NSString * const kPromptNoResultTrainDetailList = @"没有找到符合条件的车次";
NSString * const kPromptServerErrorTrainDetailList = @"哎呀，服务器偷懒了，请稍后再试";
NSString * const kPromptNoResultTrainTime = @"木有结果，再找找看";
NSString * const kPromptTrainSameStation = @"出发站到达站不能相同";
//    ==================================================== 火车票车次详情 ===================================================
NSString * const kPromptTicketLessWarningTrainDetailList =               @"该座席票量紧张可能无法成功出票，或出无座票，您是否继续预订？";
//    ==================================================== 火车票12306 ===================================================
NSString * const kPrompt12306RegisterErrUserName = @"用户名需要由6-30位数字或字母组成， 必须字母开头";
NSString * const kPrompt12306RegisterErrPassword = @"密码需要是“6-20位字母、数字或 _ 的组合”";
NSString * const kPrompt12306RegisterErrName =  @"请输入正确的姓名";
NSString * const kPrompt12306RegisterErrMobile = @"请输入正确的手机号";
NSString * const kPrompt12306RegisterErrCertiID = @"请输入正确的证件号";
NSString * const kPrompt12306RequestFail = @"接口请求失败";
NSString * const kPrompt12306LoginIdentityTip = @"购票必须实名制，请尽快登录、注册12306账号完成实名认证，以免影响您的购票出行。";
//    ==================================================== 火车票订单详情 ===================================================
NSString * const kPromptTicketFailDefaultMsg = @"对不起，未能成功为您抢到票。";
//    ==================================================== 消息中心 ===================================================
NSString * const kPromptNoResultMessageCenter = @"还没有消息，再等等看";
NSString * const kPromptNoNetworkMessageCenter = @"网络不给力\n请连接网络后点击屏幕重试";
//    ==================================================== 混合城市列表 ===================================================
NSString * const kPromptNoResultHybridCityList = @"木有结果，再找找看";
//    ==================================================== 城市频道城市列表 ===================================================
NSString * const kPromptNoResultCityChanelCityList = @"木有结果";
//    ================================================== 城市频道 ===================================================
NSString * const kPromptAppleMapGo = @"使用苹果地图导航";
NSString * const kPromptGaoDeMapGo = @"使用高德地图导航";
NSString * const kPromptBaiDuMapGo = @"使用百度地图导航";
//    ================================================== 公共 ===================================================
NSString * const kPromptNoNetworkPublic = @"木有结果，请稍后再试";
//    ================================================== 酒店 ===================================================
NSString * const kPromptCanNotBooking = @"请重新选择较早的到店时间，方可预订";
NSString * const kPromptNoArrivalTime = @"请选择最晚到店时间";
NSString * const kPromptNoHotelPhoto = @"酒店尚未上传该类型照片";

NSString * const kPromptHotelGuestError = @"请输入正确的姓名，以确保成功预订";

NSString * const kPromptHotelWriteArrivalTimeTip = @"温馨提示：若晚于最晚到店时间抵达酒店，请提前联系巴士管家客服，协商延长保留房间，以免房间过时取消。";
NSString * const kPromptHotelWriteNoIdCard = @"请填写入住人的身份证号";
NSString * const kPromptHotelWriteErrorIdCard = @"输入的身份证号不符合规范，请修正后再预订";
NSString * const kPromptNoResultHotelDetails = @"找不到该酒店";

NSString * const kPromptHotelOrderDetailTopTipNight = @"夜间订单，请您耐心等待。如您已在酒店前台，请致电巴士管家。";
NSString * const kPromptHotelOrderDetailTopTipDay = @"酒店处理订单一般需要5-15分钟，请您耐心等待，确认成功后短信通知将发送到入住人手机。";

NSString * const kPromptHotelOrderDetailNoHotelTel = @"该酒店暂无联系电话，请致电巴士管家客服";

NSString * const kPromptHotelMapNoResult = @"没有找到符合条件的酒店";
NSString * const kPromptHotelMapNoNetWork = @"网络不给力，请稍后再试";
NSString * const kPromptHotelMapNoPoi = @"范围太大，长按地图查询附近的酒店";

NSString * const kPromptNoLocationTitle = @"开启“定位服务”";
NSString * const kPromptNoLocationAuthor = @"根据您的位置，我们将提供更优的城际及市内出行服务";

@implementation CBDPromptConst

@end
