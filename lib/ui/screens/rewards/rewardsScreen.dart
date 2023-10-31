import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/screens/rewards/scratchRewardScreen.dart';
import 'package:flutterquiz/ui/screens/rewards/widgets/unlockedRewardContent.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
        child: const RewardsScreen(),
        create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
      ),
    );
  }

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Widget _buildRewardContainer(Badges reward) {
    return GestureDetector(
      onTap: () {
        if (reward.status == "1") {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              opaque: false,
              pageBuilder: (context, firstAnimation, secondAnimation) {
                return FadeTransition(
                  opacity: firstAnimation,
                  child: BlocProvider<UpdateScoreAndCoinsCubit>(
                    create: (context) =>
                        UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                    child: ScratchRewardScreen(reward: reward),
                  ),
                );
              },
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: reward.status == "2"
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: reward.status == "2"
            ? UnlockedRewardContent(reward: reward, increaseFont: false)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  UiUtils.getImagePath("scratchCardCover.png"),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildRewards() {
    return CustomScrollView(
      slivers: [
        BlocBuilder<BadgesCubit, BadgesState>(
          bloc: context.read<BadgesCubit>(),
          builder: (context, state) {
            if (state is BadgesFetchFailure) {
              return SliverToBoxAdapter(
                child: Center(
                  child: ErrorContainer(
                      errorMessage: AppLocalization.of(context)!
                          .getTranslatedValues(convertErrorCodeToLanguageKey(
                              state.errorMessage))!,
                      onTapRetry: () {
                        context.read<BadgesCubit>().getBadges(
                            userId: context.read<UserDetailsCubit>().userId(),
                            refreshBadges: true);
                      },
                      showErrorImage: true),
                ),
              );
            }

            if (state is BadgesFetchSuccess) {
              final rewards = context.read<BadgesCubit>().getRewards();
              //ifthere is no rewards
              if (rewards.isEmpty) {
                return SliverToBoxAdapter(
                  child: Text(AppLocalization.of(context)!
                      .getTranslatedValues(noRewardsKey)!),
                );
              }

              //create grid count
              return SliverGrid.count(
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
                crossAxisCount: 2,
                children: [
                  ...rewards
                      .map((reward) => Hero(
                            tag: reward.type,
                            child: _buildRewardContainer(reward),
                          ))
                      .toList(),
                ],
              );
            }

            return const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressContainer(whiteLoader: false),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        shadowColor: Theme.of(context).colorScheme.background.withOpacity(0.4),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        leading: QBackButton(
          removeSnackBars: false,
          color: Theme.of(context).colorScheme.background,
        ),
        title: Text(
          AppLocalization.of(context)!.getTranslatedValues(rewardsLbl)!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: BlocBuilder<BadgesCubit, BadgesState>(
                bloc: context.read<BadgesCubit>(),
                builder: (context, state) {
                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          fontWeight: FontWeights.bold,
                          color: Theme.of(context).colorScheme.background,
                          fontSize: 32,
                        ),
                      ),
                      children: [
                        TextSpan(
                          text:
                              "${context.read<BadgesCubit>().getRewardedCoins()} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!}",
                        ),
                        TextSpan(
                          text:
                              "\n${AppLocalization.of(context)!.getTranslatedValues(totalRewardsEarnedKey)!}",
                          style: GoogleFonts.nunito(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
          horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: _buildRewards(),
      ),
      // body: BlocConsumer<BadgesCubit, BadgesState>(
      //   listener: (context, state) {
      //     if (state is BadgesFetchFailure) {
      //       if (state.errorMessage == unauthorizedAccessCode) {
      //         UiUtils.showAlreadyLoggedInDialog(context: context);
      //       }
      //     }
      //   },
      //   bloc: context.read<BadgesCubit>(),
      //   builder: (context, state) {
      //     if (state is BadgesFetchFailure) {
      //       return Center(
      //         child: ErrorContainer(
      //           errorMessage: AppLocalization.of(context)!.getTranslatedValues(
      //               convertErrorCodeToLanguageKey(state.errorMessage))!,
      //           onTapRetry: () => context.read<BadgesCubit>().getBadges(
      //                 userId: context.read<UserDetailsCubit>().getUserId(),
      //                 refreshBadges: true,
      //               ),
      //           showErrorImage: true,
      //         ),
      //       );
      //     }
      //
      //     if (state is BadgesFetchSuccess) {
      //       final rewards = context.read<BadgesCubit>().getRewards();
      //
      //       if (rewards.isEmpty) {
      //         return Center(
      //           child: Text(AppLocalization.of(context)!
      //               .getTranslatedValues(noRewardsKey)!),
      //         );
      //       }
      //
      //       return GridView.count(
      //         crossAxisCount: 2,
      //         shrinkWrap: true,
      //         mainAxisSpacing: 20,
      //         crossAxisSpacing: 20,
      //         padding: EdgeInsets.symmetric(
      //           vertical:
      //               MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
      //           horizontal:
      //               MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      //         ),
      //         children: List.generate(
      //           rewards.length,
      //           (i) => _RewardCard(
      //             coins: rewards[i].badgeReward,
      //             desc: rewards[i].badgeNote,
      //           ),
      //         ),
      //       );
      //     }
      //
      //     return const SizedBox();
      //   },
      // ),
    );
  }
}

// Rewards Grid

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.coins, required this.desc});

  final String coins;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.background,
          ),
          width: constraints.maxWidth,
          height: constraints.maxHeight * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Coins
              Padding(
                padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                child: Text(
                  "$coins Coins",
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),

              /// Description
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.9),
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
      },
    );
  }
}
