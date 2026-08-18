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
  /// 麻辣烫称重克数；>0 表示称重行（用于十位取整优惠），汤底/赠品为 0
  int spicyGrams;

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
        this.itemType = '',
        this.spicyGrams = 0});

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    final rawGrams = json['spicyGrams'];
    final grams = rawGrams is int
        ? rawGrams
        : int.tryParse('$rawGrams') ?? 0;
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
      spicyGrams: grams,
    );
  }
}

