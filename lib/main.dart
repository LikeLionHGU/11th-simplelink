import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_search_api/src/app/app.dart';

import 'package:html/parser.dart' as parser;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';


void main() {

  KakaoSdk.init(nativeAppKey: '32d46169335ea7d1bf052f152818d4ed');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: App()
    );
  }
}
