import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/user_utils.dart';

class MultiUserBattleRoomResultScreen extends StatefulWidget {
  final List<UserBattleRoomDetails?> users;
  final int entryFee;
  final int totalQuestions;

  const MultiUserBattleRoomResultScreen({
    super.key,
    required this.users,
    required this.entryFee,
    required this.totalQuestions,
  });

  @override
  State<MultiUserBattleRoomResultScreen> createState() =>
      _MultiUserBattleRoomResultScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
        create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
        child: MultiUserBattleRoomResultScreen(
          users: args!['user'],
          entryFee: args['entryFee'],
          totalQuestions: args['totalQuestions'],
        ),
      ),
    );
  }
}

class _MultiUserBattleRoomResultScreenState
    extends State<MultiUserBattleRoomResultScreen> {
  List<Map<String, dynamic>> usersWithRank = [];
  int _winAmount = -1; //if amount is -1 then show nothing

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
    getResultAndUpdateCoins();
    super.initState();
  }

  void getResultAndUpdateCoins() {
    //create new array of map that creates user and rank
    for (var element in widget.users) {
      usersWithRank.add({
        "user": element,
      });
    }
    var points = usersWithRank.map((details) {
      return (details['user'] as UserBattleRoomDetails).correctAnswers;
    }).toList();

    points = points.toSet().toList();
    points.sort((first, second) => second.compareTo(first));

    for (var userDetails in usersWithRank) {
      int rank = points.indexOf(
              (userDetails['user'] as UserBattleRoomDetails).correctAnswers) +
          1;
      userDetails.addAll({"rank": rank});
    }
    usersWithRank.sort((first, second) => int.parse(first['rank'].toString())
        .compareTo(int.parse(second['rank'].toString())));
    //
    Future.delayed(Duration.zero, () {
      final currentUser = usersWithRank
          .where((element) =>
              (element['user'] as UserBattleRoomDetails).uid ==
              context.read<UserDetailsCubit>().userId())
          .toList()
          .first;
      final totalWinner = usersWithRank
          .where((element) => (element['rank'] == 1))
          .toList()
          .length;
      final winAmount = widget.entryFee * (widget.users.length / totalWinner);

      if (currentUser['rank'] == 1) {
        //update badge if locked
        if (context.read<BadgesCubit>().isBadgeLocked("clash_winner")) {
          context.read<BadgesCubit>().setBadge(
              badgeType: "clash_winner",
              userId: context.read<UserDetailsCubit>().userId());
        }

        //add coins
        //update coins
        // TODO: Winner is Getting Coins Twice.
        print("User Won from Result Screen");
        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
              context.read<UserDetailsCubit>().userId(),
              winAmount.toInt(),
              true,
              wonGroupBattleKey,
            );
        context.read<UserDetailsCubit>().updateCoins(
              addCoin: true,
              coins: winAmount.toInt(),
            );
        //update winAmount in ui as well
        _winAmount = winAmount.toInt();
        setState(() {});
        //
      }
    });
  }

  Widget _buildUserDetailsContainer(
    UserBattleRoomDetails userBattleRoomDetails,
    int rank,
    Size size,
    bool showStars,
    AlignmentGeometry alignment,
    EdgeInsetsGeometry edgeInsetsGeometry,
    Color color,
  ) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                UserUtils.getUserProfileWidget(
                  width: 52,
                  height: 52,
                  profileUrl: userBattleRoomDetails.profileUrl,
                ),
                Center(
                  child: SvgPicture.asset(
                    UiUtils.getImagePath("hexagon_frame.svg"),
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                userBattleRoomDetails.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeights.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${userBattleRoomDetails.correctAnswers}/${widget.totalQuestions}",
                style: TextStyle(
                  fontWeight: FontWeights.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserTopDetailsContainer(
    UserBattleRoomDetails userBattleRoomDetails,
    int rank,
    Size size,
    bool showStars,
    AlignmentGeometry alignment,
    EdgeInsetsGeometry edgeInsetsGeometry,
    Color color,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: edgeInsetsGeometry,
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                UserUtils.getUserProfileWidget(
                  width: 100,
                  height: 100,
                  profileUrl: userBattleRoomDetails.profileUrl,
                ),
                Center(
                  child: SvgPicture.asset(
                    UiUtils.getImagePath("hexagon_frame.svg"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              userBattleRoomDetails.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeights.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${userBattleRoomDetails.correctAnswers}/${widget.totalQuestions}",
                style: TextStyle(
                  fontWeight: FontWeights.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultLabel() {
    final currentUser = usersWithRank
        .where((element) =>
            (element['user'] as UserBattleRoomDetails).uid ==
            context.read<UserDetailsCubit>().userId())
        .toList()
        .first;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * (0.06),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              currentUser['rank'] == 1
                  ? AppLocalization.of(context)!
                      .getTranslatedValues('youWonLbl')!
                      .toUpperCase()
                  : AppLocalization.of(context)!
                      .getTranslatedValues('youLostLbl')!,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2.5),
            _winAmount != -1
                ? Text(
                    "$_winAmount ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!} ",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
      listener: (context, state) {
        if (state is UpdateScoreAndCoinsFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      child: Scaffold(
        appBar: QAppBar(
          roundedAppBar: false,
          title: Text(AppLocalization.of(context)!
              .getTranslatedValues('groupBattleResult')!),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * .7,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.height * UiUtils.hzMarginPct,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rank 1
                    _buildUserTopDetailsContainer(
                      usersWithRank.first['user'] as UserBattleRoomDetails,
                      usersWithRank.first['rank'],
                      Size(MediaQuery.of(context).size.width * (0.475),
                          MediaQuery.of(context).size.height * (0.35)),
                      true,
                      AlignmentDirectional.centerStart,
                      EdgeInsetsDirectional.only(
                        start: 10.0,
                        top: MediaQuery.of(context).size.height * (0.025),
                      ),
                      Colors.green,
                    ),

                    //user 2
                    usersWithRank.length == 2
                        ? _buildUserDetailsContainer(
                            usersWithRank[1]['user'] as UserBattleRoomDetails,
                            usersWithRank[1]['rank'],
                            Size(MediaQuery.of(context).size.width * (0.15),
                                MediaQuery.of(context).size.height * (0.08)),
                            false,
                            AlignmentDirectional.centerStart,
                            EdgeInsetsDirectional.zero,
                            Colors.redAccent,
                          )
                        : _buildUserDetailsContainer(
                            usersWithRank[1]['user'] as UserBattleRoomDetails,
                            usersWithRank[1]['rank'],
                            Size(MediaQuery.of(context).size.width * (0.38),
                                MediaQuery.of(context).size.height * (0.28)),
                            false,
                            AlignmentDirectional.center,
                            EdgeInsetsDirectional.only(
                              start: MediaQuery.of(context).size.width * (0.3),
                              bottom:
                                  MediaQuery.of(context).size.height * (0.42),
                            ),
                            Colors.redAccent,
                          ),
                    const SizedBox(height: 12),

                    //user 3
                    usersWithRank.length > 2
                        ? _buildUserDetailsContainer(
                            usersWithRank[2]['user'] as UserBattleRoomDetails,
                            usersWithRank[2]['rank'],
                            Size(MediaQuery.of(context).size.width * (0.36),
                                MediaQuery.of(context).size.height * (0.25)),
                            false,
                            AlignmentDirectional.centerEnd,
                            EdgeInsetsDirectional.only(
                              end: 10.0,
                              top: MediaQuery.of(context).size.height * (0.1),
                            ),
                            Colors.redAccent,
                          )
                        : const SizedBox(),

                    const SizedBox(height: 12),

                    //user 4
                    usersWithRank.length == 4
                        ? _buildUserDetailsContainer(
                            usersWithRank.last['user'] as UserBattleRoomDetails,
                            usersWithRank.last['rank'],
                            Size(MediaQuery.of(context).size.width * (0.35),
                                MediaQuery.of(context).size.height * (0.25)),
                            false,
                            AlignmentDirectional.center,
                            EdgeInsetsDirectional.only(
                              start: MediaQuery.of(context).size.width * (0.3),
                              top: MediaQuery.of(context).size.height * (0.575),
                            ),
                            Colors.redAccent,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: usersWithRank.length == 4 ? 20 : 50.0,
                ),
                //if total 4 user than padding will be 20 else 50
                child: CustomRoundedButton(
                  widthPercentage: 0.85,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues("homeBtn")!,
                  radius: 5.0,
                  showBorder: false,
                  fontWeight: FontWeight.bold,
                  height: 40.0,
                  elevation: 5.0,
                  titleColor: Theme.of(context).colorScheme.background,
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  textSize: 17.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
