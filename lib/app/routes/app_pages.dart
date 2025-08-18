import 'package:get/get.dart';

import '../modules/Activation/bindings/activation_binding.dart';
import '../modules/Activation/views/activation_view.dart';
import '../modules/CheckoutPage/bindings/checkout_page_binding.dart';
import '../modules/CheckoutPage/views/ScanCode.dart';
import '../modules/CheckoutPage/views/checkout_page_view.dart';
import '../modules/ErrorPage/bindings/error_binding.dart';
import '../modules/ErrorPage/views/error_view.dart';
import '../modules/OrderHome/bindings/order_home_binding.dart';
import '../modules/OrderHome/views/order_home_view.dart';
import '../modules/SelfCheckoutscanningcode/bindings/self_checkoutscanningcode_binding.dart';
import '../modules/SelfCheckoutscanningcode/views/self_checkoutscanningcode_view.dart';
import '../modules/SelfservicePage/bindings/selfservice_page_binding.dart';
import '../modules/SelfservicePage/views/selfservice_page_view.dart';
import '../modules/TransitPage/bindings/transit_page_binding.dart';
import '../modules/TransitPage/views/transit_page_view.dart';
import '../modules/edit_page/view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/menuPage/bindings/menu_page_binding.dart';
import '../modules/menuPage/views/menu_page_view.dart';
import '../modules/menuPage/views/menuzong_page_view.dart';
import '../modules/middlewareSettingPage/bindings/middleware_setting_page_binding.dart';
import '../modules/middlewareSettingPage/views/middleware_setting_page_view.dart';
import '../modules/receiptQueryPrint/bindings/receipt_query_binding.dart';
import '../modules/receiptQueryPrint/views/receipt_query_view.dart';
import '../modules/reimburseOrder/bindings/reimburse_order_binding.dart';
import '../modules/reimburseOrder/views/reimburse_order_view.dart';
import '../modules/setting/bindings/setting_binding.dart';
import '../modules/setting/views/setting_view.dart';
import '../modules/settingbackTransit/bindings/settingback_transit_binding.dart';
import '../modules/settingbackTransit/views/settingback_transit_view.dart';
import '../modules/settlement/bindings/settlement_binding.dart';
import '../modules/settlement/views/settlement_view.dart';
import '../modules/systemSettingPage/bindings/system_setting_page_binding.dart';
import '../modules/systemSettingPage/views/system_setting_page.dart';
import '../modules/systemSettingPage/views/system_setting_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.TRANSIT_PAGE,
      page: () => TransitPageView(),
      binding: TransitPageBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVATION,
      page: () => const ActivationView(),
      binding: ActivationBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_HOME,
      page: () => OrderHomeView(),
      binding: OrderHomeBinding(),
    ),
    GetPage(
      name: _Paths.SELFSERVICE_PAGE,
      page: () => SelfservicePageView(),
      binding: SelfservicePageBinding(),
    ),
    GetPage(
      name: _Paths.CHECKOUT_PAGE,
      page: () => CheckoutPageView(),
      binding: CheckoutPageBinding(),
    ),
    GetPage(
      name: _Paths.SCANCODE_PAGE,
      page: () => ScanCodeView(),
      binding: CheckoutPageBinding(),
    ),
    GetPage(
      name: _Paths.MENU_PAGE,
      page: () => MenuPageView(),
      binding: MenuPageBinding(),
    ),
    GetPage(
      name: _Paths.MENUZONG_PAGE,
      page: () => MenuzongPageView(),
      binding: MenuPageBinding(),
    ),
    GetPage(
      name: _Paths.SETTLEMENT,
      page: () => SettlementView(),
      binding: SettlementBinding(),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => SettingView(),
      bindings: [
        SettingBinding(),
        SettingbackTransitBinding(),
        TransitPageBinding()
      ],
    ),
    GetPage(
      name: _Paths.MIDDLEWARE_SETTING_PAGE,
      page: () => MiddlewareSettingPageView(),
      binding: MiddlewareSettingPageBinding(),
    ),
    GetPage(
      name: _Paths.SYSTEM_SETTING_PAGE,
      page: () => SystemSettingPageView(),
      binding: SystemSettingPageBinding(),
    ),
    GetPage(
      name: _Paths.SYSTEM_SETTING_PAGE_NEW,
      page: () => SystemSettingPage(),
      binding: SystemSettingPageBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGBACK_TRANSIT,
      page: () => SettingbackTransitView(),
      binding: SettingbackTransitBinding(),
    ),
    GetPage(
      name: _Paths.SELF_CHECKOUTSCANNINGCODE,
      page: () => const SelfCheckoutscanningcodeView(),
      binding: SelfCheckoutscanningcodeBinding(),
    ),
    GetPage(
      name: _Paths.REIMBURSE_ORDER,
      page: () => ReimburseOrderView(),
      binding: ReimburseOrderBinding(),
    ),
    GetPage(
      name: _Paths.ERROR_PAGE,
      page: () => ErrorPageView(),
      binding: ErrorBinding(),
    ),
    GetPage(
      name: _Paths.RECEIPT_QUERY,
      page: () => ReceiptQueryView(),
      binding: ReceiptQueryBinding(),
    ),
    GetPage(
      name: _Paths.SETTING_EDIT_PAGE,
      page: () => EditPage(),
    ),

  ];
}
