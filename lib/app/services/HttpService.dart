import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'dart:async';

import '../config/http_conf.dart';
import '../config/index.dart';


Future request(String url, {method, parameters, link_parameters=""}) async {
  //parameters = parameters ?? {};
  method = method ?? 'GET';

  try {
    Response? response;
    Dio dio = Dio();

    //By default, Dio serializes request data(except String type) to JSON. To send data in the application/x-www-form-urlencoded format instead, you can
    if(url=="smsCode" || url=="oauthToken"){
      dio.options.contentType = Headers.formUrlEncodedContentType;
    }else{
      dio.options.contentType = Headers.jsonContentType;
    }


    var request_url = servicePath[url];
    if((link_parameters?.isNotEmpty ?? true)){
      request_url = "${request_url}${link_parameters}";
    }

    if (method == 'GET') {
      if(parameters != null){
        response = await dio.get(
            request_url!,
            queryParameters: parameters
        );
      }else{
        response = await dio.get(
          request_url!,

        );
      }

    } else if (method == 'POST') {
      response = await dio.post(request_url!, data: parameters);
    } else if (method == 'DELETE') {
      response = await dio.delete(request_url!, data: parameters);
    } else if (method == 'PUT') {
      response = await dio.put(request_url!, data: parameters);
    }
    if (response?.statusCode == 200) {

      //var result = json.decode(response.toString());

      return response;
    } else {

      throw Exception('異常が生じてます。お近くのスタッフにお声かけください。...');
    }

  } catch (e) {
    var newe = e.toString();
    //if(newe.contains("502") || newe.contains("401") || newe.contains("403") || newe.contains("400") || newe.contains("404")){

      showToast('異常が生じてます。お近くのスタッフにお声かけください〜。');
      Future.delayed(Duration(milliseconds: 1000)).then((e) {

        Global.navigatorKey.currentState?.pushNamed("/transitPage");
      });
    //}else{
      //showToast('異常が生じてます。お近くのスタッフにお声かけください。');
    //}
    //return print('error:::${e}');
    throw e;
  }
}
