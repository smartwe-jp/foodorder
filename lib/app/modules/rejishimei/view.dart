import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/rejishimei/logic.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:foodorder/app/widget/num_pad.dart';
import 'package:get/get.dart';

class RejishimeView extends StatelessWidget {
  RejishimeView({Key? key, this.isRejishime = true}) : super(key: key);

  final bool isRejishime;
  //final SettingController settingController;

  late final RejishimeLogic logic =
      Get.put(RejishimeLogic(isRegisterClose: isRejishime));
  get state => logic.state;

  final TextEditingController _verifyCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<RejishimeLogic>(
          assignId: true,
          init: logic,
          builder: (logic) {
            return Center(
                child: SimpleDialog(
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      width: ScreenAdapter.width(680),
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(30),
                          right: ScreenAdapter.width(30),
                          bottom: ScreenAdapter.height(30)),
                      child: state.isSelected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "確認コードはメール アドレス ${state.selectMail} に送信されました。",
                                  style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(26),
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  child: SizedBox(
                                    height: 70,
                                    child: Center(
                                        child: TextField(
                                      controller: _verifyCodeController,
                                      textAlign: TextAlign.center,
                                      showCursor: false,
                                      style: TextStyle(
                                        fontFamily: GFont.getFontFamily(),
                                        fontSize: 40,
                                        //fontFamily: GFont.getFontFamily(),
                                      ),
                                      // Disable the default soft keybaord
                                      keyboardType: TextInputType.none,
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(24),
                                          fontFamily: GFont.getFontFamily(),
                                        ),
                                        hintText: "4桁のコードを入力してください",
                                        //border: InputBorder.none
                                      ),
                                    )),
                                  ),
                                ),
                                NumPad(
                                  buttonSize: 70,
                                  buttonColor: ColorsUtil.hexToColor("#f1f3f4"),
                                  iconColor: ColorsUtil.hexToColor("#9C9C9C"),
                                  controller: _verifyCodeController,
                                  textLength: 4,
                                  delete: () {
                                    _verifyCodeController.text =
                                        _verifyCodeController.text.substring(
                                            0,
                                            _verifyCodeController.text.length -
                                                1);
                                  },
                                  // do something with the input numbers
                                  onSubmit: () {
                                    if (_verifyCodeController.text.length < 4) {
                                      showToast("正しいコードを入力してください");
                                      return;
                                    }
                                    if (_verifyCodeController.text.length > 4) {
                                      showToast("コード最大4ビット");
                                      _verifyCodeController.text =
                                          _verifyCodeController.text
                                              .substring(0, 3);
                                      return;
                                    }
                                    state.verifyCode =
                                        _verifyCodeController.text;
                                    if (isRejishime) {
                                      logic.requestShimeInfo(
                                          _verifyCodeController.text,
                                          logic.machineCode);
                                    } else {
                                      Get.back();
                                      logic.recycleCash();
                                    }
                                  },
                                ),
                              ],
                            )
                          : requestView(),
                    ),
                    Positioned(
                      right: ScreenAdapter.width(5),
                      child: InkWell(
                        highlightColor: Colors.transparent, // 透明色
                        splashColor: Colors.transparent, // 透明色
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close_outlined,
                          color: ColorsUtil.hexToColor("#000000"),
                          size: 40.0,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ));
          }),
    );
  }

  Widget requestView() {
    return Container(
      height: 500.w,
      child: Stack(
        children: [
          //请求的列表
          Container(
            child: _mailList(),
          ),
          if (state.isRequesting)
            // Expanded(
            //   child:
            Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: CircularProgressIndicator()),
          // )
        ],
      ),
    );
  }

  Widget _mailList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      child: Column(
        children: [
          Text(
            'メールアドレスを選択してください',
            style: TextStyle(
              fontSize: ScreenAdapter.fontSize(26),
              fontFamily: GFont.getFontFamily(),
              color: ColorsUtil.hexToColor("#000000"),
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          Expanded(
              child: state.mailInfo.length == 0 && !state.isRequesting
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () {
                          state.isRequesting = true;

                          logic.loadMailAddress();
                        },
                        child: Text('再取得',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w400)),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.mailInfo.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return TextButton(
                          onPressed: () {
                            state.selectMail =
                                state.mailInfo[index]['verifyEmail'] ?? "";
                            state.selectUser =
                                state.mailInfo[index]['verifyUserName'] ?? "";

                            logic.requestVerifyCode();
                          },
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                      state.mailInfo[index]['verifyEmail'] ??
                                          "",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: GFont.getFontFamily(),
                                          fontWeight: FontWeight.w400))),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    right: 10, left: 10, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      offset: Offset(4, 3),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Text('選択',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: GFont.getFontFamily(),
                                        fontWeight: FontWeight.w400)),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
        ],
      ),
    );
  }
}
