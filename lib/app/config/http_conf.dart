//const base_url = "https://waiter.smartwe.co.jp/";  //生产环境地址
//const base_url = "https://reji.smartwe.co.jp/";  //new生产环境地址
const base_url = "https://waiter-sit.smartwe.co.jp/";  //测试环境地址


const oa_base_url = "https://oa.gutingjun.com/api/"; //刷脸正式环境地址

const servicePath = {
  'webBootIndex': base_url + 'pad/web/boot/index', //获取首页菜单地址
  'webBootIndexv1': base_url + 'pad/web/boot/index/v1', //获取首页菜单地址

  //新改版获取分类菜单
  'webBootIndexCategoryv2':
      base_url + 'pad/web/boot/index/category/v2', //获取首页分类
  'webBootIndexMenuv2': base_url + 'pad/web/boot/index/menu/v2', //获取某分类菜单
  'webBootIndexMenuv3': base_url + 'pad/web/boot/index/menu/v3', //获取某分类菜单

  'webStockBooking': base_url + 'pad/web/boot/stock-booking', //限量请求地址
  //'webBootOrder': base_url + 'pad/web/boot/order', //提交订单请求地址
  //'webBootOrder': base_url + 'pad/web/boot/v2/order', //提交订单请求地址
  'webBootOrder': base_url + 'pad/web/boot/v3/order', //提交订单请求地址
  'webBootCalculateOrder':
      base_url + 'pad/web/boot/v3/calculate/order', //自助收银提交订单请求地址
  'webBootToPay': base_url + 'pad/web/boot/toPay', //支付提交请求地址
  'webBootToPayv2': base_url + 'pad/web/boot/toPay/v2', //支付提交请求地址
  'webBootPosPayReport': base_url + 'pad/web/boot/pos/pay/report', //支付提交请求地址
  //'webBootToPayV2': base_url + 'pad/web/boot/v2/toPay', //支付提交请求地址 新 增加交易失败退出扫码情况
  //'webBootToReport': base_url + 'pad/web/boot/report', //现金支付提交请求地址
  'webBootToReportV1': base_url + 'pad/web/boot/v1/report', //现金支付提交请求地址
  //'webBootToPrint': base_url + 'pad/web/boot/print', //打印小票请求地址
  //'webBootToPrintV2': base_url + 'pad/web/boot/v2/print', //打印小票请求地址 58mm
  //'webBootToPrintV3': base_url + 'pad/web/boot/v3/print', //打印小票请求地址 80mm
  //'webBootToPrintV4': base_url + 'pad/web/boot/v4/print', //打印小票请求地址 新转成图片去掉空格，格式有变化
  'webBootToPrintV5':
      base_url + 'pad/web/boot/v5/print', //打印小票请求地址 新转成图片去掉空格，格式有变化
  'webBootToPrintV6': base_url + 'pad/web/boot/v6/print', //打印小票请求地址 领収书有变化
  'webBootToPrintV7': base_url + 'pad/web/boot/v7/print', //打印小票请求地址 增加多选，厨房菜单有变化
  'webBootToRetryPrint': base_url + 'pad/web/boot/retry/print', //打印小票请求地址 增加多选，厨房菜单有变化
  'webBootCancel': base_url + 'pad/web/boot/cancel', //取消订单请求地址
  'webBootCancelV1': base_url + 'pad/web/boot/v1/cancel', //取消订单请求地址
  'webBootChangeState': base_url + 'pad/web/boot/change/state', //机器零钱状态
  'webBootChangeInfo': base_url + 'pad/web/boot/information', //机器零钱状态
  'webBootChangeReset': base_url + 'pad/web/boot/reset', //重置机器零钱状态
  'webBootChangeSet': base_url + 'pad/web/boot/change/add', //设置机器零钱状态
  'webBootLinePayConfirm': base_url + 'pad/web/boot/linePay/confirm', //扫码超时后再次确认

  'webBootCreditCard': base_url + 'pad/web/boot/creditCard', //请求刷卡返回的字符串
  'webBootCreditCardCancel':
      base_url + 'pad/web/boot/creditCard/back', //请求刷卡取消的字符串

  'webBootLogUpload': base_url + 'pad/web/boot/log/upload', //上传现金机日志文件

  'oldrecognitionSearch':
      oa_base_url + 'oa/face/recognition/old/search', //刷脸 转base64后上传

  'recognitionRegister': oa_base_url + 'oa/face/recognition/register', //考勤激活码

  //点餐机激活
  'webBootActivate': base_url + 'pad/web/boot/activate', //点餐机激活
  'webBootActivatev2': base_url + 'pad/web/boot/activate/v2', //点餐机激活
  'webBootActivatev3': base_url + 'pad/web/boot/activate/v3', //点餐机激活 发送版本号
  'webBootActivatev4': base_url + 'pad/web/boot/activate/v4', //点餐机激活 发送版本号

  //精算机使用接口
  'shopOrderTableNum': base_url + 'pad/web/table/shopOrderTableNum', //扫桌号二维码下单
  'webBootCalculate': base_url + 'pad/web/boot/calculate', //扫桌号二维码下单
  'checkOutOrderDetails':
      base_url + 'pad/web/table/checkOutOrderDetails', //精算机结算页面订单列表

  'webBootReserve': base_url + 'pad/web/boot/v1/reserve', //提交预约排队
  'webBootToPayConfirm': base_url + 'pad/web/boot/toPay/confirm', //订单id确认

  'webBootBarCodeQuery': base_url + 'pad/web/boot/bar_code/query', //通过商品条码找商品

  //退款相关
  'webBootReimburseQuery':
      base_url + 'pad/web/boot/reimburse/query', //通过领収书注文番号开始查询
  'webBootReimburseExecute':
      base_url + 'pad/web/boot/reimburse/execute', //扫码支付的退款开始执行
  'webBootReimburseNotify': base_url + 'pad/web/boot/reimburse/notify', //退款执行通知


  //Pos测试接口
  'webBootPosTest': base_url + 'pad/web/boot/pos/test', //Pos测试接口

  'webBootTroubleNotify': base_url + 'pad/web/boot/notice', //Pos测试接口
};

