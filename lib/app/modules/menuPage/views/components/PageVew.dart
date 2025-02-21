
import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/edit_page/widgets/menu_side_bar.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
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
      physics:
          const NeverScrollableScrollPhysics(), // 防止 PageView 滚动BouncingScrollPhysics ClampingScrollPhysics NeverScrollableScrollPhysics
      onPageChanged: (int page) {
        debugPrint('MenuSidebarItemInfo onPageChanged = $page');
        // MenuSidebarItemInfo pageInfo = state.sidebarInfo?.sidebarItemList[page];
        Map pageInfo = state.topMenu[page];
        state.restoreNavigationStatus(pageInfo['categoryCode'], page);
      },
      itemBuilder: (context, pageIndex) {
        debugPrint('MenuSidebarItemInfo itemBuilder = $pageIndex');
        //Map pageInfo = state.topMenu[pageIndex];

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent + 120.dp) {
                _executePageChange(true);
              }
              if (notification.metrics.pixels <= -120.dp) {
                _executePageChange(false);
              }
            }
            return false;
          },
          child: FutureBuilder<Widget?>(
            future: state.getCategoryMenu(state.classTag.value),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No data available'));
              } else {
                return snapshot.data!;
              }
            },
          ),

          // GridView.builder(
          //   padding: EdgeInsets.all(20.dp),
          //   physics: const AlwaysScrollableScrollPhysics(), // 允许 GridView 滚动BouncingScrollPhysics NeverScrollableScrollPhysics
          //   shrinkWrap: true,
          //   addAutomaticKeepAlives: true,
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     mainAxisSpacing: mainAxisSpacing ?? 40.dp,
          //     crossAxisSpacing: crossAxisSpacing ?? 20.dp,
          //     crossAxisCount: crossAxisCount ?? 4,
          //     childAspectRatio: childAspectRatio ?? 0.76,
          //   ),
          //   itemBuilder: (BuildContext context, int index) {
          //     return menuItems[index];
          //   },
          //   itemCount: menuItems.length,
          // ),
        );
      },
    );
  }
}
