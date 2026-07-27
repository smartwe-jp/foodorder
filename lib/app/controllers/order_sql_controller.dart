import 'package:get/get.dart';

import '../models/ItemModel.dart';
import '../services/itemService.dart';

class OrderSqlController extends GetxService {
  ItemServices itemServices = ItemServices();
  List cartItems = [];
  List getcartItems = [];
  bool isLoading = true;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadDB();

    getCardList();
  }

  loadDB() async {
    await itemServices.openDB();

    getCardList();
  }

  bool isAlreadyInCart(id) {
    return cartItems.indexWhere((element) => element.id == id) > -1;
  }

  //获取购物车数据
  getCardList() async {
    try {
      getcartItems = await itemServices.getCartList();
      cartItems.clear();
      getcartItems.forEach((element) {
        cartItems.add(ShopItemModel.fromJson(element));
      });

      //update();
    } catch (e) {
      print(e);
    }
  }

  getAscCardList() async {
    try {
      getcartItems = await itemServices.getAscCartList();
      cartItems.clear();
      getcartItems.forEach((element) {
        cartItems.add(ShopItemModel.fromJson(element));
      });

      //update();
    } catch (e) {
      print(e);
    }
  }

  getCartAllPrice() async {
    var result;
    result = await itemServices.getCartListPrice();
    return result == null ? null : result[0];
  }

  getCartItemNum(menuCode) async {
    var result;
    result = await itemServices.getCartItemNumber(menuCode);
    if (result[0]["totalGoodsNum"] == null) {
      return 0;
    } else {
      return result[0]["totalGoodsNum"];
    }
  }

  getCartItemNewId(menuCode) async {
    var result;
    result = await itemServices.getCartItemNewId(menuCode);
    if (result[0] == null) {
      return 0;
    } else {
      return result[0]["id"];
    }
  }

  getCartTotalNum() async {
    var result;
    result = await itemServices.getCartTotalNumber();
    if (result == null || result[0]["totalGoodsNum"] == null) {
      return 0;
    } else {
      return result[0]["totalGoodsNum"];
    }
  }

  Future addToCart(item, {bool checkItem = false}) async {
    isLoading = true;
    var result;
    if (checkItem == true) {
      // 仅合并无规格行；有 option 的菜品每次确认都是独立一行
      final checkResult =
          await itemServices.findPlainCartRowByMenuCode(item['menuCode']);
      if (checkResult.isNotEmpty) {
        item['cartId'] = checkResult[0]['id'];
        result = await itemServices.updateToCartNum(item);
      } else {
        result = await itemServices.addToCart(item);
      }
    } else {
      result = await itemServices.addToCart(item);
    }

    isLoading = false;
    return result;
  }

  /// 原子写入一组购物车记录，避免组合商品只写入一部分。
  Future<List<int>> addCartItemsAtomically(
      List<Map<String, dynamic>> items) async {
    isLoading = true;
    try {
      return await itemServices.addCartItemsAtomically(items);
    } finally {
      isLoading = false;
    }
  }

  Future addToCartNum(item) async {
    isLoading = true;
    //update();
    var result;
    result = await itemServices.addToCartNum(item);

    isLoading = false;
    //update();
    return result;
  }

  Future reduceToCart(item) async {
    isLoading = true;
    //update();
    var result;
    var checkResult = await itemServices.getCartItemNumberByID(item['cartId']);
    if (checkResult[0]["goodsNum"] > 1) {
      result = await itemServices.reduceToCartNum(item);
    }

    isLoading = false;
    //update();
    return result;
  }

  Future<void> removeFromCart(int Id) async {
    await itemServices.removeFromCart(Id);
    final index = cartItems.indexWhere((element) => element.id == Id);
    if (index >= 0) {
      cartItems.removeAt(index);
    }
  }

  removeAllFromCart() async {
    itemServices.removeAllFromCart();

    //update();
  }
}
