const base_url = "https://admin-sit.kanran.co.jp/api/";  //测试环境地址
//const base_url = "https://new.gutingjun.com/api/";  //生产环境地址
const servicePath = {
  'webBootIndex': base_url + 'booking/web/boot/index', //获取首页菜单地址
  'webStockBooking': base_url + 'booking/web/boot/stock-booking', //限量请求地址
  'webBootOrder': base_url + 'booking/web/boot/order', //提交订单请求地址
  'webBootToPay': base_url + 'booking/web/boot/toPay', //支付提交请求地址
};