import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import '../quizRepository.dart';

@immutable
abstract class QuizoneCategoryState {}

class QuizoneCategoryInitial extends QuizoneCategoryState {}

class QuizoneCategoryProgress extends QuizoneCategoryState {}

class QuizoneCategorySuccess extends QuizoneCategoryState {
  final List<Category> categories;
  QuizoneCategorySuccess(this.categories);
}

class QuizoneCategoryFailure extends QuizoneCategoryState {
  final String errorMessage;
  QuizoneCategoryFailure(this.errorMessage);
}

class QuizoneCategoryCubit extends Cubit<QuizoneCategoryState> {
  final QuizRepository _quizRepository;
  QuizoneCategoryCubit(this._quizRepository) : super(QuizoneCategoryInitial());

  void getQuizCategoryWithUserId({
    required String languageId,
    required String userId,
  }) async {
    emit(QuizoneCategoryProgress());
    _quizRepository
        .getCategory(languageId: languageId, type: "1", userId: userId)
        .then(
      (v) {
        emit(QuizoneCategorySuccess(v));
      },
    ).catchError(
      (e) {
        emit(QuizoneCategoryFailure(e.toString()));
      },
    );
  }

  void getQuizCategory({required String languageId}) async {
    emit(QuizoneCategoryProgress());
    _quizRepository
        .getCategorywithoutuser(languageId: languageId, type: "1")
        .then((v) => emit(QuizoneCategorySuccess(v)))
        .catchError((e) => emit(QuizoneCategoryFailure(e.toString())));
  }

  void updateState(QuizoneCategoryState updatedState) {
    emit(updatedState);
  }

  getCat() {
    if (state is QuizoneCategorySuccess) {
      return (state as QuizoneCategorySuccess).categories;
    }
    return "";
  }
}
