import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/sqlService.dart';
import 'package:foodorder/services/Storage.dart';

class ItemServices {
  SQLService sqlService = SQLService();
  Storage storageService = Storage();
  List<ShopItemModel> shoppingList = [];
  DateTime nowTime = DateTime.now();


  List<ShopItemModel> getShoppingItems() {
    int count = 1;
    //可以通过http获取网络数据
    data.forEach((element) {
      element['id'] = count;
      shoppingList.add(ShopItemModel.fromJson(element));
      count++;
    });
    return shoppingList;
  }

  List<ShopItemModel> get items => getShoppingItems();

  Future openDB() async {
    return await sqlService.openDB();
  }

  loadItems() async {
    String isFirst = await isFirstTime();
    var load_year = nowTime.year;
    var load_month = nowTime.month;
    var load_day = nowTime.day;
    String dataTag = "$load_year$load_month$load_day";
print("dataTag---$dataTag");
    if (isFirst == dataTag) {
      // Load From local DB
      List items = await getLocalDBRecord();
      return items;
    } else {
      // Save Record into DB & load record
      List items = await saveToLocalDB();
      return items;
    }
  }

  Future<String> isFirstTime() async {
    return await storageService.getItem("isFirstTime");
  }

  Future saveToLocalDB() async {
    await sqlService.deleteRecord('shopping');

    List<ShopItemModel> items = this.items;
    for (var i = 0; i < items.length; i++) {
      await sqlService.saveRecord(items[i]);
    }

    var load_year = nowTime.year;
    var load_month = nowTime.month;
    var load_day = nowTime.day;
    String dataTag = "$load_year$load_month$load_day";
    storageService.setItem("isFirstTime", dataTag);
    return await getLocalDBRecord();
  }

  Future getLocalDBRecord() async {
    return await sqlService.getItemsRecord();
  }

  Future setItemAsFavourite(id, flag) async {
    return await sqlService.setItemAsFavourite(id, flag);
  }

  Future addToCart(ShopItemModel data) async {
    return await sqlService.addToCart(data);
  }

  Future getCartList() async {
    return await sqlService.getCartList();
  }

  removeFromCart(int shopId) async {
    return await sqlService.removeFromCart(shopId);
  }
}
