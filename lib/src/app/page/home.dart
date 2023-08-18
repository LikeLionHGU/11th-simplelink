import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_search_api/src/app/page/home_page.dart';
import 'package:google_search_api/src/app/page/login.dart';
import 'package:google_search_api/src/app/page/onboarding.dart';

import 'googleSearch/firebase.dart';

class Home extends StatelessWidget {

  FireBasePage firebase  = FireBasePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.data == null) {
            return OnBoarding();
          } else {
            return  HomePage();
          }
        },
      ),
    );
  }
}