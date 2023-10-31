import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/unlockedLevelCubit.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/subcatagoriesLevelsChip.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

/// Category Levels Screen
class LevelsScreen extends StatefulWidget {
  final Category category;

  const LevelsScreen({super.key, required this.category});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => LevelsScreen(
        category: arguments['Category'],
      ),
    );
  }
}

class _LevelsScreenState extends State<LevelsScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  bool _isExpanded = false;
  bool _showAllLevels = false;
  late final int maxLevels;
  late AnimationController expandController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    getUnlockedLevelData();
    prepareAnimations();
    setRotation(45);
    maxLevels = int.parse(widget.category.maxLevel!);
    _showAllLevels = maxLevels < 6;
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

  void getUnlockedLevelData() {
    Future.delayed(
      Duration.zero,
      () => context.read<UnlockedLevelCubit>().fetchUnlockLevel(
            context.read<UserDetailsCubit>().userId(),
            widget.category.id,
            "0",
          ),
    );
  }

  Widget _buildLevels() {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 75, start: 20, end: 20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          imageUrl: widget.category.image!,
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
                              widget.category.categoryName!,
                              style: TextStyle(
                                color: colorScheme.onTertiary,
                                fontSize: 18,
                                fontWeight: FontWeights.semiBold,
                                height: 1.2,
                              ),
                            ),

                            /// subcategory levels, questions details
                            ///
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    color:
                                        colorScheme.onTertiary.withOpacity(0.3),
                                    fontWeight: FontWeights.regular,
                                    fontSize: 14,
                                  ),
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.category.maxLevel.toString(),
                                    style: TextStyle(
                                      color: colorScheme.onTertiary,
                                    ),
                                  ),
                                  const TextSpan(text: ' :'),
                                  const TextSpan(text: ' Levels'),
                                  const WidgetSpan(child: SizedBox(width: 5)),
                                  WidgetSpan(
                                    child: Container(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      height: 15,
                                      width: 1,
                                    ),
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 5)),
                                  TextSpan(
                                    text: widget.category.noOfQues,
                                    style: TextStyle(
                                      color: colorScheme.onTertiary,
                                    ),
                                  ),
                                  const TextSpan(text: ' :'),
                                  const TextSpan(text: ' Questions'),
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
              /// _buildLevels
              _buildLevelSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSection() {
    return BlocConsumer<UnlockedLevelCubit, UnlockedLevelState>(
      bloc: context.read<UnlockedLevelCubit>(),
      listener: (context, state) {
        print("cureent unlock state ${state.toString()}");
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
              onTapRetry: getUnlockedLevelData,
              showErrorImage: false,
            ),
          );
        }

        if (state is UnlockedLevelFetchSuccess) {
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
                            if ((i + 1) <= state.unlockedLevel) {
                              /// Start level
                              Navigator.of(context).pushNamed(
                                Routes.quiz,
                                arguments: {
                                  "numberOfPlayer": 1,
                                  "quizType": QuizTypes.quizZone,
                                  "categoryId": widget.category.id,
                                  "subcategoryId": "",
                                  "level": (i + 1).toString(),
                                  "subcategoryMaxLevel":
                                      widget.category.maxLevel,
                                  "unlockedLevel": state.unlockedLevel,
                                  "contestId": "",
                                  "comprehensionId": "",
                                  "quizName": "Quiz Zone"
                                },
                              );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsetsDirectional.only(top: 30, start: 20, end: 20),
            child: QBackButton(
              removeSnackBars: true,
              color: Theme.of(context).primaryColor,
            ),
          ),

          ///
          _buildLevels(),

          const Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          )
        ],
      ),
    );
  }
}
