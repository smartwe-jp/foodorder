class GImage{
  static String getImageString(String shopInfo, String stringTag) {
    // 图片data包
    var imagePack;
    if (shopInfo == 'kanran') {
      imagePack = {
        "backbutton_top":"assets/images/kanran/backbutton_top.png",
        "backloading":"assets/images/kanran/backloading.gif",
        "btn001":"assets/images/kanran/btn001.png",
        "btn002":"assets/images/kanran/btn002.png",
        "cargo_loading":"assets/images/kanran/cargo_loading.gif",
        "cart_bottom":"assets/images/kanran/cart_bottom.png",
        "category_selected":"assets/images/kanran/category_selected.png",
        "category_unselected":"assets/images/kanran/category_unselected.png",
        "checked_green":"assets/images/kanran/checked_green.png",
        "delOne":"assets/images/kanran/delOne.png",
        "dialog_close":"assets/images/kanran/dialog_close.png",
        "down":"assets/images/kanran/down.png",
        "home_button":"assets/images/kanran/home_button.png",
        "home":"assets/images/kanran/home.png",
        "load_error":"assets/images/kanran/load_error.png",
        "load_nodata":"assets/images/kanran/load_nodata.png",
        "logo":"assets/images/kanran/logo.png",
        "menu_up":"assets/images/kanran/menu_up.png",
        "newloading":"assets/images/kanran/newloading.gif",
        "optionChecked":"assets/images/kanran/optionChecked.png",
        "price_tag":"assets/images/kanran/price_tag.png",
        "printticket":"assets/images/kanran/printticket.gif",
        "printticketloading":"assets/images/kanran/printticketloading.gif",
        "public_dingshi_option":"assets/images/kanran/public_dingshi_option.png",
        "public_dingshi_submit":"assets/images/kanran/public_dingshi_submit.png",
        "public_index_option":"assets/images/kanran/public_index_option.png",
        "public_index_submit":"assets/images/kanran/public_index_submit.png",
        "redDafen":"assets/images/kanran/redDafen.png",
        "redPutong":"assets/images/kanran/redPutong.png",
        "saoma":"assets/images/kanran/saoma.jpg",
        "settlement_alipay":"assets/images/kanran/settlement_alipay.png",
        "settlement_back":"assets/images/kanran/settlement_back.png",
        "settlement_cash":"assets/images/kanran/settlement_cash.png",
        "settlement_paypay":"assets/images/kanran/settlement_paypay.png",
        "settlement_tag":"assets/images/kanran/settlement_tag.png",
        "settlement_wechat":"assets/images/kanran/settlement_wechat.png",
        "settlement_zhinan_cash":"assets/images/kanran/settlement_zhinan_cash.gif",
        "settlement_zhinan_qr":"assets/images/kanran/settlement_zhinan_qr.gif",
        "shouqing_jpep":"assets/images/kanran/shouqing.jpeg",
        "shouqing_png":"assets/images/kanran/shouqing.png",
        "up":"assets/images/kanran/up.png",
        "xianjin":"assets/images/kanran/xianjin.jpg",

      };
    }

    return imagePack[stringTag];
  }
}