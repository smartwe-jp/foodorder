import 'dart:async';
import 'dart:io';
import 'dart:ui';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/modules/TransitPage/controllers/transit_page_controller.dart';
import 'package:foodorder/app/services/ResetToHomeTimer.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'app/app_binding/app_bindings.dart';
import 'app/common/local/translation_service.dart';
import 'app/config/color.dart';
import 'app/routes/app_pages.dart';
import 'app/print_task/print_task_models.dart';
import 'app/print_failed/print_failed_models.dart';

class _NavBounceTrack {
  static String? lastRoute;
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await GetStorage.init();
    await Hive.initFlutter();
    // if (!Hive.isAdapterRegistered(61)) {
    //   Hive.registerAdapter(PrintJobAdapter());
    // }
    // if (!Hive.isAdapterRegistered(62)) {
    //   Hive.registerAdapter(PrintTaskAdapter());
    // }
    if (!Hive.isAdapterRegistered(63)) {
      Hive.registerAdapter(PrintRecordAdapter());
    }
    // await Hive.openBox<PrintJob>('print_jobs');
    // await Hive.openBox<PrintTask>('print_tasks');
    await Hive.openBox<PrintRecord>('print_records');
    // if (Platform.isAndroid) {
    //   //Firebase is not full supported on windows
    //   await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform,
    //   );
    //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    // }

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
                    initialRoute: Routes.HOME,
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
        // child: Scaffold(
        //   body: PrintImageGenerateWidget(
        //     contentBuilder: (context) {
        //       return HomeView();
        //       //return WindewsTestView();

        //     },
        //     onPictureGenerated: _onPictureGenerated,
        //   ),
        // ),
      ));
      //HttpOverrides.global = MyHttpOverrides();flutter
    });

    //隐藏状态栏导航栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }, (error, stackTrace) {
    //debugPrint('runZonedGuarded: Caught error in my root zone.:: $error');
    //final logger = Logger('main');
    Logger('main').info('-- Caught error in my root zone.:: $error --');
    // if (Platform.isAndroid) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
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

void routerCallback(Routing? value, ResetToHomeTimer resetTimer) {
  logI('-- routingCallback : prev ${value?.previous} current ${value?.current} --  --');
  if (value?.current == Routes.MENU_PAGE ||
      value?.current == Routes.SCANCODE_PAGE ||
      value?.current == Routes.SELECT_PAYMENT_PAGE ||
      value?.current == Routes.SELF_CHECKOUTSCANNINGCODE ||
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