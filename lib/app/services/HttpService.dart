import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'dart:async';

import '../config/index.dart';

Future request(
  String url, {
  method,
  parameters,
  link_parameters = "",
  Duration? timeout,
  CancelToken? cancelToken,
}) async {
  //parameters = parameters ?? {};
  method = method ?? 'GET';
  Timer? timeoutTimer;
  bool didTimeout = false;
  final effectiveCancelToken = cancelToken ?? CancelToken();

  try {
    Response? response;
    Dio dio = Dio();

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final requestId = CustomLogHandler.newFlowId();
        options.extra['log_request_id'] = requestId;
        options.extra['log_started_at'] = DateTime.now().millisecondsSinceEpoch;
        logI(
          'HTTP request started',
          tag: 'HTTP',
          eventCode: 'HTTP_REQUEST_STARTED',
          flowId: requestId,
          data: {
            'method': options.method,
            'path': options.uri.path,
          },
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("Response: ${response.statusCode} ${response.data}");
        final options = response.requestOptions;
        final requestId = options.extra['log_request_id']?.toString();
        logI(
          'HTTP request succeeded',
          tag: 'HTTP',
          eventCode: 'HTTP_REQUEST_SUCCEEDED',
          flowId: requestId,
          data: {
            'method': options.method,
            'path': options.uri.path,
            'status_code': response.statusCode ?? 0,
            'duration_ms': _requestDurationMs(options),
          },
        );
        handler.next(response);
      },
      onError: (DioException e, handler) {
        final options = e.requestOptions;
        final requestId = options.extra['log_request_id']?.toString();
        logW(
          'HTTP request failed',
          tag: 'HTTP',
          eventCode: 'HTTP_REQUEST_FAILED',
          flowId: requestId,
          data: {
            'method': options.method,
            'path': options.uri.path,
            'status_code': e.response?.statusCode ?? 0,
            'duration_ms': _requestDurationMs(options),
            'dio_error_type': e.type.name,
          },
          error: e,
          stack: e.stackTrace,
        );
        handler.next(e);
      },
    ));

    //By default, Dio serializes request data(except String type) to JSON. To send data in the application/x-www-form-urlencoded format instead, you can
    if (url == "smsCode" || url == "oauthToken") {
      dio.options.contentType = Headers.formUrlEncodedContentType;
    } else {
      dio.options.contentType = Headers.jsonContentType;
    }

    if (timeout != null) {
      timeoutTimer = Timer(timeout, () {
        didTimeout = true;
        if (!effectiveCancelToken.isCancelled) {
          effectiveCancelToken
              .cancel('Request timeout after ${timeout.inSeconds}s');
        }
      });
    }

    var request_url = servicePath[url] ?? url;
    if ((link_parameters?.isNotEmpty ?? true)) {
      request_url = "${request_url}${link_parameters}";
    }

    if (method == 'GET') {
      if (parameters != null) {
        response = await dio.get(request_url,
            queryParameters: parameters, cancelToken: effectiveCancelToken);
      } else {
        response = await dio.get(
          request_url,
          cancelToken: effectiveCancelToken,
        );
      }
    } else if (method == 'POST') {
      response = await dio.post(
        request_url,
        data: parameters,
        cancelToken: effectiveCancelToken,
      );
    } else if (method == 'DELETE') {
      response = await dio.delete(
        request_url,
        data: parameters,
        cancelToken: effectiveCancelToken,
      );
    } else if (method == 'PUT') {
      response = await dio.put(
        request_url,
        data: parameters,
        cancelToken: effectiveCancelToken,
      );
    }
    if (response?.statusCode == 200) {
      //var result = json.decode(response.toString());

      return response;
    } else {
      logE(
        'HTTP request returned an unsuccessful status',
        tag: 'HTTP',
        eventCode: 'HTTP_UNSUCCESSFUL_STATUS',
        data: {
          'request_key': url,
          'method': method.toString(),
          'status_code': response?.statusCode ?? 0,
        },
      );
      throw Exception('異常が生じてます。お近くのスタッフにお声かけください。...');
    }
  } catch (e, stackTrace) {
    if (e is DioException && didTimeout) {
      logE(
        'HTTP request timed out',
        tag: 'HTTP',
        eventCode: 'HTTP_REQUEST_TIMEOUT',
        data: {
          'request_key': url,
          'method': method.toString(),
          'timeout_seconds': timeout?.inSeconds ?? 0,
        },
        error: e,
        stack: stackTrace,
      );
      throw TimeoutException('Request timeout: $url', timeout);
    }
    logE(
      'HTTP request error',
      tag: 'HTTP',
      eventCode: 'HTTP_REQUEST_ERROR',
      data: {
        'request_key': url,
        'method': method.toString(),
      },
      error: e,
      stack: stackTrace,
    );
    //if(newe.contains("502") || newe.contains("401") || newe.contains("403") || newe.contains("400") || newe.contains("404")){

    // showToast('異常が生じてます。お近くのスタッフにお声かけください〜。');
    // Future.delayed(Duration(milliseconds: 1000)).then((e) {
    //   Global.navigatorKey.currentState?.pushNamed("/transitPage");
    // });
    throw e;
  } finally {
    timeoutTimer?.cancel();
  }
}

int _requestDurationMs(RequestOptions options) {
  final startedAt = options.extra['log_started_at'];
  if (startedAt is! int) return 0;
  return DateTime.now().millisecondsSinceEpoch - startedAt;
}
