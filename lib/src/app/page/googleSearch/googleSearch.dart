//전체 코드
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SearchForm extends StatefulWidget {
  final String initialQuery; // 초기 검색어

  SearchForm({required this.initialQuery});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  String _searchText = '';
  List<String> _searchResults = [];
  @override
  void initState() {
    super.initState();
    _searchText = widget.initialQuery; // 초기 검색어 설정
    _loadSearchResults(); // Load search results
  }

  Future<void> _loadSearchResults() async {
    try {
      List<dynamic> results = await searchGoogle(_searchText);
      setState(() {
        _searchResults =
            results.map((result) => result['link'] as String).take(2).toList();
      });
    } catch (error) {
      print('Error loading search results: $error');
      // Handle error loading search results if needed
    }
  }

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
