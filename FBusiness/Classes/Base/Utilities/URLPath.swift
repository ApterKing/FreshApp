//
//  URLPath.swift
//  FBusiness
//
//

public struct URLPath {
    
    #if DEBUG
//        #if FRESH_CLIENT
        public static let host = "http://api.3xian.shop/"
//        #else
//        public static let host = "https://wx.wixinfo.com/fresh-api/"
//        #endif
    #else
        public static let host = "http://api.3xian.shop/"
    #endif
    
}

// 用户模块
public extension URLPath {
    
    public struct User {
        
        // 注册
        public static let regist = host + "user/regist"
        
        // 登录
        public static let login = host + "user/login"
        
        // 登录
        public static let logout = host + "user/logout"

        // 忘记密码
        public static let forgotPwd = host + "user/forgot"

        // 修改
        public static let updPwd = host + "user/updPwd"

        // 获取验证码
        public static let checkCode = host + "user/checkCode"

        // 用户信息
        public static let userInfo = host + "user/get"
        
        // 修改用户信息
        public static let update = host + "user/update"
        
        // 用户订单
        public static let orders = host + "user/orders"
        
        // 地址列表
        public static let addressList = host + "user/address/list"
        
        // 地址（新增、编辑）
        public static let addressSubmit = host + "user/address/submit"
        
        // 删除地址
        public static let addressDelete = host + "user/address/delete"
        
        // 用户优惠券
        public static let coupons = host + "user/coupons"
        
        // 用户收入支出明细
        public static let cashFlow = host + "user/cashFlow"
        
        // 申请提现
        public static let withdraw = host + "user/withdraw"
        
        // 获取优惠券
        public static let getCoupon = host + "user/getCoupon"

        // 填写邀请码
        public static let regInviteCode = host + "user/regInviteCode"
    }
    
}

public extension URLPath {
    
    public struct Product {

        // 置顶商品
        public static let top = host + "product/top"
        
        // 商品列表（特价商品、商品搜索等）
        public static let list = host + "product/list"

        // 商品详情
        public static let detail = host + "product/get"

        // 商品分类列表
        public static let category = host + "catelog/list"

        // 商品首页分类
        public static let categoryFront = host + "catelog/front"

        // 商品首页推荐分类
        public static let categoryRecomment = host + "catelog/recommend"

        // 商品首页推荐分类-更多列表
        public static let categoryRecommentList = host + "catelog/recommend/list"

    }
    
}

// 订单
public extension URLPath {
    
    public struct Order {
        
        // 添加订单
        public static let add = host + "order/add"

        // 取消订单
        public static let cancel = host + "order/delete"

        // 订单支付
        public static let pay = host + "order/pay"

        // 订单完成通知服务器
        public static let done = host + "order/done"

        // 订单详情
        public static let detail = host + "order/get"
        
        // 家政服务添加
        public static let homeServiceAdd = host + "order/homeService/add"

        // 家政服务列表
        public static let homeServiceList = host + "order/homeService/list"
        
        // 家政服务取消
        public static let homeServiceCancel = host + "order/homeService/delete"
        
        // 家政服务支付
        public static let homeServicePay = host + "order/homeService/pay"
        
    }
    
}

// 购物车
public extension URLPath {
    
    public struct Car {
        
        // 添加购物车
        public static let add = host + "cart/add"
        
        // 编辑购物车
        public static let edit = host + "cart/edit"
        
        // 删除购物车
        public static let delete = host + "cart/delete"
        
        // 购物车列表
        public static let list = host + "cart/list"
        
    }
    
}

// app相关
public extension URLPath {
    
    public struct Config {
        
        // 更新
        public static let update = host + "app/update"
        
        // 启动页或者banner配置
        public static let banner = host + "app/banner"
        
        // 开通城市
        public static let cities = host + "app/openedCities"
        
        // 城市配送时间
        public static let deliverConfig = host + "app/openedCities/deliverConfig"
        
        // 邀请佣金配置
        public static let commission = host + "app/commission"
        
        // 提现金额配置
        public static let withdraw = host + "app/withdraw"

    }
    
}

// 配送端
public extension URLPath {
    
    public struct Delivery {
        
        // 获取验证码
        public static let checkCode = host + "delivery/checkCode"

        // 注册
        public static let regist = host + "delivery/regist"
        
        // 登录
        public static let login = host + "delivery/login"
        
        // 配送员信息
        public static let userInfo = host + "delivery/get"
        
        // 注销
        public static let logout = host + "delivery/logout"
        
        // 获取订单
        public static let order_list = host + "delivery/order/list"
        
        // 完成订单
        public static let order_finish = host + "delivery/order/finish"
        
        // 取货
        public static let order_get = host + "delivery/order/get"
        
        // 历史统计数据
        public static let order_statistic = host + "delivery/order/statistic"
        
        // 历史统计数据
        public static let order_history = host + "delivery/order/history"
        
    }
    
}
