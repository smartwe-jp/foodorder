class GString{
  //语言包 语言 key
  static String getToString(String languageCode, String stringTag) {
    // 语言包
    var languagePack;
    if (languageCode == 'jp') {
      languagePack = {
        "show_price_front":"税込",
        "settlement_button":"お会計",
        "cancle_button":"すべてキャンセル",
        "tag_title":"お知らせ",
        "tag_content":"ショッピングカートを空にします?",
        "tag_button_yes":"はい",
        "tag_button_no":"いいえ",

        "cart_tag":"メニューをお選びください",

        "add_option_cart":"確認"
      };
    }else if(languageCode == 'zh'){
      languagePack = {
        "show_price_front":"含税",
        "settlement_button":"结算",
        "cancle_button":"全部取消",
        "tag_title":"温馨提示",
        "tag_content":"您确定要清空购物车?",
        "tag_button_yes":"确定",
        "tag_button_no":"取消",

        "cart_tag":"请选择菜品",

        "add_option_cart":"确认"
      };
    }else if(languageCode == 'en'){
      languagePack = {
        "show_price_front":"Tax included",
        "settlement_button":"Settlement",
        "cancle_button":"Cancel all",
        "tag_title":"Reminder",
        "tag_content":"Are you sure you want to empty the shopping cart?",
        "tag_button_yes":"Yes",
        "tag_button_no":"No",

        "cart_tag":"Please select dishes",

        "add_option_cart":"Confirm"
      };
    }

    return languagePack[stringTag];
  }
}