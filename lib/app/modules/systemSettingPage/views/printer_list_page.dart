import 'dart:async';
import 'dart:ffi';
import 'package:flutter_printer_plus/flutter_printer_plus.dart';

import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/common/loading_widget.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class PrinterListPage extends StatefulWidget {
  final SearchType searchType;
  final Function(PrinterInfo device) onPrinterSelected;
  final String? currentPrinter;

  const PrinterListPage(
      {required this.searchType, required this.onPrinterSelected, this.currentPrinter});

  @override
  State<PrinterListPage> createState() => _PrinterListPageState();
}

class _PrinterListPageState extends State<PrinterListPage> {
  //查询本地USB打印机列表
  Future<List<PrinterInfo>> queryLocalUSBPrinter() {
    return FlutterPrinterFinder.queryUsbPrinter().then(
      (value) => value.map((e) => PrinterInfo.fromUsbDevice(e)).toList(),
    );
  }

  //搜索网络打印机
  Future<List<PrinterInfo>> queryNetPrinters() async {
    return FlutterPrinterFinder.queryPrinterIp().then(
      (value) => value.map((e) => PrinterInfo(ip: e)).toList(),
    );
  }

  Future<List<PrinterInfo>> queryPrinter() {
    if (widget.searchType == SearchType.usb) {
      return queryLocalUSBPrinter();
    } else {
      return queryNetPrinters();
    }
  }

  Widget _printerList(List<PrinterInfo> data, {String? currentPrinter}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      child: 
      
      data.isEmpty
          ? const Center(
              child: Text('没有找到打印机,请检查网络或者USB连接'),
            )
          :
      ListView.separated(
        shrinkWrap: true,
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          return _PrinterItemWidget(
            printerInfo: data[index],
            onPrinterSelected: widget.onPrinterSelected,
            currentPrinter: currentPrinter,);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return //Scaffold(
      // appBar: AppBar(
      //   title: const Text('usb打印机列表'),
      // ),
      //body:
    SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        children: [
        Container(
          padding: EdgeInsets.all(10),
          width: ScreenAdapter.width(700),
          height: ScreenAdapter.height(800),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    // Expanded(
                    //   child: 
                      Container(
                        alignment: Alignment.center,
                        child: Text('打印机列表', style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(20.0),
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                    ),
                    //),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: FutureBuilder(
                    future: queryPrinter(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          //查询出错了
                          return const Center(
                            child: Text('查询出错了'),
                          );
                        } else {
                          return _printerList(snapshot.data, currentPrinter: widget.currentPrinter);
                        }
                      } else {
                        return const LoadingWidget();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        )  
        ]
    );
  }
}

class _PrinterItemWidget extends StatelessWidget {
  final PrinterInfo printerInfo;
  final Function onPrinterSelected;
  final String? currentPrinter;

  _PrinterItemWidget(
      {required this.printerInfo, required this.onPrinterSelected, this.currentPrinter});
  
  bool? get isSelected {
    if (printerInfo.isNetPrinter) {
      return printerInfo.ip == currentPrinter ? true : false;
    } else if (printerInfo.isUsbPrinter) {
      print("printerInfo: ${printerInfo.usbDevice?.id}");
      print("currentPrinter: ${currentPrinter}");
      return printerInfo.usbDevice?.id == currentPrinter ? true : false;
    } else {
      return false;
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(child: Text(printerInfo.name)),
        TextButton(
          onPressed: () {
            if (isSelected == false) {
              onPrinterSelected(printerInfo);
            }
            Navigator.of(context).pop();
          },
          child: Text('${isSelected == true ? '已选择' : '选择'}'),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}

enum SearchType {
  net,
  usb,
}
