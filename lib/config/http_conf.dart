//const base_url = "https://waiter.smartwe.co.jp/";  //生产环境地址
const base_url = "https://waiter-sit.smartwe.co.jp/";  //测试环境地址

//const oa_base_url = "https://testoa.gutingjun.com/api/";  //刷脸测试环境地址
const oa_base_url = "https://oa.gutingjun.com/api/";  //刷脸正式环境地址

const servicePath = {
  'webBootIndex': base_url + 'pad/web/boot/index', //获取首页菜单地址
  'webStockBooking': base_url + 'pad/web/boot/stock-booking', //限量请求地址
  //'webBootOrder': base_url + 'pad/web/boot/order', //提交订单请求地址
  //'webBootOrder': base_url + 'pad/web/boot/v2/order', //提交订单请求地址
  'webBootOrder': base_url + 'pad/web/boot/v3/order', //提交订单请求地址
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
  'webBootToPrintV5': base_url + 'pad/web/boot/v5/print', //打印小票请求地址 新转成图片去掉空格，格式有变化
  'webBootCancel': base_url + 'pad/web/boot/cancel', //取消订单请求地址
  'webBootCancelV1': base_url + 'pad/web/boot/v1/cancel', //取消订单请求地址
  'webBootChangeState': base_url + 'pad/web/boot/change/state', //机器零钱状态
  'webBootChangeReset': base_url + 'pad/web/boot/change/reset', //重置机器零钱状态
  'webBootLinePayConfirm': base_url + 'pad/web/boot/linePay/confirm', //扫码超时后再次确认

  'webBootCreditCard': base_url + 'pad/web/boot/creditCard', //请求刷卡返回的字符串
  'webBootCreditCardCancel': base_url + 'pad/web/boot/creditCard/back', //请求刷卡取消的字符串

  'webBootLogUpload': base_url + 'pad/web/boot/log/upload', //上传现金机日志文件


  'oldrecognitionSearch': oa_base_url + 'oa/face/recognition/old/search', //刷脸 转base64后上传

'recognitionRegister': oa_base_url + 'oa/face/recognition/register', //考勤激活码

  //点餐机激活
  'webBootActivate': base_url + 'pad/web/boot/activate', //点餐机激活
  'webBootActivatev2': base_url + 'pad/web/boot/activate/v2', //点餐机激活

  //精算机使用接口
  'shopOrderTableNum': base_url + 'pad/web/table/shopOrderTableNum', //扫桌号二维码下单
  'webBootCalculate': base_url + 'pad/web/boot/calculate', //扫桌号二维码下单
  'checkOutOrderDetails': base_url + 'pad/web/table/checkOutOrderDetails', //精算机结算页面订单列表

  'webBootReserve': base_url + 'pad/web/boot/v1/reserve', //提交预约排队
};