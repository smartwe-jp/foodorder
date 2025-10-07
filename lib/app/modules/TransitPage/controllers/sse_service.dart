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
          } catch (_) {}
        }
        if (event == 'heartbeat') {
          if (kDebugMode) {
            print('SSE Service: Received event: $event');
          }
        } else if (event == 'message') {
          if (kDebugMode) {
            print('SSE Service: Received heartbeat event');
          }
          if (data != null) {
            _printService.callbackBeforePrint(event, data);
          }
        } else if (event == 'print') {
          if (data != null) {
            _printService.callbackBeforePrint(event, data);
          }
        } else {

          // if (kDebugMode) {
          //   print('SSE Service: Received event: $event');
          // }
        }

        // 每收到消息，重置75秒超时检测
        _heartbeatTimers[url]?.cancel();
        _heartbeatTimers[url] = Timer(const Duration(seconds: 75), () {
          logI('SSE Service: Heartbeat timeout for (75s) $url, reconnecting...');
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
    _heartbeatTimers[url] = Timer(const Duration(seconds: 55), () {
      logI('SSE Service: Initial heartbeat timeout (no first event in 55s) $url, reconnecting...');
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

// class SseService {
//   final SSEClient _sseClient = SSEClient();
//   StreamSubscription? _sseSubscription;
//   Timer? _heartbeatTimer;

//   final isConnected = false.obs;
//   final lastData = {}.obs;
//   final lastEvent = ''.obs;
//   final lastError = ''.obs;

//   String? _currentShopId;
//   String? _apiBaseUrl;

//   DateTime? _lastHeartbeatTime;

//   final _heartbeatTimeoutDuration = const Duration(seconds: 35);

//   // Constructor to accept domain and shopId
//   SseService(String url, String id) {
//     _apiBaseUrl = url;
//     _currentShopId = id;
//   }

//   void connect() {
//     if (_apiBaseUrl == null || _currentShopId == null) {
//       if (kDebugMode) {
//         print('SSE Service: Cannot connect without domain and Id.');
//       }
//       return;
//     }
//     if (kDebugMode) {
//       print('SSE Service: Attempting to connect to Id: $_currentShopId with base URL: $_apiBaseUrl');
//     }

//     //disconnect();

//     final url = '$_apiBaseUrl$_currentShopId';

//     if (kDebugMode) {
//       print('SSE Service: Connecting to $url...');
//     }

//     final request = SSERequest(
//       requestType: RequestMethodType.get,
//       url: url,
//       headers: {
//         'Content-Type': 'text/event-stream',
//         'Cache-Control': 'no-cache',
//         'Accept': 'text/event-stream',
//       },
//       retry: true,
//       onData: (SSEResponse response) {},
//     );

//     final stream = _sseClient.connect(_currentShopId!, request);
//     _sseSubscription = stream.listen(
//           (SSEResponse response) {
//         _resetHeartbeatTimer();

//         isConnected.value = true;
//         lastError.value = '';

//         if (response.data != null && response.data.isNotEmpty) {
//           if (response.data is String) {
//             try {
//               lastData.value = jsonDecode(response.data);
//             } catch (e) {
//               if (kDebugMode) {
//                 print('SSE Service: Failed to decode response data: $e');
//               }
//               lastData.value = {}; // Fallback to raw data
//             }
//           } else if (response.data is Map<String, dynamic>) {
//             lastData.value = response.data; // Directly assign if already a Map

//           } else {
//             if (kDebugMode) {
//               print('SSE Service: Unexpected data type: ${response.data.runtimeType}');
//             }
//             lastData.value = {}; // Fallback to string representation
//           }
//           lastEvent.value = response.event ?? 'message';
//           if (kDebugMode) {
//             print('SSE Service: Received Event: ${lastEvent.value}, Data: ${lastData.value}');
//           }
//         } else {
//           if (kDebugMode) {
//             print('SSE Service: Received a keep-alive message (heartbeat).');
//           }
//         }
//       },
//       onError: (error) {
//         if (kDebugMode) {
//           print('SSE Service: Connection error: $error');
//         }
//         lastError.value = error.toString();
//         isConnected.value = false;
//         _heartbeatTimer?.cancel();
//       },
//       onDone: () {
//         if (kDebugMode) {
//           print('SSE Service: Stream for Id: $_currentShopId has been closed.');
//         }
//         isConnected.value = false;
//         _heartbeatTimer?.cancel();
//       },
//     );

//     _resetHeartbeatTimer();
//   }

//   void _resetHeartbeatTimer() {
//     _heartbeatTimer?.cancel();

//     final now = DateTime.now();
//     if (_lastHeartbeatTime != null) {
//       final interval = now.difference(_lastHeartbeatTime!).inSeconds;
//       if (kDebugMode) {
//         print('SSE Service Id($_currentShopId): Heartbeat interval: $interval seconds.');
//       }
//     }
//     _lastHeartbeatTime = now;

//     _heartbeatTimer = Timer(_heartbeatTimeoutDuration, () {
//       if (kDebugMode) {
//         final timeoutInterval = DateTime.now().difference(_lastHeartbeatTime!).inSeconds;
//         print('SSE Service Id($_currentShopId): Triggering reconnection after $timeoutInterval seconds.');
//         print('SSE Service Id($_currentShopId): Heartbeat timeout! No message received for ${_heartbeatTimeoutDuration.inSeconds} seconds.');
//         print('SSE Service Id($_currentShopId): Forcing reconnection...');
//       }

//       if (_currentShopId != null && _apiBaseUrl != null) {
//         connect();
//       }
//     });
//   }

//   void disconnect() {
//     if (_currentShopId != null) {
//       if (kDebugMode) {
//         print('SSE Service: Disconnecting from Id: $_currentShopId');
//       }
//       _sseClient.close(connectionId: _currentShopId!);
//       _sseSubscription?.cancel();
//       _heartbeatTimer?.cancel();
//       isConnected.value = false;
//     }
//   }
// }
