class GImage{
  static String getImageString(String shopInfo, String stringTag) {
    // 图片data包
    var imagePack;
    /*if (shopInfo == 'kanran') {
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
    }else */
    if (shopInfo == 'imgpublic') {
      imagePack = {
        "backbutton_top":"assets/images/public/backbutton_top.png",
        "checked_green":"assets/images/public/checked_green.png",
        "delOne":"assets/images/public/delOne.png",
        "shouqing_png":"assets/images/public/shouqing.png",
        "shouqing_png_CH":"assets/images/public/shouqing_CH.png",
        "shouqing_png_EN":"assets/images/public/shouqing_EN.png",
        "shouqing_png_JP":"assets/images/public/shouqing_JP.png",
        "shouqing_png_KO":"assets/images/public/shouqing_KO.png",
        "home_button":"assets/images/public/home_button.png",
        "qiandaobutton":"assets/images/public/qiandaobutton.png",
        "menu_up":"assets/images/public/menu_up.png",
        "zong_menu_up":"assets/images/public/zong_menu_up.png",
        "optionChecked":"assets/images/public/optionChecked.png",
        "price_tag":"assets/images/public/price_tag.png",
        "price_subtraction_tag":"assets/images/public/price_subtraction_tag.png",
        "printticketloading":"assets/images/public/printticketloading.gif",
        "redPutong":"assets/images/public/redPutong.png",
        "saoma":"assets/images/public/saoma.jpg",
        "settlement_alipay":"assets/images/public/settlement_alipay.png",
        "settlement_back":"assets/images/public/settlement_back.png",
        "settlement_paypay":"assets/images/public/settlement_paypay.png",
        "settlement_aupay":"assets/images/public/settlement_allpay.png",
        "settlement_dpay":"assets/images/public/settlement_dpay.png",
        "settlement_rpay":"assets/images/public/settlement_rpay.png",
        "settlement_mpay":"assets/images/public/settlement_mpay.png",
        "settlement_wechat":"assets/images/public/settlement_wechat.png",
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
        "settlement_bottom_lead_cash_JP":"assets/images/public/settlement_bottom_lead_cash_JP.png",
        "settlement_top_lead_card_JP":"assets/images/public/settlement_top_lead_card_JP.png",
        "settlement_top_lead_nfc_JP":"assets/images/public/settlement_top_lead_nfc_JP.png",
        "settlement_top_lead_cash_CH":"assets/images/public/settlement_top_lead_cash_CH.png",
        "settlement_bottom_lead_cash_CH":"assets/images/public/settlement_bottom_lead_cash_CH.png",
        "settlement_top_lead_card_CH":"assets/images/public/settlement_top_lead_card_CH.png",
        "settlement_top_lead_nfc_CH":"assets/images/public/settlement_top_lead_nfc_CH.png",
        "settlement_top_lead_cash_EN":"assets/images/public/settlement_top_lead_cash_EN.png",
        "settlement_bottom_lead_cash_EN":"assets/images/public/settlement_bottom_lead_cash_EN.png",
        "settlement_top_lead_card_EN":"assets/images/public/settlement_top_lead_card_EN.png",
        "settlement_top_lead_nfc_EN":"assets/images/public/settlement_top_lead_nfc_EN.png",
        "settlement_top_lead_cash_KO":"assets/images/public/settlement_top_lead_cash_KO.png",
        "settlement_bottom_lead_cash_KO":"assets/images/public/settlement_bottom_lead_cash_KO.png",
        "settlement_top_lead_card_KO":"assets/images/public/settlement_top_lead_card_KO.png",
        "settlement_top_lead_nfc_KO":"assets/images/public/settlement_top_lead_nfc_KO.png",

        "paymentSuccess":"assets/images/public/paymentSuccess.jpg",
        "checkOut_checked":"assets/images/public/checkOut_checked.png",

        "settlement_edy":"assets/images/public/settlement_edy.png",
        "settlement_id":"assets/images/public/settlement_id.png",
        "settlement_nanaco":"assets/images/public/settlement_nanaco.png",
        "settlement_waon":"assets/images/public/settlement_waon.png",
        "settlement_quicpay":"assets/images/public/settlement_quicpay.png",
        "settlement_jiaotongxi":"assets/images/public/settlement_jiaotongxi.png",


        "menu_option_check":"assets/images/public/menu_option_check.png",

        "card_visa":"assets/images/public/card_visa.png",
        "card_jcb":"assets/images/public/card_jcb.png",
        "card_diners":"assets/images/public/card_diners.jpg",
        "card_american":"assets/images/public/card_american.jpg",
        "card_unionp":"assets/images/public/card_unionp.png",
        "card_master":"assets/images/public/card_master.png",
        "card_discover":"assets/images/public/card_discover.png",

        "settlement_top_lead_cash_JP":"assets/images/public/settlement_top_lead_cash_JP.png",
        "settlement_top_lead_cash_CH":"assets/images/public/settlement_top_lead_cash_CH.png",
        "settlement_top_lead_cash_EN":"assets/images/public/settlement_top_lead_cash_EN.png",
        "settlement_top_lead_nfc_KO":"assets/images/public/settlement_top_lead_nfc_KO.png",

        "settlement_top_lead_posEdy_JP":"assets/images/public/settlement_top_lead_posEdy_JP.png",
        "settlement_top_lead_posEdy_CH":"assets/images/public/settlement_top_lead_posEdy_CH.png",
        "settlement_top_lead_posEdy_EN":"assets/images/public/settlement_top_lead_posEdy_EN.png",
        "settlement_top_lead_posEdy_KO":"assets/images/public/settlement_top_lead_posEdy_KO.png",

        "settlement_top_lead_posID_JP":"assets/images/public/settlement_top_lead_posID_JP.png",
        "settlement_top_lead_posID_CH":"assets/images/public/settlement_top_lead_posID_CH.png",
        "settlement_top_lead_posID_EN":"assets/images/public/settlement_top_lead_posID_EN.png",
        "settlement_top_lead_posID_KO":"assets/images/public/settlement_top_lead_posID_KO.png",

        "settlement_top_lead_posIC_JP":"assets/images/public/settlement_top_lead_posIC_JP.png",
        "settlement_top_lead_posIC_CH":"assets/images/public/settlement_top_lead_posIC_CH.png",
        "settlement_top_lead_posIC_EN":"assets/images/public/settlement_top_lead_posIC_EN.png",
        "settlement_top_lead_posIC_KO":"assets/images/public/settlement_top_lead_posIC_KO.png",

        "settlement_top_lead_posQUICPay_JP":"assets/images/public/settlement_top_lead_posQUICPay_JP.png",
        "settlement_top_lead_posQUICPay_CH":"assets/images/public/settlement_top_lead_posQUICPay_CH.png",
        "settlement_top_lead_posQUICPay_EN":"assets/images/public/settlement_top_lead_posQUICPay_EN.png",
        "settlement_top_lead_posQUICPay_KO":"assets/images/public/settlement_top_lead_posQUICPay_KO.png",

        "settlement_top_lead_posWAON_JP":"assets/images/public/settlement_top_lead_posWAON_JP.png",
        "settlement_top_lead_posWAON_CH":"assets/images/public/settlement_top_lead_posWAON_CH.png",
        "settlement_top_lead_posWAON_EN":"assets/images/public/settlement_top_lead_posWAON_EN.png",
        "settlement_top_lead_posWAON_KO":"assets/images/public/settlement_top_lead_posWAON_KO.png",

        "settlement_top_lead_posNanaco_JP":"assets/images/public/settlement_top_lead_posNanaco_JP.png",
        "settlement_top_lead_posNanaco_CH":"assets/images/public/settlement_top_lead_posNanaco_CH.png",
        "settlement_top_lead_posNanaco_EN":"assets/images/public/settlement_top_lead_posNanaco_EN.png",
        "settlement_top_lead_posNanaco_KO":"assets/images/public/settlement_top_lead_posNanaco_KO.png",

        "safeScanback_JP":"assets/images/public/safeScanback_JP.jpg",
        "safeScanback_CH":"assets/images/public/safeScanback_CH.jpg",
        "safeScanback_EN":"assets/images/public/safeScanback_EN.jpg",
        "safeScanback_KO":"assets/images/public/safeScanback_KO.jpg",

        "safeScantop_JP":"assets/images/public/safeScantop_JP.jpg",
        "safeScantop_CH":"assets/images/public/safeScantop_CH.jpg",
        "safeScantop_EN":"assets/images/public/safeScantop_EN.jpg",
        "safeScantop_KO":"assets/images/public/safeScantop_KO.jpg",

        "cartItemCancel":"assets/images/public/cartItemCancel.png",

        "settlement_pos_loading_JP":"assets/images/public/settlement_pos_loading_JP.jpg",
        "settlement_pos_loading_CH":"assets/images/public/settlement_pos_loading_CH.jpg",
        "settlement_pos_loading_EN":"assets/images/public/settlement_pos_loading_EN.jpg",
        "settlement_pos_loading_KO":"assets/images/public/settlement_pos_loading_KO.jpg",
      };
    }

    return imagePack[stringTag];
  }
}