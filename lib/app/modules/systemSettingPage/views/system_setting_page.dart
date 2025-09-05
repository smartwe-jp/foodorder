import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/systemSettingPage/controllers/system_setting_controller.dart';
import 'package:foodorder/app/modules/systemSettingPage/controllers/system_setting_page_controller.dart';
//import 'package:foodorder/app/modules/systemSettingPage/views/printer_list_page.dart';
import 'package:get/get.dart';

import '../../../services/PosCheckService.dart';

class SystemSettingPage extends GetView<SystemSettingPageController> {
  const SystemSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SystemSettingPageController>(builder: (logic) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 242, 242, 246),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Card(
            //elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: AppBar(
              title: Container(
                padding: const EdgeInsets.only(top: 10),
                child: const Text('システム設定',
                    style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
              leadingWidth: 120,
              leading: Container(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    Get.back(result: "setting-back");
                  },
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 32),
                        onPressed: () {
                          Get.back(result: "setting-back");
                        },
                      ),
                      Text(
                        '戻る',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: 26,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(top: 10),
              actions: [
                IconButton(
                  icon: const Icon(Icons.key, color: Colors.blue, size: 38),
                  onPressed: () {
                    logic.showSettingPassword();
                  },
                ),
                const SizedBox(width: 16),

                IconButton(
                  icon: const Icon(Icons.update, color: Colors.blue, size: 38),
                  onPressed: () {
                    logic.showDownloadingAlert();
                  },
                ),

                const SizedBox(width: 16)

              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            //spacing: 16,
            children: [
              //标题 ‘一般设定’
              const SizedBox(height: 16),
              Row(
                children: [
                  _areaTitle('一般設定'),
                  //version
                  const Spacer(),
                  Text(
                    "バージョン：${controller.local_version.value}",
                    style: const TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 20,
                        color: Colors.black54),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              _modeArea(logic.machineModeInfo),
              _setMenuDirection(logic.machineInfo.systemSettingInfo),
              _machineTypeArea(logic.machineInfo.systemSettingInfo),
              _allowReceiptArea(logic.machineInfo.systemSettingInfo),
              _setPrintPaperTxtSize(logic.machineInfo.systemSettingInfo),
              _setIsAllowReceiptMenu(logic.machineInfo.systemSettingInfo),
              _allowSettlementHome(logic.machineInfo.systemSettingInfo),
              if (Platform.isAndroid)
                _openRejishime(logic.machineInfo.systemSettingInfo),
              if (Platform.isAndroid)
                _cashDenominationSettingArea(
                    logic.machineInfo.systemSettingInfo),
              //标题 ‘プリンター設定’
              const SizedBox(height: 16),
              _areaTitle('プリンター設定'),
              //如果是Windows系统，显示USB打印机设置
              //if (Platform.isWindows) _usbPrinterSettingArea(logic.usbDevice),

              _printerSettingArea(logic.machineInfo.printerList),

              //外设设置
              const SizedBox(height: 16),
              _areaTitle('外部連携設定'),
              _callScreenSettingArea(logic.machineInfo),
              _posMachineSettingArea(logic.machineInfo),

              //SSE设置
              const SizedBox(height: 16),
              _areaTitle('注文連携設定'),
              _sseSettingArea(List<Map>.from(logic.machineInfo.sseSettingList)),


              const SizedBox(height: 44),
            ],
          ),
        ),
      );
    });
  }

  Widget _areaTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 22,
            color: Color.fromARGB(255, 83, 82, 82),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _settingTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black),
    );
  }

  Widget _settingContentSubtitle(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontFamily: 'NotoSansJP',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _settingSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        fontFamily: 'NotoSansJP',
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: Color(0xFFD90000),
      ),
    );
  }

  Widget _settingContent(String content, {Color color = Colors.black54}) {
    return Text(
      content.isEmpty ? '未設定' : content,
      style: TextStyle(
        fontFamily: 'NotoSansJP',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: content.isEmpty ? Colors.red : color,
      ),
    );
  }

  Widget _modeArea(Map modeInfo) {
    bool isSellOn = modeInfo['sell'] ?? false;
    bool isTakeoutOn = modeInfo['takeout'] ?? false;
    bool isCheckoutOn = modeInfo['checkout'] ?? false;
    bool isScanbuyOn = modeInfo['scanbuy'] ?? false;

    //实现一个Card模式的选择设置区域，上方标题 分割线 下方是四个按钮 使用Wrap容器。每个Item 选中显示边框。
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingTitle('モード設定'),
            const Divider(),
            SizedBox(
              width: double.infinity, // 让Wrap撑满
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 20.0,
                runSpacing: 8.0,
                children: [
                  _modeButton("店　内", Icons.store, isSellOn,
                          () => controller.updateMachineMode(sell: !isSellOn)),
                  _modeButton(
                      'テイクアウト',
                      Icons.takeout_dining,
                      isTakeoutOn,
                          () =>
                          controller.updateMachineMode(takeout: !isTakeoutOn)),
                  _modeButton(
                      "精算機",
                      Icons.qr_code,
                      isCheckoutOn,
                          () => controller.updateMachineMode(
                          checkout: !isCheckoutOn)),
                  _modeButton(
                      "スキャン購入",
                      Icons.barcode_reader,
                      isScanbuyOn,
                          () =>
                          controller.updateMachineMode(scanbuy: !isScanbuyOn)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(
      String label, IconData icon, bool isSelected, VoidCallback onPressed) {
    //每个Item 选中显示边框 不要使用 ElevatedButton 因为需要设置高宽
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 80,
        width: 230,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            Expanded(
              child: AutoSizeText(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setMenuDirection(Map systemSettingInfo) {
    String menuDirection = systemSettingInfo['menuDirection'] ?? '0';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _settingTitle('カテゴリ様式'),
            //实现一个类似iOS SegmentedControl的效果
            ClipRRect(
              //borderRadius: BorderRadius.circular(16),
              child: CupertinoSegmentedControl<String>(
                children: {
                  '1': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text('上に横に',
                        style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            color: menuDirection == '1'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                  '2': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text('左に縦に',
                        style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            color: menuDirection == '2'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                },
                groupValue: menuDirection,
                onValueChanged: (value) {
                  // 更新 menuDirection
                  controller.checkMenuDirection(value);
                },
                borderColor: Colors.blue, // 更细腻的边框色
                selectedColor: Colors.blue, // 选中背景蓝色
                unselectedColor: Colors.white, // 未选中白色
                //pressedColor: Colors.blue,  // 按下时淡蓝色
                padding: const EdgeInsets.all(2), // 外部留白
              ),
            )
          ],
        ),
      ),
    );
  }

  //machine type
  Widget _machineTypeArea(Map systemSettingInfo) {
    String machineType = systemSettingInfo['panelType'] ?? 'Mini';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _settingTitle('マシンタイプ'),
            //实现一个类似iOS SegmentedControl的效果
            ClipRRect(
              child: CupertinoSegmentedControl<String>(
                children: {
                  'Mini': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text('Mini',
                        style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            color: machineType == 'Mini'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                  'Max': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text('Max',
                        style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            color: machineType == 'Max'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600)),
                  ),
                },
                groupValue: machineType,
                onValueChanged: (value) {
                  // 更新 machineType
                  controller.checkPanelType(value);
                },
                borderColor: Colors.blue, // 更细腻的边框色
                selectedColor: Colors.blue, // 选中背景蓝色
                unselectedColor: Colors.white, // 未选中白色
                padding: const EdgeInsets.all(2), // 外部留白
              ),
            )
          ],
        ),
      ),
    );
  }

  //Allow Receipt
  // ...existing code...

  //Allow Receipt
  Widget _allowReceiptArea(Map systemSettingInfo) {
    String isAllowReceipt = systemSettingInfo['isAllowReceipt'] ?? '1';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _settingTitle('領収書'),
                ClipRRect(
                  child: CupertinoSegmentedControl<String>(
                    children: {
                      '1': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Text('発　行',
                            style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: 20,
                                color: isAllowReceipt == '1'
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                      '2': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Text('お客様選択',
                            style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: 20,
                                color: isAllowReceipt == '2'
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    },
                    groupValue: isAllowReceipt,
                    onValueChanged: (value) {
                      controller.checkIsAllowReceipt(value);
                    },
                    borderColor: Colors.blue,
                    selectedColor: Colors.blue,
                    unselectedColor: Colors.white,
                    padding: const EdgeInsets.all(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _settingSubtitle("注：現金でお支払いの場合の設定です。他のお支払い方法の場合は全て「発行」となります。"),
          ],
        ),
      ),
    );
  }

  //setPrintPaperTxtSize
  /// 打印菜单部分文字大小设置
  Widget _setPrintPaperTxtSize(Map systemSettingInfo) {
    String printPaperTxtSize = systemSettingInfo['printPaperTxtSize'] ?? '1';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _settingTitle('印刷文字サイズ'),
            _settingSubtitle("（セルフレジから）"),
            Spacer(),
            ClipRRect(
              child: CupertinoSegmentedControl<String>(
                children: {
                  '1': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      '普　通',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 20,
                        color: printPaperTxtSize == '1'
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  '2': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      '大',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 20,
                        color: printPaperTxtSize == '2'
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  '3': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      '特　大',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 20,
                        color: printPaperTxtSize == '3'
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                },
                groupValue: printPaperTxtSize,
                onValueChanged: (value) {
                  controller.checkPrintPaperTxtSize(value);
                },
                borderColor: Colors.blue,
                selectedColor: Colors.blue,
                unselectedColor: Colors.white,
                padding: const EdgeInsets.all(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //setIsAllowReceiptMenu
  Widget _setIsAllowReceiptMenu(Map systemSettingInfo) {
    String isAllowReceiptMenu = systemSettingInfo['isAllowReceiptMenu'] ?? '1';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _settingTitle('オーダーシート'),
                const SizedBox(height: 12),
                ClipRRect(
                  child: CupertinoSegmentedControl<String>(
                    children: {
                      '2': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Text(
                          'プリントしない',
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            color: isAllowReceiptMenu == '2'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      '1': Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: Text(
                          'プリントする',
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            color: isAllowReceiptMenu == '1'
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    },
                    groupValue: isAllowReceiptMenu,
                    onValueChanged: (value) {
                      controller.checkIsAllowReceiptMenu(value);
                    },
                    borderColor: Colors.blue,
                    selectedColor: Colors.blue,
                    unselectedColor: Colors.white,
                    padding: const EdgeInsets.all(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _settingSubtitle("注：券売機モードはキッチンプリンターを設置した場合、プリントする必要はありません。"),
          ],
        ),
      ),
    );
  }

  //setIsAllowSettlementHome
  Widget _allowSettlementHome(Map settingInfo) {
    String isAllowBackHome = settingInfo['isAllowBackHome'] ?? '0';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _settingTitle('会計完了後の画面'),
            const Spacer(),
            ClipRRect(
              child: CupertinoSegmentedControl<String>(
                children: {
                  '0': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'トップページ', //に戻る
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 20,
                        color:
                        isAllowBackHome == '0' ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  '1': Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'メニューリスト', //に戻る
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 20,
                        color:
                        isAllowBackHome == '1' ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                },
                groupValue: isAllowBackHome,
                onValueChanged: (value) {
                  controller.checkIsAllowBackHome(value);
                },
                borderColor: Colors.blue,
                selectedColor: Colors.blue,
                unselectedColor: Colors.white,
                padding: const EdgeInsets.all(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //setOpenRejishime

  Widget _openRejishime(Map settingInfo) {
    String isAllowRejishime = settingInfo['isAllowRejishime'] ?? '0';

    return Card(
        color: Colors.white,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _settingTitle('レジ締め'),
              const Spacer(),
              ClipRRect(
                child: CupertinoSegmentedControl<String>(
                  children: {
                    '0': Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Text(
                        'オフ',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: 20,
                          color: isAllowRejishime == '0'
                              ? Colors.white
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    '1': Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Text(
                        'オン',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: 20,
                          color: isAllowRejishime == '1'
                              ? Colors.white
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  },
                  groupValue: isAllowRejishime,
                  onValueChanged: (value) {
                    controller.checkIsAllowRejishime(value);
                  },
                  borderColor: Colors.blue,
                  selectedColor: Colors.blue,
                  unselectedColor: Colors.white,
                  padding: const EdgeInsets.all(2),
                ),
              ),
            ],
          ),
        ));
  }

  //Cash Allow Setting card
  /// 币种使用设置パネル
  Widget _cashDenominationSettingArea(Map settingInfo) {
    // 币种列表
    final List<Map<String, dynamic>> denominations = [
      //一円
      {
        'label': '一円',
        'key': 'isAllow1',
        'value': settingInfo['isAllowOneYen'] ?? '0',
        'onChanged': (bool val) => controller.checkIsAllowOneYen(val),
      },
      {
        'label': '五千円',
        'key': 'isAllow5000',
        'value': settingInfo['isAllow5000'] ?? '0',
        'onChanged': (bool val) => controller.checkIsAllow5000Yen(val),
      },
      {
        'label': '一万円',
        'key': 'isAllow10000',
        'value': settingInfo['isAllow10000'] ?? '0',
        'onChanged': (bool val) => controller.checkIsAllow10000Yen(val),
      },
    ];

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '現金使用設定',
              style: TextStyle(
                fontFamily: 'NotoSansJP',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(),
            SizedBox(
              width: double.infinity, // 让Wrap撑满
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 20,
                runSpacing: 16,
                children: denominations.map((item) {
                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item['label'],
                          style: const TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(),
                        Switch(
                          value: item['value'] == '1',
                          onChanged: item['onChanged'],
                          activeColor: Colors.blue,
                        ),
                        Text(
                          item['value'] == '1' ? '使える' : '使えない',
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: 16,
                            color:
                            item['value'] == '1' ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

//when is windows will add a additional card for printer settings
// only one card as other settings

  // Widget _usbPrinterSettingArea(Map usbPrinterInfo) {
  //   return Card(
  //     color: Colors.white,
  //     margin: const EdgeInsets.all(8),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _settingTitle('USBプリンター設定'),
  //           const Divider(),
  //           // USBプリンター設定内容
  //           if (usbPrinterInfo.isNotEmpty)
  //           //显示名称和打印按钮
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 _settingContent(usbPrinterInfo["productName"], color: Colors.blue),
  //                 const SizedBox(height: 8),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     controller.printTest(
  //                         SearchType.usb,
  //                         usbPrinterInfo["productName"] ?? "productName",
  //                         usbPrinterInfo["sId"] ?? "sId");
  //                   },
  //                   child: const Text('テスト印刷'),
  //                 ),
  //               ],
  //             )
  //           else
  //           //显示一个搜索按钮
  //             Container(
  //               alignment: Alignment.centerLeft,
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Get.dialog(PrinterListPage(
  //                     searchType: SearchType.usb,
  //                     currentPrinter: controller.curUsbPrinter?.id,
  //                     onPrinterSelected: (device) => {
  //                       controller.setUsbPrinter(usbPrinter: device.usbDevice)
  //                     },
  //                   ));
  //                 },
  //                 child: const Text('USBプリンターを検索'),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

//打印机设置区域 数据来自 printerList
  Widget _printerSettingArea(List printerList) {
    // 新增一个“追加”按钮卡片
    final List printersWithAdd = List.from(printerList);
    //..add({'isAddButton': true});

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ネットワークプリンター設定',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    _settingSubtitle("注：「キッチンプリンター」か「キッチン（ラベル）プリンター」かどちらか１台のご利用となります。"),
                  ],
                ),


                GestureDetector(
                  onTap: () {
                    controller.addCustomPrinter();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '追加',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Icon(Icons.add, color: Colors.blue, size: 40),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 每行两个
                childAspectRatio: 1.96,
                crossAxisSpacing: 20,
                mainAxisSpacing: 16,
              ),
              itemCount: printersWithAdd.length,
              itemBuilder: (context, index) {
                final printer = printersWithAdd[index];
                return _printerCard(printer);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 打印机卡片
  Widget _printerCard(Map printer) {
    final name = printer['name'] ?? '未命名プリンター'; // 打印机名称
    final type = printer['type'] ?? 0; // 打印机类型
    final receipt = printer['receipt'] ?? 0; // 打印机类型 0 小票 1 标签
    final labelSize = printer['labelSize'] ?? '300x225'; // 标签宽度
    final labelWidth = int.parse(labelSize.split('x')[0] ?? "40"); // 标签宽度
    final continuous = printer['continuous'] ?? 0; // 连续打印 0 单票 1 连票
    final isOff = printer['isOff'] ?? false; // 是否开启打印机
    final printIp = printer['printIp'] ?? ""; // 打印机IP
    final printPort = printer['printPort'] ?? ""; // 打印机端口
    final printDirection = printer['direction'] ?? 0; // 打印方向 0 正 1 逆
    //bool printOption = printer['option'] ?? false; // 打印选项
    bool isSingleMode = type == 11 || receipt == 1;
    bool needSetting = printIp.isEmpty || printPort.isEmpty;
    bool isDefaultPrinter = printer['isDefault'] ?? true; // 是否默认打印机

    return Container(
      decoration: BoxDecoration(
        //color 乳白色 是什么颜色值？
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'NotoSansJP',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              if (!needSetting)
                Row(
                  children: [
                    Text(
                      isOff ? 'オフ' : 'オン',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 16,
                        color: isOff ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Switch(
                      value: !isOff,
                      onChanged: (val) {
                        // 这里需要调用 controller.updatePrinterState
                        controller.updatePrinterState(type, receipt, !val);
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.blue),
                onPressed: () {
                  // 打开设置页面
                  controller.showPrintSettingDialog(type, receipt, continuous,
                      printerIp: printIp, port: printPort);
                },
              )
            ],
          ),
          const Divider(),

          Row(
            children: [
              _settingContent('アドレス：'),
              Spacer(),
              _settingContent(printIp, color: Colors.blue),
              _settingContent(':'),
              _settingContent(printPort, color: Colors.blue),
              //テストバタン
              const SizedBox(width: 8),
              if (!needSetting)
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.blue),
                  onPressed: () {
                    controller.printTest(printIp, printPort,
                        printType: receipt, labelWidth: labelWidth.toDouble());
                  },
                ),//SearchType.net,
            ],
          ),
          if (!isSingleMode) const SizedBox(height: 8),
          //打印种类 单票 连票 使用segment 选择器
          if (!isSingleMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _settingContent('プリント種類：'),
                const SizedBox(width: 12),
                CupertinoSegmentedControl<int>(
                  children: {
                    0: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Text(
                        '单票',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: 14,
                          color: continuous == 0 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    1: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Text(
                        '连票',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: 14,
                          color: continuous == 1 ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  },
                  groupValue: continuous,
                  onValueChanged: (value) {
                    controller.updatePrinterInfo(type, receipt,
                        continuous: value);
                  },
                  borderColor: Colors.blue,
                  selectedColor: Colors.blue,
                  unselectedColor: Colors.white,
                  padding: const EdgeInsets.all(2),
                ),
              ],
            ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _settingContent('方向：'),
              const SizedBox(width: 12),
              CupertinoSegmentedControl<int>(
                children: {
                  0: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      'デフォルト',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 14,
                        color: printDirection == 0 ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      '逆に',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 14,
                        color: printDirection == 1 ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                },
                groupValue: printDirection,
                onValueChanged: (value) {
                  controller.updatePrinterInfo(type, receipt, direction: value);
                },
                borderColor: Colors.blue,
                selectedColor: Colors.blue,
                unselectedColor: Colors.white,
                padding: const EdgeInsets.all(2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (receipt == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _settingContent('ラベル幅: '),
                _setLabelPrintSize(type, receipt, labelSize),
              ],
            ),

          // if is Default Printer can delete add a button
          if (!isDefaultPrinter)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await showDialog(
                      context: Get.context!,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("削除確認"),
                          content: Text("このプリンター設定を削除しますか？"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("キャンセル"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                controller.removePrinter(printer);
                              },
                              child: Text("削除する"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            )
        ],
      ),
    );
  }

  _setLabelPrintSize(int type, int receipt, String size) {
    final _labelPrintSize = {
      "60x30": "460x225",
      "50x30": "384x225",
      "40x30": "300x225",
      "60x40": "460x300",
      "50x40": "384x300",
      "40x40": "300x300",
      "60x50": "460x375",
      "50x50": "384x375",
      "40x50": "300x375"
    };
    //size 是 value 找到对应的 key
    String? labelSizeKey = _labelPrintSize.keys.firstWhere(
            (key) => _labelPrintSize[key] == size,
        orElse: () => "40x30" // 默认值
    );

    return Container(
        child: Container(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 160,
            child: DropdownButtonFormField<String>(
              value: labelSizeKey,
              onChanged: (String? newValue) {
                final printSize = _labelPrintSize[newValue] ?? "300x225";
                controller.updatePrinterInfo(type, receipt, printSize: printSize);
              },
              items:
              _labelPrintSize.keys.map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(
                    key,
                    style: TextStyle(
                      color: labelSizeKey == key
                          ? ColorsUtil.hexToColor("#409eff")
                          : Colors.black,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              isExpanded: true,
            ),
          ),
        ));
  }

  //外设关联设置 分别是叫号屏幕 和 POS 机器 都是通过网络连接的方式进行设置
  //首先是叫号屏幕设置
  Widget _callScreenSettingArea(MachineInfoController machineInfo) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingTitle('呼び出し画面設定'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _settingContent('アドレス：'),
                _settingContent(machineInfo.wlan_panel_print_ip, color: Colors.blue),
                _settingContent(':'),
                _settingContent(machineInfo.wlan_panel_print_port, color: Colors.blue),
                Spacer(),
                if (machineInfo.wlan_panel_print_ip.isNotEmpty &&
                    machineInfo.wlan_panel_print_port.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _settingContent('有効にする', color: machineInfo.isAllowScreenCall ? Colors.blue : Colors.grey),
                      const SizedBox(width: 8),
                      Switch(
                        value: machineInfo.isAllowScreenCall,
                        onChanged: (value) {
                          controller.updateScreenCallSetting(
                            isAllowScreenCall: value,
                          );
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.blue),
                  onPressed: () {
                    controller.showScreenCallSettingDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //pos 机器设置
  Widget _posMachineSettingArea(MachineInfoController machineInfo) {
    final posCheckService = Get.find<PosCheckService>();
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingTitle('キャッシュレス端末'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _settingContent('アドレス：'),
                _settingContent(machineInfo.pos_ip, color: Colors.blue),
                _settingContent(':'),
                _settingContent(machineInfo.pos_port, color: Colors.blue),
                Spacer(),
                if (machineInfo.pos_ip.isNotEmpty &&
                    machineInfo.pos_port.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _settingContent('有効にする', color: machineInfo.allowPos ? Colors.blue : Colors.grey),
                      const SizedBox(width: 8),
                      Switch(
                        value: machineInfo.allowPos,
                        onChanged: (value) {
                          controller.updatePosSetting(
                            isAllowPos: value,
                          );
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                const SizedBox(width: 20),

                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.blue),
                  onPressed: () {
                    controller.showPosSettingDialog();
                  },
                ),
              ],
            ),
            if (machineInfo.allowPos)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  ElevatedButton(onPressed: (){
                    controller.posTest(machineInfo.pos_ip, machineInfo.pos_port);
                  }, child: const Text('端末テスト')),
                  // Spacer(),
                  //
                  // _settingContent('端末チェック', color: posCheckService.isActive ? Colors.blue : Colors.grey),
                  // const SizedBox(width: 8),
                  // Switch(
                  //   value: posCheckService.isActive,
                  //   onChanged: (value) {
                  //     posCheckService.toggleActive(value);
                  //     controller.update();
                  //   },
                  //   activeColor: Colors.blue,
                  // ),
                  //SizedBox(width: 65)
                ],
              ),
          ],
        ),
      ),
    );
  }


  //订单关联设置 为设置SSE消息接收，和打印机设置类似。

  Widget _sseSettingArea(List<Map> sseSettingList) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingTitle('SSE設定'),
            const Divider(),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 每行两个
                childAspectRatio: 2.3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 16,
              ),
              itemCount: sseSettingList.length,
              itemBuilder: (context, index) {
                final sseItem = sseSettingList[index];
                return _sseCard(sseItem);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sseCard(Map sseItem) {
    final name = sseItem['name'] ?? '';
    final identify = sseItem['identify'] ?? '';
    final isOn = sseItem['isOn'] ?? false;
    final needInput = sseItem['needInput'] ?? false;
    final needCenterPrint = sseItem['needCenterPrint'] ?? false;
    final centerOn = sseItem['centerOn'] ?? false;
    final printOption = sseItem['printOption'] ?? true;
    final address = sseItem['address'] ?? "";

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _settingContentSubtitle(name),
              const Spacer(),

              if (!needInput || identify.isNotEmpty)
                Row(
                  children: [
                    Text(
                      isOn ? 'オン' : 'オフ',
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: 16,
                        color: isOn ? Colors.blue : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: isOn,
                      onChanged: (value) {
                        // controller.updateSSESetting(
                        //   name,
                        //   isOn: value,
                        //   identify: identify,
                        //   centerOn: value ? centerOn : false,
                        // );
                        controller.updateSSESetting(name, identify: identify, isOn: value, centerOn: value == true ? centerOn : false);
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),

              if (needInput)
                const SizedBox(width: 8),


              if (needInput)
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.blue),
                  onPressed: () {
                    controller.editSSESetting(name, address, identify, isOn);
                  },
                ),

            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _settingContent('番号：'),
              _settingContent(identify ?? '', color: Colors.blue),
            ],
          ),

          const SizedBox(height: 8),

          if (isOn && needCenterPrint)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _settingContent('注文伝票：'),
                Switch(
                  value: centerOn,
                  onChanged: (value) {
                    controller.updateSSESetting(name, centerOn: value);
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),

          const SizedBox(height: 8),

          if (isOn && centerOn && !needInput)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _settingContent('オプション：'),
                Switch(
                  value: printOption,
                  onChanged: (value) {
                    controller.updateSSESetting(name, printOption: value);
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),


        ],
      ),
    );
  }


}
