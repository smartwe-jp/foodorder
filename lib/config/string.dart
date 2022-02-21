class GString{
  //语言包 语言 key
  static String getToString(String languageCode, String stringTag) {
    // 语言包
    var languagePack;
    if (languageCode == 'JP') {
      languagePack = {
        "show_price_front":"税込",
        "settlement_button":"お会計",
        "cancle_button":"すべてキャンセル",
        "tag_title":"お知らせ",
        "tag_content":"ショッピングカートを空にします?",
        "tag_button_yes":"はい",
        "tag_button_no":"いいえ",

        "cart_tag":"メニューをお選びください",

        "add_option_cart":"確認",
        "settlement_total_price":"合計",
        "settlement_small_ticket_tag":"領収書が必要ですのでこちらをご注文ください",
        "settlement_payment_method":"支払方法の選択",
        "settlement_payment_method_cash":"現金",
        "settlement_payment_method_qr":"QRコード決済",
        "settlement_back":"戻る",

      };
    }else if(languageCode == 'CH'){
      languagePack = {
        "show_price_front":"含税",
        "settlement_button":"结算",
        "cancle_button":"全部取消",
        "tag_title":"温馨提示",
        "tag_content":"您确定要清空购物车?",
        "tag_button_yes":"确定",
        "tag_button_no":"取消",

        "cart_tag":"请选择菜品",

        "add_option_cart":"确认",
        "settlement_total_price":"合计",
        "settlement_small_ticket_tag":"确认领取小票",
        "settlement_payment_method":"请选择支付方式",
        "settlement_payment_method_cash":"现金",
        "settlement_payment_method_qr":"扫码支付",
        "settlement_back":"返回",
      };
    }else if(languageCode == 'EN'){
      languagePack = {
        "show_price_front":"Tax included",
        "settlement_button":"Settlement",
        "cancle_button":"Cancel all",
        "tag_title":"Reminder",
        "tag_content":"Are you sure you want to empty the shopping cart?",
        "tag_button_yes":"Yes",
        "tag_button_no":"No",

        "cart_tag":"Please select dishes",

        "add_option_cart":"Confirm",
        "settlement_total_price":"Total",
        "settlement_small_ticket_tag":"We need a receipt, so please order us",
        "settlement_payment_method":"Payment method",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_qr":"QR code settlement",
        "settlement_back":"Back",
      };
    }

    return languagePack[stringTag];
  }
}