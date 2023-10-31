import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/rewards/widgets/unlockedRewardContent.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:scratcher/widgets.dart';

class ScratchRewardScreen extends StatefulWidget {
  final Badges reward;

  const ScratchRewardScreen({super.key, required this.reward});

  @override
  _ScratchRewardScreenState createState() => _ScratchRewardScreenState();
}

class _ScratchRewardScreenState extends State<ScratchRewardScreen> {
  GlobalKey<ScratcherState> scratcherKey = GlobalKey<ScratcherState>();
  bool _showScratchHere = true;

  bool _goBack() {
    bool isFinished = scratcherKey.currentState?.isFinished ?? false;
    if (scratcherKey.currentState?.progress != 0.0 && !isFinished) {
      scratcherKey.currentState
          ?.reveal(duration: const Duration(milliseconds: 250));

      return false;
    }
    return true;
  }

  void unlockReward() {
    if (context.read<BadgesCubit>().isRewardUnlocked(widget.reward.type)) {
      return;
    }
    context.read<BadgesCubit>().unlockReward(widget.reward.type);

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          context.read<UserDetailsCubit>().userId(),
          int.parse(widget.reward.badgeReward),
          true,
          rewardByScratchingCardKey,
          type: widget.reward.type,
        );
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: int.parse(widget.reward.badgeReward),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(_goBack());
      },
      child: Scaffold(
        backgroundColor:
            Theme.of(context).colorScheme.background.withOpacity(0.45),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (0.042),
                  left: MediaQuery.of(context).size.width * (0.017),
                ),
                child: IconButton(
                  iconSize: 30,
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    if (_goBack()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: widget.reward.type,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    height: MediaQuery.of(context).size.height * (0.4),
                    width: MediaQuery.of(context).size.width * (0.8),
                    child: Scratcher(
                        onChange: (value) {
                          if (value > 0.0 && _showScratchHere) {
                            setState(() {
                              _showScratchHere = false;
                            });
                          }

                          if (value == 100.0) {
                            unlockReward();
                          }
                        },
                        onThreshold: () {
                          scratcherKey.currentState
                              ?.reveal(duration: const Duration(seconds: 0));
                        },
                        key: scratcherKey,
                        brushSize: 35,
                        threshold: 50,
                        accuracy: ScratchAccuracy.medium,
                        color: Theme.of(context).primaryColor,
                        image: Image.asset(
                            UiUtils.getImagePath("scratchCardCover.png")),
                        child: UnlockedRewardContent(
                          reward: widget.reward,
                          increaseFont: true,
                        )),
                  ),
                ),
              ),
            ),
            _showScratchHere
                ? Align(
                    alignment: Alignment.center,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.6),
                        ),
                        height: MediaQuery.of(context).size.height * (0.075),
                        width: MediaQuery.of(context).size.width * (0.8),
                        child: Center(
                          child: Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues(scratchHereKey)!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.background,
                                fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
