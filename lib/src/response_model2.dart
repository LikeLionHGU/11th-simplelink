class ResponseModel2 {
  final List<ChoiceModel> choices;
  final UsageModel usage;

  ResponseModel2({
    required this.choices,
    required this.usage,
  });

  factory ResponseModel2.fromJson(Map<String, dynamic> json) {
    final choicesJson = json['choices'] as List<dynamic>? ?? [];
    final choices = choicesJson.map((choiceJson) {
      return ChoiceModel.fromJson(choiceJson);
    }).toList();

    final usage = UsageModel.fromJson(json['usage']);

    return ResponseModel2(
      choices: choices,
      usage: usage,
    );
  }
}

class ChoiceModel {
  final int index;
  final MessageModel message;
  final String finishReason;

  ChoiceModel({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      index: json['index'],
      message: MessageModel.fromJson(json['message']),
      finishReason: json['finish_reason'],
    );
  }
}

class MessageModel {
  final String role;
  final String content;

  MessageModel({
    required this.role,
    required this.content,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      role: json['role'],
      content: json['content'],
    );
  }
}

class UsageModel {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  UsageModel({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}
