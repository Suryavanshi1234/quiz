import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/questionsCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/ui/widgets/questionsContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SelfChallengeQuestionsScreen extends StatefulWidget {
  final String? categoryId;
  final String? subcategoryId;
  final int? minutes;
  final String? numberOfQuestions;

  const SelfChallengeQuestionsScreen({
    super.key,
    required this.categoryId,
    required this.minutes,
    required this.numberOfQuestions,
    required this.subcategoryId,
  });

  @override
  State<SelfChallengeQuestionsScreen> createState() =>
      _SelfChallengeQuestionsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map<dynamic, dynamic>?;

    //keys of map are categoryId,subcategoryId,minutes,numberOfQuestions
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<QuestionsCubit>(
            create: (_) => QuestionsCubit(QuizRepository()),
          ),
          BlocProvider<UpdateBookmarkCubit>(
            create: (_) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
        ],
        child: SelfChallengeQuestionsScreen(
          categoryId: arguments!['categoryId'],
          minutes: arguments['minutes'],
          numberOfQuestions: arguments['numberOfQuestions'],
          subcategoryId: arguments['subcategoryId'],
        ),
      ),
    );
  }
}

class _SelfChallengeQuestionsScreenState
    extends State<SelfChallengeQuestionsScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  late List<Question> ques;
  late AnimationController questionAnimationController;
  late AnimationController questionContentAnimationController;
  late AnimationController timerAnimationController;
  late Animation<double> questionSlideAnimation;
  late Animation<double> questionScaleUpAnimation;
  late Animation<double> questionScaleDownAnimation;
  late Animation<double> questionContentAnimation;
  late AnimationController animationController;
  late AnimationController topContainerAnimationController;

  bool isBottomSheetOpen = false;

  //to track if setting dialog is open
  bool isSettingDialogOpen = false;

  bool isExitDialogOpen = false;

  void _getQuestions() {
    Future.delayed(Duration.zero, () {
      context.read<QuestionsCubit>().getQuestions(
            QuizTypes.selfChallenge,
            categoryId: widget.categoryId,
            subcategoryId: widget.subcategoryId,
            numberOfQuestions: widget.numberOfQuestions,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          );
    });
  }

  @override
  void initState() {
    initializeAnimation();
    timerAnimationController = AnimationController(
        vsync: this, duration: Duration(minutes: widget.minutes!))
      ..addStatusListener(currentUserTimerAnimationStatusListener);

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    topContainerAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _getQuestions();
    super.initState();
  }

  void initializeAnimation() {
    questionContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
    questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 525),
    );
    questionSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    questionScaleUpAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInQuad),
      ),
    );
    questionContentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: questionContentAnimationController,
        curve: Curves.easeInQuad,
      ),
    );
    questionScaleDownAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: questionAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutQuad),
      ),
    );
  }

  @override
  void dispose() {
    timerAnimationController
        .removeStatusListener(currentUserTimerAnimationStatusListener);
    timerAnimationController.dispose();
    questionAnimationController.dispose();
    questionContentAnimationController.dispose();
    super.dispose();
  }

  void get toggleSettingDialog => isSettingDialogOpen = !isSettingDialogOpen;

  void changeQuestion({
    required bool increaseIndex,
    required int newQuestionIndex,
  }) {
    questionAnimationController.forward(from: 0.0).then((_) {
      // reset animations
      questionAnimationController.reset();
      questionContentAnimationController.reset();

      setState(() {
        if (newQuestionIndex != -1) {
          currentQuestionIndex = newQuestionIndex;
        } else {
          if (increaseIndex) {
            currentQuestionIndex++;
          } else {
            currentQuestionIndex--;
          }
        }
      });

      //load content(options, image etc) of question
      // questionAnimationController.forward();
      questionContentAnimationController.forward();
    });
  }

  //if user has submitted the answer for current question
  bool hasSubmittedAnswerForCurrentQuestion() {
    return ques[currentQuestionIndex].attempted;
  }

  //update answer locally and on cloud
  void submitAnswer(String submittedAnswer) async {
    context.read<QuestionsCubit>().updateQuestionWithAnswerAndLifeline(
          context.read<QuestionsCubit>().questions()[currentQuestionIndex].id,
          submittedAnswer,
          context.read<UserDetailsCubit>().getUserFirebaseId(),
          context.read<SystemConfigCubit>().getPlayScore(),
        ); //change question
    await Future.delayed(const Duration(milliseconds: 500));
  }

  //listener for current user timer
  void currentUserTimerAnimationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      navigateToResult();
    }
  }

  void navigateToResult() {
    if (isBottomSheetOpen) {
      Navigator.of(context).pop();
    }
    if (isSettingDialogOpen) {
      Navigator.of(context).pop();
    }
    if (isExitDialogOpen) {
      Navigator.of(context).pop();
    }

    var totalSecondsToCompleteQuiz =
        Duration(minutes: widget.minutes!).inSeconds *
            timerAnimationController.value;

    Navigator.of(context).pushReplacementNamed(Routes.result, arguments: {
      "numberOfPlayer": 1,
      "myPoints": context.read<QuestionsCubit>().currentPoints(),
      "quizType": QuizTypes.selfChallenge,
      "questions": context.read<QuestionsCubit>().questions(),
      "entryFee": 0,
      "timeTakenToCompleteQuiz": totalSecondsToCompleteQuiz,
    });
  }

  Widget hasQuestionAttemptedContainer(int questionIndex, bool attempted) {
    return GestureDetector(
      onTap: () {
        if (questionIndex != currentQuestionIndex) {
          changeQuestion(increaseIndex: true, newQuestionIndex: questionIndex);
        }
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
          ),
          color: attempted
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.background,
        ),
        margin: const EdgeInsets.all(5.0),
        height: 40.0,
        width: 40.0,
        child: Text(
          "${questionIndex + 1}",
          style: TextStyle(
            color: attempted
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void onTapBackButton() {
    isExitDialogOpen = true;
    showDialog(
      context: context,
      builder: (_) => const ExitGameDialog(),
    ).then((_) => isExitDialogOpen = false);
  }

  void openBottomSheet(List<Question> questions) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: UiUtils.bottomSheetTopRadius,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (0.6),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              Text(
                "Questions Attempted",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const Divider(),
              const SizedBox(height: 15.0),
              Wrap(
                children: List.generate(questions.length, (i) => i)
                    .map((index) => hasQuestionAttemptedContainer(
                          index,
                          questions[index].attempted,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("attemptedLbl")!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.onTertiary,
                      size: 22,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues("unAttemptedLbl")!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              CustomRoundedButton(
                onTap: () {
                  timerAnimationController.stop();
                  Navigator.of(context).pop();
                  navigateToResult();
                },
                widthPercentage: MediaQuery.of(context).size.width,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: AppLocalization.of(context)!
                    .getTranslatedValues("submitBtn")!,
                radius: 8,
                showBorder: false,
                titleColor: Theme.of(context).colorScheme.background,
                fontWeight: FontWeight.w600,
                height: 50.0,
                textSize: 18,
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    ).then((_) => isBottomSheetOpen = false);
  }

  // Widget _buildTopMenu() {
  //   return Align(
  //     alignment: Alignment.topCenter,
  //     child: Container(
  //       margin: EdgeInsets.only(
  //           right: MediaQuery.of(context).size.width *
  //               ((1.0 - UiUtils.questionContainerWidthPercentage) * 0.5),
  //           left: MediaQuery.of(context).size.width *
  //               ((1.0 - UiUtils.questionContainerWidthPercentage) * 0.5),
  //           top: MediaQuery.of(context).padding.top),
  //       child: Row(
  //         children: [
  //           CustomBackButton(
  //             onTap: () {
  //               onTapBackButton();
  //             },
  //             iconColor: Theme.of(context).colorScheme.background,
  //           ),
  //           const Spacer(),
  //           SettingButton(onPressed: () {
  //             toggleSettingDialog();
  //             showDialog(
  //                 context: context,
  //                 builder: (_) => SettingsDialogContainer()).then((value) {
  //               toggleSettingDialog();
  //             });
  //           }),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBottomMenu(BuildContext context) {
    return BlocBuilder<QuestionsCubit, QuestionsState>(
      bloc: context.read<QuestionsCubit>(),
      builder: (context, state) {
        if (state is QuestionsFetchSuccess) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.2),
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Opacity(
                    opacity: currentQuestionIndex != 0 ? 1.0 : 0.5,
                    child: IconButton(
                      onPressed: () {
                        if (!questionAnimationController.isAnimating) {
                          if (currentQuestionIndex != 0) {
                            changeQuestion(
                              increaseIndex: false,
                              newQuestionIndex: -1,
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                  padding: const EdgeInsets.only(left: 42, right: 48),
                  child: IconButton(
                    onPressed: () {
                      isBottomSheetOpen = true;
                      openBottomSheet(state.questions);
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Theme.of(context).colorScheme.background,
                      size: 40,
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.2),
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Opacity(
                    opacity:
                        currentQuestionIndex != (state.questions.length - 1)
                            ? 1.0
                            : 0.5,
                    child: IconButton(
                      onPressed: () {
                        if (!questionAnimationController.isAnimating) {
                          if (currentQuestionIndex !=
                              (state.questions.length - 1)) {
                            changeQuestion(
                                increaseIndex: true, newQuestionIndex: -1);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Duration get timer => (timerAnimationController.duration! -
      timerAnimationController.lastElapsedDuration!);

  String get remaining => (timerAnimationController.isAnimating)
      ? "${timer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timer.inSeconds.remainder(60).toString().padLeft(2, '0')}"
      : "";

  @override
  Widget build(BuildContext context) {
    final quesCubit = context.read<QuestionsCubit>();

    return WillPopScope(
      onWillPop: () {
        onTapBackButton();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          onTapBackButton: onTapBackButton,
          title: AnimatedBuilder(
            builder: (context, c) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.4),
                    width: 4,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  remaining,
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              );
            },
            animation: timerAnimationController,
          ),
        ),
        body: Stack(
          children: [
            BlocConsumer<QuestionsCubit, QuestionsState>(
                bloc: quesCubit,
                listener: (context, state) {
                  if (state is QuestionsFetchSuccess) {
                    if (!timerAnimationController.isAnimating) {
                      timerAnimationController.forward();
                    }
                  }
                },
                builder: (context, state) {
                  if (state is QuestionsFetchInProgress ||
                      state is QuestionsIntial) {
                    return const Center(child: CircularProgressContainer());
                  }
                  if (state is QuestionsFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: true,
                        errorMessageColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(convertErrorCodeToLanguageKey(
                                state.errorMessage)),
                        onTapRetry: _getQuestions,
                        showErrorImage: true,
                      ),
                    );
                  }
                  final questions = (state as QuestionsFetchSuccess).questions;
                  ques = questions;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: QuestionsContainer(
                      timerAnimationController: timerAnimationController,
                      quizType: QuizTypes.selfChallenge,
                      showAnswerCorrectness: false,
                      lifeLines: const {},
                      topPadding: MediaQuery.of(context).size.height *
                          UiUtils.getQuestionContainerTopPaddingPercentage(
                              MediaQuery.of(context).size.height),
                      hasSubmittedAnswerForCurrentQuestion:
                          hasSubmittedAnswerForCurrentQuestion,
                      questions: questions,
                      submitAnswer: submitAnswer,
                      questionContentAnimation: questionContentAnimation,
                      questionScaleDownAnimation: questionScaleDownAnimation,
                      questionScaleUpAnimation: questionScaleUpAnimation,
                      questionSlideAnimation: questionSlideAnimation,
                      currentQuestionIndex: currentQuestionIndex,
                      questionAnimationController: questionAnimationController,
                      questionContentAnimationController:
                          questionContentAnimationController,
                      guessTheWordQuestions: const [],
                      guessTheWordQuestionContainerKeys: const [],
                    ),
                  );
                }),
            BlocBuilder<QuestionsCubit, QuestionsState>(
              bloc: quesCubit,
              builder: (context, state) {
                if (state is QuestionsFetchSuccess) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBottomMenu(context),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
