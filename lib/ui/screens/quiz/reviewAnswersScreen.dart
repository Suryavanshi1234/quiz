import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/musicPlayer/musicPlayerCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionCubit.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/music_player_container.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/questionContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ReviewAnswersScreen extends StatefulWidget {
  final List<Question> questions;
  final QuizTypes quizType;
  final List<GuessTheWordQuestion> guessTheWordQuestions;

  const ReviewAnswersScreen({
    super.key,
    required this.questions,
    required this.guessTheWordQuestions,
    required this.quizType,
  });

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    //arguments will map and keys of the map are following
    //questions and guessTheWordQuestions
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateBookmarkCubit>(
            create: (context) => UpdateBookmarkCubit(BookmarkRepository()),
          ),
          BlocProvider<ReportQuestionCubit>(
            create: (_) => ReportQuestionCubit(ReportQuestionRepository()),
          ),
        ],
        child: ReviewAnswersScreen(
          quizType: arguments!['quizType'],
          guessTheWordQuestions: arguments['guessTheWordQuestions'] ??
              List<GuessTheWordQuestion>.from([]),
          questions: arguments['questions'] ?? List<Question>.from([]),
        ),
      ),
    );
  }

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  PageController? _pageController;
  int _currentIndex = 0;
  List<GlobalKey<MusicPlayerContainerState>> musicPlayerContainerKeys = [];

  @override
  void initState() {
    _pageController = PageController();
    if (_hasAudioQuestion()) {
      for (var _ in widget.questions) {
        musicPlayerContainerKeys.add(GlobalKey<MusicPlayerContainerState>());
      }
    }

    super.initState();
  }

  bool _hasAudioQuestion() {
    if (widget.questions.isNotEmpty) {
      return widget.questions.first.audio!.isNotEmpty;
    }
    return false;
  }

  void showNotes() {
    if (widget.questions[_currentIndex].note!.isEmpty) {
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(notesNotAvailableCode))!,
          context,
          false);
      return;
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * (0.6)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Text(
                AppLocalization.of(context)!.getTranslatedValues("notesLbl")!,
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 10.0),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.1)),
                child: Text(
                  "${widget.questions[_currentIndex].question}",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 5.0),
              const Divider(),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.1)),
                child: Text(
                  "${widget.questions[_currentIndex].note}",
                  style: TextStyle(
                      fontSize: 17.0, color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getQuestionsLength() {
    if (widget.questions.isEmpty) {
      return widget.guessTheWordQuestions.length;
    }
    return widget.questions.length;
  }

  bool isGuessTheWordQuizModule() {
    return widget.guessTheWordQuestions.isNotEmpty;
  }

  Color getOptionColor(Question question, String? optionId) {
    String correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
      rawKey: context.read<AuthCubit>().getUserFirebaseId(),
      correctAnswer: question.correctAnswer!,
    );

    /// if question isn't attempted, only show which answer is correct.
    if (!question.attempted) {
      return correctAnswerId == optionId
          ? Colors.green
          : Theme.of(context).colorScheme.background;
    }

    if (question.submittedAnswerId == correctAnswerId) {
      return question.submittedAnswerId == optionId
          ? Colors.green
          : Theme.of(context).colorScheme.background;
    } else {
      if (question.submittedAnswerId == optionId) return Colors.red;

      return correctAnswerId == optionId
          ? Colors.green
          : Theme.of(context).colorScheme.background;
    }
  }

  Color getOptionTextColor(Question question, String? optionId) {
    String correctAnswerId = AnswerEncryption.decryptCorrectAnswer(
        rawKey: context.read<AuthCubit>().getUserFirebaseId(),
        correctAnswer: question.correctAnswer!);

    var scheme = Theme.of(context).colorScheme;

    if (!question.attempted) {
      return correctAnswerId == optionId
          ? scheme.background
          : scheme.onTertiary;
    }

    if (question.submittedAnswerId == correctAnswerId) {
      return question.submittedAnswerId == optionId
          ? scheme.background
          : scheme.onTertiary;
    } else {
      if (question.submittedAnswerId == optionId) {
        return scheme.background;
      }

      return correctAnswerId == optionId
          ? scheme.background
          : scheme.onTertiary;
    }
  }

  Widget _buildBottomMenu(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      height: MediaQuery.of(context).size.height * UiUtils.bottomMenuPercentage,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 5, left: 8, right: 2, bottom: 5),
            child: GestureDetector(
              onTap: () {
                if (_currentIndex != 0) {
                  _pageController!.animateToPage(_currentIndex - 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
          // Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              "${_currentIndex + 1} / ${getQuestionsLength()}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              onTap: () {
                if (_currentIndex != (getQuestionsLength() - 1)) {
                  _pageController!.animateToPage(_currentIndex + 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //to build option of given question
  Widget _buildOption(AnswerOption option, Question question) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: getOptionColor(question, option.id),
      ),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 15.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: widget.quizType == QuizTypes.mathMania
          ? Center(
              child: TeXView(
                child: TeXViewDocument(option.title!),
                style: TeXViewStyle(
                  contentColor: Theme.of(context).colorScheme.onTertiary,
                  backgroundColor: Colors.transparent,
                  sizeUnit: TeXViewSizeUnit.pixels,
                  textAlign: TeXViewTextAlign.center,
                  fontStyle: TeXViewFontStyle(fontSize: 19),
                ),
              ),
            )
          : Center(
              child: Text(
                option.title!,
                style: TextStyle(
                  color: getOptionTextColor(question, option.id),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
    );
  }

  Widget _buildOptions(Question question) {
    return Column(
      children: question.answerOptions!.map((option) {
        return _buildOption(option, question);
      }).toList(),
    );
  }

  Widget _buildGuessTheWordOptionAndAnswer(
      GuessTheWordQuestion guessTheWordQuestion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25.0),
        Padding(
          padding: EdgeInsets.zero,
          child: Text(
            "${AppLocalization.of(context)!.getTranslatedValues("yourAnsLbl")!} : ${UiUtils.buildGuessTheWordQuestionAnswer(guessTheWordQuestion.submittedAnswer)}",
            style: TextStyle(
              fontSize: 18.0,
              color: UiUtils.buildGuessTheWordQuestionAnswer(
                          guessTheWordQuestion.submittedAnswer) ==
                      guessTheWordQuestion.answer
                  ? Colors.green
                  : Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ),
        UiUtils.buildGuessTheWordQuestionAnswer(
                    guessTheWordQuestion.submittedAnswer) ==
                guessTheWordQuestion.answer
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsetsDirectional.only(start: 0.0),
                child: Text(
                  "${AppLocalization.of(context)!.getTranslatedValues("correctAndLbl")!}: ${guessTheWordQuestion.answer}",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              )
      ],
    );
  }

  Widget _buildNotes(String notes) {
    return notes.isEmpty
        ? Container()
        : widget.quizType == QuizTypes.mathMania
            ? Container(
                width: MediaQuery.of(context).size.width * (0.8),
                margin: const EdgeInsets.only(top: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues(notesKey)!,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0)),
                    const SizedBox(height: 10.0),
                    TeXView(
                      child: TeXViewDocument(notes),
                      style: TeXViewStyle(
                        contentColor: Theme.of(context).primaryColor,
                        //backgroundColor: Theme.of(context).backgroundColor,
                        sizeUnit: TeXViewSizeUnit.pixels,
                        textAlign: TeXViewTextAlign.center,
                      ),
                    )
                  ],
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width * (0.8),
                margin: const EdgeInsets.only(top: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(notesKey)!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      notes,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              );
  }

  Widget _buildQuestionAndOptions(Question question, int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: widget.quizType == QuizTypes.mathMania,
            question: question,
            questionColor: Theme.of(context).colorScheme.onTertiary,
          ),
          _hasAudioQuestion()
              ? BlocProvider<MusicPlayerCubit>(
                  create: (_) => MusicPlayerCubit(),
                  child: MusicPlayerContainer(
                    currentIndex: _currentIndex,
                    index: index,
                    url: question.audio!,
                    key: musicPlayerContainerKeys[index],
                  ),
                )
              : const SizedBox(),

          //build options
          _buildOptions(question),
          _buildNotes(question.note!),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildGuessTheWordQuestionAndOptions(GuessTheWordQuestion question) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(
            isMathQuestion: false,
            questionColor: Theme.of(context).colorScheme.onTertiary,
            question: Question(
              marks: "",
              id: question.id,
              question: question.question,
              imageUrl: question.image,
            ),
          ),
          //build options
          _buildGuessTheWordOptionAndAnswer(question),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * (0.85),
      child: PageView.builder(
          onPageChanged: (index) {
            if (_hasAudioQuestion()) {
              musicPlayerContainerKeys[_currentIndex].currentState?.stopAudio();
            }
            setState(() {
              _currentIndex = index;
            });
            if (_hasAudioQuestion()) {
              musicPlayerContainerKeys[_currentIndex].currentState?.playAudio();
            }
          },
          controller: _pageController,
          itemCount: getQuestionsLength(),
          itemBuilder: (context, index) {
            if (widget.questions.isEmpty) {
              return _buildGuessTheWordQuestionAndOptions(
                  widget.guessTheWordQuestions[index]);
            }
            return _buildQuestionAndOptions(widget.questions[index], index);
          }),
    );
  }

  Widget _buildReportButton(ReportQuestionCubit reportQuestionCubit) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          isDismissible: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          enableDrag: false,
          isScrollControlled: true,
          context: context,
          builder: (_) => ReportQuestionBottomSheetContainer(
              questionId: isGuessTheWordQuizModule()
                  ? widget.guessTheWordQuestions[_currentIndex].id
                  : widget.questions[_currentIndex].id!,
              reportQuestionCubit: reportQuestionCubit),
        );
      },
      icon: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(AppLocalization.of(context)!
            .getTranslatedValues("reviewAnswerLbl")!),
        actions: [
          (widget.questions.isNotEmpty &&
                  (widget.quizType == QuizTypes.quizZone ||
                      widget.quizType == QuizTypes.selfChallenge ||
                      widget.quizType == QuizTypes.battle ||
                      widget.quizType == QuizTypes.groupPlay))
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildReportButton(context.read<ReportQuestionCubit>()),
                  ],
                )
              : const SizedBox()
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical:
                    MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
                horizontal:
                    MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
              ),
              child: _buildQuestions(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomMenu(context),
          ),
        ],
      ),
    );
  }
}

