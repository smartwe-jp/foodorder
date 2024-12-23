import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/services/ResetToHomeTimer.dart';
import 'package:foodorder/app/services/customLogger.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;

import 'app/config/color.dart';
import 'app/config/printer_info.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/routes/app_pages.dart';

import 'firebase_options.dart';

//打印图层生成成功
Future<void> _onPictureGenerated(PicGenerateResult imgdata) async {
  //final imageBytes = imgdata.data;
  final printTask = imgdata.taskItem;

  //指定的打印机
  final printerInfo = printTask.params as PrinterInfo;
  print('printerInfo: $printerInfo');
  //打印票据类型（标签、小票）
  final printTypeEnum = printTask.printTypeEnum;

  final imageBytes =
      await imgdata.convertUint8List(imageByteFormat: ImageByteFormat.rawRgba);
  //也可以使用 ImageByteFormat.png
  final argbWidth = imgdata.imageWidth;
  final argbHeight = imgdata.imageHeight;
  if (imageBytes == null) {
    return;
  }
  if (imageBytes != null) {
    var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
      imgData: imageBytes,
      printType: printTypeEnum,
      argbWidthPx: argbWidth,
      argbHeightPx: argbHeight,
    );

    if (printerInfo.isUsbPrinter) {
      // usb 打印
      print('usb 打印');
      final conn = UsbConn(printerInfo.usbDevice!);
      conn.writeMultiBytes(printData, 1024 * 8);
    } else if (printerInfo.isNetPrinter) {
      // 网络 打印
      final conn = NetConn(printerInfo.ip!);
      conn.writeMultiBytes(printData);
    }

    // // 网络 打印
    // final conn = printerPlus.NetConn(printerInfo.ip!);
    // conn.writeMultiBytes(printData);
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await GetStorage.init();

    if (Platform.isAndroid) {
      //Firebase is not full supported on windows
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }

    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    WidgetsFlutterBinding.ensureInitialized(); //强制竖屏必须要添加这个进行初始化 否则下面会错误
    await CustomLogHandler.initializeLogging();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(ScreenUtilInit(
        designSize: const Size(1080, 1920), //设计稿的宽度和高度 px
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GlobalEventListener(
              appBuilder: (context, resetTimer) => GetMaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: "券売君",
                    theme: ThemeData(
                      primaryColor: Gcolor.primaryColor, // 设置主体颜色
                    ),
                    home: child,
                    //initialRoute: AppPages.INITIAL,
                    //配置ios动画
                    locale: Locale('jp', 'JP'), // 默认语言
                    fallbackLocale: Locale('jp', 'JP'), // 备用语言
                    defaultTransition: Transition.fadeIn,
                    getPages: AppPages.routes,
                    routingCallback: (value) {
                      debugPrint("routingCallback : ${value?.current}");
                      if (value?.current == Routes.MENU_PAGE ||
                          value?.current == Routes.SCANCODE_PAGE) {
                        resetTimer.startTimer();
                      } else if (value?.current == Routes.ENTRY_HOME ||
                          value?.current == Routes.SETTLEMENT ||
                          value?.current == Routes.SETTING) {
                        resetTimer.cancelTimer();
                      }
                    },
                    builder: (context, widget) {
                      return MediaQuery(
                        ///设置文字大小不随系统设置改变
                        data: MediaQuery.of(context)
                            .copyWith(textScaleFactor: 1.0),
                        child: FlutterEasyLoading(child: widget),
                      );
                    },
                  ));
        },
        child: Scaffold(
          body: PrintImageGenerateWidget(
            contentBuilder: (context) {
              return HomeView();
              //return WindewsTestView();
            },
            onPictureGenerated: _onPictureGenerated,
          ),
        ),
      ));
      //HttpOverrides.global = MyHttpOverrides();flutter
    });

    //隐藏状态栏导航栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }, (error, stackTrace) {
    //debugPrint('runZonedGuarded: Caught error in my root zone.:: $error');
    //final logger = Logger('main');
    Logger('main').info('-- Caught error in my root zone.:: $error --');
    if (Platform.isAndroid) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
