import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/itemService.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
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
  getCardList() async{
    try {
      getcartItems = await itemServices.getCartList();
      cartItems.clear();
      getcartItems.forEach((element) {
        cartItems.add(ShopItemModel.fromJson(element));
      });

      update();

    } catch (e) {
      print(e);
    }
  }

  getCartAllPrice() async {
    var result;
    result = await itemServices.getCartListPrice();
    return result[0];
  }

  getCartItemNum(menuCode) async {
    var result;
    result = await itemServices.getCartItemNumber(menuCode);
    if(result[0]["totalGoodsNum"] == null){
      return 0;
    }else{
      return result[0]["totalGoodsNum"];
    }

  }


  Future addToCart(item, {bool checkItem = false}) async {
    isLoading = true;
    update();
    var result;
    if(checkItem == true){
      var checkResult= await itemServices.checkToCartItem(item['menuCode']);
      if(checkResult.length>0){
        result = await itemServices.updateToCartNum(item);
      }else{
        result = await itemServices.addToCart(item);
      }
    }else{
      result = await itemServices.addToCart(item);
    }

    isLoading = false;
    update();
    return result;
  }

  Future reduceToCart(item) async {
    isLoading = true;
    update();
    var result;
    var checkResult = await itemServices.getCartItemNumber(item['menuCode']);
    if(checkResult[0]["totalGoodsNum"]>1){
      result = await itemServices.reduceToCartNum(item);
    }

    isLoading = false;
    update();
    return result;
  }

  removeFromCart(int Id) async {
    itemServices.removeFromCart(Id);
    int index = cartItems.indexWhere((element) => element.id == Id);
    cartItems.removeAt(index);
    update();
  }

  removeAllFromCart() async {
    itemServices.removeAllFromCart();

    update();
  }
}