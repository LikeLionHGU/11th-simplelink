import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'firebase.dart';

class SearchForm extends StatefulWidget {
  final String initialQuery;

  SearchForm({required this.initialQuery});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  FireBasePage firebase  = FireBasePage();
  String _searchText = '';
  List<dynamic> _searchResults = [];


  @override
  void initState() {
    super.initState();
    _searchText = widget.initialQuery;
    _loadSearchResults();
  }

  Future<void> _loadSearchResults() async {
    try {
      List<dynamic> results = await searchGoogle(_searchText);
      setState(() {
        _searchResults = results.map((result) => result).toList();
      });
    } catch (error) {
      print('Error loading search results: $error');
    }
  }

  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }




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
      List<dynamic> items = jsonResponse['items'];

      if (items.isNotEmpty) {
        await firebase.saveHistoryToFirebase(
          query,
          items.sublist(0, 2).map((item) => item as Map<String, dynamic>).toList(),
        );
        await firebase.saveKeywordAndUserIDToFirebase(query);
        await firebase.getAllKeywordsByUserID();
      }

      return items;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                var result = _searchResults[index];

                // 각 카드 정보별로 변수 선언
                final cseThumbnail = result['pagemap']['cse_thumbnail'];
                final displayLink = result['displayLink'];
                final title = result['title'];
                final snippet = result['snippet'];
                final link = result['link'];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  child: InkWell(
                    onTap: () {
                      launchURL(link);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    cseThumbnail != null
                                        ? Image.network(
                                      cseThumbnail[0]['src'],
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                    )
                                        : SizedBox(),
                                    SizedBox(width: 8),
                                    Text(
                                      displayLink,
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  title,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  snippet,
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (cseThumbnail != null) SizedBox(width: 5),
                        if (cseThumbnail != null)
                          Image.network(
                            cseThumbnail[0]['src'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: _searchResults.length > 2 ? 2 : _searchResults.length,
            ),
          ),
        ],
      ),
    );
  }
}
