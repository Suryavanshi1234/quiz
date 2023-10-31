import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehensionCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/setCategoryPlayedCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/setContestLeaderboardCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/updateLevelCubit.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/statistic/cubits/updateStatisticCubit.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/radialResultContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/assets_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/user_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  final QuizTypes?
      quizType; //to show different kind of result data for different quiz type
  final int?
      numberOfPlayer; //to show different kind of resut data for number of player
  final int?
      myPoints; // will be in use when quiz is not tyoe of battle and live battle
  final List<Question>? questions; //to see reivew answers
  final BattleRoom? battleRoom; //will be in use for battle
  final String? contestId;
  final Comprehension comprehension; //
  final List<GuessTheWordQuestion>?
      guessTheWordQuestions; //questions when quiz type is guessTheWord
  final int? entryFee;

  //if quizType is quizZone then it will be in use
  //to determine to show next level button
  //it will be in use if quizType is quizZone
  final String? subcategoryMaxLevel;

  //to determine if we need to update level or not
  //it will be in use if quizType is quizZone
  final int? unlockedLevel;

  //Time taken to complete the quiz in seconds
  final double? timeTakenToCompleteQuiz;

  //has used any lifeline - it will be in use to check badge earned or not for
  //quizZone quiz type
  final bool? hasUsedAnyLifeline;

  //Exam module details
  final Exam? exam; //to get the details related exam
  final int? obtainedMarks;
  final int? examCompletedInMinutes;
  final int? correctExamAnswers;
  final int? incorrectExamAnswers;
  final String? categoryId;
  final String? subcategoryId;

  //This will be in use if quizType is audio questions
  // and guess the word
  final bool isPlayed; //

  const ResultScreen({
    super.key,
    required this.isPlayed,
    this.exam,
    this.correctExamAnswers,
    this.incorrectExamAnswers,
    this.obtainedMarks,
    this.examCompletedInMinutes,
    this.timeTakenToCompleteQuiz,
    this.hasUsedAnyLifeline,
    this.numberOfPlayer,
    this.myPoints,
    this.battleRoom,
    this.questions,
    this.unlockedLevel,
    this.quizType,
    this.subcategoryMaxLevel,
    this.contestId,
    required this.comprehension,
    this.guessTheWordQuestions,
    this.entryFee,
    this.categoryId,
    this.subcategoryId,
  });

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    //keys of map are numberOfPlayer,quizType,questions (required)
    //if quizType is not battle and liveBattle need to pass following arguments
    //myPoints
    //if quizType is quizZone then need to pass following agruments
    //subcategoryMaxLevel, unlockedLevel
    //if quizType is battle and liveBattle then need to pass following agruments
    //battleRoom
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          //to update unlocked level for given subcategory
          BlocProvider<UpdateLevelCubit>(
            create: (_) => UpdateLevelCubit(QuizRepository()),
          ),
          //to update user score and coins
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          //to update statistic
          BlocProvider<UpdateStatisticCubit>(
            create: (_) => UpdateStatisticCubit(StatisticRepository()),
          ),
          //set ContestLeaderBoard
          BlocProvider<SetContestLeaderboardCubit>(
            create: (_) => SetContestLeaderboardCubit(QuizRepository()),
          ),
          //set quiz category played
          BlocProvider<SetCategoryPlayed>(
            create: (_) => SetCategoryPlayed(QuizRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: ResultScreen(
          isPlayed: arguments['isPlayed'] ?? true,
          comprehension:
              arguments['comprehension'] ?? Comprehension.fromJson({}),
          correctExamAnswers: arguments['correctExamAnswers'],
          incorrectExamAnswers: arguments['incorrectExamAnswers'],
          exam: arguments['exam'],
          obtainedMarks: arguments['obtainedMarks'],
          examCompletedInMinutes: arguments['examCompletedInMinutes'],
          myPoints: arguments['myPoints'],
          numberOfPlayer: arguments['numberOfPlayer'],
          questions: arguments['questions'],
          battleRoom: arguments['battleRoom'],
          quizType: arguments['quizType'],
          subcategoryMaxLevel: arguments['subcategoryMaxLevel'],
          unlockedLevel: arguments['unlockedLevel'],
          guessTheWordQuestions: arguments['guessTheWordQuestions'],
          //
          categoryId: arguments["categoryId"] ?? "",

          subcategoryId: arguments["subcategoryId"] ?? "",
          hasUsedAnyLifeline: arguments['hasUsedAnyLifeline'],
          timeTakenToCompleteQuiz: arguments['timeTakenToCompleteQuiz'],
          contestId: arguments["contestId"],
          entryFee: arguments['entryFee'],
        ),
      ),
    );
  }

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  List<Map<String, dynamic>> usersWithRank = [];
  late final String userName;
  late bool _isWinner;
  int _earnedCoins = 0;
  String? _winnerId;

  bool _displayedAlreadyLoggedInDialog = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
    if (widget.quizType == QuizTypes.battle) {
      battleConfiguration();
      userName = "";
    } else {
      //decide winner
      if (winPercentage() >= winPercentageBreakPoint) {
        _isWinner = true;
      } else {
        _isWinner = false;
      }
      //earn coins based on percentage
      earnCoinsBasedOnWinPercentage();
      setContestLeaderboard();
      userName = context.read<UserDetailsCubit>().getUserName();
    }

    //check for badges
    //update score,coins and statistic related details

    Future.delayed(Duration.zero, () {
      //earnBadge will check the condition for unlocking badges and
      //will return true or false
      //we need to return bool value so we can pass this to
      //updateScoreAndCoinsCubit since dashing_debut badge will unlock
      //from set_user_coin_score api
      _earnBadges();
      _updateScoreAndCoinsDetails();
      _updateStatistics();
      //fetchUpdateUserDetails();
    });
  }

  fetchUpdateUserDetails() {
    if (widget.quizType == QuizTypes.quizZone ||
        widget.quizType == QuizTypes.funAndLearn ||
        widget.quizType == QuizTypes.guessTheWord ||
        widget.quizType == QuizTypes.audioQuestions ||
        widget.quizType == QuizTypes.mathMania) {
      context.read<UserDetailsCubit>().fetchUserDetails();
    }
  }

  void _updateStatistics() {
    if (widget.quizType != QuizTypes.selfChallenge &&
        widget.quizType != QuizTypes.exam) {
      context.read<UpdateStatisticCubit>().updateStatistic(
            answeredQuestion: attemptedQuestion(),
            categoryId: getCategoryIdOfQuestion(),
            userId: context.read<UserDetailsCubit>().userId(),
            correctAnswers: correctAnswer(),
            winPercentage: winPercentage(),
          );
    }
  }

  //update stats related to battle, score of user and coins given to winner
  void battleConfiguration() async {
    String winnerId = "";

    if (widget.battleRoom!.user1!.points == widget.battleRoom!.user2!.points) {
      _isWinner = true;
      _winnerId = winnerId;
      _updateCoinsAndScoreAndStatisticForBattle(widget.battleRoom!.entryFee!);
    } else {
      if (widget.battleRoom!.user1!.points > widget.battleRoom!.user2!.points) {
        winnerId = widget.battleRoom!.user1!.uid;
      } else {
        winnerId = widget.battleRoom!.user2!.uid;
      }
      await Future.delayed(Duration.zero);
      _isWinner = context.read<UserDetailsCubit>().userId() == winnerId;
      _winnerId = winnerId;
      _updateCoinsAndScoreAndStatisticForBattle(
          widget.battleRoom!.entryFee! * 2);
      //update winner id and _isWinner in ui
      setState(() {});
    }
  }

  void _updateCoinsAndScoreAndStatisticForBattle(int earnedCoins) {
    Future.delayed(
      Duration.zero,
      () {
        //
        String currentUserId = context.read<UserDetailsCubit>().userId();
        UserBattleRoomDetails currentUser =
            widget.battleRoom!.user1!.uid == currentUserId
                ? widget.battleRoom!.user1!
                : widget.battleRoom!.user2!;
        if (_isWinner) {
          //update score and coins for user
          context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
                currentUserId,
                currentUser.points,
                true,
                earnedCoins,
                wonBattleKey,
              );
          //update score locally and database
          context.read<UserDetailsCubit>().updateCoins(
                addCoin: true,
                coins: earnedCoins,
              );
          context.read<UserDetailsCubit>().updateScore(currentUser.points);

          //update battle stats

          context.read<UpdateStatisticCubit>().updateBattleStatistic(
                userId1: currentUserId == widget.battleRoom!.user1!.uid
                    ? widget.battleRoom!.user1!.uid
                    : widget.battleRoom!.user2!.uid,
                userId2: widget.battleRoom!.user1!.uid != currentUserId
                    ? widget.battleRoom!.user1!.uid
                    : widget.battleRoom!.user2!.uid,
                winnerId: _winnerId!,
              );
        } else {
          //if user is not winner then update only score
          context.read<UpdateScoreAndCoinsCubit>().updateScore(
                currentUserId,
                currentUser.points,
              );
          context.read<UserDetailsCubit>().updateScore(currentUser.points);
        }
      },
    );
  }

  void _earnBadges() {
    String userId = context.read<UserDetailsCubit>().userId();
    BadgesCubit badgesCubit = context.read<BadgesCubit>();
    if (widget.quizType == QuizTypes.battle) {
      //if badges is locked
      if (badgesCubit.isBadgeLocked("ultimate_player")) {
        int badgeEarnPoints =
            (correctAnswerPointsForBattle + extraPointForQuickestAnswer) *
                totalQuestions();

        //if user's points is same as highest points
        UserBattleRoomDetails currentUser =
            widget.battleRoom!.user1!.uid == userId
                ? widget.battleRoom!.user1!
                : widget.battleRoom!.user2!;
        if (currentUser.points == badgeEarnPoints) {
          badgesCubit.setBadge(badgeType: "ultimate_player", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      //
      //if totalQuestion is less than minimum question then do not check for badges
      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      //funAndLearn is related to flashback
      if (badgesCubit.isBadgeLocked("flashback")) {
        int funNLearnQuestionMinimumTimeForBadge =
            badgesCubit.getBadgeCounterByType("flashback");
        //if badges not loaded some how
        if (funNLearnQuestionMinimumTimeForBadge == -1) {
          return;
        }
        int badgeEarnTimeInSeconds =
            totalQuestions() * funNLearnQuestionMinimumTimeForBadge;
        if (correctAnswer() == totalQuestions() &&
            widget.timeTakenToCompleteQuiz! <=
                badgeEarnTimeInSeconds.toDouble()) {
          badgesCubit.setBadge(badgeType: "flashback", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (badgesCubit.isBadgeLocked("dashing_debut")) {
        badgesCubit.setBadge(badgeType: "dashing_debut", userId: userId);
      }
      //
      //if totalQuestion is less than minimum question then do not check for badges

      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      if (badgesCubit.isBadgeLocked("brainiac")) {
        if (correctAnswer() == totalQuestions() &&
            !widget.hasUsedAnyLifeline!) {
          badgesCubit.setBadge(badgeType: "brainiac", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      //if totalQuestion is less than minimum question then do not check for badges
      if (totalQuestions() < minimumQuestionsForBadges) {
        return;
      }

      if (badgesCubit.isBadgeLocked("super_sonic")) {
        int guessTheWordQuestionMinimumTimeForBadge =
            badgesCubit.getBadgeCounterByType("super_sonic");

        //if badges not loaded some how
        if (guessTheWordQuestionMinimumTimeForBadge == -1) {
          return;
        }

        //if user has solved the quiz with in badgeEarnTime then they can earn badge
        int badgeEarnTimeInSeconds =
            totalQuestions() * guessTheWordQuestionMinimumTimeForBadge;
        if (correctAnswer() == totalQuestions() &&
            widget.timeTakenToCompleteQuiz! <=
                badgeEarnTimeInSeconds.toDouble()) {
          badgesCubit.setBadge(badgeType: "super_sonic", userId: userId);
        }
      }
    } else if (widget.quizType == QuizTypes.dailyQuiz) {
      if (badgesCubit.isBadgeLocked("thirsty")) {
        //
        badgesCubit.setBadge(badgeType: "thirsty", userId: userId);
      }
    }
  }

  void setContestLeaderboard() async {
    await Future.delayed(Duration.zero);
    if (widget.quizType == QuizTypes.contest) {
      context.read<SetContestLeaderboardCubit>().setContestLeaderboard(
            userId: context.read<UserDetailsCubit>().userId(),
            questionAttended: attemptedQuestion(),
            correctAns: correctAnswer(),
            contestId: widget.contestId,
            score: widget.myPoints,
          );
    }
  }

  String _getCoinUpdateTypeBasedOnQuizZone() {
    if (widget.quizType == QuizTypes.quizZone) {
      return wonQuizZoneKey;
    }
    if (widget.quizType == QuizTypes.mathMania) {
      return wonMathQuizKey;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return wonGuessTheWordKey;
    }
    if (widget.quizType == QuizTypes.trueAndFalse) {
      return wonTrueFalseKey;
    }
    if (widget.quizType == QuizTypes.dailyQuiz) {
      return wonDailyQuizKey;
    }
    if (widget.quizType == QuizTypes.audioQuestions) {
      return wonAudioQuizKey;
    }
    if (widget.quizType == QuizTypes.funAndLearn) {
      return wonFunNLearnKey;
    }
    return "-";
  }

  void _updateCoinsAndScore() {
    //update score and coins for user
    context.read<UpdateScoreAndCoinsCubit>().updateCoinsAndScore(
          context.read<UserDetailsCubit>().userId(),
          widget.myPoints!,
          true,
          _earnedCoins,
          _getCoinUpdateTypeBasedOnQuizZone(),
        );
    //update score locally and database
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: _earnedCoins,
        );

    context.read<UserDetailsCubit>().updateScore(widget.myPoints);
  }

  //
  void _updateScoreAndCoinsDetails() {
    //if percentage is more than 30 then update socre and coins
    if (_isWinner) {
      //
      //if quizType is quizZone we need to update unlocked level,coins and score
      //only one time
      //
      if (widget.quizType == QuizTypes.quizZone) {
        //if given level is same as unlocked level then update level
        if (int.parse(widget.questions!.first.level!) == widget.unlockedLevel) {
          int updatedLevel = int.parse(widget.questions!.first.level!) + 1;
          //update level

          print("update level body ${widget.subcategoryId == "0"}");
          print("update level body ${widget.subcategoryId.runtimeType}");
          context.read<UpdateLevelCubit>().updateLevel(
                context.read<UserDetailsCubit>().userId(),
                widget.categoryId,
                widget.subcategoryId,
                updatedLevel.toString(),
              );

          _updateCoinsAndScore();
        } else {
          print("Level already unlocked so no coins and score updates");
        }
        if (widget.subcategoryId == "0") {
          context.read<UnlockedLevelCubit>().fetchUnlockLevel(
                context.read<UserDetailsCubit>().userId(),
                widget.categoryId,
                "0",
              );
        } else {
          context.read<SubCategoryCubit>().fetchSubCategory(
              widget.categoryId!, context.read<UserDetailsCubit>().userId());
        }
      }
      //
      else if (widget.quizType == QuizTypes.funAndLearn &&
          !widget.comprehension.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.funAndLearn,
            userId: context.read<UserDetailsCubit>().userId(),
            categoryId: widget.questions!.first.categoryId!,
            subcategoryId: widget.questions!.first.subcategoryId! == "0"
                ? ""
                : widget.questions!.first.subcategoryId!,
            typeId: widget.comprehension.id!);
      }
      //
      else if (widget.quizType == QuizTypes.guessTheWord && !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.guessTheWord,
            userId: context.read<UserDetailsCubit>().userId(),
            categoryId: widget.guessTheWordQuestions!.first.category,
            subcategoryId:
                widget.guessTheWordQuestions!.first.subcategory == "0"
                    ? ""
                    : widget.guessTheWordQuestions!.first.subcategory,
            typeId: "");
      } else if (widget.quizType == QuizTypes.audioQuestions &&
          !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.audioQuestions,
            userId: context.read<UserDetailsCubit>().userId(),
            categoryId: widget.questions!.first.categoryId!,
            subcategoryId: widget.questions!.first.subcategoryId! == "0"
                ? ""
                : widget.questions!.first.subcategoryId!,
            typeId: "");
      } else if (widget.quizType == QuizTypes.mathMania && !widget.isPlayed) {
        _updateCoinsAndScore();
        context.read<SetCategoryPlayed>().setCategoryPlayed(
            quizType: QuizTypes.mathMania,
            userId: context.read<UserDetailsCubit>().userId(),
            categoryId: widget.questions!.first.categoryId!,
            subcategoryId: widget.questions!.first.subcategoryId! == "0"
                ? ""
                : widget.questions!.first.subcategoryId!,
            typeId: "");
      }
    }
    fetchUpdateUserDetails();
  }

  void earnCoinsBasedOnWinPercentage() {
    if (_isWinner) {
      double percentage = winPercentage();
      _earnedCoins = UiUtils.coinsBasedOnWinPercentage(
          percentage,
          widget.quizType!,
          context.read<SystemConfigCubit>().getMaxPercentageWinning(),
          context.read<SystemConfigCubit>().getMaxWinningCoins());
    }
  }

  //This will execute once user press back button or go back from result screen
  //so respective data of category,sub category and fun n learn can be updated
  void onPageBackCalls() {
    if (widget.quizType == QuizTypes.funAndLearn &&
        _isWinner &&
        !widget.comprehension.isPlayed) {
      context.read<ComprehensionCubit>().getComprehension(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.questions!.first.subcategoryId! == "0"
                ? "category"
                : "subcategory",
            typeId: widget.questions!.first.subcategoryId! == "0"
                ? widget.questions!.first.categoryId!
                : widget.questions!.first.subcategoryId!,
            userId: context.read<UserDetailsCubit>().userId(),
          );
    } else if (widget.quizType == QuizTypes.audioQuestions &&
        _isWinner &&
        !widget.isPlayed) {
      //
      if (widget.questions!.first.subcategoryId == "0") {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.audioQuestions),
            userId: context.read<UserDetailsCubit>().userId());
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
            widget.questions!.first.categoryId!,
            context.read<UserDetailsCubit>().userId());
      }
    } else if (widget.quizType == QuizTypes.guessTheWord &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.guessTheWordQuestions!.first.subcategory == "0") {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.guessTheWord),
            userId: context.read<UserDetailsCubit>().userId());
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
            widget.guessTheWordQuestions!.first.category,
            context.read<UserDetailsCubit>().userId());
      }
    } else if (widget.quizType == QuizTypes.mathMania &&
        _isWinner &&
        !widget.isPlayed) {
      if (widget.questions!.first.subcategoryId == "0") {
        //update category
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type:
                UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.mathMania),
            userId: context.read<UserDetailsCubit>().userId());
      } else {
        //update subcategory
        context.read<SubCategoryCubit>().fetchSubCategory(
            widget.questions!.first.categoryId!,
            context.read<UserDetailsCubit>().userId());
      }
    } else if (widget.quizType == QuizTypes.quizZone) {
      if (widget.subcategoryId == "") {
        context.read<UnlockedLevelCubit>().fetchUnlockLevel(
              context.read<UserDetailsCubit>().userId(),
              widget.categoryId,
              "0",
            );
      } else {
        context.read<SubCategoryCubit>().fetchSubCategory(
            widget.categoryId!, context.read<UserDetailsCubit>().userId());
      }
    }
    fetchUpdateUserDetails();
  }

  String getCategoryIdOfQuestion() {
    if (widget.quizType == QuizTypes.battle) {
      return widget.battleRoom!.categoryId!.isEmpty
          ? "0"
          : widget.battleRoom!.categoryId!;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return widget.guessTheWordQuestions!.first.category;
    }
    return widget.questions!.first.categoryId!.isEmpty
        ? "-"
        : widget.questions!.first.categoryId!;
  }

  int correctAnswer() {
    if (widget.quizType == QuizTypes.exam) {
      return widget.correctExamAnswers!;
    }
    int correctAnswer = 0;
    if (widget.quizType == QuizTypes.guessTheWord) {
      for (var question in widget.guessTheWordQuestions!) {
        if (question.answer ==
            UiUtils.buildGuessTheWordQuestionAnswer(question.submittedAnswer)) {
          correctAnswer++;
        }
      }
    } else {
      for (var question in widget.questions!) {
        if (AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<AuthCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!) ==
            question.submittedAnswerId) {
          correctAnswer++;
        }
      }
    }
    return correctAnswer;
  }

  int attemptedQuestion() {
    int attemptedQuestion = 0;
    if (widget.quizType == QuizTypes.exam) {
      return 0;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      //
      for (var question in widget.guessTheWordQuestions!) {
        if (question.hasAnswered) {
          attemptedQuestion++;
        }
      }
    } else {
      //
      for (var question in widget.questions!) {
        if (question.attempted) {
          attemptedQuestion++;
        }
      }
    }
    return attemptedQuestion;
  }

  double winPercentage() {
    if (widget.quizType == QuizTypes.battle) return 0.0;

    if (widget.quizType == QuizTypes.exam) {
      return (widget.obtainedMarks! * 100.0) /
          int.parse(widget.exam!.totalMarks);
    }

    if (widget.quizType == QuizTypes.guessTheWord) {
      return (correctAnswer() * 100.0) / widget.guessTheWordQuestions!.length;
    } else {
      return (correctAnswer() * 100.0) / widget.questions!.length;
    }
  }

  bool showCoinsAndScore() {
    if (widget.quizType == QuizTypes.selfChallenge ||
        widget.quizType == QuizTypes.contest ||
        widget.quizType == QuizTypes.exam) {
      return false;
    }

    if (widget.quizType == QuizTypes.quizZone) {
      return (int.parse(widget.questions!.first.level!) ==
          widget.unlockedLevel);
    }
    if (widget.quizType == QuizTypes.funAndLearn) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.comprehension.isPlayed;
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    if (widget.quizType == QuizTypes.audioQuestions) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    if (widget.quizType == QuizTypes.mathMania) {
      //if user completed more than 30% and has not played this paragraph yet
      return _isWinner && !widget.isPlayed;
    }
    return _isWinner;
  }

  int totalQuestions() {
    if (widget.quizType == QuizTypes.exam) {
      return (widget.correctExamAnswers! + widget.incorrectExamAnswers!);
    }
    if (widget.quizType == QuizTypes.guessTheWord) {
      return widget.guessTheWordQuestions!.length;
    }
    return widget.questions!.length;
  }

  Widget _buildGreetingMessage() {
    final String title;
    final String message;

    if (widget.quizType == QuizTypes.battle) {
      if (_winnerId!.isEmpty) {
        title = "matchDrawLbl";
        message = "congratulationsLbl";
      } else if (_isWinner) {
        title = "victoryLbl";
        message = "congratulationsLbl";
      } else {
        title = "defeatLbl";
        message = "betterNextLbl";
      }
    } else if (widget.quizType == QuizTypes.exam) {
      title = widget.exam!.title;
      message = examResultKey;
    } else {
      final scorePct = winPercentage();

      if (scorePct <= 30) {
        title = goodEffort;
        message = keepLearning;
      } else if (scorePct <= 50) {
        title = wellDone;
        message = makingProgress;
      } else if (scorePct <= 70) {
        title = greatJob;
        message = closerToMastery;
      } else if (scorePct <= 90) {
        title = excellentWork;
        message = keepGoing;
      } else {
        title = fantasticJob;
        message = achievedMastery;
      }
    }

    final titleStyle = TextStyle(
      fontSize: 26,
      color: Theme.of(context).colorScheme.onTertiary,
      fontWeight: FontWeights.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.quizType == QuizTypes.exam
                    ? title
                    : AppLocalization.of(context)!.getTranslatedValues(title)!,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              if (widget.quizType != QuizTypes.exam &&
                  widget.quizType != QuizTypes.battle) ...[
                Text(
                  " ${userName.split(' ').first}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeights.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5.0),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.shortestSide * .85,
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues(message)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.0,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDataWithIconContainer(
    String title,
    String icon,
    EdgeInsetsGeometry margin,
  ) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      // padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * (0.2125),
      height: 33.0,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            UiUtils.getImagePath(icon),
            color: Theme.of(context).colorScheme.onTertiary,
            width: 19,
            height: 19,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeights.bold,
              fontSize: 18,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualResultContainer(String userProfileUrl) {
    String lottieAnimation = _isWinner
        ? "assets/animations/confetti.json"
        : "assets/animations/defeats.json";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Don't show any confetti in exam results.
        if (widget.quizType != QuizTypes.exam) ...[
          Align(
            alignment: Alignment.topCenter,
            child: Lottie.asset(lottieAnimation, fit: BoxFit.fill),
          ),
        ],
        Align(
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double verticalSpacePercentage = 0.0;

              double radialSizePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = 0.015;
//test in
                radialSizePercentage = 0.6;
              } else {
                verticalSpacePercentage = 0.035;
                radialSizePercentage = 0.525;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildGreetingMessage(),
                  SizedBox(
                    height: constraints.maxHeight * verticalSpacePercentage,
                  ),
                  widget.quizType! == QuizTypes.exam
                      ? Transform.translate(
                          offset: const Offset(0.0, -20.0),
                          child: RadialPercentageResultContainer(
                            percentage: winPercentage(),
                            timeTakenToCompleteQuizInSeconds:
                                widget.examCompletedInMinutes,
                            size: Size(
                              constraints.maxHeight * radialSizePercentage,
                              constraints.maxHeight * radialSizePercentage,
                            ),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            UserUtils.getUserProfileWidget(
                              profileUrl: userProfileUrl,
                              width: 107,
                              height: 107,
                              // height: constraints.maxHeight *
                              //     (profileRadiusPercentage - 0.079),
                              // width: constraints.maxWidth *
                              //     (profileRadiusPercentage - 0.079 + 0.15),
                            ),
                            SvgPicture.asset(
                              UiUtils.getImagePath("hexagon_frame.svg"),
                              width: 132,
                              height: 132,
                              // height: constraints.maxHeight *
                              //     (profileRadiusPercentage),
                              // width: constraints.maxWidth *
                              //     (profileRadiusPercentage - 0.05 + 0.15),
                            ),
                          ],
                        ),
                  // SizedBox(
                  //   height: constraints.maxHeight * verticalSpacePercentage,
                  // ),
                  widget.quizType! == QuizTypes.exam
                      ? Transform.translate(
                          offset: const Offset(0, -30.0),
                          child: Text(
                            "${widget.obtainedMarks}/${widget.exam!.totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.0 *
                                  MediaQuery.of(context).textScaleFactor *
                                  (1.1),
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        )
                      : const SizedBox()
                  // : Text(
                  //     userName,
                  //     maxLines: 2,
                  //     textAlign: TextAlign.center,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeights.bold,
                  //       color: Theme.of(context).colorScheme.onTertiary,
                  //     ),
                  //   )
                ],
              );
            },
          ),
        ),

        //incorrect answer
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: _buildResultDataWithIconContainer(
            widget.quizType == QuizTypes.exam
                ? "${widget.incorrectExamAnswers}/${totalQuestions()}"
                : "${totalQuestions() - correctAnswer()}/${totalQuestions()}",
            "wrong.svg",
            EdgeInsetsDirectional.only(
              start: 15.0,
              bottom: showCoinsAndScore() ? 20.0 : 30.0,
            ),
          ),
        ),
        //correct answer
        showCoinsAndScore()
            ? Align(
                alignment: AlignmentDirectional.bottomStart,
                child: _buildResultDataWithIconContainer(
                  "${correctAnswer()}/${totalQuestions()}",
                  "correct.svg",
                  const EdgeInsetsDirectional.only(start: 15.0, bottom: 60.0),
                ),
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: _buildResultDataWithIconContainer(
                  "${correctAnswer()}/${totalQuestions()}",
                  "correct.svg",
                  const EdgeInsetsDirectional.only(end: 15.0, bottom: 30.0),
                ),
              ),

        //points
        showCoinsAndScore()
            ? Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                  "${widget.myPoints}",
                  "score.svg",
                  const EdgeInsetsDirectional.only(end: 15.0, bottom: 60.0),
                ),
              )
            : const SizedBox(),

        //earned coins
        showCoinsAndScore()
            ? Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: _buildResultDataWithIconContainer(
                  "$_earnedCoins",
                  "earnedCoin.svg",
                  const EdgeInsetsDirectional.only(end: 15.0, bottom: 20.0),
                ),
              )
            : const SizedBox(),

        //build radils percentage container
        widget.quizType! == QuizTypes.exam
            ? const SizedBox()
            : Align(
                alignment: Alignment.bottomCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double radialSizePercentage = 0.0;
                    if (constraints.maxHeight <
                        UiUtils.profileHeightBreakPointResultScreen) {
                      radialSizePercentage = 0.4;
                    } else {
                      radialSizePercentage = 0.325;
                    }
                    return Transform.translate(
                      offset: const Offset(0.0, 15.0),
                      child: RadialPercentageResultContainer(
                        percentage: winPercentage(),
                        timeTakenToCompleteQuizInSeconds:
                            widget.timeTakenToCompleteQuiz?.toInt(),
                        size: Size(
                          constraints.maxHeight * radialSizePercentage,
                          constraints.maxHeight * radialSizePercentage,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildBattleResultDetails() {
    UserBattleRoomDetails? winnerDetails =
        widget.battleRoom!.user1!.uid == _winnerId
            ? widget.battleRoom!.user1
            : widget.battleRoom!.user2;
    UserBattleRoomDetails? looserDetails =
        widget.battleRoom!.user1!.uid != _winnerId
            ? widget.battleRoom!.user1
            : widget.battleRoom!.user2;

    print("WinnerID $_isWinner");
    return _winnerId == null
        ? const SizedBox()
        : LayoutBuilder(
            builder: (context, constraints) {
              double verticalSpacePercentage = 0.0;
              if (constraints.maxHeight <
                  UiUtils.profileHeightBreakPointResultScreen) {
                verticalSpacePercentage = _winnerId!.isEmpty ? 0.035 : 0.03;
              } else {
                verticalSpacePercentage = _winnerId!.isEmpty ? 0.075 : 0.05;
              }
              return Column(
                children: [
                  _buildGreetingMessage(),
                  widget.entryFee! > 0
                      ? context.read<UserDetailsCubit>().userId() == _winnerId
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, right: 30, left: 30),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "${AppLocalization.of(context)!.getTranslatedValues("youWin")!} ${widget.entryFee! * 2} ${AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                            )
                          : _winnerId!.isEmpty
                              ? const SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        right: 30,
                                        left: 30),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      "${AppLocalization.of(context)!.getTranslatedValues("youLossLbl")!} ${widget.entryFee} ${AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary),
                                    ),
                                  ),
                                )
                      : const SizedBox(
                          height: 50,
                        ),
                  SizedBox(
                    height:
                        constraints.maxHeight * verticalSpacePercentage - 10.2,
                  ),
                  _winnerId!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        UserUtils.getUserProfileWidget(
                                          width: 80,
                                          height: 80,
                                          profileUrl: widget
                                              .battleRoom!.user1!.profileUrl,
                                        ),
                                        Center(
                                          child: SvgPicture.asset(
                                            UiUtils.getImagePath(
                                                "hexagon_frame.svg"),
                                            height: 90,
                                            width: 90,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.battleRoom!.user1!.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeights.bold,
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues(scoreLbl)} ${widget.battleRoom!.user1!.points}",
                                        style: TextStyle(
                                          fontWeight: FontWeights.bold,
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  SvgPicture.asset(
                                    AssetsUtils.getImagePath("versus.svg"),
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                  ),
                                  const SizedBox(
                                    height: 80,
                                  ),
                                  const SizedBox()
                                ],
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        UserUtils.getUserProfileWidget(
                                          width: 80,
                                          height: 80,
                                          profileUrl: widget
                                              .battleRoom!.user2!.profileUrl,
                                        ),
                                        Center(
                                          child: SvgPicture.asset(
                                            UiUtils.getImagePath(
                                                "hexagon_frame.svg"),
                                            width: 90,
                                            height: 90,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.battleRoom!.user2!.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeights.bold,
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues(scoreLbl)} ${widget.battleRoom!.user2!.points}",
                                        style: TextStyle(
                                          fontWeight: FontWeights.bold,
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        UserUtils.getUserProfileWidget(
                                          width: 80,
                                          height: 80,
                                          profileUrl: winnerDetails!.profileUrl,
                                        ),
                                        Center(
                                          child: SvgPicture.asset(
                                            UiUtils.getImagePath(
                                                "hexagon_frame.svg"),
                                            width: 90,
                                            height: 90,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      winnerDetails.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeights.bold,
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues(scoreLbl)} ${winnerDetails.points}",
                                        style: TextStyle(
                                          fontWeight: FontWeights.bold,
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  SvgPicture.asset(
                                    AssetsUtils.getImagePath("versus.svg"),
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                  ),
                                  const SizedBox(
                                    height: 80,
                                  ),
                                  const SizedBox()
                                ],
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        UserUtils.getUserProfileWidget(
                                          width: 80,
                                          height: 80,
                                          profileUrl: looserDetails!.profileUrl,
                                        ),
                                        Center(
                                          child: SvgPicture.asset(
                                            UiUtils.getImagePath(
                                                "hexagon_frame.svg"),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                            width: 90,
                                            height: 90,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      looserDetails.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeights.bold,
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues(scoreLbl)} ${looserDetails.points}",
                                        style: TextStyle(
                                          fontWeight: FontWeights.bold,
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              );
            },
          );
  }

  Widget _buildResultDetails(BuildContext context) {
    final userProfileUrl =
        context.read<UserDetailsCubit>().getUserProfile().profileUrl ?? "";

    //build results for 1 user
    if (widget.numberOfPlayer == 1) {
      return _buildIndividualResultContainer(userProfileUrl);
    }
    if (widget.numberOfPlayer == 2) {
      return _buildBattleResultDetails();
    }
    return const SizedBox();
  }

  Widget _buildResultContainer(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        height: MediaQuery.of(context).size.height * (0.560),
        width: MediaQuery.of(context).size.width * (0.90),
        decoration: BoxDecoration(
          color: _isWinner
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.onTertiary.withOpacity(.05),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: _buildResultDetails(context),
      ),
    );
  }

  Widget _buildButton(
      String buttonTitle, Function onTap, BuildContext context) {
    return CustomRoundedButton(
      widthPercentage: 0.90,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle: buttonTitle,
      radius: 8,
      elevation: 5.0,
      showBorder: false,
      fontWeight: FontWeights.regular,
      height: 50.0,
      titleColor: Theme.of(context).colorScheme.background,
      onTap: onTap,
      textSize: 20.0,
    );
  }

  //play again button will be build different for every quizType
  Widget _buildPlayAgainButton() {
    if (widget.quizType == QuizTypes.selfChallenge) {
      return const SizedBox();
    } else if (widget.quizType == QuizTypes.audioQuestions) {
      if (_isWinner) {
        return const SizedBox.shrink();
      }

      return _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("playAgainBtn")!,
          () {
        fetchUpdateUserDetails();
        Navigator.of(context).pushReplacementNamed(
          Routes.quiz,
          arguments: {
            "numberOfPlayer": 1,
            "isPlayed": widget.isPlayed,
            "quizType": QuizTypes.audioQuestions,
            "subcategoryId": widget.questions!.first.subcategoryId == "0"
                ? ""
                : widget.questions!.first.subcategoryId,
            "categoryId": widget.questions!.first.subcategoryId == "0"
                ? widget.questions!.first.categoryId
                : "",
          },
        );
      }, context);
    } else if (widget.quizType == QuizTypes.guessTheWord) {
      if (_isWinner) {
        return const SizedBox();
      }

      return _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("playAgainBtn")!,
          () {
        fetchUpdateUserDetails();
        Navigator.of(context).pushReplacementNamed(
          Routes.guessTheWord,
          arguments: {
            "isPlayed": widget.isPlayed,
            "type": widget.guessTheWordQuestions!.first.subcategory == "0"
                ? "category"
                : "subcategory",
            "typeId": widget.guessTheWordQuestions!.first.subcategory == "0"
                ? widget.guessTheWordQuestions!.first.category
                : widget.guessTheWordQuestions!.first.subcategory,
          },
        );
      }, context);
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      return Container();
    } else if (widget.quizType == QuizTypes.quizZone) {
      //if user is winner
      if (_isWinner) {
        //we need to check if currentLevel is last level or not
        int maxLevel = int.parse(widget.subcategoryMaxLevel!);
        int currentLevel = int.parse(widget.questions!.first.level!);
        if (maxLevel == currentLevel) {
          return const SizedBox.shrink();
        }
        return _buildButton(
            AppLocalization.of(context)!.getTranslatedValues("nextLevelBtn")!,
            () {
          //if given level is same as unlocked level then we need to update level
          //else do not update level
          int? unlockedLevel =
              int.parse(widget.questions!.first.level!) == widget.unlockedLevel
                  ? (widget.unlockedLevel! + 1)
                  : widget.unlockedLevel;
          //play quiz for next level
          fetchUpdateUserDetails();
          Navigator.of(context).pushReplacementNamed(
            Routes.quiz,
            arguments: {
              "numberOfPlayer": widget.numberOfPlayer,
              "quizType": widget.quizType,
              //if subcategory id is empty for question means we need to fetch quesitons by it's category
              "categoryId": widget.categoryId,
              "subcategoryId": widget.subcategoryId,
              "level": (currentLevel + 1).toString(),
              //increase level
              "subcategoryMaxLevel": widget.subcategoryMaxLevel,
              "unlockedLevel": unlockedLevel,
            },
          );
        }, context);
      }
      //if user failed to complete this level
      return _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("playAgainBtn")!,
          () {
        fetchUpdateUserDetails();
        //to play this level again (for quizZone quizType)
        Navigator.of(context).pushReplacementNamed(Routes.quiz, arguments: {
          "numberOfPlayer": widget.numberOfPlayer,
          "quizType": widget.quizType,
          //if subcategory id is empty for question means we need to fetch quesitons by it's category
          "categoryId": widget.categoryId,
          "subcategoryId": widget.subcategoryId,
          "level": widget.questions!.first.level,
          "unlockedLevel": widget.unlockedLevel,
          "subcategoryMaxLevel": widget.subcategoryMaxLevel,
        });
      }, context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildShareYourScoreButton() {
    return _buildButton(
        AppLocalization.of(context)!.getTranslatedValues("shareScoreBtn")!,
        () async {
      try {
        //capturing image
        final image = await screenshotController.capture();
        //root directory path
        final directory = (await getApplicationDocumentsDirectory()).path;

        String fileName = DateTime.now().microsecondsSinceEpoch.toString();
        //create file with given path
        File file = await File("$directory/$fileName.png").create();
        //write as bytes
        await file.writeAsBytes(image!.buffer.asUint8List());

        final appLink = context.read<SystemConfigCubit>().getAppUrl();

        final referalCode =
            context.read<UserDetailsCubit>().getUserProfile().referCode ?? "";

        final scoreText = "$appName"
            "\n${AppLocalization.of(context)!.getTranslatedValues('myScoreLbl')!}"
            "\n${AppLocalization.of(context)!.getTranslatedValues("appLink")!}"
            "\n$appLink"
            "\n${AppLocalization.of(context)!.getTranslatedValues("useMyReferral")} $referalCode ${AppLocalization.of(context)!.getTranslatedValues("toGetCoins")}";

        await Share.shareXFiles(
          [XFile(file.path)],
          text: scoreText,
        );
      } catch (e) {
        UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(defaultErrorMessageCode))!,
          context,
          false,
        );
      }
    }, context);
  }

  Widget _buildReviewAnswersButton() {
    print("widget quiz ${widget.quizType}");
    if (context.read<SystemConfigCubit>().isPaymentRequestEnable()) {
      if (widget.quizType == QuizTypes.quizZone ||
          widget.quizType == QuizTypes.audioQuestions ||
          widget.quizType == QuizTypes.guessTheWord ||
          widget.quizType == QuizTypes.funAndLearn ||
          widget.quizType == QuizTypes.mathMania) {
        return Column(
          children: [
            _buildButton(
                AppLocalization.of(context)!
                    .getTranslatedValues("reviewAnsBtn")!, () {
              //
              fetchUpdateUserDetails();
              final updateCoinsCubit = context.read<UpdateScoreAndCoinsCubit>();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  actions: [
                    TextButton(
                      onPressed: () {
                        //check if user has enough coins
                        if (int.parse(
                                context.read<UserDetailsCubit>().getCoins()!) <
                            reviewAnswersDeductCoins) {
                          UiUtils.errorMessageDialog(
                            context,
                            AppLocalization.of(context)!
                                .getTranslatedValues(notEnoughCoinsKey),
                          );
                          return;
                        }

                        //update coins

                        updateCoinsCubit.updateCoins(
                          context.read<UserDetailsCubit>().userId(),
                          reviewAnswersDeductCoins,
                          false,
                          reviewAnswerLbl,
                        );

                        context.read<UserDetailsCubit>().updateCoins(
                              addCoin: false,
                              coins: reviewAnswersDeductCoins,
                            );
                        //close the dialog

                        Navigator.of(context).pop();
                        //navigate to review answer

                        Navigator.of(context).pushNamed(
                          Routes.reviewAnswers,
                          arguments: {
                            "quizType": widget.quizType,
                            "questions":
                                widget.quizType == QuizTypes.guessTheWord
                                    ? List<Question>.from([])
                                    : widget.questions,
                            "guessTheWordQuestions":
                                widget.quizType == QuizTypes.guessTheWord
                                    ? widget.guessTheWordQuestions
                                    : List<GuessTheWordQuestion>.from([]),
                          },
                        );
                      },
                      child: Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues(continueLbl)!,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues(cancelButtonKey)!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                  content: Text(
                    "$reviewAnswersDeductCoins ${AppLocalization.of(context)!.getTranslatedValues(coinsWillBeDeductedKey)!}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              );
            }, context),
            const SizedBox(height: 15.0)
          ],
        );
      }
    }

    return Column(
      children: [
        _buildButton(
            AppLocalization.of(context)!.getTranslatedValues("reviewAnsBtn")!,
            () {
          //
          fetchUpdateUserDetails();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    //check if user has enough coins
                    if (int.parse(
                            context.read<UserDetailsCubit>().getCoins()!) <
                        reviewAnswersDeductCoins) {
                      UiUtils.errorMessageDialog(
                        context,
                        AppLocalization.of(context)!
                            .getTranslatedValues(notEnoughCoinsKey),
                      );
                      return;
                    }

                    //update coins

                    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                          context.read<UserDetailsCubit>().userId(),
                          reviewAnswersDeductCoins,
                          false,
                          reviewAnswerLbl,
                        );

                    context.read<UserDetailsCubit>().updateCoins(
                          addCoin: false,
                          coins: reviewAnswersDeductCoins,
                        );
                    //close the dialog

                    Navigator.of(context).pop();
                    //navigate to review answer

                    Navigator.of(context).pushNamed(
                      Routes.reviewAnswers,
                      arguments: {
                        "quizType": widget.quizType,
                        "questions": widget.quizType == QuizTypes.guessTheWord
                            ? List<Question>.from([])
                            : widget.questions,
                        "guessTheWordQuestions":
                            widget.quizType == QuizTypes.guessTheWord
                                ? widget.guessTheWordQuestions
                                : List<GuessTheWordQuestion>.from([]),
                      },
                    );
                  },
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(continueLbl)!,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(cancelButtonKey)!,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
              content: Text(
                "$reviewAnswersDeductCoins ${AppLocalization.of(context)!.getTranslatedValues(coinsWillBeDeductedKey)!}",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          );
        }, context),
        const SizedBox(height: 15.0)
      ],
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    double betweenButtonSpace = 15.0;
    if (widget.quizType == QuizTypes.battle) {
      return Column(
        children: [
          SizedBox(height: betweenButtonSpace),
          _buildReviewAnswersButton(),
          // SizedBox(height: betweenButtonSpace),
          _buildShareYourScoreButton(),
          SizedBox(height: betweenButtonSpace),
          _buildButton(
              AppLocalization.of(context)!.getTranslatedValues("homeBtn")!, () {
            fetchUpdateUserDetails();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, context),
        ],
      );
    }

    if (widget.quizType! == QuizTypes.exam) {
      return Column(
        children: [
          _buildShareYourScoreButton(),
          SizedBox(height: betweenButtonSpace),
          _buildButton(
              AppLocalization.of(context)!.getTranslatedValues("homeBtn")!, () {
            fetchUpdateUserDetails();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, context),
        ],
      );
    }

    return Column(
      children: [
        _buildPlayAgainButton(),
        SizedBox(height: betweenButtonSpace),
        _buildReviewAnswersButton(),
        _buildShareYourScoreButton(),
        SizedBox(height: betweenButtonSpace),
        _buildButton(
          AppLocalization.of(context)!.getTranslatedValues("homeBtn")!,
          () {
            fetchUpdateUserDetails();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          context,
        ),
        SizedBox(height: betweenButtonSpace),
      ],
    );
  }

  String appbarTitle() {
    String title = "quizResultLbl";
    switch (widget.quizType) {
      case QuizTypes.quizZone:
        title = "quizResultLbl";
        break;
      case QuizTypes.selfChallenge:
        title = "selfChallengeResult";
        break;
      case QuizTypes.audioQuestions:
        title = "audioQuizResult";
        break;
      case QuizTypes.mathMania:
        title = "mathQuizResult";
        break;
      case QuizTypes.guessTheWord:
        title = "guessTheWordResult";
        break;
      case QuizTypes.exam:
        title = "examResult";
        break;
      case QuizTypes.dailyQuiz:
        title = "dailyQuizResult";
        break;
      case QuizTypes.battle:
        title = "randomBattleResult";
        break;
      case QuizTypes.funAndLearn:
        title = "funAndLearnResult";
        break;
      case QuizTypes.trueAndFalse:
        title = "truefalseQuizResult";
        break;
      case QuizTypes.bookmarkQuiz:
        title = "bookmarkQuizResult";
        break;
      default:
        break;
    }
    return AppLocalization.of(context)!.getTranslatedValues(title)!;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        onPageBackCalls();

        return Future.value(true);
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
            listener: (context, state) {
              if (state is UpdateScoreAndCoinsFailure) {
                if (state.errorMessage == unauthorizedAccessCode) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                }
              }
            },
          ),
          BlocListener<UpdateStatisticCubit, UpdateStatisticState>(
            listener: (context, state) {
              if (state is UpdateStatisticFailure) {
                //
                if (state.errorMessageCode == unauthorizedAccessCode) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                }
              }
            },
          ),
          BlocListener<SetContestLeaderboardCubit, SetContestLeaderboardState>(
            listener: (context, state) {
              if (state is SetContestLeaderboardFailure) {
                //
                if (state.errorMessage == unauthorizedAccessCode) {
                  //already showed already logged in from other api error
                  if (!_displayedAlreadyLoggedInDialog) {
                    _displayedAlreadyLoggedInDialog = true;
                    UiUtils.showAlreadyLoggedInDialog(context: context);
                    return;
                  }
                }
              }
              if (state is SetContestLeaderboardSuccess) {
                context.read<ContestCubit>().getContest(
                      context.read<UserDetailsCubit>().userId(),
                    );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: QAppBar(
            roundedAppBar: false,
            title: Text(appbarTitle()),
            onTapBackButton: () {
              onPageBackCalls();
              Navigator.pop(context);
            },
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: _buildResultContainer(context)),
                    const SizedBox(height: 20.0),
                    _buildResultButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
