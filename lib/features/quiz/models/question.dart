import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/correctAnswer.dart';

class Question {
  final String? question;
  final String? id;
  final String? categoryId;
  final String? subcategoryId;
  final String? imageUrl;
  final String? level;
  final CorrectAnswer? correctAnswer;
  final String? note;
  final String? languageId;
  final String submittedAnswerId;
  final String?
      questionType; //multiple option if type is 1, binary options type 2
  final List<AnswerOption>? answerOptions;
  final bool attempted;
  final String? audio;
  final String? audioType;
  final String? marks;

  Question(
      {this.questionType,
      this.answerOptions,
      this.correctAnswer,
      this.id,
      this.languageId,
      this.level,
      this.note,
      this.question,
      this.categoryId,
      this.imageUrl,
      this.subcategoryId,
      this.audio,
      this.audioType,
      this.attempted = false,
      this.submittedAnswerId = "",
      this.marks});

  static Question fromJson(Map questionJson) {
    print(questionJson);
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    List<String> optionIds = ["a", "b", "c", "d", "e"];
    List<AnswerOption> options = [];

    //creating answerOption model
    final queType = questionJson['question_type'] ?? '';

    if (queType == '2') {
      String ops1 = questionJson['optiona'].toString();
      String ops2 = questionJson['optionb'].toString();
      if (ops1.isNotEmpty) {
        options.add(AnswerOption(id: "a", title: ops1));
      }
      if (ops2.isNotEmpty) {
        options.add(AnswerOption(id: "b", title: ops2));
      }
    } else {
      for (var optionId in optionIds) {
        String optionTitle = questionJson["option$optionId"] ?? '';
        if (optionTitle.isNotEmpty) {
          options.add(AnswerOption(id: optionId, title: optionTitle));
        }
      }
    }

    options.shuffle();

    return Question(
      id: questionJson['id'],
      categoryId: questionJson['category'] ?? "",
      imageUrl: questionJson['image'],
      languageId: questionJson['language_id'],
      subcategoryId: questionJson['subcategory'] ?? "",
      correctAnswer: CorrectAnswer.fromJson(questionJson['answer']),
      level: questionJson['level'] ?? "",
      question: questionJson['question'],
      note: questionJson['note'] ?? "",
      questionType: questionJson['question_type'] ?? "",
      audio: questionJson['audio'] ?? "",
      audioType: questionJson['audio_type'] ?? "",
      marks: questionJson['marks'] ?? "",
      answerOptions: options,
    );
  }

  static Question fromBookmarkJson(Map questionJson) {
    //answer options is fix up to e and correct answer
    //identified this optionId (ex. a)
    List<String> optionIds = ["a", "b", "c", "d", "e"];
    List<AnswerOption> options = [];

    //creating answerOption model
    for (var optionId in optionIds) {
      String optionTitle = questionJson["option$optionId"].toString();
      if (optionTitle.isNotEmpty) {
        options.add(AnswerOption(id: optionId, title: optionTitle));
      }
    }
    options.shuffle();

    return Question(
        id: questionJson['question_id'],
        categoryId: questionJson['category'] ?? "",
        imageUrl: questionJson['image'],
        languageId: questionJson['language_id'],
        subcategoryId: questionJson['subcategory'] ?? "",
        correctAnswer: CorrectAnswer.fromJson(questionJson['answer']),
        level: questionJson['level'] ?? "",
        question: questionJson['question'],
        note: questionJson['note'] ?? "",
        questionType: questionJson['question_type'] ?? "",
        audio: questionJson['audio'] ?? "",
        audioType: questionJson['audio_type'] ?? "",
        marks: questionJson['marks'] ?? "",
        answerOptions: options);
  }

  Question updateQuestionWithAnswer({required String submittedAnswerId}) {
    return Question(
        marks: marks,
        submittedAnswerId: submittedAnswerId,
        audio: audio,
        audioType: audioType,
        answerOptions: answerOptions,
        attempted: submittedAnswerId.isEmpty ? false : true,
        categoryId: categoryId,
        correctAnswer: correctAnswer,
        id: id,
        imageUrl: imageUrl,
        languageId: languageId,
        level: level,
        note: note,
        question: question,
        questionType: questionType,
        subcategoryId: subcategoryId);
  }

  Question copyWith({String? submittedAnswer, bool? attempted}) {
    return Question(
        marks: marks,
        submittedAnswerId: submittedAnswer ?? submittedAnswerId,
        answerOptions: answerOptions,
        audio: audio,
        audioType: audioType,
        attempted: attempted ?? this.attempted,
        categoryId: categoryId,
        correctAnswer: correctAnswer,
        id: id,
        imageUrl: imageUrl,
        languageId: languageId,
        level: level,
        note: note,
        question: question,
        questionType: questionType,
        subcategoryId: subcategoryId);
  }
}
