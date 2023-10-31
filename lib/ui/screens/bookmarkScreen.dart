import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late final String _userId;
  late final String _userFirebaseId;

  late TabController tabController;
  late final tabs = <String>[
    AppLocalization.of(context)!.getTranslatedValues(quizZone)!,
    AppLocalization.of(context)!.getTranslatedValues(guessTheWord)!,
    AppLocalization.of(context)!.getTranslatedValues(audioQuestionsKey)!,
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _userId = context.read<UserDetailsCubit>().userId();
    _userFirebaseId = context.read<UserDetailsCubit>().getUserFirebaseId();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void openBottomSheet({
    required String question,
    required String? imageUrl,
    required String correctAnswer,
    required String yourAnswer,
  }) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15.0),

          /// Title
          Text(
            tabs[tabController.index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
          const Divider(),

          ///
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15.0),
                Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeights.regular,
                    fontSize: 18.0,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                if (imageUrl != null && imageUrl != '') ...[
                  const SizedBox(height: 30.0),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: MediaQuery.of(context).size.width * .9,
                      height: MediaQuery.of(context).size.width * .5,
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        placeholder: (_, __) => const Center(
                          child: CircularProgressContainer(),
                        ),
                        imageUrl: imageUrl,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
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
                    ),
                  ),
                ],
                const SizedBox(height: 15.0),
                Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues("yourAnsLbl")!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  width: double.maxFinite,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    yourAnswer,
                    style: TextStyle(
                      fontWeight: FontWeights.regular,
                      fontSize: 16.0,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(.3),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues("correctAndLbl")!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  width: double.maxFinite,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    correctAnswer,
                    style: TextStyle(
                      fontWeight: FontWeights.regular,
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizZoneQuestions() {
    final bookmarkCubit = context.read<BookmarkCubit>();
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is BookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .65,
                  child: ListView.separated(
                    itemBuilder: (_, index) {
                      Question question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarked question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (_) =>
                            UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) => BlocConsumer<
                              UpdateBookmarkCubit, UpdateBookmarkState>(
                            bloc: context.read<UpdateBookmarkCubit>(),
                            listener: (_, state) {
                              if (state is UpdateBookmarkSuccess) {
                                bookmarkCubit.removeBookmarkQuestion(
                                    question.id, _userId);
                              }
                              if (state is UpdateBookmarkFailure) {
                                UiUtils.setSnackbar(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues(
                                            convertErrorCodeToLanguageKey(
                                                updateBookmarkFailureCode))!,
                                    context,
                                    false);
                              }
                            },
                            builder: (context, state) {
                              return GestureDetector(
                                onTap: () {
                                  openBottomSheet(
                                      question: question.question!,
                                      yourAnswer: context
                                          .read<BookmarkCubit>()
                                          .getSubmittedAnswerForQuestion(
                                              question.id),
                                      imageUrl: question.imageUrl,
                                      correctAnswer: question
                                          .answerOptions![question
                                              .answerOptions!
                                              .indexWhere(
                                        (e) =>
                                            e.id ==
                                            AnswerEncryption
                                                .decryptCorrectAnswer(
                                              rawKey: _userFirebaseId,
                                              correctAnswer:
                                                  question.correctAnswer!,
                                            ),
                                      )]
                                          .title!);
                                },
                                child: BookmarkCard(
                                  queId: question.id!,
                                  index: "${index + 1}",
                                  title: question.question!,
                                  desc:
                                      "${question.answerOptions![question.answerOptions!.indexWhere((e) => e.id == AnswerEncryption.decryptCorrectAnswer(rawKey: _userFirebaseId, correctAnswer: question.correctAnswer!))].title}",
                                  type: '1', // type QuizZone
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: UiUtils.listTileGap),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, state) {
                      if (state is BookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: AppLocalization.of(context)!
                              .getTranslatedValues("playBookmarkBtn")!,
                          radius: 8.0,
                          showBorder: false,
                          fontWeight: FontWeights.semiBold,
                          height: 58.0,
                          titleColor: Theme.of(context).colorScheme.background,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.quizZone,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18.0,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is BookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessageCode)),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context.read<BookmarkCubit>().getBookmark(_userId);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAudioQuestions() {
    final bookmarkCubit = context.read<AudioQuestionBookmarkCubit>();
    return BlocBuilder<AudioQuestionBookmarkCubit, AudioQuestionBookMarkState>(
      bloc: bookmarkCubit,
      builder: (context, state) {
        if (state is AudioQuestionBookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .65,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      Question question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarekd question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (_) =>
                            UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) => BlocConsumer<
                              UpdateBookmarkCubit, UpdateBookmarkState>(
                            bloc: context.read<UpdateBookmarkCubit>(),
                            listener: (context, state) {
                              if (state is UpdateBookmarkSuccess) {
                                bookmarkCubit.removeBookmarkQuestion(
                                  question.id,
                                  _userId,
                                );
                              }
                              if (state is UpdateBookmarkFailure) {
                                UiUtils.setSnackbar(
                                  AppLocalization.of(context)!
                                      .getTranslatedValues(
                                          convertErrorCodeToLanguageKey(
                                              updateBookmarkFailureCode))!,
                                  context,
                                  false,
                                );
                              }
                            },
                            builder: (context, state) {
                              return GestureDetector(
                                onTap: state is UpdateBookmarkInProgress
                                    ? () {}
                                    : () {
                                        openBottomSheet(
                                          question: question.question!,
                                          yourAnswer: bookmarkCubit
                                              .getSubmittedAnswerForQuestion(
                                                  question.id),
                                          correctAnswer: question
                                              .answerOptions![question
                                                  .answerOptions!
                                                  .indexWhere((element) =>
                                                      element.id ==
                                                      AnswerEncryption
                                                          .decryptCorrectAnswer(
                                                        rawKey: context
                                                            .read<
                                                                UserDetailsCubit>()
                                                            .getUserFirebaseId(),
                                                        correctAnswer: question
                                                            .correctAnswer!,
                                                      ))]
                                              .title!,
                                          imageUrl: '',
                                        );
                                      },
                                child: BookmarkCard(
                                  queId: question.id!,
                                  index: "${index + 1}",
                                  title: question.question!,
                                  desc: question
                                      .answerOptions![question.answerOptions!
                                          .indexWhere((e) =>
                                              e.id ==
                                              AnswerEncryption
                                                  .decryptCorrectAnswer(
                                                rawKey: _userFirebaseId,
                                                correctAnswer:
                                                    question.correctAnswer!,
                                              ))]
                                      .title!,
                                  type: '4', // type Audio Quiz
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                    separatorBuilder: (_, i) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: BlocBuilder<AudioQuestionBookmarkCubit,
                      AudioQuestionBookMarkState>(
                    builder: (context, state) {
                      if (state is AudioQuestionBookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: AppLocalization.of(context)!
                              .getTranslatedValues("playBookmarkBtn")!,
                          radius: 8.0,
                          showBorder: false,
                          fontWeight: FontWeight.w500,
                          height: 58.0,
                          titleColor: Theme.of(context).colorScheme.background,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.audioQuestions,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18.0,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is AudioQuestionBookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessageCode)),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context.read<AudioQuestionBookmarkCubit>().getBookmark(_userId);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Center noBookmarksFound() => Center(
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("noBookmarkQueLbl")!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontSize: 20.0,
          ),
        ),
      );

  Widget _buildGuessTheWordQuestions() {
    final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
    return BlocBuilder<GuessTheWordBookmarkCubit, GuessTheWordBookmarkState>(
      bloc: context.read<GuessTheWordBookmarkCubit>(),
      builder: (context, state) {
        if (state is GuessTheWordBookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .65,
                child: ListView.separated(
                  separatorBuilder: (_, i) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015),
                  itemBuilder: (context, index) {
                    GuessTheWordQuestion question = state.questions[index];

                    //providing updateBookmarkCubit to every bookmarked question
                    return BlocProvider<UpdateBookmarkCubit>(
                      create: (context) =>
                          UpdateBookmarkCubit(BookmarkRepository()),
                      //using builder so we can access the recently provided cubit
                      child: Builder(
                        builder: (context) => BlocConsumer<UpdateBookmarkCubit,
                            UpdateBookmarkState>(
                          bloc: context.read<UpdateBookmarkCubit>(),
                          listener: (context, state) {
                            if (state is UpdateBookmarkSuccess) {
                              bookmarkCubit.removeBookmarkQuestion(
                                question.id,
                                _userId,
                              );
                            }
                            if (state is UpdateBookmarkFailure) {
                              UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            updateBookmarkFailureCode))!,
                                context,
                                false,
                              );
                            }
                          },
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                openBottomSheet(
                                  yourAnswer: context
                                      .read<GuessTheWordBookmarkCubit>()
                                      .getSubmittedAnswerForQuestion(
                                          question.id),
                                  question: question.question,
                                  correctAnswer: question.answer,
                                  imageUrl: question.image,
                                );
                              },
                              child: BookmarkCard(
                                queId: question.id,
                                index: "${index + 1}",
                                title: question.question,
                                desc: question.answer,
                                type: '3',
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: state.questions.length,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: BlocBuilder<GuessTheWordBookmarkCubit,
                      GuessTheWordBookmarkState>(
                    builder: (context, state) {
                      if (state is GuessTheWordBookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: AppLocalization.of(context)!
                              .getTranslatedValues("playBookmarkBtn")!,
                          radius: 8.0,
                          showBorder: false,
                          fontWeight: FontWeight.w500,
                          height: 58.0,
                          titleColor: Theme.of(context).colorScheme.background,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.guessTheWord,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18.0,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is GuessTheWordBookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessageCode),
            ),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () =>
                context.read<GuessTheWordBookmarkCubit>().getBookmark(_userId),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(
            AppLocalization.of(context)!.getTranslatedValues(bookmarkLbl)!),
        bottom: TabBar(
          isScrollable: true,
          controller: tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
          horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: TabBarView(
          controller: tabController,
          children: [
            _buildQuizZoneQuestions(),
            _buildGuessTheWordQuestions(),
            _buildAudioQuestions(),
          ],
        ),
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    super.key,
    required this.index,
    required this.title,
    required this.desc,
    required this.queId,
    required this.type,
  });

  final String index;
  final String title;
  final String desc;
  final String queId;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .116,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            width: MediaQuery.of(context).size.width * .110,
            height: MediaQuery.of(context).size.width * .110,
            child: Center(
              child: Text(
                index,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeights.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * .62,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeights.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),

                /// Subtitle
                Text(
                  desc,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          /// Close
          GestureDetector(
            onTap: () {
              context.read<UpdateBookmarkCubit>().updateBookmark(
                    context.read<UserDetailsCubit>().userId(),
                    queId,
                    "0",
                    type,
                  );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
