import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:async';
import 'package:foodorder/config/index.dart';
import 'package:flutter/material.dart';

Future request(String url, {method, parameters, link_parameters=""}) async {
  //parameters = parameters ?? {};
  method = method ?? 'GET';

  Map<String, String> formData_pinjie = {
    /*"adid": "202d82a58855159ee553397008731aaa",
    "app_platform": "app",
    "app_version": "1.0.0",
    "device_brand": "apple",
    "device_model": "iPhone9,4",
    "network_type":"",
    "os_version": "13.3.1",*/
  };

  //整理请求参数
  /*if (parameters == null) {
    parameters = formData_pinjie;
  } else {
    parameters.addAll(formData_pinjie);
  }*/

  try {
    Response response;
    Dio dio = Dio();

    //By default, Dio serializes request data(except String type) to JSON. To send data in the application/x-www-form-urlencoded format instead, you can
    if(url=="smsCode" || url=="oauthToken"){
      dio.options.contentType = Headers.formUrlEncodedContentType;
    }else{
      dio.options.contentType = Headers.jsonContentType;
    }

    /*if(token  != null){
      //print(token);
      dio.options.headers["Authorization"]="${token}";
    }*/

    var request_url = servicePath[url];
    if((link_parameters?.isNotEmpty ?? true)){
      request_url = "${request_url}${link_parameters}";
    }

    if (method == 'GET') {
      if(parameters != null){
        response = await dio.get(
            request_url,
            queryParameters: parameters
        );
      }else{
        response = await dio.get(
          request_url,

        );
      }

    } else if (method == 'POST') {
      response = await dio.post(request_url, data: parameters);
    } else if (method == 'DELETE') {
      response = await dio.delete(request_url, data: parameters);
    } else if (method == 'PUT') {
      response = await dio.put(request_url, data: parameters);
    }
    if (response.statusCode == 200) {

      //var result = json.decode(response.toString());

      return response;
    } else {

      throw Exception('后端接口异常,请检查测试代码和服务器运行情况...');
    }

  } catch (e) {
    return print('error:::${e}');
  }
}
