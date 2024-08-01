import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/setting/views/RecycleButton.dart';
import 'package:foodorder/app/modules/setting/views/setting_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

extension CycleCashSettingView on SettingView {
  cycleCashSetting() {
    final cashListInfo = controller.cashInfoList.value;

    return Container(
        child: Column(children: [
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: ScreenAdapter.height(20)),
        //padding: EdgeInsets.only(bottom: ScreenAdapter.width(20)),
        child: Text("お預り金/釣り状態(NO.${controller.machineCode.value})",
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: ScreenAdapter.fontSize(22),
              fontWeight: FontWeight.w600,
              color: ColorsUtil.hexToColor("#000000"),
            )),
      ),
      Table(
          border: TableBorder.all(
            color: Colors.grey.shade400,
            width: 1.0,
          ),
          columnWidths: const <int, TableColumnWidth>{
            0: FixedColumnWidth(100),
          },
          children: [
            TableRow(children: [
              Container(
                height: 80,
                alignment: Alignment.center,
                child: Text("金种",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              ...cashListInfo.entries.map((element) {
                return Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text("${element.key}",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(20),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )),
                );
              }).toList()
            ]),
            TableRow(children: [
              Container(
                height: 80,
                alignment: Alignment.center,
                child: Text("枚数",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: ScreenAdapter.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#000000"),
                    )),
              ),
              ...cashListInfo.entries.map((element) {
                return Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text("${element.value['remaining']}",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(20),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )),
                );
              }).toList()
              ]
            )
          ]
        ),

        Table(
          border: TableBorder.all(
            color: Colors.grey.shade400,
            width: 1.0,
          ),
          columnWidths: const <int, TableColumnWidth>{
            0: FixedColumnWidth(100),
          },
          children: [
              TableRow(
                children: [
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Text("操作",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(20),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  ),

                  controller.isAllowRejishime.value ? 
                  RecycleButton(title: "レジ締め", onPressed: (){
                    controller.showRejishimeiView();
                  },) : 
                  RecycleButton(title: "預り金回収", onPressed: (){
                    controller.showRecycleAlert();
                  },),
                  
                  RecycleButton(title: "両替", onPressed: (){
                    
                  },) 

                ]
              )
            
          ]
        )
    
       ]
      )
    );
  }
}
