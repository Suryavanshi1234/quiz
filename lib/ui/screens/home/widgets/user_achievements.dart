import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class UserAchievements extends StatelessWidget {
  const UserAchievements({
    super.key,
    this.userRank = "0",
    this.userCoins = "0",
    this.userScore = "0",
    required this.animation,
  });

  final String userRank;
  final String userCoins;
  final String userScore;
  final Animation<Offset> animation;

  @override
  Widget build(BuildContext context) {
    final rank = AppLocalization.of(context)!.getTranslatedValues("rankLbl")!;
    final coins = AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!;
    final score = AppLocalization.of(context)!.getTranslatedValues("scoreLbl")!;

    return SlideTransition(
      position: animation,
      child: LayoutBuilder(
        builder: (_, constraints) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: constraints.maxWidth * (0.05),
                right: constraints.maxWidth * (0.05),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 25),
                        blurRadius: 30,
                        spreadRadius: 3,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      )
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(constraints.maxWidth * (0.525)),
                    ),
                  ),
                  width: constraints.maxWidth,
                  height: 100,
                ),
              ),
              Positioned(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.5, horizontal: 20),
                  margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height *
                        UiUtils.vtMarginPct,
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Achievement(title: rank, value: userRank),
                      VerticalDivider(
                        color: Colors.white.withOpacity(0.6),
                        indent: 12,
                        endIndent: 14,
                        thickness: 2,
                      ),
                      _Achievement(title: coins, value: userCoins),
                      VerticalDivider(
                        color: Colors.white.withOpacity(0.6),
                        indent: 12,
                        endIndent: 14,
                        thickness: 2,
                      ),
                      _Achievement(title: score, value: userScore),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Achievement extends StatelessWidget {
  const _Achievement({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeights.bold,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeights.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
