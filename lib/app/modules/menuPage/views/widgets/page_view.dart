
import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:get/get.dart';
import '../../controllers/menu_page_extension.dart';

class MenuView extends StatelessWidget {
  final MenuPageController state;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final int? crossAxisCount;
  final double? childAspectRatio;

  MenuView(
      {Key? key,
        required this.state,
        this.mainAxisSpacing,
        this.crossAxisSpacing,
        this.crossAxisCount,
        this.childAspectRatio})
      : super(key: key);

  void _executePageChange(bool next) {
    if (state.isChangingPage) return;
    state.isChangingPage = true;

    if (next) {
      if (state.selectIndex != state.topMenu.length - 1) {
        state.pageController
            .nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          state.isChangingPage = false;
        });
      } else {
        state.isChangingPage = false;
      }
    } else {
      if (state.selectIndex != 0) {
        state.pageController
            .previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          state.isChangingPage = false;
        });
      } else {
        state.isChangingPage = false;
      }
    }
  }

  // void _schedulePageChange(bool next) {
  //   if (state.isChangingPage || state.pageChangeScheduled) return;
  //   state.pageChangeScheduled = true;
  //
  //   SchedulerBinding.instance.addPostFrameCallback((_) {
  //     _executePageChange(next);
  //     state.pageChangeScheduled = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: state.pageController,
      itemCount: state.topMenu.length,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(), // 防止 PageView 滚动BouncingScrollPhysics ClampingScrollPhysics NeverScrollableScrollPhysics
      onPageChanged: (int page) {
        debugPrint('MenuSidebarItemInfo onPageChanged = $page');
        // MenuSidebarItemInfo pageInfo = state.sidebarInfo?.sidebarItemList[page];
        Map pageInfo = state.topMenu[page];
        state.restoreNavigationStatus(pageInfo['categoryCode'], page);
      },
      itemBuilder: (context, pageIndex) {
        debugPrint('MenuSidebarItemInfo itemBuilder = $pageIndex');
        final categoryCode = state.topMenu[pageIndex]['categoryCode'];
        //Map pageInfo = state.topMenu[pageIndex];

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent + 200) {
                _executePageChange(true);
              }
              if (notification.metrics.pixels <= -200) {
                _executePageChange(false);
              }
            }
            return false;
          },
          child: _CategoryMenuPage(
            key: ValueKey(categoryCode),
            state: state,
            categoryCode: categoryCode,
          ),
        );
      },
    );
  }
}

class _CategoryMenuPage extends StatefulWidget {
  final MenuPageController state;
  final String categoryCode;

  const _CategoryMenuPage({
    Key? key,
    required this.state,
    required this.categoryCode,
  }) : super(key: key);

  @override
  State<_CategoryMenuPage> createState() => _CategoryMenuPageState();
}

class _CategoryMenuPageState extends State<_CategoryMenuPage> {
  late Future<Widget?> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenu();
  }

  @override
  void didUpdateWidget(covariant _CategoryMenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryCode != widget.categoryCode) {
      _menuFuture = _loadMenu();
    }
  }

  Future<Widget?> _loadMenu() {
    return widget.state.getCategoryMenu(categoryCode: widget.categoryCode);
  }

  void _retry() {
    setState(() {
      _menuFuture = _loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget?>(
      future: _menuFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _MenuLoadFailedView(onRetry: _retry);
        }
        return snapshot.data!;
      },
    );
  }
}

class _MenuLoadFailedView extends StatelessWidget {
  final VoidCallback onRetry;

  const _MenuLoadFailedView({Key? key, required this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 96,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 24),
          Text(
            'load_menu_failure_title'.tr,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(
              'retry_button'.tr,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
