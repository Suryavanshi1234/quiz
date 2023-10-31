class SystemConfigModel {
  // TODO: audio timer for ques [audioTimer], after timer ends show options, if user hasn't opened them.
  late String adsEnabled;
  late String adsType;
  late String androidBannerId;
  late String androidGameID;
  late String androidInterstitialId;
  late String androidRewardedId;
  late String answerMode;
  late String appLink;
  late String appMaintenance;
  late String appVersion;
  late String appVersionIos;
  late String audioQuestionMode;
  late String audioTimer;
  late String battleGroupCategoryMode;
  late String battleModeGroup;
  late String battleModeOne;
  late String battleRandomCategoryMode;
  late String coinAmount;
  late String coinLimit;
  late String contestMode;
  late String currencySymbol;
  late String dailyQuizMode;
  late String earnCoin;
  late String examMode;
  late String falseValue;
  late String fixQuestion;
  late String forceUpdate;
  late String funAndLearnTimer;
  late String funNLearnMode;
  late String guessTheWordMaxWinningCoins;
  late String guessTheWordMode;
  late String guessTheWordTimer;
  late String inAppPurchaseMode;
  late String iosAppLink;
  late String iosBannerId;
  late String iosGameID;
  late String iosInterstitialId;
  late String iosMoreApps;
  late String iosRewardedId;
  late String languageMode;
  late String lifelineDeductCoins;
  late String mathQuizMode;
  late String mathsQuizTimer;
  late String maxWinningCoins;
  late String maxWinningPercentage;
  late String moreApps;
  late String optionEMode;
  late String paymentMessage;
  late String paymentMode;
  late String perCoin;
  late String playCoins;
  late String playScore;
  late String quizTimer;
  late String randomBattleEntryCoins;
  late String randomBattleSeconds;
  late String referCoin;
  late String reviewAnswersDeductCoins;
  late String rewardCoin;
  late String selfChallengeMode;
  late String selfChallengeTimer;
  late String shareAppText;
  late String showAnswerCorrectness;
  late String systemTimezone;
  late String systemTimezoneGmt;
  late String totalQuestion;
  late String trueValue;
  late String truefalseMode;
  late String welcomeBonusCoins;

  SystemConfigModel({
    required this.adsEnabled,
    required this.adsType,
    required this.androidBannerId,
    required this.androidGameID,
    required this.androidInterstitialId,
    required this.androidRewardedId,
    required this.answerMode,
    required this.appLink,
    required this.appMaintenance,
    required this.appVersion,
    required this.appVersionIos,
    required this.audioQuestionMode,
    required this.audioTimer,
    required this.battleGroupCategoryMode,
    required this.battleModeGroup,
    required this.battleModeOne,
    required this.battleRandomCategoryMode,
    required this.coinAmount,
    required this.coinLimit,
    required this.contestMode,
    required this.currencySymbol,
    required this.dailyQuizMode,
    required this.earnCoin,
    required this.examMode,
    required this.falseValue,
    required this.fixQuestion,
    required this.forceUpdate,
    required this.funAndLearnTimer,
    required this.funNLearnMode,
    required this.guessTheWordMaxWinningCoins,
    required this.guessTheWordMode,
    required this.guessTheWordTimer,
    required this.inAppPurchaseMode,
    required this.iosAppLink,
    required this.iosBannerId,
    required this.iosGameID,
    required this.iosInterstitialId,
    required this.iosMoreApps,
    required this.iosRewardedId,
    required this.languageMode,
    required this.lifelineDeductCoins,
    required this.mathQuizMode,
    required this.mathsQuizTimer,
    required this.maxWinningCoins,
    required this.maxWinningPercentage,
    required this.moreApps,
    required this.optionEMode,
    required this.paymentMessage,
    required this.paymentMode,
    required this.perCoin,
    required this.playCoins,
    required this.playScore,
    required this.quizTimer,
    required this.randomBattleEntryCoins,
    required this.randomBattleSeconds,
    required this.referCoin,
    required this.reviewAnswersDeductCoins,
    required this.rewardCoin,
    required this.selfChallengeMode,
    required this.selfChallengeTimer,
    required this.shareAppText,
    required this.showAnswerCorrectness,
    required this.systemTimezone,
    required this.systemTimezoneGmt,
    required this.totalQuestion,
    required this.trueValue,
    required this.truefalseMode,
    required this.welcomeBonusCoins,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    adsEnabled = json['in_app_ads_mode'] ?? "";
    adsType = json['ads_type'] ?? "";
    androidBannerId = json['android_banner_id'] ?? "";
    androidGameID = json['android_game_id'] ?? "";
    androidInterstitialId = json['android_interstitial_id'] ?? "";
    androidRewardedId = json['android_rewarded_id'] ?? "";
    answerMode = json['answer_mode'] ?? "";
    appLink = json['app_link'] ?? "";
    appMaintenance = json['app_maintenance'] ?? "0";
    appVersion = json['app_version'] ?? "";
    appVersionIos = json['app_version_ios'] ?? "";
    audioQuestionMode = json['audio_mode_question'] ?? "";
    audioTimer = json['audio_seconds'] ?? "";
    battleGroupCategoryMode = json['battle_group_category_mode'] ?? "";
    battleModeGroup = json['battle_mode_group'] ?? "";
    battleModeOne = json['battle_mode_one'] ?? "";
    battleRandomCategoryMode = json['battle_random_category_mode'] ?? "";
    coinAmount = json['coin_amount'] ?? "0";
    coinLimit = json['coin_limit'] ?? "0";
    contestMode = json['contest_mode'] ?? "";
    currencySymbol = json['currency_symbol'] ?? '\$';
    dailyQuizMode = json['daily_quiz_mode'] ?? "";
    earnCoin = json['earn_coin'] ?? "";
    examMode = json['exam_module'] ?? "0";
    falseValue = json['false_value'] ?? "";
    fixQuestion = json['fix_question'] ?? "";
    forceUpdate = json['force_update'] ?? "";
    funAndLearnTimer = json['fun_and_learn_time_in_seconds'] ?? "";
    funNLearnMode = json['fun_n_learn_question'] ?? "";
    guessTheWordMaxWinningCoins = json['guess_the_word_max_winning_coin'] ?? "";
    guessTheWordMode = json['guess_the_word_question'] ?? "";
    guessTheWordTimer = json['guess_the_word_seconds'] ?? "";
    inAppPurchaseMode = json['in_app_purchase_mode'] ?? "0";
    iosAppLink = json['ios_app_link'] ?? "";
    iosBannerId = json['ios_banner_id'] ?? "";
    iosGameID = json['ios_game_id'] ?? "";
    iosInterstitialId = json['ios_interstitial_id'] ?? "";
    iosMoreApps = json['ios_more_apps'] ?? "";
    iosRewardedId = json['ios_rewarded_id'] ?? "";
    languageMode = json['language_mode'] ?? "";
    lifelineDeductCoins = json['lifeline_deduct_coin'] ?? "";
    mathQuizMode = json['maths_quiz_mode'] ?? "";
    mathsQuizTimer = json['maths_quiz_seconds'] ?? "";
    maxWinningCoins = json['maximum_winning_coins'] ?? "";
    maxWinningPercentage = json['maximum_coins_winning_percentage'] ?? "";
    moreApps = json['more_apps'] ?? "";
    optionEMode = json['option_e_mode'] ?? "";
    paymentMessage = json['payment_message'] ?? "";
    paymentMode = json['payment_mode'] ?? "0";
    perCoin = json['per_coin'] ?? "0";
    playCoins = json['coins'] ?? "";
    playScore = json['score'] ?? "";
    quizTimer = json['quiz_zone_duration'] ?? "";
    randomBattleEntryCoins = json['random_battle_entry_coin'] ?? "";
    randomBattleSeconds = json['random_battle_seconds'] ?? "";
    referCoin = json['refer_coin'] ?? "";
    reviewAnswersDeductCoins = json['review_answers_deduct_coin'] ?? "";
    rewardCoin = json['reward_coin'] ?? "";
    selfChallengeMode = json['self_challenge_mode'] ?? "0";
    selfChallengeTimer = json['self_challange_max_minutes'] ?? "";
    shareAppText = json['shareapp_text'] ?? "";
    showAnswerCorrectness = json['answer_mode'] ?? "1";
    systemTimezone = json['system_timezone'] ?? "";
    systemTimezoneGmt = json['system_timezone_gmt'] ?? "";
    totalQuestion = json['total_question'] ?? "";
    trueValue = json['true_value'] ?? "";
    truefalseMode = json['true_false_mode'] ?? "";
    welcomeBonusCoins = json['welcome_bonus_coin'] ?? "";
  }
}
