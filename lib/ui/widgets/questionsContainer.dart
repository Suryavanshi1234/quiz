import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/screens/quiz/quiz_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audioQuestionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/optionContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/lifeLine_options.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionsContainer extends StatefulWidget {
  final List<GlobalKey> guessTheWordQuestionContainerKeys;

  final List<GlobalKey>? audioQuestionContainerKeys;
  final QuizTypes quizType;
  final Function hasSubmittedAnswerForCurrentQuestion;
  final int currentQuestionIndex;
  final Function submitAnswer;
  final AnimationController questionContentAnimationController;
  final AnimationController questionAnimationController;
  final Animation<double> questionSlideAnimation;
  final Animation<double> questionScaleUpAnimation;
  final Animation<double> questionScaleDownAnimation;
  final Animation<double> questionContentAnimation;
  final List<Question> questions;
  final List<GuessTheWordQuestion> guessTheWordQuestions;
  final double? topPadding;
  final String? level;
  final Map<String, LifelineStatus> lifeLines;
  final bool? showAnswerCorrectness;
  final AnimationController timerAnimationController;
  final bool? showGuessTheWordHint;

  const QuestionsContainer({
    super.key,
    required this.submitAnswer,
    required this.quizType,
    required this.guessTheWordQuestionContainerKeys,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.currentQuestionIndex,
    required this.guessTheWordQuestions,
    required this.questionAnimationController,
    required this.questionContentAnimationController,
    required this.questionContentAnimation,
    required this.questionScaleDownAnimation,
    required this.questionScaleUpAnimation,
    required this.questionSlideAnimation,
    required this.questions,
    required this.lifeLines,
    this.showGuessTheWordHint,
    this.audioQuestionContainerKeys,
    this.showAnswerCorrectness,
    required this.timerAnimationController,
    this.level,
    this.topPadding,
  });

  @override
  State<QuestionsContainer> createState() => _QuestionsContainerState();
}

class _QuestionsContainerState extends State<QuestionsContainer> {
  List<AnswerOption> fiftyFiftyAnswerOptions = [];
  List<int> percentages = [];

  late double textSize;

  @override
  void initState() {
    textSize = widget.quizType == QuizTypes.groupPlay
        ? 20
        : context.read<SettingsCubit>().getSettings().playAreaFontSize;
    super.initState();
  }

  //to get question length
  int getQuestionsLength() {
    if (widget.questions.isNotEmpty) {
      return widget.questions.length;
    }
    return widget.guessTheWordQuestions.length;
  }

  Widget _buildOptions(Question question, BoxConstraints constraints) {
    if (widget.lifeLines.isNotEmpty) {
      if (widget.lifeLines[fiftyFifty] == LifelineStatus.using) {
        if (!question.attempted) {
          fiftyFiftyAnswerOptions = LifeLineOptions.getFiftyFiftyOptions(
            question.answerOptions!,
            AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!),
          );
        }
        //build lifeline when using 50/50 lifelines
        return Column(
          children: fiftyFiftyAnswerOptions
              .map(
                (answerOption) => OptionContainer(
                  quizType: widget.quizType,
                  submittedAnswerId: question.submittedAnswerId,
                  showAnswerCorrectness: widget.showAnswerCorrectness!,
                  showAudiencePoll: false,
                  hasSubmittedAnswerForCurrentQuestion:
                      widget.hasSubmittedAnswerForCurrentQuestion,
                  constraints: constraints,
                  answerOption: answerOption,
                  correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                    rawKey:
                        context.read<UserDetailsCubit>().getUserFirebaseId(),
                    correctAnswer: question.correctAnswer!,
                  ),
                  submitAnswer: widget.submitAnswer,
                ),
              )
              .toList(),
        );
      }

