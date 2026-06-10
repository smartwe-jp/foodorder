import 'package:flutter/material.dart';
import 'package:foodorder/app/widget/CustomButton.dart';
import 'package:get/get.dart';

import '../../../../services/CustomLogerHandler.dart';
import '../../controllers/menu_page_controller.dart';

class CartSheetView extends StatefulWidget {
  final MenuPageController controller;
  final Widget Function(BuildContext context) cartBuilder;

  const CartSheetView({
    Key? key,
    required this.controller,
    required this.cartBuilder,
  }) : super(key: key);

  @override
  State<CartSheetView> createState() => _CartSheetViewState();
}

class _CartSheetViewState extends State<CartSheetView> {
  Worker? _worker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _worker ??= debounce(widget.controller.showCartTotalGoodsNum, (count) {
      if (!mounted || count != 0) return;

      final route = ModalRoute.of(context);
      logI("CartSheetView debounce, route: $route");
      if (route?.isCurrent == true) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    logI("CartSheetView dispose");
    _worker?.dispose();
    _worker = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuPageController>(
      id: 'shopping_cart',
      builder: (_) => Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: widget.cartBuilder(context),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 100,
              child: CustomButton(
                bgColor: Colors.white,
                titleColor: Colors.black,
                radius: 20,
                title: "settlement_back".tr,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendSheetView extends StatefulWidget {
  final MenuPageController controller;
  final Widget Function(BuildContext context) recommendBuilder;

  const RecommendSheetView({
    Key? key,
    required this.controller,
    required this.recommendBuilder,
  }) : super(key: key);

  @override
  State<RecommendSheetView> createState() => _RecommendSheetViewState();
}

class _RecommendSheetViewState extends State<RecommendSheetView> {
  Worker? _worker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _worker ??= debounce(widget.controller.showCartTotalGoodsNum, (count) {
      if (!mounted || count != 0) return;

      final route = ModalRoute.of(context);
      logI("RecommendSheetView debounce, route: $route");
      if (route?.isCurrent == true) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    logI("RecommendSheetView dispose");
    _worker?.dispose();
    _worker = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuPageController>(
      id: 'shopping_cart',
      builder: (_) => Container(
        child: widget.recommendBuilder(context),
      ),
    );
  }
}
