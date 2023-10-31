import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UpdateUserDetailState {}

class UpdateUserDetailInitial extends UpdateUserDetailState {}

class UpdateUserDetailInProgress extends UpdateUserDetailState {}

class UpdateUserDetailSuccess extends UpdateUserDetailState {}

class UpdateUserDetailFailure extends UpdateUserDetailState {
  final String errorMessage;

  UpdateUserDetailFailure(this.errorMessage);
}

class UpdateUserDetailCubit extends Cubit<UpdateUserDetailState> {
  final ProfileManagementRepository _profileManagementRepository;

  UpdateUserDetailCubit(this._profileManagementRepository)
      : super(UpdateUserDetailInitial());

  void updateState(UpdateUserDetailState newState) {
    emit(newState);
  }

  void removeAdsForUser(bool status) {
    emit(UpdateUserDetailInProgress());
    _profileManagementRepository
        .removeAdsForUser(status)
        .then((value) => emit(UpdateUserDetailSuccess()))
        .catchError((e) => emit(UpdateUserDetailFailure(e.toString())));
  }

  void updateProfile(
      {required String userId,
      required String email,
      required String name,
      required String mobile}) async {
    emit(UpdateUserDetailInProgress());
    _profileManagementRepository
        .updateProfile(
      userId: userId,
      email: email,
      mobile: mobile,
      name: name,
    )
        .then((value) {
      emit(UpdateUserDetailSuccess());
    }).catchError((e) {
      emit(UpdateUserDetailFailure(e.toString()));
    });
  }
}
