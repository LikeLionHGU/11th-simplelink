// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:google_search_api/src/app/page/bookmark.dart';
import 'package:google_search_api/src/app/page/googleSearch/googleSearch.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../response_model.dart';
import 'googleSearch/firebase.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FireBasePage firebase = FireBasePage();
  late final TextEditingController promptController;
  List<Map<String, dynamic>> messages = [];
  late ResponseModel _responseModel;
  final List<String> _previousQuestions = [
    "논문 잘 쓰는 방법",
    "민증 재발급하는 방법",
    "서울에서 경주로 가는 방법",
    "태풍 대비하는 방법",
    "개강 전 준비해야 할 일",
    "개강 전 준비해야 할 일",
    "개강 전 준비해야 할 일",
    "개강 전 준비해야 할 일",
  ];
  var _showAllPreviousQuestions = false;

  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xff0067C0),
          title: Image.asset('assets/logo.png', // 로고 이미지 경로
              width: 80),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border_outlined),
              color: Colors.white,
              onPressed: () {
                completionFun();
                // 다른 페이지로 넘어가는 동작 구현
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BookmarkPage(),
                //
                //   ),
                // );
              },
            ),
          ],
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
              decoration: const BoxDecoration(
                color: Color(0xff0067C0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              height: 300,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 100, 24, 0),
                      child: Text(
                        "무엇이든 물어보세요 \n링크로 대답해 드릴게요",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffffffff),
                            height: 1.5),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormFieldBldr(
                            promptController: promptController,
                            btnFun: completionFun)),
                  ])),
          const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Text(
                "이전에 질문했던 기록",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1b1b1b),
                  height: 24 / 20,
                ),
                textAlign: TextAlign.left,
              )),
          Expanded(
            child: FutureBuilder(
                future: firebase.getAllKeywordsByUserID(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    print("length:${snapshot.data!.length }");
                    print("bool:${_showAllPreviousQuestions }");
                    final List<String> keywords = snapshot.data!;
                    return ListView.builder(
                      itemCount: _showAllPreviousQuestions
                          ? snapshot.data!.length
                          : 5, // 최대 5개까지만 표시하거나 모두 표시
                      itemBuilder: (context, index) {
                        print(index);
                        return Card(
                            color: const Color(0xffF1F1F1),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 4),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  snapshot.data![index],
                                  style: const TextStyle(
                                      // fontFamily: "SF Pro",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff1b1b1b),
                                      height: 1),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                iconSize: 15,
                                onPressed: () {
                                  // X 버튼을 눌렀을 때의 동작 구현
                                  setState(() {
                                    snapshot.data!.removeAt(index);
                                  });
                                },
                              ),
                            ));
                      },
                    );
                  }

            if (snapshot.data!.length > 5 && !_showAllPreviousQuestions){
              TextButton(
                onPressed: () {
                  print(firebase.getTop5KeywordsByUserID());
                  completionFun();
                  setState(() {
                    _showAllPreviousQuestions = true; // "기록 더보기" 버튼을 누르면 모두 표시
                  });
                },
                child: const Text("펼쳐보기",
                    style: TextStyle(
                      fontFamily: "SF Pro",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff727781),
                      height: 14 / 12,
                      decoration: TextDecoration.underline,
                    )));}


                }
            ),
          ),
        ]));
  }

  completionFun() async {
    setState(() {
      messages.add({"role": "user", "content": promptController.text});
      messages.add({"role": "assistant", "content": 'Loading...'});
    });

    print(
        "API 요청 전: ${promptController.text} Curious about this, what should I Google? Answer only one keyword");
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
                "${promptController.text} Curious about this, what should I Google? Answer only one keyword"
          }
        ],
        "model": "gpt-3.5-turbo", // Use the appropriate chat model
      }),
    );

    setState(() {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      _responseModel = ResponseModel.fromJson(responseData);
      messages.last["content"] = _responseModel.choices.isNotEmpty
          ? (_responseModel.choices[0].message.content)
          : '';
      debugPrint(messages.last["content"]);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchForm(
          initialQuery: _responseModel.choices.isNotEmpty
              ? _responseModel.choices[0].message.content
              : '',
          question: promptController.text,
        ),
      ),
    );
  }
}

class PromptBldr extends StatelessWidget {
  const PromptBldr({super.key, required this.messages});

  final List<Map<String, dynamic>> messages;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 1.35,
        color: const Color(0xff434654),
        child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: messages.map((message) {
                      return Text(
                        message['content'],
                        textAlign: TextAlign.start,
                        style:
                            const TextStyle(fontSize: 25, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ))));
  }
}
// Align

class TextFormFieldBldr extends StatelessWidget {
  const TextFormFieldBldr(
      {super.key, required this.promptController, required this.btnFun});

  final TextEditingController promptController;
  final Function btnFun;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        cursorColor: Colors.white,
        controller: promptController,
        autofocus: true,
        style: const TextStyle(color: Colors.black87, fontSize: 16, height: 2),
        decoration: InputDecoration(
          contentPadding:

              const EdgeInsets.only(top: 12, left: 16, bottom: 12, right: 16),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff444653)),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: "질문할 내용을 입력하세요.",
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xff727781),
            height: 2,
          ),
          suffix: Container(
            width: 30,
            height: 54, // 수정된 부분

            alignment: Alignment.center,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff00429A),
            ),
            child: IconButton(
              onPressed: () => btnFun(),
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// children: [
//           Expanded(child: PromptBldr(messages: messages)),
//           TextFormFieldBldr(
//               promptController: promptController, btnFun: completionFun),
//         ],
