class GImage{
  static String getImageString(String shopInfo, String stringTag) {
    // 图片data包
    var imagePack;
    if (shopInfo == 'kanran') {
      imagePack = {
        "home":"assets/images/kanran/home.png",
        "logo":"assets/images/kanran/logo.png",
      };
    }else if (shopInfo == 'sanfeng') {
      imagePack = {
        "home":"assets/images/sanfeng/home.png",
        "logo":"assets/images/sanfeng/logo.png",
      };
    }else if (shopInfo == 'rijindoujin') {
      imagePack = {
        "home":"assets/images/rijindoujin/home.png",
        "logo":"assets/images/rijindoujin/logo.png",

      };
    }else if (shopInfo == 'ichixianjia') {
      imagePack = {
        "home":"assets/images/ichixianjia/home.jpg",
        "logo":"assets/images/ichixianjia/logo.png",

      };
    }else if (shopInfo == 'gongcha') {
      imagePack = {
        "home":"assets/images/gongcha/home.png",
        "logo":"assets/images/gongcha/logo.png",

      };
    }else if (shopInfo == 'imgpublic') {
      imagePack = {
        "backbutton_top":"assets/images/public/backbutton_top.png",
        "checked_green":"assets/images/public/checked_green.png",
        "delOne":"assets/images/public/delOne.png",
        "home_button":"assets/images/public/home_button.png",
        "qiandaobutton":"assets/images/public/qiandaobutton.png",
        "menu_up":"assets/images/public/menu_up.png",
        "optionChecked":"assets/images/public/optionChecked.png",
        "price_tag":"assets/images/public/price_tag.png",
        "price_subtraction_tag":"assets/images/public/price_subtraction_tag.png",
        "printticketloading":"assets/images/public/printticketloading.gif",
        "redPutong":"assets/images/public/redPutong.png",
        "saoma":"assets/images/public/saoma.jpg",
        "settlement_alipay":"assets/images/public/settlement_alipay.png",
        "settlement_back":"assets/images/public/settlement_back.png",
        "settlement_cash":"assets/images/public/settlement_cash.png",
        "settlement_paypay":"assets/images/public/settlement_paypay.png",
        "settlement_wechat":"assets/images/public/settlement_wechat.png",
        "xianjin":"assets/images/public/xianjin.jpg",
        "eatin":"assets/images/public/eatin.png",
        "takeout":"assets/images/public/takeout.png",
        "jingsuantag":"assets/images/public/jingsuantag.png",
        "error_public":"assets/images/public/error_public.jpg",
        "payment_cash":"assets/images/public/payment_cash.png",
        "payment_qr":"assets/images/public/payment_qr.png",
        "payment_card":"assets/images/public/payment_card.png",
        "payment_nfc":"assets/images/public/payment_nfc.png",
        "dining_away_checked":"assets/images/public/dining_away_checked.png",
        "dining_in_checked":"assets/images/public/dining_in_checked.png",
        "settlement_top_cash":"assets/images/public/settlement_top_cash.png",
        "settlement_top_qr":"assets/images/public/settlement_top_qr.png",
        "settlement_top_card":"assets/images/public/settlement_top_card.png",
        "settlement_top_nfc":"assets/images/public/settlement_top_nfc.png",
        "settlement_top_lead_qr":"assets/images/public/settlement_top_lead_qr.jpg",
        "settlement_top_lead_cash_JP":"assets/images/public/settlement_top_lead_cash_JP.png",
        "settlement_top_lead_card_JP":"assets/images/public/settlement_top_lead_card_JP.png",
        "settlement_top_lead_nfc_JP":"assets/images/public/settlement_top_lead_nfc_JP.png",
        "settlement_top_lead_cash_CH":"assets/images/public/settlement_top_lead_cash_CH.png",
        "settlement_top_lead_card_CH":"assets/images/public/settlement_top_lead_card_CH.png",
        "settlement_top_lead_nfc_CH":"assets/images/public/settlement_top_lead_nfc_CH.png",
        "settlement_top_lead_cash_EN":"assets/images/public/settlement_top_lead_cash_EN.png",
        "settlement_top_lead_card_EN":"assets/images/public/settlement_top_lead_card_EN.png",
        "settlement_top_lead_nfc_EN":"assets/images/public/settlement_top_lead_nfc_EN.png",

        "paymentSuccess":"assets/images/public/paymentSuccess.jpg",

      };
    }

    return imagePack[stringTag];
  }
}