import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLService {
  Database? db;

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
      // 兼容旧版本：尝试添加列（若已存在则忽略异常）
      try {
        await db?.execute(
            "ALTER TABLE cart_list ADD COLUMN itemType TEXT DEFAULT ''");
      } catch (_) {}
      try {
        await db?.execute(
            "ALTER TABLE cart_list ADD COLUMN spicyGrams INTEGER DEFAULT 0");
      } catch (_) {}
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
          "goodsNum INTEGER,"
          "itemType TEXT DEFAULT '',"
          "spicyGrams INTEGER DEFAULT 0)";

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
    // 限购按 menuCode 汇总所有规格行的 goodsNum
    var query =
        "SELECT SUM(goodsNum) AS totalGoodsNum FROM cart_list WHERE menuCode = ?";
    return await db?.rawQuery(query, [menuCode]);
  }

  Future getCartItemNewId(String menuCode) async {
    var query = "SELECT id FROM cart_list WHERE menuCode = ? LIMIT 1";
    return await db?.rawQuery(query, [menuCode]);
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
    var query = "SELECT * FROM cart_list WHERE menuCode = ?";
    return await db?.rawQuery(query, [menuCode]);
  }

  /// 查找可合并的无规格行：同一 menuCode 且 option 为空
  /// 有 option 的菜品每次确认加购都是独立一行，不走此合并
  Future findPlainCartRowByMenuCode(String menuCode) async {
    var query =
        "SELECT * FROM cart_list WHERE menuCode = ? AND (optionGroupVoList = '' OR optionGroupVoList IS NULL) LIMIT 1";
    return await db?.rawQuery(query, [menuCode]);
  }

  Future addToCart(data) async {
    await this.db?.transaction((txn) async {
      final itemType = data["itemType"] ?? '';
      final spicyGrams = data["spicyGrams"] ?? 0;
      var qry =
          'INSERT INTO cart_list(menuCode, mainTitle, image, currentPrice,unitPrice,qtyBounds,optionGroupVoList,optionVoListMsg,goodsNum,itemType,spicyGrams) VALUES("${data["menuCode"]}", "${data["mainTitle"]}","${data["image"]}", ${data["currentPrice"]},${data["unitPrice"]},${data["qtyBounds"]},"${data["optionGroupVoList"]}","${data["optionVoListMsg"]}",${data["goodsNum"]},"${itemType}",${spicyGrams})';
      int id1 = await txn.rawInsert(qry);
      return id1;
    });
  }

  /// 在同一个事务中写入多条购物车记录，任意一条失败则全部回滚。
  Future<List<int>> addCartItemsAtomically(
      List<Map<String, dynamic>> items) async {
    final database = db;
    if (database == null) {
      throw StateError('购物车数据库尚未初始化');
    }

    return database.transaction((txn) async {
      final ids = <int>[];
      for (final data in items) {
        ids.add(await txn.insert('cart_list', {
          'menuCode': data['menuCode'] ?? '',
          'mainTitle': data['mainTitle'] ?? '',
          'image': data['image'] ?? '',
          'currentPrice': data['currentPrice'] ?? 0,
          'unitPrice': data['unitPrice'] ?? 0,
          'qtyBounds': data['qtyBounds'] ?? 0,
          'optionGroupVoList': data['optionGroupVoList'] ?? '',
          'optionVoListMsg': data['optionVoListMsg'] ?? '',
          'goodsNum': data['goodsNum'] ?? 1,
          'itemType': data['itemType'] ?? '',
          'spicyGrams': data['spicyGrams'] ?? 0,
        }));
      }
      return ids;
    });
  }

  Future updateToCartNum(data) async {
    await db?.transaction((txn) async {
      // 按 cartId 更新单行，避免同 menuCode 多规格行被批量 +1
      var query =
          "UPDATE cart_list SET goodsNum=goodsNum+?, currentPrice=currentPrice+? WHERE id = ?";
      int id2 = await txn.rawUpdate(query, [
        data["goodsNum"],
        data["unitPrice"],
        data["cartId"],
      ]);
      return id2;
    });
  }

  Future addToCartNum(data) async {
    var query =
        "UPDATE cart_list SET goodsNum=goodsNum+?, currentPrice=currentPrice+? WHERE id = ?";
    return await db?.rawUpdate(query, [
      data["goodsNum"],
      data["unitPrice"],
      data["cartId"],
    ]);
  }

  Future reduceToCartNum(data) async {
    var query =
        "UPDATE cart_list SET goodsNum=goodsNum-?, currentPrice=currentPrice-? WHERE id = ?";
    return await db?.rawUpdate(query, [
      data["goodsNum"],
      data["unitPrice"],
      data["cartId"],
    ]);
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
