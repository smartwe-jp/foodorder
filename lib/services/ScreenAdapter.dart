
import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
class ScreenAdapter{

  static init(context){//Size(1080, 1920)
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
  }
  static height(double value){
     return ScreenUtil().setHeight(value);
  }
  static width(double value){
      return ScreenUtil().setWidth(value);
  }
  //屏幕物理高度
  static getScreenHeight(){
    return ScreenUtil().screenHeight;
  }
  //屏幕物理宽度
  static getScreenWidth(){
    return ScreenUtil().screenWidth;
  }

  static fontSize(double value){
    return ScreenUtil().setSp(value);
  }
  // ScreenUtil.screenHeight 
}

// ScreenAdaper