class ReportQuestionBottomSheetContainer extends StatefulWidget {
  final ReportQuestionCubit reportQuestionCubit;
  final String questionId;

  const ReportQuestionBottomSheetContainer({
    super.key,
    required this.reportQuestionCubit,
    required this.questionId,
  });

  @override
  State<ReportQuestionBottomSheetContainer> createState() =>
      _ReportQuestionBottomSheetContainerState();
}

class _ReportQuestionBottomSheetContainerState
    extends State<ReportQuestionBottomSheetContainer> {
  final textEditingController = TextEditingController();
  late String errorMessage = "";

  String _buildButtonTitle(ReportQuestionState state) {
    if (state is ReportQuestionInProgress) {
      return AppLocalization.of(context)!
          .getTranslatedValues(submittingButton)!;
    }
    if (state is ReportQuestionFailure) {
      return AppLocalization.of(context)!.getTranslatedValues(retryLbl)!;
    }
    return AppLocalization.of(context)!.getTranslatedValues(submitBtn)!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportQuestionCubit, ReportQuestionState>(
      bloc: widget.reportQuestionCubit,
      listener: (context, state) {
        if (state is ReportQuestionSuccess) {
          Navigator.of(context).pop();
        }
        if (state is ReportQuestionFailure) {
          if (state.errorMessageCode == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
            return;
          }
          //
          setState(() {
            errorMessage = AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessageCode))!;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (widget.reportQuestionCubit.state is ReportQuestionInProgress) {
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: IconButton(
                        onPressed: () {
                          if (widget.reportQuestionCubit.state
                              is! ReportQuestionInProgress) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(reportQuestionKey)!,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                //
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.125),
                  ),
                  padding: const EdgeInsets.only(left: 20.0),
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: AppLocalization.of(context)!
                          .getTranslatedValues(enterReasonKey)!,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .02),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(height: 20.0)
                      : SizedBox(
                          height: 20.0,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .02),

                BlocBuilder<ReportQuestionCubit, ReportQuestionState>(
                  bloc: widget.reportQuestionCubit,
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .3),
                      child: CustomRoundedButton(
                        widthPercentage: MediaQuery.of(context).size.width,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: _buildButtonTitle(state),
                        radius: 10.0,
                        showBorder: false,
                        onTap: () {
                          if (state is! ReportQuestionInProgress) {
                            widget.reportQuestionCubit.reportQuestion(
                                message: textEditingController.text.trim(),
                                questionId: widget.questionId,
                                userId:
                                    context.read<UserDetailsCubit>().userId());
                          }
                        },
                        fontWeight: FontWeight.bold,
                        titleColor: Theme.of(context).colorScheme.background,
                        height: 40.0,
                      ),
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
