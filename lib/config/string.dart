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

        "cart_tag":"メニューをお選びください",

        "add_option_cart":"確認",
        "settlement_total_price":"合計",
        "settlement_small_ticket_tag":"領収書が必要ですのでこちらをご注文ください",
        //"settlement_payment_method":"以下のお支払い方法をご利用いただけます。",
        "settlement_payment_method":"直接、現金を投入するか、バーコードをスキャンしてください。",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"現金",
        "settlement_payment_method_study_qr":"QRコード決済",
        "settlement_payment_method_title":"支払方法のガイド",
        "settlement_back":"戻る",
        "settlement_confirmButton":"支払確定",
        "settlement_continueMoney":"请继续投币",
        "settlement_orderPrice":"買い上げ",
        "settlement_putMoney":"預かり    ",
        "settlement_outMoney":"お釣り    ",
        "settlement_print_outprice_tag":"    お釣りを取って下さい  \r\n しばらくお待ちください",
        "settlement_print_tag":"しばらくお待ちください",
        "settlement_noprint_tag":"しばらくお待ちください",
        "settlement_change_method":"はい",
        "settlement_nopayment_error":"        支払いが失敗しました。  \r\n 他の支払い方法をお選ぶください。",

        "tag_print_content_paper_shortage":"用紙切れです、お近くのスタッフにお知らせください",
        "tag_print_content_paper_error":"故障、お近くのスタッフにお知らせください",
        "tag_print_button_yes":"処理済み",
        "tag_print_button_no":"印刷しない",

        "show_server_error":"しばらく経ってから、やり直してください",
        "show_put_money_error":"続けてコインを入れてください",
        "show_please_select_error":"メニューをお選びください",

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

        "cart_tag":"请选择菜品",

        "add_option_cart":"确 认",
        "settlement_total_price":"合计",
        "settlement_small_ticket_tag":"确认领取小票",
        //"settlement_payment_method":"可以使用以下支付方法。",
        "settlement_payment_method":"请直接投入现金或扫码。",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"现金",
        "settlement_payment_method_study_qr":"扫码支付",
        "settlement_payment_method_title":"支付方法指南",
        "settlement_back":"返回",
        "settlement_confirmButton":"确定支付",
        "settlement_continueMoney":"请继续投币",
        "settlement_orderPrice":"订单金额",
        "settlement_putMoney":"已投币    ",
        "settlement_outMoney":"找零    ",
        "settlement_print_outprice_tag":"请取出零钱,等待小票打印",
        "settlement_print_tag":"请等待小票打印",
        "settlement_noprint_tag":"请稍候~",
        "settlement_change_method":"确定",
        "settlement_nopayment_error":"支付失败，请选择其他方式支付",


        "tag_print_content_paper_shortage":"小票机缺纸，请联系工作人员",
        "tag_print_content_paper_error":"打印故障，请联系工作人员",
        "tag_print_button_yes":"已处理",
        "tag_print_button_no":"不打印",
        "show_server_error":"服务器错误请稍后重试",
        "show_put_money_error":"请继续投币",
        "show_please_select_error":"请选择",

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

        "cart_tag":"Please select dishes",

        "add_option_cart":"Confirm",
        "settlement_total_price":"Total",
        "settlement_small_ticket_tag":"We need a receipt, so please order us",
        //"settlement_payment_method":"Please select a payment method for your order：",
        "settlement_payment_method":"Please insert money or scan QR code.",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"Cash",
        "settlement_payment_method_study_qr":"QR Code Payments",
        "settlement_payment_method_title":"Guide to Payment Methods",
        "settlement_back":"Back",
        "settlement_confirmButton":"Comfirm payment",
        "settlement_continueMoney":"请继续投币",
        "settlement_orderPrice":"Tatol amount",
        "settlement_putMoney":"Amount paid",
        "settlement_outMoney":"Change due",
        "settlement_print_outprice_tag":"Please take your change and receipt",
        "settlement_print_tag":"Please take your receipt.",
        "settlement_noprint_tag":"Please wait a moment.",
        "settlement_change_method":"Yes",
        "settlement_nopayment_error":"Payment failed, please choose another payment method.",

        "tag_print_content_paper_shortage":"System error. Please contact our staff.",
        "tag_print_content_paper_error":"System error. Please contact our staff.",
        "tag_print_button_yes":"已处理",
        "tag_print_button_no":"不打印",
        "show_server_error":"System error. Please contact our staff.",
        "show_put_money_error":"请继续投币",
        "show_please_select_error":"Please complete your order.",
      };
    }

    return languagePack[stringTag];
  }
}