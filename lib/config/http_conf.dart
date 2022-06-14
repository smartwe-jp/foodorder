const base_url = "https://waiter.smartwe.co.jp/";  //生产环境地址
//const base_url = "https://waiter-sit.smartwe.co.jp/";  //测试环境地址

//const oa_base_url = "https://testoa.gutingjun.com/api/";  //刷脸测试环境地址
const oa_base_url = "https://oa.gutingjun.com/api/";  //刷脸正式环境地址

const servicePath = {
  'webBootIndex': base_url + 'pad/web/boot/index', //获取首页菜单地址
  'webStockBooking': base_url + 'pad/web/boot/stock-booking', //限量请求地址
  'webBootOrder': base_url + 'pad/web/boot/order', //提交订单请求地址
  'webBootToPay': base_url + 'pad/web/boot/toPay', //支付提交请求地址
  'webBootToReport': base_url + 'pad/web/boot/report', //现金支付提交请求地址
  //'webBootToPrint': base_url + 'pad/web/boot/print', //打印小票请求地址
  'webBootToPrint': base_url + 'pad/web/boot/v2/print', //打印小票请求地址
  'webBootCancel': base_url + 'pad/web/boot/cancel', //取消订单请求地址
  'webBootChangeState': base_url + 'pad/web/boot/change/state', //机器零钱状态
  'webBootChangeReset': base_url + 'pad/web/boot/change/reset', //重置机器零钱状态
  'webBootLinePayConfirm': base_url + 'pad/web/boot/linePay/confirm', //扫码超时后再次确认


  'oldrecognitionSearch': oa_base_url + 'oa/face/recognition/old/search', //刷脸 转base64后上传
};