import 'package:flutter/cupertino.dart';

class ShopItemModel {
  String menuCode;
  String mainTitle;
  String image;
  int currentPrice;
  String optionGroupVoList;
  String optionVoListMsg;
  int goodsNum;
  int id;

  ShopItemModel(
      {this.menuCode,
        this.id,
        this.mainTitle,
        this.image,
        this.currentPrice,
        this.optionGroupVoList,
        this.optionVoListMsg,
        this.goodsNum});

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      menuCode: json['menuCode'],
      mainTitle: json['mainTitle'],
      image: json['image'],
      currentPrice:json['currentPrice'],
      optionGroupVoList: json['optionGroupVoList'],
      optionVoListMsg: json['optionVoListMsg'],
      goodsNum: json['goodsNum']
    );
  }
}

