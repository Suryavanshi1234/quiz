import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/errorMessageDialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

//Need to optimize and separate the ui and other logic related process

class UiUtils {
  static const questionContainerHeightPercentage = 0.785;

  // static const quizTypeMaxHeightPercentage = 0.275;
  // static const quizTypeMinHeightPercentage = 0.185;
  static const questionContainerWidthPercentage = 0.90;

  static const profileHeightBreakPointResultScreen = 355.0;
  static double quesitonContainerWidthPercentage = 0.85;
  static const appBarHeightPercentage = 0.16;
  static const bottomMenuPercentage = 0.075;

  /// Dialog
  static const dialogHeightPercentage = 0.65;
  static const dialogWidthPercentage = 0.85;
  static const dialogBlurSigma = 9.0;
  static const dialogRadius = 40.0;

  /// Bottom Sheet
  static const bottomSheetTopRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  /// Badges
  static List<String> needToUpdateBadgesLocally = [];

  /// Global
  // Margin Percentage for Screen Content
  static const hzMarginPct = 0.04;
  static const vtMarginPct = 0.02;

  // Space in-between List Tiles
  static const listTileGap = 12.0;

  static final kAppbarBoxShadow = [
    BoxShadow(
      blurRadius: 5.0,
      color: Colors.black.withOpacity(0.3),
      offset: Offset.zero,
    )
  ];

