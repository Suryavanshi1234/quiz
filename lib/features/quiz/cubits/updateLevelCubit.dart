import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class UpdateLevelState {}

class UpdateLevelInitial extends UpdateLevelState {}

class UpdateLevelInProgress extends UpdateLevelState {}

class UpdateLevelSuccess extends UpdateLevelState {}

class UpdateLevelFailure extends UpdateLevelState {
  final String errorMessage;
  UpdateLevelFailure(this.errorMessage);
}

class UpdateLevelCubit extends Cubit<UpdateLevelState> {
  final QuizRepository _quizRepository;
  UpdateLevelCubit(this._quizRepository) : super(UpdateLevelInitial());

  //to update level
  void updateLevel(String? userId, String? category, String? subCategory,
      String level) async {
    emit(UpdateLevelInProgress());
    try {
      _quizRepository.updateLevel(
          category: category,
          level: level,
          subCategory: subCategory,
          userId: userId);

      emit((UpdateLevelSuccess()));
    } catch (e) {
      print("update level error  ${e.toString()}");
      emit(UpdateLevelFailure(e.toString()));
    }
  }
}
