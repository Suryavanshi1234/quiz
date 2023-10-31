import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/comprehensionCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class FunAndLearnTitleScreen extends StatefulWidget {
  final String type;
  final String typeId;
  final String title;

  const FunAndLearnTitleScreen({
    super.key,
    required this.type,
    required this.typeId,
    required this.title,
  });

  @override
  State<FunAndLearnTitleScreen> createState() => _FunAndLearnTitleScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => FunAndLearnTitleScreen(
        type: arguments['type'],
        typeId: arguments['typeId'],
        title: arguments['title'] ?? "",
      ),
    );
  }
}

class _FunAndLearnTitleScreen extends State<FunAndLearnTitleScreen> {
  @override
  void initState() {
    super.initState();
    getComprehension();
  }

  void getComprehension() {
    Future.delayed(Duration.zero, () {
      context.read<ComprehensionCubit>().getComprehension(
            userId: context.read<UserDetailsCubit>().userId(),
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: widget.type,
            typeId: widget.typeId,
          );
    });
  }

  Widget _buildComprehensionList() {
    return BlocConsumer<ComprehensionCubit, ComprehensionState>(
      bloc: context.read<ComprehensionCubit>(),
      listener: (context, state) {
        if (state is ComprehensionFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      builder: (context, state) {
        if (state is ComprehensionProgress || state is ComprehensionInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is ComprehensionFailure) {
          return ErrorContainer(
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage)),
            onTapRetry: getComprehension,
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
          );
        }

        final comprehensions = (state as ComprehensionSuccess).getComprehension;

        return ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount: comprehensions.length,
          separatorBuilder: (_, i) => const SizedBox(
            height: UiUtils.listTileGap,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                print("Played : ${comprehensions[index].isPlayed}");
                Navigator.of(context).pushNamed(Routes.funAndLearn, arguments: {
                  "comprehension": comprehensions[index],
                  "quizType": QuizTypes.funAndLearn
                });
              },
              child: LayoutBuilder(
                builder: (_, boxConstraints) {
                  final colorScheme = Theme.of(context).colorScheme;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: boxConstraints.maxWidth * (0.1),
                        right: boxConstraints.maxWidth * (0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 25),
                                blurRadius: 5,
                                spreadRadius: 2,
                                color: Color(0x40808080),
                              )
                            ],
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(
                                  boxConstraints.maxWidth * .525),
                            ),
                          ),
                          width: boxConstraints.maxWidth,
                          height: 45,
                        ),
                      ),
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.background,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          width: boxConstraints.maxWidth,
                          child: Row(
                            children: [
                              /// title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comprehensions[index].title!,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: colorScheme.onTertiary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "Question: ${comprehensions[index].noOfQue!}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onTertiary
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              /// right arrow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color:
                                        colorScheme.onTertiary.withOpacity(0.1),
                                  ),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 30,
                                  color: colorScheme.onTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        roundedAppBar: false,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildComprehensionList(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }
}
