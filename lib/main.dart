import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;




import 'app/app_binding/app_bindings.dart';
import 'app/common/local/translation_service.dart';
import 'app/config/color.dart';
import 'app/config/printer_info.dart';
import 'app/controllers/app_config.dart';
import 'app/modules/TransitPage/controllers/transit_page_controller.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/routes/app_pages.dart';

import 'package:firebase_core/firebase_core.dart';
import 'app/services/CustomLogerHandler.dart';
import 'app/services/ResetToHomeTimer.dart';
import 'firebase_options.dart';

class _NavBounceTrack {
  static String? lastRoute;
}

//打印图层生成成功
Future<void> _onPictureGenerated(PicGenerateResult imgData) async {
  //final imageBytes = imgdata.data;
  final printTask = imgData.taskItem;

  //指定的打印机
  final printerInfo = printTask.params as PrinterInfo;
  //打印票据类型（标签、小票）
  final printTypeEnum = printTask.printTypeEnum;

  final imageBytes = await imgData.convertUint8List(imageByteFormat:ImageByteFormat.rawRgba);
  //也可以使用 ImageByteFormat.png
  final argbWidth = imgData.imageWidth;
  final argbHeight = imgData.imageHeight;
  if (imageBytes == null) {
    return;
  }

  var printData = await printerPlus.PrinterCommandTool.generatePrintCmd(
    imgData: imageBytes,
    printType: printTypeEnum,
    argbWidthPx: argbWidth,
    argbHeightPx: argbHeight,
  );

  // 网络 打印
  final conn = printerPlus.NetConn(printerInfo.ip!);
  print("打印机连接地址：${printerInfo.ip}");
  conn.writeMultiBytes(printData);

}

void main() {
  runZonedGuarded(() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GetStorage.init();

    Get.putAsync<AppConfig>(() async {
      final config = AppConfig();
      await config.onInit(); // Assume init() is an async method
      return config;
    });

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    WidgetsFlutterBinding.ensureInitialized(); //强制竖屏必须要添加这个进行初始化 否则下面会错误
    await CustomLogHandler.initializeLogging();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
      runApp(
        ScreenUtilInit(
            designSize: const Size(1080, 1920),   //设计稿的宽度和高度 px
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context , child) {
              return  GlobalEventListener(
                  appBuilder: (context, resetTimer) => GetMaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: "券売君",
                    theme: ThemeData(
                      primaryColor: Gcolor.primaryColor, // 设置主体颜色
                    ),
                    home: child,
                    //initialRoute: Routes.HOME,
                    //initialRoute: AppPages.INITIAL,
                    //配置ios动画
                    locale: Locale('ja', 'JP'), // 默认语言
                    fallbackLocale: Locale('ja', 'JP'), // 备用语言
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('zh', 'CH'),
                      Locale('en', 'US'),
                      Locale('ko', 'KR'),
                      Locale('ja', 'JP'),
                    ],
                    translations: TranslationService(),
                    defaultTransition: Transition.fadeIn,
                    getPages: AppPages.routes,
                    initialBinding: AppBindings(),
                    routingCallback: (value) {
                      routerCallback(value, resetTimer);
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
                  },
                  onPictureGenerated: _onPictureGenerated,
                ),
              ),
            )
      );
    });

    //隐藏状态栏导航栏
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.immersive, overlays: []);


  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.:$error');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

void routerCallback(Routing? value, ResetToHomeTimer resetTimer) {
  logI('-- routingCallback : prev ${value?.previous} current ${value?.current} --  --');
  if (value?.current == Routes.MENU_PAGE ||
      value?.current == Routes.SCANCODE_PAGE ||
      value?.current == Routes.SELECT_PAYMENT_PAGE ||
      (value?.current == Routes.CHECKOUT_PAGE && Platform.isAndroid)
  ) {
    resetTimer.startTimer();
  } else if (value?.current == Routes.ORDER_HOME ||
      value?.current == Routes.SETTLEMENT ||
      value?.current == Routes.SETTING || value?.current == '/SettingView') {
    resetTimer.cancelTimer();
  }

  //检测是否从 checkout 返回 transit，若是则立即纠正回 checkout
  final cur = value?.current;
  final prev = value?.previous;
  final isTransit = cur == Routes.TRANSIT_PAGE;
  final isFromCheckout = prev == Routes.CHECKOUT_PAGE;
  if (isTransit && isFromCheckout) {
    // 用 microtask，确保控制器已就绪
    logI('--forcing return to Checkout 1--');
    Future.microtask(() {
      if (Get.isRegistered<TransitPageController>()) {
        Get.find<TransitPageController>().getIsShowCashInfo();
      } else {
        logI('--TransitPageController not registered--');
        Get.offNamedUntil('/transit-page', (route) => route.isFirst);
      }
    });
  } else {
    final last = _NavBounceTrack.lastRoute;
    final fromCheckoutBySnapshot = last == Routes.CHECKOUT_PAGE;

    if (isTransit && fromCheckoutBySnapshot) {
      logI('--forcing return to Checkout 2--');
      Future.microtask(() {
        if (Get.isRegistered<TransitPageController>()) {
          Get.find<TransitPageController>().getIsShowCashInfo();
        } else {
          logI('--TransitPageController not registered--');
          Get.offNamedUntil('/transit-page', (route) => route.isFirst);
        }
      });
    }
  }
  _NavBounceTrack.lastRoute = cur;
}