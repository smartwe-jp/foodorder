

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class RecycleAlert extends StatelessWidget {
  // final String title;
  // final String content;
  final Function onConfirm;
  final Function onCancel;

  RecycleAlert({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(ScreenAdapter.width(20)),
              width: ScreenAdapter.width(500),
              height: ScreenAdapter.height(200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    alignment: Alignment.topLeft,
                    child: Text("ご注意",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(22),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                    alignment: Alignment.centerLeft,
                    child: Text("預り金を全回収してもよろしいですか？",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(22),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      Spacer(),
                      Container(
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorsUtil.hexToColor("#888888")),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:
                          TextButton(
                            child: Text("キャンセル",
                            style: TextStyle(
                              fontFamily:'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(18),
                            fontWeight: FontWeight.w400,
                            color: ColorsUtil.hexToColor("#000000"),
                            )),
                            onPressed: () {
                              onCancel();
                            },
                          ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#dca550"),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child:
                        TextButton(
                          child: Text("確認",
                                  style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(18),
                                  fontWeight: FontWeight.w400,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                          onPressed: () {
                            onConfirm();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
  }
}