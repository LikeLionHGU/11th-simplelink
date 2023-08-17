import 'dart:convert';
import 'package:google_search_api/src/app/page/googleSearch/googleSearch.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../response_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController promptController;
  List<Map<String, dynamic>> messages = [];
  late ResponseModel _responseModel;

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
        backgroundColor: const Color(0xff444653),
        appBar: AppBar(
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xff444653),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: PromptBldr(messages: messages)),
            TextFormFieldBldr(
                promptController: promptController, btnFun: completionFun),
          ],
        ));
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

    print("API 응답: ${response.body}");

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
                        style: TextStyle(fontSize: 25, color: Colors.white),
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
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
            child: Row(children: [
              Flexible(
                child: TextFormField(
                  cursorColor: Colors.white,
                  controller: promptController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xff444653)), // BorderSide
                      borderRadius: BorderRadius.circular(5.5),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff444653)), // BorderSide
                    ),
                    filled: true,
                    fillColor: const Color(0xff444653),
                    hintText: "Ask me anything!",
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ), // InputDecoration / TextFormField
              ), // Flexible
              Container(
                color: const Color(0xff19bc99),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                    onPressed: () => btnFun(),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ])));
  }
}
