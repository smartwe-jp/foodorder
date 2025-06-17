import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/edit_page/logic.dart';
import 'package:foodorder/app/modules/edit_page/state.dart';
import 'package:foodorder/app/modules/edit_page/widgets/menu_liest_view.dart';
import 'package:foodorder/app/modules/edit_page/widgets/menu_side_bar.dart';
import 'package:get/get.dart';

class EditPage extends StatelessWidget {
  EditPage({Key? key}) : super(key: key);

  final logic = Get.put(EditPageLogic());
  final EditPageState state = Get.find<EditPageLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<EditPageLogic>(
        builder: (logic) =>
            logic.obx(
                  (states) => Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuSideBar(
                        data: state,
                        onTap: (MenuSidebarItemInfo item) {
                          logic.changeCategory(item.tag, item.index);
                        }),
                    Expanded(child: MenuListView(menuItems: state.currentPageItems))
                  ],
                ),
              ),
              onLoading: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      ColorsUtil.hexToColor("#80B646")),
                ),
              ),
            ),
      ),
    );
  }
}
