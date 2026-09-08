import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLService {
  static Future<Database>? _sharedDatabaseReady;

  Database? db;
  late final Future<Database> _databaseReady;

  SQLService() {
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _databaseReady = _sharedDatabaseReady ??= _openDB();
  }

  Future<void> init() async {
    await _databaseReady;
  }

  Future openDB() async {
    await _databaseReady;
    return true;
  }

  Future<Database> _openDB() async {
    try {
      // Get a location using getDatabasesPath
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'smartweshopping.db');

      // open the database
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print(db);
          await _createTables(db);
        },
      );
      db = database;
      await _ensureCartColumns(database);
      return database;
    } catch (e) {
      print("ERROR IN OPEN DATABASE $e");
      return Future.error(e);
    }
  }

  Future<void> createTables() async {
    await _createTables(await _databaseReady);
  }

  Future<void> _createTables(Database database) async {
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

      await database.execute(qry);
    } catch (e) {
      print("ERROR IN CREATE TABLE");
      print(e);
    }
  }

  Future<void> _ensureCartColumns(Database database) async {
    final columns = await database.rawQuery('PRAGMA table_info(cart_list)');
    final columnNames = columns.map((column) => column['name']).toSet();
    if (!columnNames.contains('itemType')) {
      await database
          .execute("ALTER TABLE cart_list ADD COLUMN itemType TEXT DEFAULT ''");
    }
    if (!columnNames.contains('spicyGrams')) {
      await database.execute(
          'ALTER TABLE cart_list ADD COLUMN spicyGrams INTEGER DEFAULT 0');
    }
  }

  Future getCartList() async {
    try {
      final database = await _databaseReady;
      return await database
          .rawQuery('SELECT * FROM cart_list ORDER BY id DESC', []);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future getAscCartList() async {
    try {
      final database = await _databaseReady;
      return await database
          .rawQuery('SELECT * FROM cart_list ORDER BY id ASC', []);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future getCartListPrice() async {
    var query = "SELECT SUM(currentPrice) AS totalPrice FROM cart_list";
    return await (await _databaseReady).rawQuery(query);
  }

  Future getCartItemNum(String menuCode) async {
    var query =
        "SELECT SUM(goodsNum) AS totalGoodsNum FROM cart_list where menuCode = ${menuCode}";
    return await (await _databaseReady).rawQuery(query);
  }

  Future getCartItemNewId(String menuCode) async {
    var query = "SELECT id FROM cart_list where menuCode = ${menuCode}";
    return await (await _databaseReady).rawQuery(query);
  }

  Future getCartTotalNum() async {
    var query = "SELECT SUM(goodsNum) AS totalGoodsNum FROM cart_list";
    return await (await _databaseReady).rawQuery(query);
  }

  Future getCartItemNumberByID(int cartId) async {
    var query = "SELECT goodsNum FROM cart_list where id = ${cartId}";
    return await (await _databaseReady).rawQuery(query);
  }

  Future checkItemAsCartList(String menuCode) async {
    var query = "SELECT * FROM cart_list where menuCode = ${menuCode}";
    return await (await _databaseReady).rawQuery(query);
  }

  Future addToCart(data) async {
    final database = await _databaseReady;
    await database.transaction((txn) async {
      final id1 = await txn.insert('cart_list', {
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
      });
      return id1;
    });
  }

  Future<List<int>> addCartItemsAtomically(
      List<Map<String, dynamic>> items) async {
    final database = await _databaseReady;
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
    final database = await _databaseReady;
    await database.transaction((txn) async {
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
    return await (await _databaseReady).rawUpdate(query);
  }

  Future reduceToCartNum(data) async {
    var query =
        "UPDATE cart_list SET goodsNum=goodsNum-${data["goodsNum"]},currentPrice=currentPrice-${data["unitPrice"]} where id = '${data["cartId"]}'";
    return await (await _databaseReady).rawUpdate(query);
  }

  Future removeFromCart(int Id) async {
    var qry = "DELETE FROM cart_list where id = ${Id}";
    return await (await _databaseReady).rawDelete(qry);
  }

  Future removeAllFromCart() async {
    var qry = "cart_list";
    return await (await _databaseReady).delete(qry);
  }
}
