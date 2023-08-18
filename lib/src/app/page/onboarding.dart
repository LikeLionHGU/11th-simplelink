import 'package:flutter/material.dart';
import 'package:google_search_api/src/app/app.dart';
import 'package:google_search_api/src/app/page/home_page.dart';
import 'login.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageViewWidget(),
            )
          ],
        ),
      ),
    );
  }
}

class PageViewWidget extends StatelessWidget {
  const PageViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller =
    PageController(initialPage: 0, viewportFraction: 1);

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      children: <Widget>[
        Container(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Image.asset('assets/Group4.png'),
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                'assets/Group3.png',
                width: 307,
                height: 72,
              ),
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/dots1.png',
                width: 48,
                height: 8,
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: [
              const SizedBox(
                height: 185,
              ),
              Image.asset('assets/search.png'),
              const SizedBox(
                height: 115,
              ),
              Image.asset(
                'assets/Group5.png',
                width: 206,
                height: 96,
              ),
              const SizedBox(
                height: 48,
              ),
              Image.asset(
                'assets/dots2.png',
                width: 48,
                height: 8,
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: [
              const SizedBox(
                height: 250,
              ),
              Image.asset('assets/example.png'),
              const SizedBox(
                height: 150,
              ),
              Image.asset(
                'assets/Group6.png',
                width: 178,
                height: 100,
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/dots3.png',
                width: 48,
                height: 8,
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                child: Image.asset(
                  'assets/start.png',
                  width: 358,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
