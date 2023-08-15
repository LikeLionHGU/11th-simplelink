//전체 코드
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class SearchForm extends StatefulWidget {
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  String _searchText = '';
  List<String> _searchResults = [];

  //url에 해당하는 버튼을 화면에서 눌렀을때 해당 url을 launch하는 메서드
  //todo 아직 열리지 않는당... 이유는 몰름
  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  //구글 내에서 검색을 하는 메서드
  Future<List<dynamic>> searchGoogle(String query) async {
    final apiKey = 'AIzaSyDvGCnxpSQfvupl0YW2tjhHIEXMut3JKvU';
    final customSearchEngineId = 'c41ab699082cc4121';

    final url = Uri.https(
      'www.googleapis.com',
      '/customsearch/v1',
      {
        'key': apiKey,
        'cx': customSearchEngineId,
        'q': query,
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['items'];
    } else {
      throw Exception('Failed to load search results');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '검색어',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value.trim();
                      });
                    },
                    onSubmitted: (value) {

                      searchGoogle(value);
                    },
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _searchText.isEmpty
                      ? null
                      : () async {
                    // 비동기 함수를 호출하는 별도 함수를 추가했음
                    List<dynamic> results = await searchGoogle(_searchText);
                    setState(() {
                      // 상위 2개의 링크만 사용하도록 코드를 변경함.
                      _searchResults = results
                          .map((result) => result['link'] as String)
                          .take(2)
                          .toList();
                    });
                  },
                  child: Text('검색'),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: _searchText.isNotEmpty && _searchResults.isEmpty
                      ? CircularProgressIndicator()
                      : SizedBox(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, index) {
                String result = _searchResults[index];
                return ListTile(
                  title: Text(result),
                  onTap: () {
                    if (result.isNotEmpty) {
                      launchURL(result);
                    }
                  },
                );
              },
              itemCount: _searchResults.length,
            ),
          ),
        ],
      ),
    );
  }
}