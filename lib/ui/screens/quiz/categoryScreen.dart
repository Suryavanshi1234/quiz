import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class CategoryScreen extends StatefulWidget {
  final QuizTypes quizType;

  // final String categoryName;

  const CategoryScreen({super.key, required this.quizType});

  @override
  State<CategoryScreen> createState() => _CategoryScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => CategoryScreen(
        quizType: arguments['quizType'] as QuizTypes,
        // categoryName: arguments['categoryName'],
      ),
    );
  }
}

class _CategoryScreen extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // preload ads
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });

    context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuestionLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(widget.quizType),
          userId: context.read<UserDetailsCubit>().userId(),
        );
    super.initState();
  }

  String getCategoryTitle(QuizTypes quizType) {
    String title = "quizZone";
    if (quizType == QuizTypes.mathMania) {
      title = "mathMania";
    } else if (quizType == QuizTypes.audioQuestions) {
      title = "audioQuestions";
    } else if (quizType == QuizTypes.guessTheWord) {
      title = "guessTheWord";
    } else if (quizType == QuizTypes.funAndLearn) {
      title = "funAndLearn";
    }
    return AppLocalization.of(context)!.getTranslatedValues(title)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(getCategoryTitle(widget.quizType))),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: showCategory(),
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

  void _handleOnTapCategory(BuildContext context, Category category) {
    /// noOf is number of subcategories
    if (category.noOf == "0") {
      if (widget.quizType == QuizTypes.quizZone) {
        /// if category doesn't have any subCategory, check for levels.
        if (category.maxLevel == "0") {
          print("+++ play Quiz");
          //direct move to quiz screen pass level as 0
          Navigator.of(context).pushNamed(Routes.quiz, arguments: {
            "numberOfPlayer": 1,
            "quizType": QuizTypes.quizZone,
            "categoryId": category.id,
            "subcategoryId": "",
            "level": "0",
            "subcategoryMaxLevel": "0",
            "unlockedLevel": 0,
            "contestId": "",
            "comprehensionId": "",
            "quizName": "Quiz Zone",
            'showRetryButton': category.noOfQues! != '0',
          });
        } else {
          //navigate to level screen
          Navigator.of(context)
              .pushNamed(Routes.levels, arguments: {"Category": category});
        }
      } else if (widget.quizType == QuizTypes.audioQuestions) {
        Navigator.of(context).pushNamed(Routes.quiz, arguments: {
          "numberOfPlayer": 1,
          "quizType": QuizTypes.audioQuestions,
          "categoryId": category.id,
          "isPlayed": category.isPlayed,
        });
      } else if (widget.quizType == QuizTypes.guessTheWord) {
        Navigator.of(context).pushNamed(Routes.guessTheWord, arguments: {
          "type": "category",
          "typeId": category.id,
          "isPlayed": category.isPlayed,
        });
      } else if (widget.quizType == QuizTypes.funAndLearn) {
        Navigator.of(context).pushNamed(Routes.funAndLearnTitle, arguments: {
          "type": "category",
          "typeId": category.id,
          "title": category.categoryName,
        });
      } else if (widget.quizType == QuizTypes.mathMania) {
        Navigator.of(context).pushNamed(Routes.quiz, arguments: {
          "numberOfPlayer": 1,
          "quizType": QuizTypes.mathMania,
          "categoryId": category.id,
          "isPlayed": category.isPlayed,
        });
      }
    } else {
      if (widget.quizType == QuizTypes.quizZone) {
        Navigator.of(context).pushNamed(
          Routes.subcategoryAndLevel,
          arguments: {
            "category_id": category.id,
            "category_name": category.categoryName!,
          },
        );
      } else {
        Navigator.of(context).pushNamed(Routes.subCategory, arguments: {
          "categoryId": category.id,
          "quizType": widget.quizType,
          "category_name": category.categoryName!,
        });
      }
    }
  }

  Widget showCategory() {
    return BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
      bloc: context.read<QuizCategoryCubit>(),
      listener: (context, state) {
        if (state is QuizCategoryFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            print(state.errorMessage);
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      builder: (context, state) {
        if (state is QuizCategoryProgress || state is QuizCategoryInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is QuizCategoryFailure) {
          return ErrorContainer(
            showBackButton: false,
            errorMessageColor: Theme.of(context).primaryColor,
            showErrorImage: true,
            errorMessage: AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage),
            ),
            onTapRetry: () {
              context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    type: UiUtils.getCategoryTypeNumberFromQuizType(
                        widget.quizType),
                    userId: context.read<UserDetailsCubit>().userId(),
                  );
            },
          );
        }
        final categoryList = (state as QuizCategorySuccess).categories;
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          controller: scrollController,
          shrinkWrap: true,
          itemCount: categoryList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, i) =>
              const SizedBox(height: UiUtils.listTileGap),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                print("+++ On Tapping Cat $index");
                _handleOnTapCategory(context, categoryList[index]);
              },
              child: LayoutBuilder(
                builder: (context, boxConstraints) {
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
                          height: 50,
                        ),
                      ),
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          width: boxConstraints.maxWidth,
                          child: Row(
                            children: [
                              /// Leading Image
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary
                                        .withOpacity(0.1),
                                  ),
                                ),
                                padding: const EdgeInsets.all(5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(1.0),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    memCacheWidth: 50,
                                    memCacheHeight: 50,
                                    placeholder: (_, __) => const SizedBox(),
                                    imageUrl: categoryList[index].image!,
                                    errorWidget: (_, i, e) => Image(
                                      image: AssetImage(
                                        UiUtils.getImagePath("ic_launcher.png"),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              /// title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      categoryList[index].categoryName!,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (widget.quizType ==
                                        QuizTypes.quizZone) ...[
                                      Text(
                                        "${AppLocalization.of(context)!.getTranslatedValues("questionLbl")!} : ${categoryList[index].noOfQues!}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ] else if (widget.quizType ==
                                        QuizTypes.funAndLearn) ...[
                                      Text(
                                        categoryList[index].noOf == "0"
                                            ? "comprehensive: ${categoryList[index].noOfQues!}"
                                            : "Subcategories: ${categoryList[index].noOf!}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        categoryList[index].noOf == "0"
                                            ? "Question: ${categoryList[index].noOfQues!}"
                                            : "Subcategories: ${categoryList[index].noOf!}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              /// right arrow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary
                                          .withOpacity(0.1)),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 30,
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
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
}
