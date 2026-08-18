import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLService {
  Database? db;
  SQLService() {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    init();
  }

  Future<void> init() async {
    await openDB();
  }

  Future openDB() async {
    try {
      // Get a location using getDatabasesPath
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'smartweshopping.db');

      // open the database
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print(db);
          this.db = db;
          createTables();
        },
      );
      return true;
    } catch (e) {
      print("ERROR IN OPEN DATABASE $e");
      return Future.error(e);
    }
  }

  createTables() async {
    try {
      var qry = "CREATE TABLE IF NOT EXISTS cart_list ( "
          "id INTEGER PRIMARY KEY,"
          "menuCode TEXT,"
          "mainTitle TEXT,"
          "image Text,"
          "currentPrice INTEGER,"
          "unitPrice INTEGER,"
          "qtyBounds INTEGER,"
          "optionGroupVoList TEXT,"
          "optionVoListMsg TEXT,"
          "goodsNum INTEGER)";

      await db?.execute(qry);
    } catch (e) {
      print("ERROR IN CREATE TABLE");
      print(e);
    }
  }

  Future getCartList() async {
    try {
      var list =
          await db?.rawQuery('SELECT * FROM cart_list ORDER BY id DESC', []);
      return list ?? [];
    } catch (e) {
      return Future.error(e);
    }
  }

  Future getAscCartList() async {
    try {
      var list =
          await db?.rawQuery('SELECT * FROM cart_list ORDER BY id ASC', []);
      return list ?? [];
    } catch (e) {
      return Future.error(e);
    }
  }

  Future getCartListPrice() async {
    var query = "SELECT SUM(currentPrice) AS totalPrice FROM cart_list";
    return await this.db?.rawQuery(query);
  }

  Future getCartItemNum(String menuCode) async {
    var query =
        "SELECT SUM(goodsNum) AS totalGoodsNum FROM cart_list where menuCode = ${menuCode}";
    return await this.db?.rawQuery(query);
  }

  Future getCartItemNewId(String menuCode) async {
    var query = "SELECT id FROM cart_list where menuCode = ${menuCode}";
    return await this.db?.rawQuery(query);
  }

  Future getCartTotalNum() async {
    var query = "SELECT SUM(goodsNum) AS totalGoodsNum FROM cart_list";
    return await this.db?.rawQuery(query);
  }

  Future getCartItemNumberByID(int cartId) async {
    var query = "SELECT goodsNum FROM cart_list where id = ${cartId}";
    return await this.db?.rawQuery(query);
  }

  Future checkItemAsCartList(String menuCode) async {
    var query = "SELECT * FROM cart_list where menuCode = ${menuCode}";
    return await this.db?.rawQuery(query);
  }

  Future addToCart(data) async {
    await this.db?.transaction((txn) async {
      var qry =
          'INSERT INTO cart_list(menuCode, mainTitle, image, currentPrice,unitPrice,qtyBounds,optionGroupVoList,optionVoListMsg,goodsNum) VALUES("${data["menuCode"]}", "${data["mainTitle"]}","${data["image"]}", ${data["currentPrice"]},${data["unitPrice"]},${data["qtyBounds"]},"${data["optionGroupVoList"]}","${data["optionVoListMsg"]}",${data["goodsNum"]})';
      int id1 = await txn.rawInsert(qry);
      return id1;
    });
  }

  Future updateToCartNum(data) async {
    await this.db?.transaction((txn) async {
      var query =
          "UPDATE cart_list SET goodsNum=goodsNum+${data["goodsNum"]},currentPrice=currentPrice+${data["unitPrice"]} where menuCode = '${data["menuCode"]}'";
      int id2 = await txn.rawUpdate(query);
      return id2;
    });
    //var query = "UPDATE cart_list SET goodsNum=goodsNum+${data["goodsNum"]},currentPrice=currentPrice+${data["unitPrice"]} where menuCode = '${data["menuCode"]}'";

    //return await this.db?.rawUpdate(query);
  }

  Future addToCartNum(data) async {
    var query =
        "UPDATE cart_list SET goodsNum=goodsNum+${data["goodsNum"]},currentPrice=currentPrice+${data["unitPrice"]} where id = '${data["cartId"]}'";
    return await this.db?.rawUpdate(query);
  }

  Future reduceToCartNum(data) async {
    var query =
        "UPDATE cart_list SET goodsNum=goodsNum-${data["goodsNum"]},currentPrice=currentPrice-${data["unitPrice"]} where id = '${data["cartId"]}'";
    return await this.db?.rawUpdate(query);
  }

  Future removeFromCart(int Id) async {
    var qry = "DELETE FROM cart_list where id = ${Id}";
    return await this.db?.rawDelete(qry);
  }

  Future removeAllFromCart() async {
    var qry = "cart_list";
    return await this.db?.delete(qry);
  }
}
