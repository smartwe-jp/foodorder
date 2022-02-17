library add_cart_parabola;



import 'dart:ui';

import 'package:flutter/material.dart';

class ParabolaAnimateWidget extends StatefulWidget{
  final GlobalKey rootKey;
  final Offset startOffset;
  final Offset endOffset;
  final String animateImgUrl;
  final Function animateCallback;
  final int duration;
  final double controlRatio;


  ParabolaAnimateWidget(this.rootKey,this.startOffset,this.endOffset,this.animateImgUrl,this.animateCallback,{int duration = -1,double controlRatio})
      : this.duration = duration,this.controlRatio = controlRatio,assert(animateImgUrl != null);


  @override
  _ParabolaAnimateWidgetState createState() => _ParabolaAnimateWidgetState();

}

class _ParabolaAnimateWidgetState extends State<ParabolaAnimateWidget> with SingleTickerProviderStateMixin {





  AnimationController _controller;
  Animation _animation;


  double widgetLeft = 0.0;
  double widgetTop = 0.0;

  double animateLen = 0.0;
  PathMetric animatePM ;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: widget.duration <=0 ? 1000 : widget.duration));


    WidgetsBinding.instance.addPostFrameCallback((_){
      if(widget.startOffset == null || widget.endOffset == null){
        widget.animateCallback(AnimationStatus.completed);
        return;
      }
      generateAnimateAttr();
      startAnimation();
    });
    widgetLeft = widget.startOffset?.dx ==null ? widgetLeft : widget.startOffset.dx;
    widgetTop = widget.startOffset?.dy == null ? widgetTop : widget.startOffset.dy;

  }
/*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }
  @override
  void didUpdateWidget (ParabolaAnimateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

  }*/

  generateAnimateAttr(){
    //RenderBox startRB = startKey.currentContext.findRenderObject();
//    Offset startOffset = startRB.localToGlobal(Offset.zero,ancestor: rootKey.currentContext.findRenderObject());
//    RenderBox endRB = endKey.currentContext.findRenderObject();
//    Offset endOffset = endRB.localToGlobal(Offset.zero,ancestor: rootKey.currentContext.findRenderObject());
    Path path = getPath();
    PathMetrics pms = path.computeMetrics();
    animatePM = pms.elementAt(0);
    animateLen = animatePM.length;

  }

  Path getPath() {

    //print("start offset :${start.toString()}");
    double controlPointX = generateControlPointX();
    Path path = Path();
    path.moveTo(widget.startOffset.dx,widget.startOffset.dy);
    path.quadraticBezierTo(controlPointX,
        widget.startOffset.dy, widget
            .endOffset.dx, widget.endOffset.dy);
    //path.cubicTo(size.width / 4, 3 * size.height / 4, 3 * size.width / 4, size.height / 4, size.width, size.height);

    return path;
  }

  //make sure control-point'x is between startDx and endDx;
  //and performed like Bezier

  double generateControlPointX(){
    double controlRatio = widget.controlRatio ?? 2;
    double sX = widget.startOffset.dx;
    double eX = widget.endOffset.dx;
    double largeX = sX > eX ? sX : eX;
    double smallX = sX < eX ? sX : eX;
    double controlX = largeX / controlRatio;
    if(controlX < smallX){
      controlX = ((largeX - smallX) / controlRatio) + smallX;
    }
    return controlX;
  }



  @override
  Widget build(BuildContext context) {

    return Positioned(
      left: widgetLeft,
      top: widgetTop,
      child: Opacity(
        opacity: 0.8,
        //child: widget.animateWidget,
        child: ClipOval(
          child: Image.network(
            widget.animateImgUrl,
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }


  startAnimation(){

    _animation = Tween(begin: 0.0,end: animateLen).animate(_controller)
      ..addListener((){
        //print("animation value ${_animation.value}");
        double tempStart = _animation.value;
        Tangent t = animatePM.getTangentForOffset(tempStart);
        setState(() {
          widgetLeft = t.position.dx;
          widgetTop = t.position.dy;
        });
      })
      ..addStatusListener((status){
        widget.animateCallback(status);
        if(status == AnimationStatus.completed){
          _controller?.stop();
          _controller?.dispose();
        }
      });
    _controller.forward();
  }

}



