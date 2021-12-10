//
//  CBDPublicEnum.h
//  CarBaDa
//
//  Created by Jabir-Zhang on 2019/6/20.
//  Copyright © 2019 wyj. All rights reserved.
//

#ifndef CBDPublicEnum_h
#define CBDPublicEnum_h

#pragma mark - 全局项目号ProjectType
typedef NS_ENUM(NSInteger, refreshOrderListType){
    Refresh_All = 0,
    Refresh_Bus = 1,
    Refresh_Car = 2,
    Refresh_ShuttleBus = 3,
    Refresh_SchoolBus = 4,
    Refresh_AirportBus = 5,
    Refresh_CityShuttleBus = 6,
    Refresh_Train = 7,
    Refresh_OfficalCar = 8,
    Refresh_NewCityShuttleBus = 9,//定制快车
    Refresh_Current = 10,
    Refresh_NO = 11,
    Refresh_AirportBagCar = 12,
    Refresh_CustomCharteredBus = 14,
    Refresh_Carpool = 15,//城际拼车
    Refresh_Hotel = 17,//酒店
    Refresh_OneYuanFree = 18,//一元免单
    Refresh_MemberLevel = 19,//会员等级
    Refresh_VipCenter = 21,
    Refresh_TourTransport = 25,//景区直通车，游运
    Refresh_SpecialCar = 26,//快车直达  定制到家
    Refresh_Resorts = 27,//景区门票
    Refresh_OPCar = 28,
    Refresh_HotelAPI = 34,//客户端酒店
    Refresh_TransportStation = 37,//接送站
    Refresh_HailingCar = 40,//网约车
    Refresh_HailingSpecialCar = 41,  //打车。专车
    Refresh_StewardCard = 42,  //超级管家卡
    Refresh_FlightInfo = 39,//航班动态
    Refresh_Flight = 43,//机票项目
    Refresh_PublicAssets = 99,//H5公共资源库
    Refresh_ChangeUser = 1000,//暂时用于标记用户切换时订单列表数据清空刷新
    Refresh_Hybrid = 1001,//混合项目
    Refresh_ChannerlGoods = 30,//增值生活卖场
    Refresh_CustomBus = 48,//定制公交
    Refresh_ExpressDelivery = 53,//管家跑腿
    Refresh_HomePage = 9999//公共首页项目
};//订单列表中刷新订单类别 && 亦可作为projecttype来用  from appdelegate

#pragma mark - 车巴达收银台——支付结果页类型
/**
 车巴达支付结果页类型

 - CBDPayType_PaySuccess: 支付成功,普通支付
 - CBDPayType_BookSuccess: 预订成功，后支付模式
 - CBDPayType_DirectPaySuccess:直付成功
 - CBDPayType_ValueAddedProductsPay:项目中增值产品支付
 */
typedef NS_ENUM(NSInteger, CBDPayType){
    CBDPayType_PaySuccess = 0 ,
    CBDPayType_BookSuccess = 1,
    CBDPayType_DirectPaySuccess,
    CBDPayType_ValueAddedProductsPay
};

#pragma mark - 混合
typedef NS_ENUM(NSInteger, ExpressBusPageindexEnum)
{
    ExpressBus_Home = 0,
    ExpressBus_LineList = 1,
    ExpressBus_OrderFilling = 2,//订单填写页
    ExpressBus_OrderDetails = 3
};

/**
 包车项目pageindex

 - CharteredBus_Home: 包车首页
 - CharteredBus_ChooseCar: 国内包车选车页
 - CharteredBus_DomesticOrderDetails: 国内包车订单详情
 - CharteredBus_CustomOrderDetails: 定制包车订单详情（只有定制包车usefor为10的是此类型的订单详情）
 */
typedef NS_ENUM(NSInteger, CharteredBusPageIndex){
    CharteredBus_Home = 0,
    CharteredBus_ChooseCar = 1,
    CharteredBus_DomesticOrderDetails = 2,
    CharteredBus_CustomOrderDetails= 3
};

#pragma mark - 火车票

typedef NS_ENUM(NSInteger, TrainSiftStatus) {
    SiftTimeAsc=0,
    SiftTimeDesc=1,
    SiftCostAsc=2,
    SiftCostDesc=3,
    SiftPriceAsc=4
};//火车票筛选状态

//在线选座模式
typedef NS_ENUM(NSInteger, OnlineSelectSeatType){
    SelectSeatOnline_SpecifyLowerBerth = 1,//指定卧铺
    SelectSeatOnline_HighspeedRail = 2,//高铁选座
    SelectSeatOnline_SpecifiedWindow = 3,//指定靠窗
    SelectSeatOnline_OfficialSelectSeat = 4,//官方选座
};

#pragma mark ---------------------------------------------------- 公共 ----------------------------------------------------
#pragma mark - 进入订单详情来源的枚举
/**
 进入订单详情来源的枚举

 - OrderDetailsFrom_OrderList: 来自订单列表
 - OrderDetailsFrom_Pay: 来自支付
 - OrderDetailsFrom_PastOrderList: 来自三个月签订单
 - OrderDetailsFrom_TravelAssistant: 来自行程助手
 */
typedef NS_ENUM(NSInteger, OrderDetailsFromType){
    OrderDetailsFrom_OrderList = 0,
    OrderDetailsFrom_Pay = 1,
    OrderDetailsFrom_PastOrderList = 2,
    OrderDetailsFrom_TravelAssistant = 3
};

#endif /* CBDPublicEnum_h */
