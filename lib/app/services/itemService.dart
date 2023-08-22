import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodorder/app/services/sqlService.dart';
import 'Storage.dart';

import '../models/ItemModel.dart';
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

  Future addToCartNum(data) async {
    return await sqlService.addToCartNum(data);
  }

  Future reduceToCartNum(data) async {
    return await sqlService.reduceToCartNum(data);
  }

  Future getCartList() async {
    return await sqlService.getCartList();
  }

  Future getCartListPrice() async {
    return await sqlService.getCartListPrice();
  }

  Future getCartItemNumber(menuCode) async {
    return await sqlService.getCartItemNum(menuCode);
  }

  Future getCartTotalNumber() async {
    return await sqlService.getCartTotalNum();
  }

  Future getCartItemNumberByID(cartId) async {
    return await sqlService.getCartItemNumberByID(cartId);
  }

  removeFromCart(int Id) async {
    return await sqlService.removeFromCart(Id);
  }

  removeAllFromCart() async {
    return await sqlService.removeAllFromCart();
  }
}
