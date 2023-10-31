import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/exam/cubits/completedExamsCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examsCubit.dart';
import 'package:flutterquiz/features/exam/examRepository.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/exam/exam_result_screen.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examKeyBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ExamsCubit>(create: (_) => ExamsCubit(ExamRepository())),
          BlocProvider<CompletedExamsCubit>(
            create: (_) => CompletedExamsCubit(ExamRepository()),
          ),
        ],
        child: const ExamsScreen(),
      ),
    );
  }
}

class _ExamsScreenState extends State<ExamsScreen> {
  int currentSelectedQuestionIndex = 0;

  late final _completedExamScrollController = ScrollController()
    ..addListener(hasMoreResultScrollListener);

  ///
  late final String userId;
  late final String languageId;

  void hasMoreResultScrollListener() {
    if (_completedExamScrollController.position.maxScrollExtent ==
        _completedExamScrollController.offset) {
      log("At the end of the list");

      ///
      if (context.read<CompletedExamsCubit>().hasMoreResult()) {
        context.read<CompletedExamsCubit>().getMoreResult(
              userId: userId,
              languageId: languageId,
            );
      } else {
        log("No more result");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    userId = context.read<UserDetailsCubit>().userId();
    languageId = UiUtils.getCurrentQuestionLanguageId(context);

    getExams();
    getCompletedExams();
  }

  @override
  void dispose() {
    _completedExamScrollController.removeListener(hasMoreResultScrollListener);
    _completedExamScrollController.dispose();
    super.dispose();
  }

  void getExams() {
    Future.delayed(Duration.zero, () {
      context
          .read<ExamsCubit>()
          .getExams(userId: userId, languageId: languageId);
    });
  }

  void getCompletedExams() {
    Future.delayed(Duration.zero, () {
      context
          .read<CompletedExamsCubit>()
          .getCompletedExams(userId: userId, languageId: languageId);
    });
  }

  void showExamKeyBottomSheet(BuildContext context, Exam exam) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: true,
      isScrollControlled: true,
      elevation: 5.0,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) => ExamKeyBottomSheetContainer(
        navigateToExamScreen: navigateToExamScreen,
        exam: exam,
      ),
    );
  }

  // void showExamResultBottomSheet(BuildContext context, ExamResult examResult) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     elevation: 5.0,
  //     context: context,
  //     enableDrag: true,
  //     isDismissible: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: UiUtils.bottomSheetTopRadius,
  //     ),
  //     builder: (_) => ExamResultBottomSheetContainer(examResult: examResult),
  //   );
  // }

  void navigateToExamScreen() async {
    Navigator.of(context).pop();

    Navigator.of(context).pushNamed(Routes.exam).then((value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          print("Fetch exam details again");
          //fetch exams again with fresh status
          context
              .read<ExamsCubit>()
              .getExams(userId: userId, languageId: languageId);
          //fetch completed exam again with fresh status
          context
              .read<CompletedExamsCubit>()
              .getCompletedExams(userId: userId, languageId: languageId);
        }
      });
    });
  }

  Widget _buildExamResults() {
    return BlocConsumer<CompletedExamsCubit, CompletedExamsState>(
      listener: (context, state) {
        if (state is CompletedExamsFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<CompletedExamsCubit>(),
      builder: (context, state) {
        if (state is CompletedExamsFetchInProgress ||
            state is CompletedExamsInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is CompletedExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
                errorMessageColor: Theme.of(context).primaryColor,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorMessage)),
                onTapRetry: getCompletedExams,
                showErrorImage: true),
          );
        }
        return ListView.builder(
          controller: _completedExamScrollController,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount:
              (state as CompletedExamsFetchSuccess).completedExams.length,
          itemBuilder: (context, index) {
            return _buildResultContainer(
              examResult: state.completedExams[index],
              hasMoreResultFetchError: state.hasMoreFetchError,
              index: index,
              totalExamResults: state.completedExams.length,
              hasMore: state.hasMore,
            );
          },
        );
      },
    );
  }

  Widget _buildTodayExams() {
    return BlocConsumer<ExamsCubit, ExamsState>(
      listener: (_, state) {
        if (state is ExamsFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<ExamsCubit>(),
      builder: (context, state) {
        if (state is ExamsFetchInProgress || state is ExamsInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is ExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageColor: Theme.of(context).primaryColor,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              onTapRetry: getExams,
              showErrorImage: true,
            ),
          );
        }

        final exams = (state as ExamsFetchSuccess).exams;

        if (exams.isEmpty) {
          return Center(
            child: Text(
              AppLocalization.of(context)!
                  .getTranslatedValues("allExamsCompleteLbl")!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 20.0,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount: exams.length,
          itemBuilder: (_, i) => _buildTodayExamContainer(exams[i]),
          separatorBuilder: (_, i) => const SizedBox(height: 10),
        );
      },
    );
  }

  Widget _buildTodayExamContainer(Exam exam) {
    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(exam.date),
    );
    print("Exam Duration: ${exam.duration}");
    return GestureDetector(
      onTap: () => showExamKeyBottomSheet(context, exam),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Exam title
                  Text(
                    exam.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  /// Date & Duration
                  Text(
                    "$formattedDate  |  ${exam.duration} min",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            /// Marks
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.transparent,
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                "${exam.totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!}",
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainer({
    required ExamResult examResult,
    required int index,
    required int totalExamResults,
    required bool hasMoreResultFetchError,
    required bool hasMore,
  }) {
    if (index == totalExamResults - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreResultFetchError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                onPressed: () {
                  context.read<CompletedExamsCubit>().getMoreResult(
                        userId: userId,
                        languageId: languageId,
                      );
                },
                icon: Icon(
                  Icons.error,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: CircularProgressContainer(),
            ),
          );
        }
      }
    }

    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(examResult.date),
    );
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ExamResultScreen(examResult: examResult),
        ));
        // showExamResultBottomSheet(context, examResult);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: MediaQuery.of(context).size.height * .1,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    examResult.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * (0.5),
                  child: Text(
                    formattedDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  "${examResult.obtainedMarks()}/${examResult.totalMarks} ${AppLocalization.of(context)!.getTranslatedValues(markKey)!} ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: QAppBar(
          title:
              Text(AppLocalization.of(context)!.getTranslatedValues("exam")!),
          bottom: TabBar(
            tabs: [
              Tab(
                text:
                    AppLocalization.of(context)!.getTranslatedValues(dailyLbl)!,
              ),
              Tab(
                text: AppLocalization.of(context)!
                    .getTranslatedValues(completedLbl)!,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildTodayExams(),
                _buildExamResults(),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BannerAdContainer(),
            ),
          ],
        ),
      ),
    );
  }
}
