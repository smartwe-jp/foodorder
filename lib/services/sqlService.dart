
import 'package:foodorder/models/ItemModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLService {
  Database db;

  Future openDB() async {
    try {
      // Get a location using getDatabasesPath
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'shopping.db');

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
      var list = await db?.rawQuery('SELECT * FROM cart_list', []);
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
    var query = "SELECT SUM(goodsNum) AS totalGoodsNum FROM cart_list where menuCode = ${menuCode}";
    return await this.db?.rawQuery(query);
  }

  Future checkItemAsCartList(String menuCode) async {
    var query = "SELECT * FROM cart_list where menuCode = ${menuCode}";
    return await this.db?.rawQuery(query);
  }

  Future addToCart(data) async {
    await this.db?.transaction((txn) async {
      var qry =
          'INSERT INTO cart_list(menuCode, mainTitle, image, currentPrice,optionGroupVoList,optionVoListMsg,goodsNum) VALUES("${data["menuCode"]}", "${data["mainTitle"]}","${data["image"]}", ${data["currentPrice"]},"${data["optionGroupVoList"]}","${data["optionVoListMsg"]}",${data["goodsNum"]})';
      int id1 = await txn.rawInsert(qry);
      return id1;
    });
  }

  Future updateToCartNum(data) async {
    var query = "UPDATE cart_list SET goodsNum=goodsNum+${data["goodsNum"]},currentPrice=currentPrice+${data["currentPrice"]} where menuCode = '${data["menuCode"]}'";
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
