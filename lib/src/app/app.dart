import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_search_api/src/app/page/googleSearch/googleSearch.dart';
import 'package:google_search_api/src/app/page/home.dart';
import 'page/home_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("firebase load fail"),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
      return Home();
    }
        return const CircularProgressIndicator();
      },
    );
  }
}
