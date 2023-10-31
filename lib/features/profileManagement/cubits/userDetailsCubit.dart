import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UserDetailsState {}

class UserDetailsInitial extends UserDetailsState {}

class UserDetailsFetchInProgress extends UserDetailsState {}

class UserDetailsFetchSuccess extends UserDetailsState {
  final UserProfile userProfile;

  UserDetailsFetchSuccess(this.userProfile);
}

class UserDetailsFetchFailure extends UserDetailsState {
  final String errorMessage;

  UserDetailsFetchFailure(this.errorMessage);
}

class UserDetailsCubit extends Cubit<UserDetailsState> {

  final ProfileManagementRepository _profileManagementRepository;

  UserDetailsCubit(this._profileManagementRepository)
      : super(UserDetailsInitial());

  //to fetch user details form remote
  void fetchUserDetails() async {
    emit(UserDetailsFetchInProgress());

    try {
      UserProfile userProfile =
          await _profileManagementRepository.getUserDetailsById();
      emit(UserDetailsFetchSuccess(userProfile));
    } catch (e) {
      emit(UserDetailsFetchFailure(e.toString()));
    }
  }

  String getUserName() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.name!
      : "";

  String userId() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.userId!
      : "";

  String getUserFirebaseId() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.firebaseId!
      : "";

  String? getUserMobile() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.mobileNumber
      : "";

  String? getUserEmail() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.email
      : "";

  void updateUserProfileUrl(String profileUrl) {
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;

      emit((UserDetailsFetchSuccess(
        oldUserDetails.copyWith(profileUrl: profileUrl),
      )));
    }
  }

  void updateUserProfile({
    String? profileUrl,
    String? name,
    String? allTimeRank,
    String? allTimeScore,
    String? coins,
    String? status,
    String? mobile,
    String? email,
    String? adsRemovedForUser,
  }) {
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;
      final userDetails = oldUserDetails.copyWith(
        email: email,
        mobile: mobile,
        coins: coins,
        allTimeRank: allTimeRank,
        allTimeScore: allTimeScore,
        name: name,
        profileUrl: profileUrl,
        status: status,
        adsRemovedForUser: adsRemovedForUser,
      );

      emit((UserDetailsFetchSuccess(userDetails)));
    }
  }

  //update only coins (this will be call only when updating coins after using lifeline )
  void updateCoins({int? coins, bool? addCoin}) {
    //
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;

      final currentCoins = int.parse(oldUserDetails.coins!);
      log("Coins : $currentCoins");
      final updatedCoins =
          addCoin! ? (currentCoins + coins!) : (currentCoins - coins!);
      log("After Update Coins: $updatedCoins");
      final userDetails = oldUserDetails.copyWith(
        coins: updatedCoins.toString(),
      );
      emit((UserDetailsFetchSuccess(userDetails)));
    }
  }

  //update score
  void updateScore(int? score) {
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;
      final currentScore = int.parse(oldUserDetails.allTimeScore!);
      final userDetails = oldUserDetails.copyWith(
        allTimeScore: (currentScore + score!).toString(),
      );
      emit((UserDetailsFetchSuccess(userDetails)));
    }
  }

  String? getCoins() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.coins
      : "0";

  UserProfile getUserProfile() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile
      : UserProfile();

  bool removeAds() => state is UserDetailsFetchSuccess
      ? (state as UserDetailsFetchSuccess).userProfile.adsRemovedForUser == "1"
      : false;
}
