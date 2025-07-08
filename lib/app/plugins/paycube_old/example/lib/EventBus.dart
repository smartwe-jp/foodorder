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

