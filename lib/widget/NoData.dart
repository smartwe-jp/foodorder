import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/services/ScreenAdapter.dart';


class NoDataView extends StatefulWidget {


  final VoidCallback emptyRetry; //无数据事件处理

  NoDataView(this.emptyRetry);

  @override
  _NoDataViewState createState() => _NoDataViewState();
}

class _NoDataViewState extends State<NoDataView> {
  @override
  Widget build(BuildContext context) {
    ScreenAdapter.init(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: InkWell(
        onTap: widget.emptyRetry,
        child: Container(
          height: ScreenUtil().setHeight(400),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(405),
                height: ScreenUtil().setHeight(320),
                child: Image.asset('assets/images/load_nodata.png',fit: BoxFit.fitWidth,),
              ),
              Text('暂无相关数据...',style: TextStyle(color: Colors.black),)],
          ),
        ),
      ),
    );
  }
}