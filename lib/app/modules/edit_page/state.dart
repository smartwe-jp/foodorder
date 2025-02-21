import 'package:foodorder/app/modules/edit_page/widgets/menu_side_bar.dart';

class EditPageState {
  late List topMenu;
  late List currentPageItems;
  late int selectIndex;

  EditPageState() {
    selectIndex = 0;
    topMenu = [];
    //currentPageItems = [];
  }

  MenuSidebarInfo? get sidebarInfo => MenuSidebarInfo(
      title: '分類',
      sidebarItemList: List.generate(topMenu.length, (index) {
        final menu = topMenu[index];

        return MenuSidebarItemInfo(
          tag: menu['categoryCode'],
          title: menu['categoryName'],
          icon: menu['image'],
          color: menu['color'] ?? '#2B9F93',
          //menuData: menu['menuVoList'],
          index: index,
          isSelected: index == selectIndex,
        );
      }));
}
