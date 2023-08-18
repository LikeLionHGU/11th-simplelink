import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../../response_model2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchForm extends StatefulWidget {
  final String question;
  final String initialQuery;

  const SearchForm({required this.question, required this.initialQuery});

  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  String _searchText = '';
  String _questionText = '';
  List<dynamic> _searchResults = [];
  List<Map<String, dynamic>> messages = [];
  late ResponseModel2 _responseModel;
  List<String> textBoxTexts = [];
  late List<String> searchTexts = [];
  @override
  void initState() {
    super.initState();
    _searchText = widget.initialQuery;
    _questionText = widget.question;
    _loadSearchResults();
    _keywordRec();
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

  Future<void> _keywordRec() async {
    try {
      setState(() {
        messages.add({"role": "user", "content": _searchText});
        messages.add({"role": "assistant", "content": 'Loading...'});
      });

      print("API 요청 전: ${_searchText}");
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['token']}',
        },
        body: jsonEncode({
          "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {
              "role": "user",
              "content":
                  "Give me three search keyword similar with ${_searchText} "
            }
          ],
          "model": "gpt-3.5-turbo", // Use the appropriate chat model
        }),
      );

      setState(() {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        _responseModel = ResponseModel2.fromJson(responseData);
        messages.last["content"] = _responseModel.choices.isNotEmpty
            ? (_responseModel.choices[0].message.content)
            : '';
        print(messages.last["content"]);
        searchTexts = _responseModel.choices[0].message.content
            .split('\n')
            .where((line) => line.isNotEmpty && line.contains('. '))
            .map((line) {
          final match = RegExp(r'\d+\.\s*(.+)').firstMatch(line);
          if (match != null) {
            final text = match.group(1);
            return '"$text"';
          }
          return '';
        }).toList();

        print(searchTexts);
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
    const apiKey = 'AIzaSyDvGCnxpSQfvupl0YW2tjhHIEXMut3JKvU';
    const customSearchEngineId = 'c41ab699082cc4121';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0067C0),
        title: const Text(
          "검색결과",
          style: TextStyle(
            fontFamily: "SF Pro",
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 17 / 14,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff00429A), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),

                  spreadRadius: 0,
                  blurRadius: 32,
                  offset: const Offset(0, 4), // 위치 조정
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 14, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _questionText,
                    style: const TextStyle(
                      fontFamily: "SF Pro",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff1b1b1b),
                      height: 19 / 16,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff00429A),
                    ),
                    child: const Center(
                      child: Icon(Icons.search_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Row(
            children: [
              SizedBox(width: 24),
              Icon(Icons.electric_bolt, size: 14, color: Color(0xff00429A)),
              SizedBox(width: 2),
              Text(
                "링크로 가장 빠르게 알아보세요!",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff00429a),
                  height: 14 / 12,
                ),
                textAlign: TextAlign.left,
              )
            ],
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              itemBuilder: (context, index) {
                var result = _searchResults[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // 배경색 없애기
                    border:
                        Border.all(color: Colors.grey.shade300), // 테두리 회색으로 변경
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      launchURL(result['link']);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    result['pagemap']['cse_thumbnail'] != null
                                        ? Image.network(
                                            result['pagemap']['cse_thumbnail']
                                                [0]['src'],
                                            width: 16,
                                            height: 16,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.public, size: 16),
                                    const SizedBox(width: 5),
                                    Text(
                                      result['displayLink'],
                                      style: const TextStyle(
                                        fontFamily: "SF Pro",
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff333333),
                                        height: 12 / 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  result['title'],
                                  style: const TextStyle(
                                    fontFamily: "SF Pro",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff000000),
                                    height: 14 / 12,
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  result['snippet'],
                                  style: const TextStyle(
                                    fontFamily: "SF Pro",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff888888),
                                    height: 1,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (result['pagemap']['cse_thumbnail'] != null)
                          const SizedBox(width: 5),
                        if (result['pagemap']['cse_thumbnail'] != null)
                          Image.network(
                            result['pagemap']['cse_thumbnail'][0]['src'],
                            width: 120,
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
          const Row(
            children: [
              SizedBox(width: 24),
              Icon(Icons.border_color, size: 14, color: Color(0xff00429A)),
              SizedBox(width: 2),
              Text(
                "한줄로 정리해드려요.",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff00429a),
                  height: 14 / 12,
                ),
                textAlign: TextAlign.left,
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffF1F1F1),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: const Text(
              "멋사는 중앙이 아닌 각 대학에서 모집하기에 일정과 서류/면접 질문 등이 대학마다 상이하다.",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
                height: 1.2,
              ),
            ),
          ),
          const Row(
            children: [
              SizedBox(width: 24),
              Icon(Icons.live_help, size: 14, color: Color(0xff00429A)),
              SizedBox(width: 2),
              Text(
                "이렇게 검색해보세요.",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff00429a),
                  height: 14 / 12,
                ),
                textAlign: TextAlign.left,
              )
            ],
          ),
          const SizedBox(height: 12),
          Column(children: searchTexts.map((text) => TextBox(text)).toList()),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => SearchForm(
  //       initialQuery: _responseModel.choices.isNotEmpty
  //           ? _responseModel.choices[0].message.content
  //           : '',
  //       question: promptController.text,
  //     ),
  //   ),
  // );
}

class TextBox extends StatefulWidget {
  final String text;

  const TextBox(this.text, {super.key});

  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  @override
  Widget build(BuildContext context) {
    print("로드 됨! ${widget.text}");
    final formattedText = widget.text.replaceAll('"', '');
    return Container(
      width: 342,
      height: 40,
      margin: const EdgeInsets.only(bottom: 8, left: 24, right: 24),
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 13, right: 13),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        formattedText,
        style: const TextStyle(
          fontFamily: "SF Pro",
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xff1b1b1b),
          height: 14 / 12,
        ),
      ),
    );
  }
}
