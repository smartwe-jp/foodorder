class GString{
  //语言包 语言 key
  static String getToString(String languageCode, String stringTag) {
    // 语言包
    var languagePack;
    if (languageCode == 'JP') {
      languagePack = {
        //"top_back_button":"言語",
        //"top_back_button":"ホーム",
        "top_back_button":"Language",

        "show_price_front":"税込",
        "show_original_price_front":"定価",
        "settlement_button":"お会計",
        "cancle_button":"すべてキャンセル",
        "tag_title":"お知らせ",
        "tag_content":"ショッピングカートを空にします?",
        "tag_button_yes":"はい",
        "tag_button_no":"いいえ",
        "tag_checkOut":"QRコードをスキャンしてください",

        "menu_dingtype_eatin":"店内",
        "menu_dingtype_takeout":"テイクアウト",
        "menu_dingtype_title":"いらっしゃいませ",
        "menu_dingtype_title_tag":"店内またはテイクアウトをお選びください",
        "menu_dingtype_eatin_tag":"店内でお召し上がりのお客様はこちら",
        "menu_dingtype_takeout_tag":"テイクアウトのお客様はこちら",


        "cart_tag":"メニューをお選びください",

        "add_option_cart":"確  認",
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
        "settlement_back_alertcontent":"お支払いを取り消ししますか？",
        "settlement_confirmButton":"支払い確定",
        "settlement_confirmButton_yes":"領収書発行",
        "settlement_confirmButton_no2":"支払い確定",
        "settlement_confirmButton_no":"領収書不発行",
        "settlement_orderPrice":"お支払い金額",
        "settlement_putMoney":"お預り    ",
        "settlement_outMoney":"お釣り    ",
        "settlement_print_outprice_tag":"    お釣りを取って下さい  \r\n しばらくお待ちください",
        "settlement_print_tag":"しばらくお待ちください",
        "settlement_print_loading_tag":"しばらくお待ちください",//少々お待ちください
        "settlement_noprint_tag":"しばらくお待ちください",
        "settlement_nopayment_error":"        支払いが失敗しました。  \r\n 他の支払い方法をお選ぶください。",
        "settlement_scancodenoopen_error":" 済みません、今度は現金でお願いします。",
        "settlement_scancodenochange_error":"済みません、他の支払い方法を選んでください。",
        "settlement_posPay_error":"決済失敗ので、別の支払方法にて取引を実施してください。",
        "settlement_posPay_error_connect_worker":"支払いが失敗しました。\r\n 他の支払い方法をお選ぶください。",//スタッフに連絡してください！
        "settlement_posPay_connect_error":"セルフレジは端末に接続されてません、スタフに聞いてお願いします。",
        "settlement_posPay_loadint_title":"支払処理中です、しばらくお待ち下さい。",

        "tag_print_content_paper_shortage":"用紙切れです、お近くのスタッフにお知らせください",
        "tag_print_content_paper_error":"故障、お近くのスタッフにお知らせください",
        "tag_print_button_yes":"処理済み",
        "tag_print_button_no":"印刷しない",

        "show_server_error":"しばらく経ってから、やり直してください",
        //"show_put_money_error":"続けてコインを入れてください",
        "show_please_select_error":"メニューをお選びください",

        "settlement_top_title_cash":"現金",
        "settlement_top_title_qr":"バーコード決済",
        "settlement_top_title_card":"クレジットカード",
        "settlement_top_title_wallet":"電子マネー",
        "settlement_top_title_nfc":"タッチ決済",

        "settlement_top_title_edy":"楽天Edy",
        "settlement_top_title_iD":"iD",
        "settlement_top_title_IC":"IC",
        "settlement_top_title_QUICPay":"QUICPay",
        "settlement_top_title_WAON":"WAON",
        "settlement_top_title_nanaco":"nanaco",

        "select_payment_dining_title":"店内または持ち帰りをお選びください",
        "select_payment_type_title":"支払い方法をお選びください",

        "payment_success_title":"支払完了いたしました",

        "show_storage_num_error":"この料理の在庫が不足しています",

        "show_del_cart_item_tag":"商品を削除しますか?",
        "show_del_cart_item_yes":"はい",
        "show_del_cart_item_no":"いいえ",

        "show_product_restrictions":"%%份限定",
        "show_check_tableno":"お席番号：",

        "select_checkOut_tip_title":"店内またはテイクアウトをお選びください",
        "select_checkOut_tip_selected":"                店内      \r\n（お食事後のお会計）",
        "checkoutScanTitle":"お会計",

        "menu_option_more_multipleState":"最大%%つまで",
        "menu_option_less_smallest":"%%をお選びください",
        "show_selectPay_point":"点",

        "select_selfservice_bag_title":"请选择是否需要袋子",
        "select_selfservice_nobag_title":"不要",
      };
    }else if(languageCode == 'CH'){
      languagePack = {
        //"top_back_button":"言語",
        //"top_back_button":"首页",
        "top_back_button":"Language",

        "show_price_front":"含税",
        "show_original_price_front":"原价",
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

        "add_option_cart":"确  认",
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
        "settlement_back_alertcontent":"您要取消支付吗？",
        "settlement_confirmButton":"确定支付",
        "settlement_confirmButton_yes":"要发票",
        "settlement_confirmButton_no2":"不要发票",
        "settlement_orderPrice":"订单金额",
        "settlement_putMoney":"已投币    ",
        "settlement_outMoney":"找零    ",
        "settlement_print_outprice_tag":"请取出零钱,等待小票打印",
        "settlement_print_tag":"请等待小票打印",
        "settlement_print_loading_tag":"请稍候~",//，请稍候
        "settlement_noprint_tag":"请稍候~",
        "settlement_nopayment_error":"支付失败，请选择其他方式支付",
        "settlement_scancodenoopen_error":"请选择现金支付。",
        "settlement_scancodenochange_error":"暂不支持该支付，请选择其他方式。",
        "settlement_posPay_error":"決済失敗ので、別の支払方法にて取引を実施してください。",
        "settlement_posPay_connect_error":"自助结账终端未连接，请向工作人员咨询。",
        "settlement_posPay_error_connect_worker":"支付失败,请联系工作人员！",
        "settlement_posPay_loadint_title":"支付处理中，请稍等片刻。",

        "tag_print_content_paper_shortage":"小票机缺纸，请联系工作人员",
        "tag_print_content_paper_error":"打印故障，请联系工作人员",
        "tag_print_button_yes":"已处理",
        "tag_print_button_no":"不打印",
        "show_server_error":"服务器错误请稍后重试",
        //"show_put_money_error":"请继续投币",
        "show_please_select_error":"请选择",

        "settlement_top_title_cash":"现金",
        "settlement_top_title_qr":"扫码支付",
        "settlement_top_title_card":"信用卡",
        "settlement_top_title_wallet":"电子钱包",
        "settlement_top_title_nfc":"NFC支付",

        "settlement_top_title_edy":"楽天Edy",
        "settlement_top_title_iD":"iD",
        "settlement_top_title_IC":"IC",
        "settlement_top_title_QUICPay":"QUICPay",
        "settlement_top_title_WAON":"WAON",
        "settlement_top_title_nanaco":"nanaco",

        "select_payment_dining_title":"请选择堂食还是打包",
        "select_payment_type_title":"请选择支付方式",

        "payment_success_title":"支付成功!",

        "show_storage_num_error":"此菜品库存数量不足",

        "show_del_cart_item_tag":"是否要删除商品？",
        "show_del_cart_item_yes":"删除",
        "show_del_cart_item_no":"不删除",

        "show_product_restrictions":"%%份限定",
        "show_check_tableno":"桌号：",
        "select_checkOut_tip_title":"请选择结账或者外卖",
        "select_checkOut_tip_selected":"结账",
        "checkoutScanTitle":"结账",

        "menu_option_more_multipleState":"最多%%个",
        "menu_option_less_smallest":"请选择%%",
        "show_selectPay_point":"份",

        "select_selfservice_bag_title":"请选择是否需要袋子",
        "select_selfservice_nobag_title":"不要",
      };
    }else if(languageCode == 'EN'){
      languagePack = {
        //"top_back_button":"言語",
        //"top_back_button":"Home",
        "top_back_button":"Language",

        "show_price_front":"Tax-In",
        "show_original_price_front":"Orig",
        "settlement_button":"Check Out",
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
        "settlement_back_alertcontent":"Do you want to cancel the payment?",
        "settlement_confirmButton":"Confirm",
        "settlement_confirmButton_yes":"Have a receipt",
        "settlement_confirmButton_no":"No receipt",
        "settlement_confirmButton_no2":"No receipt",
        "settlement_orderPrice":"Tatol amount",
        "settlement_putMoney":"Amount paid",
        "settlement_outMoney":"Change due",
        "settlement_print_outprice_tag":"Please take your change and receipt",
        "settlement_print_tag":"Please take your receipt.",
        "settlement_print_loading_tag":"Processing……",//, please wait
        "settlement_noprint_tag":"Please wait a moment.",
        "settlement_nopayment_error":"Payment failed, please choose another payment method.",
        "settlement_scancodenoopen_error":"Please select cash payment.",
        "settlement_scancodenochange_error":"Please choose another method。",
        "settlement_posPay_error":"決済失敗ので、別の支払方法にて取引を実施してください。",
        "settlement_posPay_error_connect_worker":"Payment failed. Please contact the staff!",
        "settlement_posPay_connect_error":"The self-checkout is not connected to the terminal. Please ask the staff for assistance.",
        "settlement_posPay_loadint_title":"Payment processing. Please wait for a moment.",

        "tag_print_content_paper_shortage":"System error. Please contact our staff.",
        "tag_print_content_paper_error":"System error. Please contact our staff.",
        "tag_print_button_yes":"已处理",
        "tag_print_button_no":"不打印",
        "show_server_error":"System error. Please contact our staff.",
        //"show_put_money_error":"请继续投币",
        "show_please_select_error":"Please complete your order.",

        "settlement_top_title_cash":"Cash",
        "settlement_top_title_qr":"Code Payment",
        "settlement_top_title_card":"Credit Card",
        "settlement_top_title_wallet":"E-Wallet",
        "settlement_top_title_nfc":"Tap to pay",

        "settlement_top_title_edy":"楽天Edy",
        "settlement_top_title_iD":"iD",
        "settlement_top_title_IC":"IC",
        "settlement_top_title_QUICPay":"QUICPay",
        "settlement_top_title_WAON":"WAON",
        "settlement_top_title_nanaco":"nanaco",

        "select_payment_dining_title":"Please choose Eat in or Take out",
        "select_payment_type_title":"Please select a payment method",

        "payment_success_title":"Payment succeeded.",

        "show_storage_num_error":"Out of stock",

        "show_del_cart_item_tag":"Remove item？",
        "show_del_cart_item_yes":"Yes",
        "show_del_cart_item_no":"No",

        "show_product_restrictions":"LIMIT %%",
        "show_check_tableno":"Table No.",
        "select_checkOut_tip_title":"Choose in-store or takeout",
        "select_checkOut_tip_selected":"Check out",
        "checkoutScanTitle":"Bill",

        "menu_option_more_multipleState":"Up to %% maximum",
        "menu_option_less_smallest":"Please select %%",
        "show_selectPay_point":"",

        "select_selfservice_bag_title":"请选择是否需要袋子",
        "select_selfservice_nobag_title":"不要",
      };
    }else if(languageCode == 'KO'){
      languagePack = {
        //"top_back_button":"言語",언어
        //"top_back_button":"첫장",//首页
        "top_back_button":"Language",

        "show_price_front":"세금 포함",//含税
        "show_original_price_front":"원가",
        "settlement_button":"합의",
        "cancle_button":"모두 취소",
        "tag_title":"친절한 팁",
        "tag_content":"장바구니를 비우시겠습니까?",
        "tag_button_yes":"확정",
        "tag_button_no":"취소",
        "tag_checkOut":"스캔해 주세요",//请扫码

        "menu_dingtype_eatin":"식사",//堂食
        "menu_dingtype_takeout":"테이크아웃",//打包
        "menu_dingtype_title":"환영",
        "menu_dingtype_title_tag":"매장 내 식사 또는 테이크아웃을 선택하세요.",
        "menu_dingtype_eatin_tag":"식사는 여기를 클릭하십시오",
        "menu_dingtype_takeout_tag":"테이크아웃여기를 클릭",

        "cart_tag":"요리를 선택해주세요",

        "add_option_cart":"확인",
        "settlement_total_price":"총",
        "settlement_small_ticket_tag":"영수증 확인",
        //"settlement_payment_method":"다음 지불 방법을 사용할 수 있습니다",
        "settlement_payment_method":"직접 현금을 넣거나 QR 코드를 스캔하세요.",
        "settlement_payment_method_only_cash":"현금으로 직접 입금해주세요",
        "settlement_payment_method_cash":"Cash",
        "settlement_payment_method_paypay":"PayPay",
        "settlement_payment_method_wechat":"WeChat Pay",
        "settlement_payment_method_alipay":"Alipay",
        "settlement_payment_method_study_cash":"현금",
        "settlement_payment_method_study_qr":"스캔 코드 결제",
        "settlement_payment_method_title":"결제수단 안내",
        "settlement_back":"반품",
        "settlement_back_alertcontent":"결제를 취소하시겠습니까?",
        "settlement_confirmButton":"결제 확인",
        "settlement_confirmButton_yes":"영수증 발행",
        "settlement_confirmButton_no":"결제 확인",
        "settlement_confirmButton_no2":"결제 확인",
        "settlement_orderPrice":"주문금액",
        "settlement_putMoney":"입금완료   ",
        "settlement_outMoney":"거스름돈을 주다",
        "settlement_print_outprice_tag":"거스름돈을 꺼내고 영수증을 기다리세요",
        "settlement_print_tag":"영수증을기다리세요",
        "settlement_print_loading_tag":"처리 중...",//처리중이니 기다려주세요
        "settlement_noprint_tag":"기다리세요.",
        "settlement_nopayment_error":"결제에 실패했습니다. 다른 결제 수단을 선택하세요.",
        "settlement_scancodenoopen_error":"현금결제를 선택해주세요",
        "settlement_scancodenochange_error":"지금은 결제가 되지 않습니다. 다른 결제 수단을 선택하세요.",
        "settlement_posPay_error":"決済失敗ので、別の支払方法にて取引を実施してください。",
        "settlement_posPay_error_connect_worker":"결제가 실패했습니다. 직원에게 연락하세요.",
        "settlement_posPay_connect_error":"셀프 레지는 단말기에 연결되어 있지 않습니다. 직원에게 문의해 주세요.",
        "settlement_posPay_loadint_title":"결제 처리 중입니다. 잠시 기다려 주세요.",

        "tag_print_content_paper_shortage":"영수증 기계에 용지가 없습니다. 직원에게 문의하십시오.",
        "tag_print_content_paper_error":"인쇄 실패, 직원에게 문의하십시오.",
        "tag_print_button_yes":"처리됨",
        "tag_print_button_no":"인쇄 불가",
        "show_server_error":"서버 오류입니다. 나중에 다시 시도하십시오.",
        //"show_put_money_error":"계속 현금을 넣어주세요",
        "show_please_select_error":"선택하세요",

        "settlement_top_title_cash":"현금",
        "settlement_top_title_qr":"스캔 코드 결제",
        "settlement_top_title_card":"신용카드",
        "settlement_top_title_wallet":"전자지갑",
        "settlement_top_title_nfc":"NFC지블",

        "settlement_top_title_edy":"楽天Edy",
        "settlement_top_title_iD":"iD",
        "settlement_top_title_IC":"IC",
        "settlement_top_title_QUICPay":"QUICPay",
        "settlement_top_title_WAON":"WAON",
        "settlement_top_title_nanaco":"nanaco",

        "select_payment_dining_title":"매장 내 식사 또는 테이크아웃을 선택하세요.",
        "select_payment_type_title":"결제 방법을 선택해주세요",

        "payment_success_title":"결제 성공",

        "show_storage_num_error":"재고 부족",

        "show_del_cart_item_tag":"상품을 삭제하시겠습니까?",
        "show_del_cart_item_yes":"삭제합니다",
        "show_del_cart_item_no":"삭제하지 않음",

        "show_product_restrictions":"%%개한정판매",
        "show_check_tableno":"좌석 번호",
        "select_checkOut_tip_title":"매장 내 또는 포장 주문하시겠어요",
        "select_checkOut_tip_selected":"체크아웃",
        "checkoutScanTitle":"계산하다",

        "menu_option_more_multipleState":"최대 %%개까지",
        "menu_option_less_smallest":"%% 선택해주세요",
        "show_selectPay_point":"점",

        "select_selfservice_bag_title":"请选择是否需要袋子",
        "select_selfservice_nobag_title":"不要",
      };
    }

    return languagePack[stringTag];
  }
}