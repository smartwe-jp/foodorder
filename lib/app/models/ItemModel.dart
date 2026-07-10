import 'package:flutter/cupertino.dart';

class ShopItemModel {
  String? menuCode;
  String mainTitle;
  String? image;
  int? currentPrice;
  int? unitPrice;
  int? qtyBounds;
  String? optionGroupVoList;
  String? optionVoListMsg;
  int goodsNum;
  int? id;
  /// 条目类型标识：'spicy' = 麻辣烫条目（购物车不显示数量加减），'' = 普通条目
  String itemType;

  ShopItemModel(
      {this.menuCode,
        this.id,
        required this.mainTitle,
        this.image,
        this.currentPrice,
        this.unitPrice,
        this.qtyBounds,
        this.optionGroupVoList,
        this.optionVoListMsg,
        required this.goodsNum,
        this.itemType = ''});

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      menuCode: json['menuCode'],
      mainTitle: json['mainTitle'],
      image: json['image'],
      currentPrice:json['currentPrice'],
      unitPrice:json['unitPrice'],
      qtyBounds:json['qtyBounds'],
      optionGroupVoList: json['optionGroupVoList'],
      optionVoListMsg: json['optionVoListMsg'],
      goodsNum: json['goodsNum'],
      itemType: json['itemType'] ?? '',
    );
  }
}

