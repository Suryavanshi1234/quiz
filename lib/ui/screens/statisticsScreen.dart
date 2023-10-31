import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/statistic/cubits/statisticsCubit.dart';
import 'package:flutterquiz/features/statistic/models/statisticModel.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';
import 'package:flutterquiz/ui/widgets/badgesIconContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();

  static Route<StatisticsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<StatisticCubit>(
        child: const StatisticsScreen(),
        create: (_) => StatisticCubit(StatisticRepository()),
      ),
    );
  }
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final detailsContainerHeightPercentage = 0.145;
  final detailsContainerBorderRadius = 20.0;
  final detailsTitleFontSize = 18.0;
  final showTotalBadgesCounter = 4;

  get _detailsTitleTextStyle => TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onTertiary,
        fontSize: 18.0,
      );

  final _correctAnsColor = const Color(0xFF62A9CD);
  final _incorrectAnsColor = const Color(0xFF8C4593);
  final _wonColor = const Color(0xFF90C88A);
  final _lostColor = const Color(0xFFF79478);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context
          .read<StatisticCubit>()
          .getStatisticWithBattle(context.read<UserDetailsCubit>().userId());
    });

    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
  }

  Widget _buildCollectedBadgesContainer() {
    return BlocBuilder<BadgesCubit, BadgesState>(
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        final child = state is BadgesFetchSuccess
            ? context.read<BadgesCubit>().getUnlockedBadges().isEmpty
                ? const SizedBox()
                : Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 5.0),
                          Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues(collectedBadgesKey)!,
                            style: _detailsTitleTextStyle,
                          ),
                          const Spacer(),
                          context
                                      .read<BadgesCubit>()
                                      .getUnlockedBadges()
                                      .length >
                                  showTotalBadgesCounter
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(Routes.badges);
                                  },
                                  child: Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues(viewAllKey)!,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(width: 5.0),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        height: MediaQuery.of(context).size.height *
                            (detailsContainerHeightPercentage),
                        decoration: BoxDecoration(
                          boxShadow: [
                            UiUtils.buildBoxShadow(
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(2.5, 2.5),
                            ),
                          ],
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(
                              detailsContainerBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (context
                                          .read<BadgesCubit>()
                                          .getUnlockedBadges()
                                          .length <
                                      showTotalBadgesCounter
                                  ? context
                                      .read<BadgesCubit>()
                                      .getUnlockedBadges()
                                  : context
                                      .read<BadgesCubit>()
                                      .getUnlockedBadges()
                                      .sublist(0, showTotalBadgesCounter))
                              .map(
                                (badge) => Container(
                                  width:
                                      MediaQuery.of(context).size.width * .20,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BadgesIconContainer(
                                        addTopPadding: false,
                                        badge: badge,
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              detailsContainerHeightPercentage,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.2),
                                        ),
                                      ),
                                      Container(
                                        //color: Colors.red,
                                        height: 40,
                                        child: Text(
                                          badge.badgeLabel,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeights.medium,
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  )
            : const SizedBox();

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: child,
        );
      },
    );
  }

  Widget _buildQuestionDetailsContainer() {
    StatisticModel statistics =
        context.read<StatisticCubit>().getStatisticsDetails();

    final incorrectAnswers = int.parse(statistics.answeredQuestions) -
        int.parse(statistics.correctAnswers);

    final sweepDegree = (360 * int.parse(statistics.correctAnswers)) /
        int.parse(statistics.answeredQuestions);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(questionDetailsKey)!,
              style: _detailsTitleTextStyle,
            )
          ],
        ),
        const SizedBox(height: 10.0),
        Container(
          height: MediaQuery.of(context).size.height *
              (detailsContainerHeightPercentage),
          decoration: BoxDecoration(
              boxShadow: [
                UiUtils.buildBoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2.5, 2.5)),
              ],
              color: Theme.of(context).colorScheme.background,
              borderRadius:
                  BorderRadius.circular(detailsContainerBorderRadius)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    width: 82,
                    height: 82,
                    child: CustomPaint(
                      painter: _CircleCustomPainter(
                        color: _incorrectAnsColor,
                        arcColor: _correctAnsColor,
                        strokeWidth: 8,
                        sweepDegree: sweepDegree,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              statistics.answeredQuestions,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues(totalKey)!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiary
                                    .withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _dot(_correctAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(correctKey)!} : ",
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              statistics.correctAnswers,
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_incorrectAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(incorrectKey)!} : ",
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              incorrectAnswers.toString(),
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dot(Color? color, {final double size = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildBattleStatisticsContainer() {
    StatisticModel statistics =
        context.read<StatisticCubit>().getStatisticsDetails();

    final totalBattles = statistics.calculatePlayedBattles();
    final wonBattles = int.parse(statistics.battleVictories);
    final sweepDegree = (360 * wonBattles) / totalBattles;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(battleStatisticsKey)!,
              style: _detailsTitleTextStyle,
            )
          ],
        ),
        const SizedBox(height: 10.0),
        Container(
          height: MediaQuery.of(context).size.height *
              (detailsContainerHeightPercentage),
          decoration: BoxDecoration(
              boxShadow: [
                UiUtils.buildBoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(2.5, 2.5)),
              ],
              color: Theme.of(context).colorScheme.background,
              borderRadius:
                  BorderRadius.circular(detailsContainerBorderRadius)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    width: 82,
                    height: 82,
                    child: CustomPaint(
                      painter: _CircleCustomPainter(
                        color: _lostColor,
                        arcColor: _wonColor,
                        strokeWidth: 8,
                        sweepDegree: sweepDegree,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              totalBattles.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues(totalKey)!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiary
                                    .withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _dot(_incorrectAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues("draw")!} : ",
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              statistics.battleDrawn,
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_wonColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(wonKey)!} : ",
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              wonBattles.toString(),
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_lostColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(lostKey)!} : ",
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              statistics.battleLoose,
                              style: TextStyle(
                                color: Theme.of(context).canvasColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsContainer({
    required bool showQuestionAndBattleStatistics,
  }) {
    // UserProfile userProfile = context.read<UserDetailsCubit>().getUserProfile();

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
        horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      children: [
        _buildCollectedBadgesContainer(),
        const SizedBox(height: 20.0),
        if (showQuestionAndBattleStatistics) ...[
          Column(
            children: [
              _buildQuestionDetailsContainer(),
              const SizedBox(height: 20.0),
              _buildBattleStatisticsContainer(),
              const SizedBox(height: 30),
            ],
          )
        ] else ...[
          Container(
            height: MediaQuery.of(context).size.height * 0.75,
            //  color: Colors.blue,
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  UiUtils.getImagePath("not_found.svg"),
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.width * 0.18,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Text(
                  "No Statistics found",
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontWeight: FontWeights.bold,
                        fontSize: 22.0),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  "Please participate in the quiz as\n statistics are not yet available.",
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontWeight: FontWeights.regular,
                        fontSize: 20.0),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.035),
                CustomRoundedButton(
                  widthPercentage: MediaQuery.of(context).size.width,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle:
                      AppLocalization.of(context)!.getTranslatedValues(playLbl),
                  radius: 10,
                  showBorder: false,
                  height: 50,
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushNamed(Routes.category,
                        arguments: {"quizType": QuizTypes.quizZone});
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                CustomRoundedButton(
                  widthPercentage: MediaQuery.of(context).size.width,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  buttonTitle:
                      AppLocalization.of(context)!.getTranslatedValues(homeBtn),
                  radius: 10,
                  showBorder: false,
                  height: 50,
                  titleColor: Theme.of(context).primaryColor,
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(AppLocalization.of(context)!
            .getTranslatedValues(statisticsLabelKey)!),
      ),
      body: BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
          if (state is StatisticFetchFailure) {
            if (state.errorMessageCode == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        builder: (context, state) {
          if (state is StatisticFetchSuccess) {
            return _buildStatisticsContainer(
              showQuestionAndBattleStatistics: true,
            );
          }
          if (state is StatisticFetchFailure) {
            return _buildStatisticsContainer(
              showQuestionAndBattleStatistics: false,
            );
          }

          return const Center(child: CircularProgressContainer());
        },
      ),
    );
  }
}

class _CircleCustomPainter extends CustomPainter {
  final Color color;
  final Color arcColor;
  final double strokeWidth;
  final double sweepDegree;

  /// The PI constant.
  static const double pi = 3.1415926535897932;

  const _CircleCustomPainter({
    required this.color,
    required this.arcColor,
    required this.strokeWidth,
    required this.sweepDegree,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final p2 = Paint()
      ..strokeWidth = strokeWidth
      ..color = arcColor
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    const double startAngle = 3 * (pi * 0.5);
    final double sweepAngle = (sweepDegree * pi) / 180.0;

    canvas.drawCircle(center, size.width * 0.5, p);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.5),
      startAngle,
      sweepAngle,
      false,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
