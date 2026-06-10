import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_http_sse/client/sse_client.dart';
import 'package:flutter_http_sse/enum/request_method_type_enum.dart';
import 'package:flutter_http_sse/model/sse_request.dart';
import 'package:flutter_http_sse/model/sse_response.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:get/get.dart';

class SseService extends GetxService {
  final SSEClient _client = SSEClient();
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, DateTime> _lastHeartbeat = {};
  final Map<String, Timer> _heartbeatTimers = {};
  PrintService _printService = Get.find();

  final RxMap subscriptions = {}.obs; //为空则未连接，true为已连接，false为连接中

  /// 添加新的 SSE 监听

  Future<void> addSseListen(String url) async {

    if (_subscriptions.containsKey(url)) {
      logI('SSE Service: Already subscribed to $url');
      return;
    }

    logI('SSE Service: Attempting to connect to $url');
    subscriptions[url] = false;

    final request = SSERequest(
      requestType: RequestMethodType.get,
      url: url,
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Accept': 'text/event-stream',
      },
      retry: true,
      onData: (SSEResponse response) {},
      onError: (error) {

        logI('SSE Service: Error in request for $url: $error');
      
        Future.delayed(Duration(milliseconds: 500), (){
          disconnect(url).then((_) {
            addSseListen(url);
          });
        });
      },
    );

    final stream = _client.connect(url, request, fromJson: (json) => json);

    final sub = stream.listen(
      (SSEResponse res) {
        // ...数据处理...
        if (kDebugMode) {
          print('SSE Service: Received from $url  event: ${res.event} message: ${res.data}');
        }
        subscriptions[url] = true;
        final event = res.event;
        Map? data;
        if (res.data is Map) {
          data = res.data as Map;
        } else if (res.data is String) {
          try {
            data = jsonDecode(res.data);
          } catch (_) {
            logW('SSE Service: Failed to parse data event: $event, raw data: ${res.data}');
          }
        }
        if (event == 'heartbeat') {
          //if (kDebugMode) {
            logI('SSE Service: Received event: $event');
          //}
        } else if (event == 'message'
          || event == 'print'
          || event == 'payment_Completed'
          || event == 'rePrint'
          || event == 'item_cancel'
          || event == 'expiryPrint'
          ) {
          //if (kDebugMode) {
            logI('SSE Service: Received $event event, data: $data');
          //}
          if (data != null) {
            _printService.callbackBeforePrint(event, data);
          }
        } else {
          // if (kDebugMode) {
          //   print('SSE Service: Received event: $event');
          // }
        }

        // 每收到消息，重置65秒超时检测
        _heartbeatTimers[url]?.cancel();
        _heartbeatTimers[url] = Timer(const Duration(seconds: 65), () {
          logI('SSE Service: Heartbeat timeout for (65s) $url, reconnecting...');
          disconnect(url).then((_) {
            _startReconnect(url, request);
          });
        });
      },
      onError: (err) {
        logI('SSE Service: onError Connection error for $url: $err');
        _heartbeatTimers[url]?.cancel();
        Future.delayed(Duration(milliseconds: 500), (){
          disconnect(url).then((_) {
            addSseListen(url);
          });
        });
      },
      onDone: () {
        logI('SSE Service: onDone Connection closed for $url');
        _heartbeatTimers[url]?.cancel();
        Future.delayed(Duration(milliseconds: 500), (){
          disconnect(url).then((_) {
            addSseListen(url);
          });
        });
      },
      cancelOnError: true,
    );

    _subscriptions[url] = sub;

    // 启动首次心跳定时器（防止连接后迟迟没消息）
    _heartbeatTimers[url]?.cancel();
    _heartbeatTimers[url] = Timer(const Duration(seconds: 45), () {
      logI('SSE Service: Initial heartbeat timeout (no first event in 45s) $url, reconnecting...');
      disconnect(url).then((_) {
        _startReconnect(url, request);
      });
    });
  }

  /// 主动断开连接
  Future<void> disconnect(String url) async {

    //check if the subscription exists
    if (!_subscriptions.containsKey(url)) {
      logI('SSE Service: No found active subscription for $url');
      return;
    }

    logI('SSE Service: disconnect for $url');
    subscriptions.remove(url);
    _subscriptions[url]?.cancel();
    _subscriptions.remove(url);
    _client.close(connectionId: url);
    _heartbeatTimers[url]?.cancel();
    _heartbeatTimers.remove(url);
    _lastHeartbeat.remove(url);
  }

  /// 自动重连
  void _startReconnect(String url, SSERequest request) {
    Future.delayed(const Duration(seconds: 2), () {
      addSseListen(url);
    });
  }

  /// 断开所有连接
  Future<void> disconnectAll() async {
    if (kDebugMode) {
      logI('SSE Service: Disconnecting all subscriptions');
    }
    for (final url in _subscriptions.keys.toList()) {
      await disconnect(url);
    }
    _client.close();
  }

  @override
  void onClose() {
    disconnectAll();
    super.onClose();
  }
}