  void bottomSheet({required BuildContext context, required Widget child}) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: bottomSheetTopRadius),
      builder: (_) => child,
    );
  }

  static String buildGuessTheWordQuestionAnswer(List<String> submittedAnswer) {
    String answer = "";
    for (var element in submittedAnswer) {
      if (element.isNotEmpty) answer = answer + element;
    }
    return answer;
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    // print(message.notification);
    var msgType = message.data['type'].toString();
    if (msgType == "badges") {
      needToUpdateBadgesLocally.add(message.data['badge_type'].toString());
    } else if (msgType == "payment_request") {
      ProfileManagementLocalDataSource.updateReversedCoins(
          double.parse(message.data['coins'].toString()).toInt());
    }
  }

  static void updateBadgesLocally(BuildContext context) {
    for (var badgeType in needToUpdateBadgesLocally) {
      context.read<BadgesCubit>().unlockBadge(badgeType);
    }
    needToUpdateBadgesLocally.clear();
  }

  static void needToUpdateCoinsLocally(BuildContext context) async {
    int coins = await ProfileManagementLocalDataSource.getUpdateReversedCoins();

    print("Need to update coins by $coins");

    if (coins != 0) {
      context.read<UserDetailsCubit>().updateCoins(addCoin: true, coins: coins);
    }
  }

  static void setSnackbar(String msg, BuildContext context, bool showAction,
      {Function? onPressedAction, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: showAction ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.background,
              fontWeight: FontWeights.regular,
              fontSize: 16.0,
            ),
          ),
        ),
        behavior: SnackBarBehavior.fixed,
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
        action: showAction
            ? SnackBarAction(
                label: "Retry",
                onPressed: onPressedAction as void Function(),
                textColor: Theme.of(context).colorScheme.background,
              )
            : null,
        elevation: 2.0,
      ),
    );
  }

  static void errorMessageDialog(BuildContext context, String? errorMessage) {
    showDialog(
      context: context,
      builder: (_) => ErrorMessageDialog(errorMessage: errorMessage),
    );
  }

  static String getImagePath(final String imageName) {
    return "assets/images/$imageName";
  }

  static String getprofileImagePath(String imageName) {
    return "assets/images/profile/$imageName";
  }

  static String getEmojiPath(String emojiName) {
    return "assets/images/emojis/$emojiName";
  }

  static BoxShadow buildBoxShadow(
      {Offset? offset, double? blurRadius, Color? color}) {
    return BoxShadow(
      color: color ?? Colors.black.withOpacity(0.1),
      blurRadius: blurRadius ?? 10.0,
      offset: offset ?? const Offset(5.0, 5.0),
    );
  }

  static String getCurrentQuestionLanguageId(BuildContext context) {
    final currentLanguage = context.read<AppLocalizationCubit>().state.language;
    if (context.read<SystemConfigCubit>().getLanguageMode() == "1") {
      final supportedLanguage =
          context.read<SystemConfigCubit>().getSupportedLanguages();
      final supportedLanguageIndex = supportedLanguage.indexWhere((element) =>
          getLocaleFromLanguageCode(element.languageCode) == currentLanguage);

      return supportedLanguageIndex == -1
          ? defaultLanguageCode
          : supportedLanguage[supportedLanguageIndex].id;
    }

    return defaultQuestionLanguageId;
  }

  static String getCurrentQuestionLanguagecode(BuildContext context) {
    final currentLanguage = context.read<AppLocalizationCubit>().state.language;
    if (context.read<SystemConfigCubit>().getLanguageMode() == "1") {
      final supportedLanguage =
          context.read<SystemConfigCubit>().getSupportedLanguages();
      final supportedLanguageIndex = supportedLanguage.indexWhere((element) =>
          getLocaleFromLanguageCode(element.languageCode) == currentLanguage);

      return supportedLanguageIndex == -1
          ? defaultLanguageCode
          : supportedLanguage[supportedLanguageIndex].languageCode;
    }

    return defaultQuestionLanguageId;
  }

  static double getTransactionContainerHeight(double dheight) {
    if (dheight >= 800) {
      return 0.1;
    }
    if (dheight >= 700) {
      return 0.145;
    }
    if (dheight >= 600) {
      return 0.165;
    }
    return 0.1775;
  }

  static double getQuestionContainerTopPaddingPercentage(double dheight) {
    if (dheight >= 800) {
      return 0.06;
    }
    if (dheight >= 700) {
      return 0.065;
    }
    if (dheight >= 600) {
      return 0.07;
    }
    return 0.075;
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");

    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static String formatNumber(int number) {
    return NumberFormat.compact().format(number).toLowerCase();
  }

  //This method will determine how much coins will user get after
  //completing the quiz
  static int coinsBasedOnWinPercentage(
    double percentage,
    QuizTypes quizType,
    double maxCoinsWinningPercentage,
    int maxWinningCoins,
  ) {
    //if percentage is more than maxCoinsWinningPercentage then user will earn maxWinningCoins
    //
    //if percentage is less than maxCoinsWinningPercentage
    //coin value will deduct from maxWinning coins
    //earned coins = (maxWinningCoins - ((maxCoinsWinningPercentage - percentage)/ 10))

    //For example: if percentage is 70 then user will
    //earn 3 coins if maxWinningCoins is 4

    int earnedCoins = 0;
    if (percentage >= maxCoinsWinningPercentage) {
      earnedCoins = quizType == QuizTypes.guessTheWord
          ? guessTheWordMaxWinningCoins
          : maxWinningCoins;
    } else {
      int maxCoins = quizType == QuizTypes.guessTheWord
          ? guessTheWordMaxWinningCoins
          : maxWinningCoins;

      earnedCoins =
          (maxCoins - ((maxCoinsWinningPercentage - percentage) / 10)).toInt();
    }

    return earnedCoins < 0 ? 0 : earnedCoins;
  }

  static String getCategoryTypeNumberFromQuizType(QuizTypes quizType) {
    //quiz_zone=1, fun_n_learn=2, guess_the_word=3, audio_question=4, maths_question=5
    if (quizType == QuizTypes.mathMania) {
      return "5";
    }
    if (quizType == QuizTypes.audioQuestions) {
      return "4";
    }
    if (quizType == QuizTypes.guessTheWord) {
      return "3";
    }
    if (quizType == QuizTypes.funAndLearn) {
      return "2";
    }
    return "1";
  }

  //calculate amount per coins based on users coins
  static double calculateAmountPerCoins({
    required int userCoins,
    required int amount,
    required int coins,
  }) {
    return (amount * userCoins) / coins;
  }

  //calculate coins based on entered amount
  static int calculateDeductedCoinsForRedeemableAmount({
    required double userEnteredAmount,
    required int amount,
    required int coins,
  }) {
    return (coins * userEnteredAmount) ~/ amount;
  }

  static Future<bool> forceUpdate(String updatedVersion) async {
    if (updatedVersion.isEmpty) {
      return false;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";

    bool updateBasedOnVersion = _shouldUpdateBasedOnVersion(
        currentVersion.split("+").first, updatedVersion.split("+").first);

    if (updatedVersion.split("+").length == 1 ||
        currentVersion.split("+").length == 1) {
      return updateBasedOnVersion;
    }

    bool updateBasedOnBuildNumber = _shouldUpdateBasedOnBuildNumber(
        currentVersion.split("+").last, updatedVersion.split("+").last);

    return (updateBasedOnVersion || updateBasedOnBuildNumber);
  }

  static bool _shouldUpdateBasedOnVersion(
      String currentVersion, String updatedVersion) {
    List<int> currentVersionList =
        currentVersion.split(".").map((e) => int.parse(e)).toList();
    List<int> updatedVersionList =
        updatedVersion.split(".").map((e) => int.parse(e)).toList();

    if (updatedVersionList[0] > currentVersionList[0]) {
      return true;
    }
    if (updatedVersionList[1] > currentVersionList[1]) {
      return true;
    }
    if (updatedVersionList[2] > currentVersionList[2]) {
      return true;
    }

    return false;
  }

  static bool _shouldUpdateBasedOnBuildNumber(
      String currentBuildNumber, String updatedBuildNumber) {
    return int.parse(updatedBuildNumber) > int.parse(currentBuildNumber);
  }

  static void vibrate() {
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  static void fetchBookmarkAndBadges(
      {required BuildContext context, required String userId}) {
    //fetch bookmark quiz zone
    if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
      print("Fetch bookmark details");
      context.read<BookmarkCubit>().getBookmark(userId);
      //delete any unused group battle room which is created by this user
      // BattleRoomRepository().deleteUnusedBattleRoom(userId);
    }

    //fetch guess the word bookmark
    if (context.read<GuessTheWordBookmarkCubit>().state
        is! GuessTheWordBookmarkFetchSuccess) {
      print("Fetch guess the word bookmark details");
      context.read<GuessTheWordBookmarkCubit>().getBookmark(userId);
    }

    //fetch audio question bookmark
    if (context.read<AudioQuestionBookmarkCubit>().state
        is! AudioQuestionBookmarkFetchSuccess) {
      print("Fetch audio question bookmark details");
      context.read<AudioQuestionBookmarkCubit>().getBookmark(userId);
    }

    if (context.read<BadgesCubit>().state is! BadgesFetchSuccess) {
      print("Fetch badges details");
      //get badges for given user
      context.read<BadgesCubit>().getBadges(userId: userId);

      //complete any pennding exam
      context.read<ExamCubit>().completePendingExams(userId: userId);
    }
  }

  static int determineBattleCorrectAnswerPoints(
      double animationControllerValue, int questionDurationInSeconds) {
    double secondsTakenToAnswer =
        (questionDurationInSeconds * animationControllerValue);

    print("Took ${secondsTakenToAnswer}s to give the answer");

    //improve points system here if needed
    if (secondsTakenToAnswer <= 2) {
      return correctAnswerPointsForBattle + extraPointForQuickestAnswer;
    } else if (secondsTakenToAnswer <= 4) {
      return correctAnswerPointsForBattle + extraPointForSecondQuickestAnswer;
    }
    return correctAnswerPointsForBattle;
  }

  static double timeTakenToSubmitAnswer(
      {required double animationControllerValue,
      required QuizTypes quizType,
      required int guessTheWordTime,
      required int quizZoneTimer}) {
    double secondsTakenToAnswer;

    if (quizType == QuizTypes.guessTheWord) {
      secondsTakenToAnswer = (guessTheWordTime * animationControllerValue);
    } else {
      secondsTakenToAnswer = (quizZoneTimer * animationControllerValue);
    }
    return secondsTakenToAnswer;
  }

  static void showAlreadyLoggedInDialog({
    required BuildContext context,
    Function()? onLoggedInCallback,
  }) {
    context.read<AuthCubit>().signOut();
    showDialog(
      context: context,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: AlreadyLoggedInDialog(
          onAlreadyLoggedInCallBack: onLoggedInCallback,
        ),
      ),
    );
  }
}
