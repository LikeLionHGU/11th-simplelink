import 'package:flutter/material.dart';
import 'package:google_search_api/src/app/app.dart';

import 'package:html/parser.dart' as parser;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 초기화
  KakaoSdk.init(nativeAppKey: '32d46169335ea7d1bf052f152818d4ed');
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: App());
  }
}
