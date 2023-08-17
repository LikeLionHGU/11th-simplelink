import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SearchForm extends StatefulWidget {
  final String initialQuery;

  SearchForm({required this.initialQuery});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
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
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                var result = _searchResults[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  child: InkWell(
                    onTap: () {
                      launchURL(result['link']);
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
                                    result['pagemap']['cse_thumbnail'] != null
                                        ? Image.network(
                                      result['pagemap']['cse_thumbnail'][0]['src'],
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                    )
                                        : SizedBox(),
                                    SizedBox(width: 8),
                                    Text(
                                      result['displayLink'],
                                      style: TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  result['title'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  result['snippet'],
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (result['pagemap']['cse_thumbnail'] != null) SizedBox(width: 5),
                        if (result['pagemap']['cse_thumbnail'] != null)
                          Image.network(
                            result['pagemap']['cse_thumbnail'][0]['src'],
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
