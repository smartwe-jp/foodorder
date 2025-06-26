import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/CustomButton.dart';
import '../controllers/system_setting_page_controller.dart';


class SetPrinterView extends StatefulWidget {

  final String name;
  final int printerType;
  final bool isDefault;
  final bool isAdd;
  final String printerIp;
  final int selectedPrintType;
  final int receiptType; // 0:, 1:Label
  final Map notSelectedPrinterMap;

  SetPrinterView({Key? key,
    this.isAdd = false,
    this.name = "",
    this.printerType = 0,
    this.isDefault = false,
    this.printerIp = "192.168.1.10",
    this.selectedPrintType = 0,
    this.receiptType = 0, // 0:paper, 1:Label
    this.notSelectedPrinterMap = const {},
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SetPrinterViewState();
  }

}

class _SetPrinterViewState extends State<SetPrinterView> {

  final TextEditingController textEditingController1 = TextEditingController();
  final TextEditingController textEditingController2 = TextEditingController();
  final SystemSettingPageController controller = Get.find();

  late int _selectedPrintType;
  late String _selectedValue; // 默认选择单票打印


  @override
  void initState() {
    if (!widget.isDefault) {
      _selectedValue = widget.notSelectedPrinterMap.keys.first;
    }

    _selectedPrintType = widget.selectedPrintType;
    textEditingController1.text = widget.name;
    textEditingController2.text = widget.printerIp;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
      return SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding: const EdgeInsets.all(0),
        children: [
          Stack(
            children: [
              Container(
                  width: ScreenAdapter.width(700),
                  height: ScreenAdapter.height(500),
                  padding: EdgeInsets.only(
                      left: ScreenAdapter.width(40),
                      top: ScreenAdapter.height(30),
                      right: ScreenAdapter.width(20),
                      bottom: ScreenAdapter.height(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "プリンターを追加",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(32),
                            fontWeight: FontWeight.bold),
                      ),

                      SizedBox(height: 120),

                      //选择打印机类型来自subPrinterList，如果已经存在则不显示
                      if (!widget.isDefault)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("プリンタータイプ", style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24))),
                          SizedBox(width: ScreenAdapter.width(40)),
                          Expanded(
                              flex: 1,
                              child:
                              //实现下拉选择器 数据来自 notSelectedPrinterList
                              DropdownButton<String>(
                                value: _selectedValue.isEmpty
                                    ? widget.notSelectedPrinterMap.keys.first : _selectedValue,
                                isExpanded: true,
                                items: widget.notSelectedPrinterMap.entries
                                    .map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(24),
                                          color: ColorsUtil.hexToColor("#000000"),
                                          fontWeight: FontWeight.w600,
                                        )
                                    ), // 显示打印机名称
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedValue = newValue;
                                    });
                                  }
                                },
                              )
                          )
                        ],
                      ),

                      // if (!widget.isDefault)
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Text("名前", style: TextStyle(
                      //         fontSize: ScreenAdapter.fontSize(24))),
                      //     SizedBox(width: ScreenAdapter.width(40)),
                      //     Expanded(
                      //         flex: 1,
                      //         child: TextField(
                      //           controller: textEditingController1,
                      //           keyboardType: TextInputType.text,
                      //           decoration: InputDecoration(
                      //             hintStyle: TextStyle(
                      //                 fontSize: ScreenAdapter.fontSize(24)),
                      //             hintText: 'プリンターの名前',
                      //             //border: InputBorder.none
                      //           ),
                      //         )
                      //     )
                      //   ],
                      // ),

                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Text("IPアドレス",style: TextStyle(fontSize: ScreenAdapter.fontSize(24))),
                      //     SizedBox(width: ScreenAdapter.width(40)),
                      //     Expanded(
                      //         flex: 1,
                      //         child: TextField(
                      //           controller: textEditingController2,
                      //           keyboardType: TextInputType.text,
                      //           decoration: InputDecoration(
                      //             hintStyle: TextStyle(fontSize: ScreenAdapter.fontSize(24)),
                      //             hintText: "192.168.1.10",
                      //             //border: InputBorder.none
                      //           ),
                      //         )
                      //     )
                      //   ],
                      // ),
                      //SizedBox(height: ScreenAdapter.height(20)),
                      // if (widget.receiptType == 0) // 0:紙, 1:ラベル
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Text("印刷タイプ", style: TextStyle(
                      //         fontSize: ScreenAdapter.fontSize(24))),
                      //     SizedBox(width: ScreenAdapter.width(40)),
                      //     Expanded(
                      //       flex: 1,
                      //       child: Wrap(
                      //         spacing: ScreenAdapter.width(20),
                      //         runSpacing: ScreenAdapter.height(20),
                      //         children: continusSettingButtons(),
                      //       ),
                      //     )
                      //   ],
                      // ),

                      const Spacer(),
                      Center(
                        child: SizedBox(
                          width: ScreenAdapter.width(200),
                          child: CustomButton(
                              title: "確認",
                              onTap: () async {
                                // if (textEditingController2.text.isEmpty) {
                                //   Get.snackbar("お知らせ",
                                //       "IPアドレスとポートを入力してください",
                                //       maxWidth: ScreenAdapter.width(500),
                                //       duration: const Duration(
                                //           milliseconds: 1500));
                                //   return;
                                // }
                                if (widget.isAdd) {
                                  controller.addSubPrinter(
                                      widget.notSelectedPrinterMap[_selectedValue],
                                      _selectedValue);
                                }
                                Get.back();

                              }),
                        )
                      ),
                      SizedBox(height: ScreenAdapter.height(20))
                    ],
                  )
              ),
              Positioned(
                right: ScreenAdapter.width(0),
                top: ScreenAdapter.height(0),
                child: InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.close_outlined,
                    color: ColorsUtil.hexToColor("#000000"),
                    size: 28.0,
                  ),
                ),
              )
            ],
          )
        ],
      );
  }


  List<Widget> continusSettingButtons() {
    return [
      InkWell(
        highlightColor: Colors.transparent, // 透明色
        splashColor: Colors.transparent, // 透明色
        onTap: (){
          setState(() {
            _selectedPrintType = 0;
          });
        },
        child: Container(
          margin: EdgeInsets.only(left: ScreenAdapter.width(10), right: ScreenAdapter.width(10)),
          //设置 child 居中
          alignment: const Alignment(0, 0),
          height: ScreenAdapter.height(55),
          width: ScreenAdapter.width(150),
          //边框设置
          decoration: BoxDecoration(
            //背景
            color: (_selectedPrintType == 0) ? ColorsUtil.hexToColor("#2699f4"):Colors.grey[200],
            //设置四周圆角 角度
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                    text: "オン",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(22.0),
                      color: (_selectedPrintType == 0) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                    ),
                    children: [
                      TextSpan(
                        text: "（単票）",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(22),
                          fontWeight: FontWeight.w400,
                          color: (_selectedPrintType == 0) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#d90000"),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
      InkWell(
        highlightColor: Colors.transparent, // 透明色
        splashColor: Colors.transparent, // 透明色
        onTap: (){
          setState(() {
            _selectedPrintType = 1;
          });

        },
        child: Container(
          margin: EdgeInsets.only(left: ScreenAdapter.width(10), right: ScreenAdapter.width(10)),
          //设置 child 居中
          height: ScreenAdapter.height(55),
          width: ScreenAdapter.width(150),
          //边框设置
          decoration: BoxDecoration(
            //背景
            color: (_selectedPrintType == 1) ? ColorsUtil.hexToColor("#2699f4"):Colors.grey[200],
            //设置四周圆角 角度
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                    text: "オン",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(22.0),
                      color: (_selectedPrintType == 1)? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                    ),
                    children: [
                      TextSpan(
                        text: "（連票）",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(22),
                          fontWeight: FontWeight.w400,
                          color: (_selectedPrintType == 1) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#d90000"),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    ];
  }

}
