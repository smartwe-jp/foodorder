import 'package:flutter/cupertino.dart';

class ShopItemModel {
  String menuCode;
  String mainTitle;
  String image;
  int currentPrice;
  String optionGroupVoList;
  int goodsNum;
  int id;

  ShopItemModel(
      {this.menuCode,
        this.id,
        this.mainTitle,
        this.image,
        this.currentPrice,
        this.optionGroupVoList,
        this.goodsNum});

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      menuCode: json['menuCode'],
      mainTitle: json['mainTitle'],
      image: json['image'],
      currentPrice:json['currentPrice'],
      optionGroupVoList: json['optionGroupVoList'],
      goodsNum: json['goodsNum']
    );
  }
}

