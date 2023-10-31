import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

abstract class RewardedAdState {}

class RewardedAdInitial extends RewardedAdState {}

class RewardedAdLoaded extends RewardedAdState {}

class RewardedAdLoadInProgress extends RewardedAdState {}

class RewardedAdFailure extends RewardedAdState {}

class RewardedAdCubit extends Cubit<RewardedAdState> {
  RewardedAdCubit() : super(RewardedAdInitial());

  RewardedAd? _rewardedAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  void _createGoogleRewardedAd(BuildContext context) {
    //dispose ad and then load
    _rewardedAd?.dispose();
    RewardedAd.load(
      adUnitId: context.read<SystemConfigCubit>().googleRewardedAdId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdFailedToLoad: (error) {
        print("Rewarded ad failed to load");
        emit(RewardedAdFailure());
      }, onAdLoaded: (ad) {
        _rewardedAd = ad;
        print("Rewarded ad loaded successfully");
        emit(RewardedAdLoaded());
      }),
    );
  }

  void createUnityRewardsAd() {
    UnityAds.load(
      placementId: unityRewardsPlacement(),
      onComplete: (placementId) => emit(RewardedAdLoaded()),
      onFailed: (p, e, m) => emit(RewardedAdFailure()),
    );
  }

  void createRewardedAd(
    BuildContext context, {
    required Function onFbRewardAdCompleted,
  }) {
    emit(RewardedAdLoadInProgress());

    var sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable() &&
        !context.read<UserDetailsCubit>().removeAds()) {
      var adsType = sysConfigCubit.adsType();
      if (adsType == 1) {
        _createGoogleRewardedAd(context);
      } else {
        createUnityRewardsAd();
      }
    }
  }

  void showAd({
    required Function onAdDismissedCallback,
    required BuildContext context,
  }) {
    //if ads is enable
    var sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable() &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (state is RewardedAdLoaded) {
        //if google ad is enable
        var adsType = sysConfigCubit.adsType();
        if (adsType == 1) {
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissedCallback();
              createRewardedAd(context, onFbRewardAdCompleted: () {});
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              //need to show this reason to user
              emit(RewardedAdFailure());
              createRewardedAd(context, onFbRewardAdCompleted: () {});
            },
          );
          rewardedAd?.show(onUserEarnedReward: (_, __) => {});
        } else {
          UnityAds.showVideoAd(
            placementId: unityRewardsPlacement(),
            onComplete: (placementId) {
              onAdDismissedCallback();
              createRewardedAd(context, onFbRewardAdCompleted: () {});
            },
            onFailed: (placementId, error, message) =>
                print('Video Ad $placementId failed: $error $message'),
            onStart: (placementId) => print('Video Ad $placementId started'),
            onClick: (placementId) => print('Video Ad $placementId click'),
          );
        }
      } else if (state is RewardedAdFailure) {
        //create reward ad if ad is not loaded successfully
        createRewardedAd(context, onFbRewardAdCompleted: onAdDismissedCallback);
      }
    }
  }

  String unityRewardsPlacement() {
    if (Platform.isAndroid) {
      return "Rewarded_Android";
    }
    if (Platform.isIOS) {
      return "Rewarded_iOS";
    }

    return "";
  }

  @override
  Future<void> close() async {
    _rewardedAd?.dispose();
    return super.close();
  }
}
