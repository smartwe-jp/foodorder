import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

class AppTool {
  /// 中间弹出提示框

  showCenterTipsAlter(
      BuildContext context, confirmCallback, String title, String desText, String confirmText, String cancelText) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShowTipsAlterWidget(confirmCallback, title, desText, confirmText, cancelText);
        });
  }

}


class ShowTipsAlterWidget extends StatefulWidget {
  final confirmCallback;

  final title;

  final desText;

  final confirmText;

  final cancelText;

  const ShowTipsAlterWidget(this.confirmCallback, this.title, this.desText, this.confirmText, this.cancelText);

  @override
  _ShowTipsAlterWidgetState createState() => _ShowTipsAlterWidgetState();
}

class _ShowTipsAlterWidgetState extends State<ShowTipsAlterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenAdapter.width(950),
      child: SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Align(
          alignment: Alignment.center,
          child:  Text(widget.title,style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
        ),
        children: <Widget>[
          Container(
          width: ScreenAdapter.width(650),

          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Align(
                child: Text(widget.desText,
                    style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                alignment: Alignment(0, 0),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1.0,
                color: Colors.black12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 70.0),
                    child: TextButton(
                      child: Text(
                        widget.cancelText,
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: ScreenAdapter.fontSize(32.0)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  //垂直分割线
                  SizedBox(
                    width: 1,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 70.0),
                    child: TextButton(
                      child: Text(
                        widget.confirmText,
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: ScreenAdapter.fontSize(32.0)),
                      ),
                      onPressed: () async {
                        widget.confirmCallback('确定');

                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        ]
      ),
    );
  }
}

