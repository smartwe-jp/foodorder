import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/itemService.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  ItemServices itemServices = ItemServices();
  List<ShopItemModel> items = [];
  List<ShopItemModel> itemstwo = [];
  List<ShopItemModel> itemsthree = [];
  List<ShopItemModel> itemsfour = [];
  List<ShopItemModel> cartItems = [];
  List getcartItems = [];
  bool isLoading = true;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadDB();
  }

  loadDB() async {
    await itemServices.openDB();
    loadItems();print("loadItems234");
    getCardList();
  }

  getItem(int id) {
    return items.singleWhere((element) => element.id == id);
  }

  bool isAlreadyInCart(id) {
    return cartItems.indexWhere((element) => element.shopId == id) > -1;
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

  //获取商品数据
  loadItems()async{
    try {
      isLoading = true;
      update();

      List list = await itemServices.loadItems();
      list.forEach((element) {
        var item = ShopItemModel.fromJson(element);
        if(item.classid == 1){
          items.add(item);
        }else if(item.classid == 2){
          itemstwo.add(item);
        }else if(item.classid == 3){
          itemsthree.add(item);
        }else if(item.classid == 4){
          itemsfour.add(item);
        }

      });

      isLoading = false;
      update();
    } catch (e) {
      print(e);
    }
  }

  setToFav(int id, bool flag) async {
    int index = items.indexWhere((element) => element.id == id);

    items[index].fav = flag;
    update();
    try {
      await itemServices.setItemAsFavourite(id, flag);
    } catch (e) {
      print(e);
    }
  }

  Future addToCart(ShopItemModel item) async {
    isLoading = true;
    update();
    var result = await itemServices.addToCart(item);
    isLoading = false;
    update();
    return result;
  }

  removeFromCart(int shopId) async {
    itemServices.removeFromCart(shopId);
    int index = cartItems.indexWhere((element) => element.shopId == shopId);
    cartItems.removeAt(index);
    update();
  }

  removeAllFromCart() async {
    itemServices.removeAllFromCart();

    update();
  }
}