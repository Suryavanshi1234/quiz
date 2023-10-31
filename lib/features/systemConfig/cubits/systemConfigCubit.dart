//State
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/systemConfig/model/supportedQuestionLanguage.dart';
import 'package:flutterquiz/features/systemConfig/model/systemConfigModel.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';
import 'package:flutterquiz/utils/constants/constants.dart';

abstract class SystemConfigState {}

class SystemConfigInitial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  final SystemConfigModel systemConfigModel;
  final List<SupportedLanguage> supportedLanguages;
  final List<String> emojis;

  final List<String> defaultProfileImages;

  SystemConfigFetchSuccess({
    required this.systemConfigModel,
    required this.defaultProfileImages,
    required this.supportedLanguages,
    required this.emojis,
  });
}

class SystemConfigFetchFailure extends SystemConfigState {
  final String errorCode;

  SystemConfigFetchFailure(this.errorCode);
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  final SystemConfigRepository _systemConfigRepository;

  SystemConfigCubit(this._systemConfigRepository)
      : super(SystemConfigInitial());

  void getSystemConfig() async {
    emit(SystemConfigFetchInProgress());
    try {
      List<SupportedLanguage> supportedLanguages = [];
      final systemConfig = await _systemConfigRepository.getSystemConfig();
      final defaultProfileImages = await _systemConfigRepository
          .getImagesFromFile("assets/files/defaultProfileImages.json");

      reviewAnswersDeductCoins =
          int.parse(systemConfig.reviewAnswersDeductCoins);
      guessTheWordMaxWinningCoins =
          int.parse(systemConfig.guessTheWordMaxWinningCoins);
      randomBattleEntryCoins = int.parse(systemConfig.randomBattleEntryCoins);
      lifeLineDeductCoins = int.parse(systemConfig.lifelineDeductCoins);
      payoutRequestCurrency = systemConfig.currencySymbol;

      final emojis = await _systemConfigRepository
          .getImagesFromFile("assets/files/emojis.json");

      if (systemConfig.languageMode == "1") {
        supportedLanguages =
            await _systemConfigRepository.getSupportedQuestionLanguages();
      }
      emit(SystemConfigFetchSuccess(
        systemConfigModel: systemConfig,
        defaultProfileImages: defaultProfileImages,
        supportedLanguages: supportedLanguages,
        emojis: emojis,
      ));
    } catch (e) {
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }

  String getLanguageMode() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.languageMode
      : defaultQuestionLanguageId;

  List<SupportedLanguage> getSupportedLanguages() =>
      state is SystemConfigFetchSuccess
          ? (state as SystemConfigFetchSuccess).supportedLanguages
          : [];

  List<String> getEmojis() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).emojis
      : [];

  SystemConfigModel getSystemDetails() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel
      : SystemConfigModel.fromJson({});

  String? getIsCategoryEnableForBattle() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .battleRandomCategoryMode
      : "0";

  String? getIsCategoryEnableForGroupBattle() =>
      state is SystemConfigFetchSuccess
          ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .battleGroupCategoryMode
          : "0";

  bool getShowCorrectAnswerMode() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.answerMode == "1"
      : true;

  bool get isDailyQuizEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.dailyQuizMode ==
          "1"
      : false;

  bool get isTrueFalseQuizEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.truefalseMode ==
          "1"
      : false;

  bool get isContestEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.contestMode == "1"
      : false;

  bool get isFunNLearnEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.funNLearnMode ==
          "1"
      : false;

  bool get isOneVsOneBattleEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.battleModeOne ==
          "1"
      : false;

  bool get isGroupBattleEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.battleModeGroup ==
          "1"
      : false;

  bool get isExamQuizEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.examMode == "1"
      : false;

  bool get isGuessTheWordEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .guessTheWordMode ==
          "1"
      : false;

  bool get isAudioQuizEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .audioQuestionMode ==
          "1"
      : false;

  String get appVersion {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .appVersionIos;
      }

      return (state as SystemConfigFetchSuccess).systemConfigModel.appVersion;
    }

    return "1.0.0+1";
  }

  String getAppUrl() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        log(
          name: 'App Link (Android)',
          (state as SystemConfigFetchSuccess).systemConfigModel.appLink,
        );

        return (state as SystemConfigFetchSuccess).systemConfigModel.appLink;
      }
      if (Platform.isIOS) {
        log(
          name: 'App Link (IOS)',
          (state as SystemConfigFetchSuccess).systemConfigModel.iosAppLink,
        );

        return (state as SystemConfigFetchSuccess).systemConfigModel.iosAppLink;
      }
    }

    return "";
  }

  String googleBannerId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .androidBannerId;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .iosBannerId;
      }
    }

    return "";
  }

  String googleInterstitialAdId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .androidInterstitialId;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .iosInterstitialId;
      }
    }

    return "";
  }

  String googleRewardedAdId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .androidRewardedId;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess)
            .systemConfigModel
            .iosRewardedId;
      }
    }

    return "";
  }

  bool get isForceUpdateEnable => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.forceUpdate == "1"
      : false;

  bool get isAppUnderMaintenance => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.appMaintenance ==
          "1"
      : false;

  String getEarnCoin() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.earnCoin
      : "0";

  String getReferCoin() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.referCoin
      : "0";

  bool isAdsEnable() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.adsEnabled == "1"
      : false;

  bool isPaymentRequestEnable() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.paymentMode == "1"
      : false;

  bool get isSelfChallengeQuizEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .selfChallengeMode ==
          "1"
      : false;

  bool isInAppPurchaseEnable() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .inAppPurchaseMode ==
          "1"
      : false;

  bool get isMathQuizEnabled => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.mathQuizMode ==
          "1"
      : false;

  int perCoin() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess).systemConfigModel.perCoin)
      : 0;

  int coinAmount() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.coinAmount)
      : 0;

  int minimumCoinLimit() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.coinLimit)
      : 0;

  int adsType() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess).systemConfigModel.adsType)
      : 0;

  String androidGameID() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.androidGameID
      : "";

  String iosGameID() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.iosGameID
      : "";

  String getPlayCoin() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel.playCoins
      : "0";

  int getPlayScore() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.playScore)
      : 0;

  int getQuizTime() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.quizTimer)
      : 0;

  int getRandomBattleSeconds() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .randomBattleSeconds)
      : 0;

  int getSelfChallengeTime() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .selfChallengeTimer)
      : 0;

  int getGuessTheWordTime() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .guessTheWordTimer)
      : 0;

  int getMathsQuizTime() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.mathsQuizTimer)
      : 0;

  int getFunAndLearnTime() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .funAndLearnTimer)
      : 0;

  int getAudioTimer() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.audioTimer)
      : 0;

  double getMaxPercentageWinning() => state is SystemConfigFetchSuccess
      ? double.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .maxWinningPercentage)
      : 0;

  int getMaxWinningCoins() => state is SystemConfigFetchSuccess
      ? int.parse(
          (state as SystemConfigFetchSuccess).systemConfigModel.maxWinningCoins)
      : 0;

  int getGuessTheWordMaxWinningCoins() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .guessTheWordMaxWinningCoins)
      : 0;

  int getRandomBattleEntryCoins() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .randomBattleEntryCoins)
      : 0;

  int getReviewAnswersDeductCoins() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .reviewAnswersDeductCoins)
      : 0;

  int getLifeLineDeductCoins() => state is SystemConfigFetchSuccess
      ? int.parse((state as SystemConfigFetchSuccess)
          .systemConfigModel
          .lifelineDeductCoins)
      : 0;
}
