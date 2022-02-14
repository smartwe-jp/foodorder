//四种视图状态
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'NoData.dart';

enum LoadState { State_Success, State_Error, State_Loading, State_Empty }

///根据不同状态来展示不同的视图
class LoadStateLayout extends StatefulWidget {

  final LoadState state; //页面状态
  final Widget successWidget;//成功视图
  final VoidCallback errorRetry; //错误事件处理
  final VoidCallback emptyRetry; //空数据事件处理

  LoadStateLayout(
      {Key key,
        this.state = LoadState.State_Loading,//默认为加载状态
        this.successWidget,
        this.errorRetry,
        this.emptyRetry
      })
      : super(key: key);

  @override
  _LoadStateLayoutState createState() => _LoadStateLayoutState();
}

class _LoadStateLayoutState extends State<LoadStateLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //宽高都充满屏幕剩余空间
      width: double.infinity,
      height: double.infinity,
      child: _buildWidget,
    );
  }

  ///根据不同状态来显示不同的视图
  Widget get _buildWidget {
    switch (widget.state) {
      case LoadState.State_Success:
        return widget.successWidget;
        break;
      case LoadState.State_Error:
        return _errorView;
        break;
      case LoadState.State_Loading:
        return _loadingView;
        break;
      case LoadState.State_Empty:
        return NoDataView(widget.emptyRetry);
        break;
      default:
        return null;
    }
  }

  ///加载中视图
  Widget get _loadingView {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: Container(
        height: ScreenUtil().setHeight(400),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(405),
              height: ScreenUtil().setHeight(320),
              child: Image.asset('assets/images/cargo_loading.gif',fit: BoxFit.fitWidth,),
            ),
            Text('拼命加载中...',style: TextStyle(color: Colors.black),)],
        ),
      ),
    );
  }

  ///错误视图
  Widget get _errorView {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: widget.errorRetry,
          child: Container(
            height: ScreenUtil().setHeight(400),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(405),
                  height: ScreenUtil().setHeight(317),
                  child: Image.asset('assets/images/load_error.png',fit: BoxFit.fitWidth,),
                ),
                Text("加载失败，请轻触重试!",style: TextStyle(color: Colors.black),),
              ],
            ),
          ),
        )
    );
  }
}