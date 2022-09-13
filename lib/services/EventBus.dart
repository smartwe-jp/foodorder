import 'package:event_bus/event_bus.dart';


//Bus 初始化 

EventBus eventBus = EventBus();

//现金机广播
class PayCubeEvent{
  String str;
  PayCubeEvent(String str){
    this.str=str;
  }
}

//购物车广播
class clearCartEvent{
  String str;
  clearCartEvent(String str){
    this.str=str;
  }
}

//刷脸激活码广播
class setAttendanceCodeEvent{
  String str;
  setAttendanceCodeEvent(String str){
    this.str=str;
  }
}

