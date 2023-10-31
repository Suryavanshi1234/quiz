import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class UnlockedRewardContent extends StatelessWidget {
  final Badges reward;
  final bool increaseFont;

  const UnlockedRewardContent({
    super.key,
    required this.reward,
    required this.increaseFont,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14.0, left: 14.0),
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "${reward.badgeReward} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: increaseFont ? 20 : 18,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "${AppLocalization.of(context)!.getTranslatedValues(byUnlockingKey)!} ${reward.badgeLabel}",
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.9),
                    fontSize: increaseFont ? 16 : 14,
                  ),
                ),
              ),
            ),
            const Spacer(),

            /// Reward Confetti
            Align(
              alignment: Alignment.bottomRight,
              child: SvgPicture.asset(
                UiUtils.getImagePath("reward_confetti.svg"),
                width: constraints.maxWidth,
              ),
            ),
          ],
        ),
      );
    });
  }
}
