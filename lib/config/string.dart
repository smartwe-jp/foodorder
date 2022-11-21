class GString{
  //语言包 语言 key
  static String getToString(String languageCode, String stringTag) {
    // 语言包
    var languagePack;
    if (languageCode == 'JP') {
      languagePack = {
        "top_back_button":"言語",

        "show_price_front":"税込",
        "settlement_button":"お会計",
        "cancle_button":"すべてキャンセル",
        "tag_title":"お知らせ",
        "tag_content":"ショッピングカートを空にします?",
        "tag_button_yes":"はい",
        "tag_button_no":"いいえ",
        "tag_checkOut":"QRコードをスキャンしてください",

        "menu_dingtype_eatin":"店内",
        "menu_dingtype_takeout":"お持ち帰り",
        "menu_dingtype_title":"いらっしゃいませ",
        "menu_dingtype_title_tag":"店内またはお持ち帰りをお選びください",
        "menu_dingtype_eatin_tag":"店内でお召し上がりのお客様はこちら",
        "menu_dingtype_takeout_tag":"お持ち帰りのお客様はこちら",


        "cart_tag":"メニューをお選びください",

        "add_option_cart":"確認",
        "settlement_total_price":"合計",
        "settlement_small_ticket_tag":"領収書が必要ですのでこちらをご注文ください",
        //"settlement_payment_method":"以下のお支払い方法をご利用いただけます。",
        "settlement_payment_method":"現金を投入するか、QRコードをスキャンしてください。",
        "settlement_payment_method_only_cash":"現金を投入してください。",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"現金",
        "settlement_payment_method_study_qr":"QRコード決済",
        "settlement_payment_method_title":"お支払い方法のガイド",
        "settlement_back":"戻る",
        "settlement_confirmButton":"支払確定",
        "settlement_confirmButton_yes":"領収書発行",
        "settlement_confirmButton_no":"領収書不発行",
        "settlement_continueMoney":"请继续投币",
        "settlement_orderPrice":"お支払い金額",
        "settlement_putMoney":"お預り    ",
        "settlement_outMoney":"お釣り    ",
        "settlement_print_outprice_tag":"    お釣りを取って下さい  \r\n しばらくお待ちください",
        "settlement_print_tag":"しばらくお待ちください",
        "settlement_print_loading_tag":"少々お待ちください",
        "settlement_noprint_tag":"しばらくお待ちください",
        "settlement_change_method":"はい",
        "settlement_nopayment_error":"        支払いが失敗しました。  \r\n 他の支払い方法をお選ぶください。",
        "settlement_scancodenoopen_error":" 済みません、今度は現金でお願いします。",
        "settlement_scancodenochange_error":"済みません、他の支払い方法を選んでください。",

        "tag_print_content_paper_shortage":"用紙切れです、お近くのスタッフにお知らせください",
        "tag_print_content_paper_error":"故障、お近くのスタッフにお知らせください",
        "tag_print_button_yes":"処理済み",
        "tag_print_button_no":"印刷しない",

        "show_server_error":"しばらく経ってから、やり直してください",
        "show_put_money_error":"続けてコインを入れてください",
        "show_please_select_error":"メニューをお選びください",

        "settlement_top_title_cash":"現金",
        "settlement_top_title_qr":"バーコード決済",
        "settlement_top_title_card":"クレジットカード",
        "settlement_top_title_nfc":"タッチ決済",

        "select_payment_dining_title":"店内または持ち帰りをお選びください",
        "select_payment_type_title":"支払い方法をお選びください",

      };
    }else if(languageCode == 'CH'){
      languagePack = {
        "top_back_button":"言語",

        "show_price_front":"含税",
        "settlement_button":"结算",
        "cancle_button":"全部取消",
        "tag_title":"温馨提示",
        "tag_content":"您确定要清空购物车?",
        "tag_button_yes":"确定",
        "tag_button_no":"取消",
        "tag_checkOut":"请扫码",

        "menu_dingtype_eatin":"堂食",
        "menu_dingtype_takeout":"打包",
        "menu_dingtype_title":"欢迎光临",
        "menu_dingtype_title_tag":"请选择堂食或者打包",
        "menu_dingtype_eatin_tag":"堂食请点击此处",
        "menu_dingtype_takeout_tag":"打包请点击此处",

        "cart_tag":"请选择菜品",

        "add_option_cart":"确 认",
        "settlement_total_price":"合计",
        "settlement_small_ticket_tag":"确认领取小票",
        //"settlement_payment_method":"可以使用以下支付方法。",
        "settlement_payment_method":"请直接投入现金或扫码。",
        "settlement_payment_method_only_cash":"请直接投入现金。",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"现金",
        "settlement_payment_method_study_qr":"扫码支付",
        "settlement_payment_method_title":"支付方法指南",
        "settlement_back":"返回",
        "settlement_confirmButton":"确定支付",
        "settlement_confirmButton_yes":"要发票",
        "settlement_confirmButton_no":"不要发票",
        "settlement_continueMoney":"请继续投币",
        "settlement_orderPrice":"订单金额",
        "settlement_putMoney":"已投币    ",
        "settlement_outMoney":"找零    ",
        "settlement_print_outprice_tag":"请取出零钱,等待小票打印",
        "settlement_print_tag":"请等待小票打印",
        "settlement_print_loading_tag":"处理中，请稍候……",
        "settlement_noprint_tag":"请稍候~",
        "settlement_change_method":"确定",
        "settlement_nopayment_error":"支付失败，请选择其他方式支付",
        "settlement_scancodenoopen_error":"请选择现金支付。",
        "settlement_scancodenochange_error":"暂不支持该支付，请选择其他方式。",

        "tag_print_content_paper_shortage":"小票机缺纸，请联系工作人员",
        "tag_print_content_paper_error":"打印故障，请联系工作人员",
        "tag_print_button_yes":"已处理",
        "tag_print_button_no":"不打印",
        "show_server_error":"服务器错误请稍后重试",
        "show_put_money_error":"请继续投币",
        "show_please_select_error":"请选择",

        "settlement_top_title_cash":"现金",
        "settlement_top_title_qr":"扫码支付",
        "settlement_top_title_card":"信用卡",
        "settlement_top_title_nfc":"NFC支付",

        "select_payment_dining_title":"请选择堂食还是打包",
        "select_payment_type_title":"请选择支付方式",

      };
    }else if(languageCode == 'EN'){
      languagePack = {
        "top_back_button":"言語",

        "show_price_front":"Tax-In",
        "settlement_button":"Check out",
        "cancle_button":"Cancel all",
        "tag_title":"Reminder",
        "tag_content":"Are you sure you want to empty the shopping cart?",
        "tag_button_yes":"Yes",
        "tag_button_no":"No",
        "tag_checkOut":"Please scan QR code.",

        "menu_dingtype_eatin":"Eat in",
        "menu_dingtype_takeout":"Take out",
        "menu_dingtype_title":"Welcome",
        "menu_dingtype_title_tag":"Choose eat-in or takeout",
        "menu_dingtype_eatin_tag":"Click here for customers who eat in the store",
        "menu_dingtype_takeout_tag":"Click here for takeaway customers",

        "cart_tag":"Please select dishes",

        "add_option_cart":"Confirm",
        "settlement_total_price":"Total",
        "settlement_small_ticket_tag":"We need a receipt, so please order us",
        //"settlement_payment_method":"Please select a payment method for your order：",
        "settlement_payment_method":"Please insert money or scan QR code.",
        "settlement_payment_method_only_cash":"Please insert money.",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"Cash",
        "settlement_payment_method_study_qr":"QR Code Payments",
        "settlement_payment_method_title":"Guide to Payment Methods",
        "settlement_back":"Back",
        "settlement_confirmButton":"Comfirm payment",
        "settlement_confirmButton_yes":"Have a receipt",
        "settlement_confirmButton_no":"No receipt",
        "settlement_continueMoney":"请继续投币",
        "settlement_orderPrice":"Tatol amount",
        "settlement_putMoney":"Amount paid",
        "settlement_outMoney":"Change due",
        "settlement_print_outprice_tag":"Please take your change and receipt",
        "settlement_print_tag":"Please take your receipt.",
        "settlement_print_loading_tag":"Processing, please wait",
        "settlement_noprint_tag":"Please wait a moment.",
        "settlement_change_method":"Yes",
        "settlement_nopayment_error":"Payment failed, please choose another payment method.",
        "settlement_scancodenoopen_error":"Please select cash payment.",
        "settlement_scancodenochange_error":"Please choose another method。",

        "tag_print_content_paper_shortage":"System error. Please contact our staff.",
        "tag_print_content_paper_error":"System error. Please contact our staff.",
        "tag_print_button_yes":"已处理",
        "tag_print_button_no":"不打印",
        "show_server_error":"System error. Please contact our staff.",
        "show_put_money_error":"请继续投币",
        "show_please_select_error":"Please complete your order.",

        "settlement_top_title_cash":"Cash",
        "settlement_top_title_qr":"Code payment",
        "settlement_top_title_card":"Credit card",
        "settlement_top_title_nfc":"Tap to pay",

        "select_payment_dining_title":"Please choose Eat in or Take out",
        "select_payment_type_title":"Please choose your payment method",
      };
    }

    return languagePack[stringTag];
  }
}