      if (widget.lifeLines[audiencePoll] == LifelineStatus.using) {
        if (!question.attempted) {
          percentages = LifeLineOptions.getAudiencePollPercentage(
              question.answerOptions!,
              AnswerEncryption.decryptCorrectAnswer(
                  rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                  correctAnswer: question.correctAnswer!));
        }

        //build options when using audience poll lifeline
        return Column(
            children: question.answerOptions!.map((option) {
          int percentageIndex = question.answerOptions!.indexOf(option);
          return OptionContainer(
            quizType: widget.quizType,
            submittedAnswerId: question.submittedAnswerId,
            showAnswerCorrectness: widget.showAnswerCorrectness!,
            showAudiencePoll: true,
            audiencePollPercentage: percentages[percentageIndex],
            hasSubmittedAnswerForCurrentQuestion:
                widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!),
            submitAnswer: widget.submitAnswer,
          );
        }).toList());
      }
      //build answer when no lifeline is in using state
      return Column(
        children: question.answerOptions!.map((option) {
          return OptionContainer(
            quizType: widget.quizType,
            submittedAnswerId: question.submittedAnswerId,
            showAnswerCorrectness: widget.showAnswerCorrectness!,
            showAudiencePoll: false,
            hasSubmittedAnswerForCurrentQuestion:
                widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: AnswerEncryption.decryptCorrectAnswer(
                rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
                correctAnswer: question.correctAnswer!),
            submitAnswer: widget.submitAnswer,
          );
        }).toList(),
      );
    }
    //build options when no need to use lifeline
    return Column(
      children: question.answerOptions!.map((option) {
        return OptionContainer(
          quizType: widget.quizType,
          submittedAnswerId: question.submittedAnswerId,
          showAnswerCorrectness: widget.showAnswerCorrectness!,
          showAudiencePoll: false,
          hasSubmittedAnswerForCurrentQuestion:
              widget.hasSubmittedAnswerForCurrentQuestion,
          constraints: constraints,
          answerOption: option,
          correctOptionId: AnswerEncryption.decryptCorrectAnswer(
              rawKey: context.read<UserDetailsCubit>().getUserFirebaseId(),
              correctAnswer: question.correctAnswer!),
          submitAnswer: widget.submitAnswer,
          trueFalseOption: question.questionType == '2',
        );
      }).toList(),
    );
  }

  Widget _buildCurrentCoins() {
    // if (widget.lifeLines.isEmpty) {
    //   return const SizedBox();
    // }
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            return Align(
              alignment: AlignmentDirectional.topEnd,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "${AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!} : ",
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: "${state.userProfile.coins}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        });
  }

  Widget _buildCurrentQuestionIndex() {
    final onTertiary = Theme.of(context).colorScheme.onTertiary;
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "${widget.currentQuestionIndex + 1}",
              style: TextStyle(
                color: onTertiary.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: " / ${widget.questions.length}",
              style: TextStyle(color: onTertiary),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText(
      {required String questionText, required String questionType}) {
    return widget.quizType == QuizTypes.mathMania
        ? TeXView(
            onRenderFinished: (_) {
              widget.timerAnimationController.forward();
            },
            child: TeXViewDocument(questionText),
            style: TeXViewStyle(
              contentColor: Theme.of(context).colorScheme.onTertiary,
              // backgroundColor: Theme.of(context).backgroundColor,
              sizeUnit: TeXViewSizeUnit.pixels,
              textAlign: TeXViewTextAlign.center,
              fontStyle: TeXViewFontStyle(fontSize: textSize.toInt() + 5),
            ),
          )
        : Text(
            questionText,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                height: 1.125,
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: textSize,
              ),
            ),
          );
  }

  Widget _buildQuestionContainer(
      double scale, int index, bool showContent, BuildContext context) {
    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        if (widget.questions.isEmpty) {
          return GuessTheWordQuestionContainer(
            showHint: widget.showGuessTheWordHint ?? true,
            timerAnimationController: widget.timerAnimationController,
            key: showContent
                ? widget.guessTheWordQuestionContainerKeys[
                    widget.currentQuestionIndex]
                : null,
            submitAnswer: widget.submitAnswer,
            constraints: constraints,
            currentQuestionIndex: widget.currentQuestionIndex,
            questions: widget.guessTheWordQuestions,
          );
        } else {
          if (widget.quizType == QuizTypes.audioQuestions) {
            return AudioQuestionContainer(
              showAnswerCorrectness: widget.showAnswerCorrectness ?? false,
              key: widget
                  .audioQuestionContainerKeys![widget.currentQuestionIndex],
              hasSubmittedAnswerForCurrentQuestion:
                  widget.hasSubmittedAnswerForCurrentQuestion,
              constraints: constraints,
              currentQuestionIndex: widget.currentQuestionIndex,
              questions: widget.questions,
              submitAnswer: widget.submitAnswer,
              timerAnimationController: widget.timerAnimationController,
            );
          }
          Question question = widget.questions[index];
          return SingleChildScrollView(
            child: Column(
              children: [
                widget.quizType == QuizTypes.battle ||
                        widget.quizType == QuizTypes.groupPlay
                    ? const SizedBox()
                    : const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.lifeLines.isNotEmpty) ...[
                      _buildCurrentCoins(),
                    ],
                    if (widget.quizType == QuizTypes.groupPlay) ...[
                      const SizedBox()
                    ],
                    _buildCurrentQuestionIndex(),
                    if (widget.quizType == QuizTypes.groupPlay) ...[
                      const SizedBox()
                    ],
                  ],
                ),
                const SizedBox(height: 20.0),
                Container(
                  alignment: Alignment.center,
                  child: _buildQuestionText(
                    questionText: question.question!,
                    questionType: question.questionType!,
                  ),
                ),
                question.imageUrl != null && question.imageUrl!.isNotEmpty
                    ? SizedBox(height: constraints.maxHeight * (0.0175))
                    : SizedBox(height: constraints.maxHeight * (0.02)),
                question.imageUrl != null && question.imageUrl!.isNotEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: constraints.maxHeight *
                            (widget.quizType == QuizTypes.groupPlay
                                ? 0.25
                                : 0.325),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: CachedNetworkImage(
                          placeholder: (_, __) => const Center(
                            child: CircularProgressContainer(),
                          ),
                          imageUrl: question.imageUrl!,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: widget.quizType == QuizTypes.groupPlay
                                      ? BoxFit.contain
                                      : BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            );
                          },
                          errorWidget: (_, i, e) {
                            return Center(
                              child: Icon(
                                Icons.error,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                _buildOptions(question, constraints),
                const SizedBox(height: 5),
              ],
            ),
          );
        }
      },
    );

    return Container(
      transform: Matrix4.identity()..scale(scale),
      transformAlignment: Alignment.center,
      // padding: const EdgeInsets.symmetric(horizontal: 15.0),
      width: MediaQuery.of(context).size.width *
          UiUtils.questionContainerWidthPercentage,
      height: MediaQuery.of(context).size.height *
          (UiUtils.questionContainerHeightPercentage -
              0.045 * (widget.quizType == QuizTypes.groupPlay ? 1.0 : 0.0)),
      child: showContent
          ? SlideTransition(
              position: widget.questionContentAnimation.drive(Tween<Offset>(
                  begin: const Offset(0.5, 0.0), end: Offset.zero)),
              child: FadeTransition(
                opacity: widget.questionContentAnimation,
                child: child,
              ),
            )
          : const SizedBox(),
      // decoration: BoxDecoration(
      //     // color: Theme.of(context).backgroundColor,
      //     borderRadius: BorderRadius.circular(25)),
    );
  }

  Widget _buildQuestion(int questionIndex, BuildContext context) {
    //print(questionIndex);
    //if current question index is same as question index means
    //it is current question and will be on top
    //so we need to add animation that slide and fade this question
    if (widget.currentQuestionIndex == questionIndex) {
      return FadeTransition(
        opacity: widget.questionSlideAnimation.drive(
          Tween<double>(begin: 1.0, end: 0.0),
        ),
        child: SlideTransition(
          position: widget.questionSlideAnimation.drive(
            Tween<Offset>(begin: Offset.zero, end: const Offset(-1.5, 0.0)),
          ),
          child: _buildQuestionContainer(1.0, questionIndex, true, context),
        ),
      );
    }
    //if the question is second or after current question
    //so we need to animation that scale this question
    //initial scale of this question is 0.95

    else if (questionIndex > widget.currentQuestionIndex &&
        (questionIndex == widget.currentQuestionIndex + 1)) {
      return AnimatedBuilder(
        animation: widget.questionAnimationController,
        builder: (context, child) {
          double scale = 0.95 +
              widget.questionScaleUpAnimation.value -
              widget.questionScaleDownAnimation.value;
          return _buildQuestionContainer(scale, questionIndex, false, context);
        },
      );
    }
    //to build question except top 2

    else if (questionIndex > widget.currentQuestionIndex) {
      return _buildQuestionContainer(1.0, questionIndex, false, context);
    }
    //if the question is already animated that show empty container
    return const SizedBox();
  }

  //to build questions
  List<Widget> _buildQuestions(BuildContext context) {
    List<Widget> children = [];

    //loop terminate condition will be questions.length instead of 4
    for (var i = 0; i < getQuestionsLength(); i++) {
      //add question
      children.add(_buildQuestion(i, context));
    }
    //need to reverse the list in order to display 1st question in top
    children = children.reversed.toList();

    return children;
  }

  @override
  Widget build(BuildContext context) {
    //Font Size change Lister to change questions font size
    return BlocListener<SettingsCubit, SettingsState>(
      bloc: context.read<SettingsCubit>(),
      listener: (context, state) {
        if (state.settingsModel!.playAreaFontSize != textSize) {
          setState(() {
            textSize =
                context.read<SettingsCubit>().getSettings().playAreaFontSize;
          });
        }
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: _buildQuestions(context),
      ),
    );
  }
}
