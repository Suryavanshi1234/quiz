import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/subcatagoriesLevelsChip.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SubCategoryAndLevelScreen extends StatefulWidget {
  const SubCategoryAndLevelScreen({
    super.key,
    this.category,
    this.categoryName,
  });

  final String? category;
  final String? categoryName;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map;

    return CupertinoPageRoute(
      builder: (_) => SubCategoryAndLevelScreen(
        category: args['category_id'] as String?,
        categoryName: args['category_name'] as String?,
      ),
    );
  }

  @override
  State<SubCategoryAndLevelScreen> createState() =>
      _SubCategoryAndLevelScreen();
}

class _SubCategoryAndLevelScreen extends State<SubCategoryAndLevelScreen> {
  @override
  void initState() {
    fetchSubCategory();
    super.initState();
  }

  void fetchSubCategory() {
    context.read<SubCategoryCubit>().fetchSubCategory(
          widget.category!,
          context.read<UserDetailsCubit>().userId(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(widget.categoryName!), roundedAppBar: false),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                Flexible(
                  child: BlocConsumer<SubCategoryCubit, SubCategoryState>(
                    bloc: context.read<SubCategoryCubit>(),
                    listener: (context, state) {
                      if (state is SubCategoryFetchFailure) {
                        if (state.errorMessage == unauthorizedAccessCode) {
                          UiUtils.showAlreadyLoggedInDialog(context: context);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is SubCategoryFetchInProgress ||
                          state is SubCategoryInitial) {
                        return const Center(
                          child: CircularProgressContainer(whiteLoader: false),
                        );
                      }
                      if (state is SubCategoryFetchFailure) {
                        return ErrorContainer(
                          errorMessageColor: Theme.of(context).primaryColor,
                          errorMessage: AppLocalization.of(context)!
                              .getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      state.errorMessage)),
                          showErrorImage: true,
                          onTapRetry: fetchSubCategory,
                        );
                      }

                      if (state is SubCategoryFetchSuccess) {
                        final subCategoryList = state.subcategoryList;

                        return ListView.separated(
                          separatorBuilder: (_, i) =>
                              const SizedBox(height: UiUtils.listTileGap),
                          padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height *
                                UiUtils.vtMarginPct,
                            horizontal: MediaQuery.of(context).size.width *
                                UiUtils.hzMarginPct,
                          ),
                          itemCount: subCategoryList.length,
                          // itemCount: 1,
                          itemBuilder: (_, i) {
                            return BlocProvider<UnlockedLevelCubit>(
                              create: (_) =>
                                  UnlockedLevelCubit(QuizRepository()),
                              child: AnimatedSubcategoryContainer(
                                subcategory: subCategoryList[i],
                                category: widget.category,
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
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

class AnimatedSubcategoryContainer extends StatefulWidget {
  final String? category;
  final Subcategory subcategory;

  const AnimatedSubcategoryContainer({
    super.key,
    required this.subcategory,
    required this.category,
  });

  @override
  State<AnimatedSubcategoryContainer> createState() =>
      _AnimatedSubcategoryContainerState();
}

class _AnimatedSubcategoryContainerState
    extends State<AnimatedSubcategoryContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;

  bool _isExpanded = false;
  late final int maxLevels;
  bool _showAllLevels = false;

  @override
  void initState() {
    scheduleMicrotask(() {
      maxLevels = int.parse(widget.subcategory.maxLevel!);
      _showAllLevels = maxLevels < 6;

      ///fetch unlocked level for current selected subcategory
      fetchUnlockedLevel();
    });

    prepareAnimations();
    setRotation(45);

    super.initState();
  }

  void fetchUnlockedLevel() {
    context.read<UnlockedLevelCubit>().fetchUnlockLevel(
          context.read<UserDetailsCubit>().userId(),
          widget.category,
          widget.subcategory.id,
        );
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOutCubic),
      ),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOutCubic),
      ),
    );
  }

  void setRotation(int degrees) {
    final angle = degrees * math.pi / 90;
    _rotationAnimation = Tween(begin: 0.0, end: angle).animate(
      CurvedAnimation(
        parent: expandController,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          /// subcategory
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;

                if (_isExpanded) {
                  expandController.forward();
                } else {
                  expandController.reverse();
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.background,
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  /// subcategory Icon
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: CachedNetworkImage(
                      imageUrl: widget.subcategory.image!,
                      errorWidget: (_, s, d) => Icon(
                        Icons.subject,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// subcategory details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// subcategory name
                        Text(
                          widget.subcategory.subcategoryName!,
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontSize: 18,
                            fontWeight: FontWeights.semiBold,
                            height: 1.2,
                          ),
                        ),

                        /// subcategory levels, questions details
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                color: colorScheme.onTertiary.withOpacity(0.3),
                                fontWeight: FontWeights.regular,
                                fontSize: 14,
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: widget.subcategory.maxLevel.toString(),
                                style: TextStyle(
                                  color: colorScheme.onTertiary,
                                ),
                              ),
                              const TextSpan(text: ' :'),
                              TextSpan(
                                  text:
                                      ' ${AppLocalization.of(context)!.getTranslatedValues("levels")!}'),
                              const WidgetSpan(child: SizedBox(width: 5)),
                              WidgetSpan(
                                child: Container(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  height: 15,
                                  width: 1,
                                ),
                              ),
                              const WidgetSpan(child: SizedBox(width: 5)),
                              TextSpan(
                                text: widget.subcategory.noOfQue,
                                style: TextStyle(
                                  color: colorScheme.onTertiary,
                                ),
                              ),
                              const TextSpan(text: ' :'),
                              TextSpan(
                                  text:
                                      ' ${AppLocalization.of(context)!.getTranslatedValues("questions")!}'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  /// subcategory show levels arrow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 25,
                        color: colorScheme.onTertiary,
                      ),
                      builder: (_, child) => Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: child,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          /// subcategory expanded levels
          _buildLevelSection(),
        ],
      ),
    );
  }

  Widget _buildLevelSection() {
    return BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
      listener: (context, state) {
        if (state is UnlockedLevelFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      builder: (_, state) {
        if (state is UnlockedLevelFetchInProgress ||
            state is UnlockedLevelInitial) {
          return const Center(child: CircularProgressContainer());
        }

        if (state is UnlockedLevelFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              topMargin: 0.0,
              onTapRetry: fetchUnlockedLevel,
              showErrorImage: false,
            ),
          );
        }

        if (state is UnlockedLevelFetchSuccess) {
          int unlockedLevel = (state).unlockedLevel;
          return SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: animation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                paddedDivider(),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      _showAllLevels ? maxLevels : 6,
                      (i) {
                        return GestureDetector(
                          onTap: () {
                            if ((i + 1) <= unlockedLevel) {
                              /// Start level
                              Navigator.of(context).pushNamed(
                                Routes.quiz,
                                arguments: {
                                  "numberOfPlayer": 1,
                                  "quizType": QuizTypes.quizZone,
                                  "categoryId": widget.category,
                                  "subcategoryId": widget.subcategory.id,
                                  "level": (i + 1).toString(),
                                  "subcategoryMaxLevel":
                                      widget.subcategory.maxLevel,
                                  "unlockedLevel": state.unlockedLevel,
                                  "contestId": "",
                                  "comprehensionId": "",
                                  "quizName": "Quiz Zone"
                                },
                              ).then((value) => fetchUnlockedLevel());
                            } else {
                              UiUtils.setSnackbar(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(
                                        convertErrorCodeToLanguageKey(
                                            levelLockedCode))!,
                                context,
                                false,
                              );
                            }
                          },
                          child: SubcategoriesLevelChip(
                            isLevelUnlocked: (i + 1) <= state.unlockedLevel,
                            isLevelPlayed: (i + 2) <= state.unlockedLevel,
                            currIndex: i,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                paddedDivider(),

                /// View More/Less
                if (maxLevels > 6) ...[
                  GestureDetector(
                    onTap: () => setState(() {
                      _showAllLevels = !_showAllLevels;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      child: Text(
                        AppLocalization.of(context)!.getTranslatedValues(
                            !_showAllLevels ? 'viewMore' : 'showLess')!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.onTertiary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return Text(
          AppLocalization.of(context)!.getTranslatedValues("noLevelsLbl")!,
        );
      },
    );
  }

  Padding paddedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Divider(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 2,
      ),
    );
  }
}
