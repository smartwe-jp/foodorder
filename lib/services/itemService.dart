import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/sqlService.dart';
import 'package:foodorder/services/Storage.dart';

import 'HttpService.dart';

class ItemServices {
  SQLService sqlService = SQLService();
  Storage storageService = Storage();
  List<ShopItemModel> shoppingList = [];
  DateTime nowTime = DateTime.now();


  Future openDB() async {
    return await sqlService.openDB();
  }




  Future addToCart(data) async {
    return await sqlService.addToCart(data);
  }

  Future checkToCartItem(data) async {
    return await sqlService.checkItemAsCartList(data);
  }

  Future updateToCartNum(data) async {
    return await sqlService.updateToCartNum(data);
  }

  Future getCartList() async {
    return await sqlService.getCartList();
  }

  Future getCartListPrice() async {
    return await sqlService.getCartListPrice();
  }

  removeFromCart(int Id) async {
    return await sqlService.removeFromCart(Id);
  }

  removeAllFromCart() async {
    return await sqlService.removeAllFromCart();
  }
}
